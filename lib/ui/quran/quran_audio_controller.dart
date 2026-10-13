import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/last_played_repo.dart';
import 'package:rafeeq/data/repo/recitors_repo.dart';

final quranAudioControllerProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
      QuranAudioController.new,
    );

enum QuranPlaybackScope { surah, juz }

class QuranAudioState {
  static const provisionalDuration = Duration(seconds: 10);
  static const playbackEndGracePeriod = Duration(seconds: 10);

  const QuranAudioState({
    this.surahNumber,
    this.surahName = '',
    this.surahArabicName = '',
    this.playbackScope = QuranPlaybackScope.surah,
    this.playbackScopeNumber,
    this.reciterName = '',
    this.reciterNativeName = '',
    this.ayahs = const [],
    this.currentIndex = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.isBuffering = false,
    this.isVisible = false,
    this.isPlaybackComplete = false,
    this.playbackEndRemaining = Duration.zero,
  });

  final int? surahNumber;
  final String surahName;
  final String surahArabicName;
  final QuranPlaybackScope playbackScope;
  final int? playbackScopeNumber;
  final String reciterName;
  final String reciterNativeName;
  final List<Ayah> ayahs;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final bool isPlaying;
  final bool isLoading;
  final bool isBuffering;
  final bool isVisible;
  final bool isPlaybackComplete;
  final Duration playbackEndRemaining;

  Ayah? get currentAyah => ayahs.isEmpty || currentIndex >= ayahs.length
      ? null
      : ayahs[currentIndex];

  bool get canGoPrevious => currentIndex > 0;
  bool get canGoNext => currentIndex + 1 < ayahs.length;
  int? get activePlaybackNumber =>
      playbackScopeNumber ??
      (playbackScope == QuranPlaybackScope.surah ? surahNumber : null);
  int get lastPlaybackNumber =>
      playbackScope == QuranPlaybackScope.juz ? Juz.values.length : 114;
  String get playbackUnitName =>
      playbackScope == QuranPlaybackScope.juz ? 'Juz' : 'Surah';
  String get playbackLabel => playbackScope == QuranPlaybackScope.juz
      ? 'Juz ${activePlaybackNumber ?? ''}'.trim()
      : surahName;
  bool get canPlayPreviousSelection => (activePlaybackNumber ?? 1) > 1;
  bool get canPlayNextSelection =>
      (activePlaybackNumber ?? lastPlaybackNumber) < lastPlaybackNumber;

  double get playbackEndProgress {
    if (!isPlaybackComplete) return 0;
    final totalMilliseconds = playbackEndGracePeriod.inMilliseconds;
    final elapsedMilliseconds =
        totalMilliseconds - playbackEndRemaining.inMilliseconds;
    return (elapsedMilliseconds / totalMilliseconds).clamp(0.0, 1.0);
  }

  Duration get effectiveDuration {
    final isPreparingAyah =
        position == Duration.zero && (isLoading || isBuffering);
    if (isPreparingAyah || duration <= Duration.zero) {
      return provisionalDuration;
    }
    return duration;
  }

  QuranAudioState copyWith({
    int? surahNumber,
    String? surahName,
    String? surahArabicName,
    QuranPlaybackScope? playbackScope,
    int? playbackScopeNumber,
    String? reciterName,
    String? reciterNativeName,
    List<Ayah>? ayahs,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    bool? isPlaying,
    bool? isLoading,
    bool? isBuffering,
    bool? isVisible,
    bool? isPlaybackComplete,
    Duration? playbackEndRemaining,
  }) {
    return QuranAudioState(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      surahArabicName: surahArabicName ?? this.surahArabicName,
      playbackScope: playbackScope ?? this.playbackScope,
      playbackScopeNumber: playbackScopeNumber ?? this.playbackScopeNumber,
      reciterName: reciterName ?? this.reciterName,
      reciterNativeName: reciterNativeName ?? this.reciterNativeName,
      ayahs: ayahs ?? this.ayahs,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isBuffering: isBuffering ?? this.isBuffering,
      isVisible: isVisible ?? this.isVisible,
      isPlaybackComplete: isPlaybackComplete ?? this.isPlaybackComplete,
      playbackEndRemaining: playbackEndRemaining ?? this.playbackEndRemaining,
    );
  }
}

class QuranAudioController extends Notifier<QuranAudioState> {
  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  int _loadGeneration = 0;
  Timer? _playbackEndTimer;
  Map<int, ({String englishName, String arabicName})> _surahNames = const {};

  @override
  QuranAudioState build() {
    _player = AudioPlayer();
    _subscriptions.addAll([
      _player.currentIndexStream.listen(_onIndexChanged),
      _player.playerStateStream.listen(_onPlayerStateChanged),
      _player.positionStream.listen(
        (position) => state = state.copyWith(position: position),
      ),
      _player.durationStream.listen(
        (duration) =>
            state = state.copyWith(duration: duration ?? Duration.zero),
      ),
      _player.bufferedPositionStream.listen(
        (position) => state = state.copyWith(bufferedPosition: position),
      ),
    ]);
    ref.onDispose(() async {
      _playbackEndTimer?.cancel();
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      await _player.dispose();
    });
    return const QuranAudioState();
  }

  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required String surahArabicName,
    required List<Ayah> ayahs,
    int startAyahNumber = 1,
  }) async {
    if (ayahs.isEmpty) return;
    final startIndex = ayahs.indexWhere(
      (ayah) => ayah.numberInSurah == startAyahNumber,
    );
    final safeIndex = startIndex < 0 ? 0 : startIndex;
    await _playSelection(
      playbackScope: QuranPlaybackScope.surah,
      playbackScopeNumber: surahNumber,
      initialSurahNumber: surahNumber,
      initialSurahName: surahName,
      initialSurahArabicName: surahArabicName,
      ayahs: ayahs,
      initialIndex: safeIndex,
      surahNames: {
        surahNumber: (englishName: surahName, arabicName: surahArabicName),
      },
    );
  }

  Future<void> playJuz({
    required int juzNumber,
    int? startAyahGlobalNumber,
  }) async {
    final quranData = await ref.read(quranDataProvider.future);
    final ayahs = quranData.ayahs
        .where((ayah) => ayah.juz == juzNumber)
        .toList(growable: false);
    if (ayahs.isEmpty) return;
    final requestedIndex = startAyahGlobalNumber == null
        ? 0
        : ayahs.indexWhere((ayah) => ayah.number == startAyahGlobalNumber);
    final initialIndex = requestedIndex < 0 ? 0 : requestedIndex;
    final initialAyah = ayahs[initialIndex];
    final surahNames = {
      for (final surah in quranData.surah)
        surah.surahNumber: (
          englishName: surah.englishName,
          arabicName: surah.name,
        ),
    };
    final initialSurahNames = surahNames[initialAyah.surahNumber]!;
    await _playSelection(
      playbackScope: QuranPlaybackScope.juz,
      playbackScopeNumber: juzNumber,
      initialSurahNumber: initialAyah.surahNumber,
      initialSurahName: initialSurahNames.englishName,
      initialSurahArabicName: initialSurahNames.arabicName,
      ayahs: ayahs,
      initialIndex: initialIndex,
      surahNames: surahNames,
    );
  }

  /// Rebuilds the active audio sources after the selected reciter changes,
  /// keeping the current scope and ayah as the starting point.
  Future<void> reloadCurrentSelection() async {
    final currentAyah = state.currentAyah;
    final playbackNumber = state.activePlaybackNumber;
    if (currentAyah == null || playbackNumber == null || state.ayahs.isEmpty) {
      return;
    }

    final surahNames = _surahNames.isEmpty
        ? {
            currentAyah.surahNumber: (
              englishName: state.surahName,
              arabicName: state.surahArabicName,
            ),
          }
        : _surahNames;
    await _playSelection(
      playbackScope: state.playbackScope,
      playbackScopeNumber: playbackNumber,
      initialSurahNumber: currentAyah.surahNumber,
      initialSurahName:
          surahNames[currentAyah.surahNumber]?.englishName ?? state.surahName,
      initialSurahArabicName:
          surahNames[currentAyah.surahNumber]?.arabicName ??
          state.surahArabicName,
      ayahs: state.ayahs,
      initialIndex: state.currentIndex,
      surahNames: surahNames,
      forceReload: true,
    );
  }

  Future<void> _playSelection({
    required QuranPlaybackScope playbackScope,
    required int playbackScopeNumber,
    required int initialSurahNumber,
    required String initialSurahName,
    required String initialSurahArabicName,
    required List<Ayah> ayahs,
    required int initialIndex,
    required Map<int, ({String englishName, String arabicName})> surahNames,
    bool forceReload = false,
  }) async {
    _cancelPlaybackEndCountdown();
    _surahNames = surahNames;

    if (state.playbackScope == playbackScope &&
        state.activePlaybackNumber == playbackScopeNumber &&
        state.ayahs.isNotEmpty &&
        !forceReload) {
      state = state.copyWith(
        isVisible: true,
        isPlaybackComplete: false,
        playbackEndRemaining: Duration.zero,
      );
      await _player.seek(Duration.zero, index: initialIndex);
      await _player.play();
      return;
    }

    final generation = ++_loadGeneration;
    state = QuranAudioState(
      surahNumber: initialSurahNumber,
      surahName: initialSurahName,
      surahArabicName: initialSurahArabicName,
      playbackScope: playbackScope,
      playbackScopeNumber: playbackScopeNumber,
      ayahs: List.unmodifiable(ayahs),
      currentIndex: initialIndex,
      isLoading: true,
      isVisible: true,
    );

    try {
      final reciter = await ref.read(recitersRepoProvider).getReciter();
      if (generation != _loadGeneration) return;
      final sources = ayahs
          .map((ayah) {
            final names = surahNames[ayah.surahNumber];
            final uri = Uri.parse(
              reciter.getAyahLink(
                ayah.number,
                surahNumber: ayah.surahNumber,
                ayahInSurah: ayah.numberInSurah,
              ),
            );
            return AudioSource.uri(
              uri,
              tag: MediaItem(
                id: uri.toString(),
                album: 'Quran',
                title:
                    '${names?.englishName ?? initialSurahName} ${ayah.numberInSurah}',
                artist: reciter.englishName,
              ),
            );
          })
          .toList(growable: false);

      state = state.copyWith(
        reciterName: reciter.englishName,
        reciterNativeName: reciter.name,
      );
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false);
      await _player.play();
    } catch (_) {
      if (generation == _loadGeneration) {
        state = state.copyWith(isLoading: false, isBuffering: false);
      }
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isLoading || state.ayahs.isEmpty) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero, index: 0);
      }
      await _player.play();
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() async {
    if (state.ayahs.isEmpty || state.isPlaybackComplete) return;
    await _player.play();
  }

  Future<void> previous() async {
    if (!state.canGoPrevious) {
      await _player.seek(Duration.zero);
      return;
    }
    await _player.seek(Duration.zero, index: state.currentIndex - 1);
  }

  Future<void> next() async {
    if (state.canGoNext) {
      await _player.seek(Duration.zero, index: state.currentIndex + 1);
    }
  }

  Future<void> previousOrPreviousSelection() async {
    if (state.canGoPrevious) {
      await previous();
      return;
    }
    if (state.canPlayPreviousSelection) {
      await _playAdjacentSelection(-1, startAtEnd: true);
    }
  }

  Future<void> nextOrNextSelection() async {
    if (state.canGoNext) {
      await next();
      return;
    }
    if (state.canPlayNextSelection) {
      await _playAdjacentSelection(1);
    }
  }

  Future<void> jumpToAyah(int globalAyahNumber) async {
    final index = state.ayahs.indexWhere(
      (ayah) => ayah.number == globalAyahNumber,
    );
    if (index < 0) return;
    await _player.seek(Duration.zero, index: index);
  }

  Future<void> playPreviousSelection() => _playAdjacentSelection(-1);

  Future<void> playNextSelection() => _playAdjacentSelection(1);

  Future<void> seek(Duration position) async {
    state = state.copyWith(position: position);
    await _player.seek(position);
  }

  Future<void> stop() async {
    _cancelPlaybackEndCountdown();
    _loadGeneration++;
    await _player.stop();
    state = const QuranAudioState();
  }

  void _onIndexChanged(int? index) {
    if (index == null || index >= state.ayahs.length) return;
    final ayah = state.ayahs[index];
    final names = _surahNames[ayah.surahNumber];
    state = state.copyWith(
      currentIndex: index,
      surahNumber: ayah.surahNumber,
      surahName: names?.englishName,
      surahArabicName: names?.arabicName,
      position: _player.position,
      duration: _player.duration ?? state.duration,
    );
    ref
        .read(lastPlayedRepoProvider)
        .saveGlobalLastPlayedIndex(state.ayahs[index].number - 1);
  }

  void _onPlayerStateChanged(PlayerState playerState) {
    final processingState = playerState.processingState;
    final isPlaybackComplete = processingState == ProcessingState.completed;
    state = state.copyWith(
      isPlaying: playerState.playing && !isPlaybackComplete,
      isLoading: processingState == ProcessingState.loading,
      isBuffering: processingState == ProcessingState.buffering,
    );
    if (isPlaybackComplete) startPlaybackEndCountdown();
  }

  void startPlaybackEndCountdown() {
    if (state.isPlaybackComplete && (_playbackEndTimer?.isActive ?? false)) {
      return;
    }
    _cancelPlaybackEndCountdown();
    state = state.copyWith(
      position: state.duration,
      isPlaying: false,
      isLoading: false,
      isBuffering: false,
      isVisible: true,
      isPlaybackComplete: true,
      playbackEndRemaining: QuranAudioState.playbackEndGracePeriod,
    );

    const tick = Duration(milliseconds: 100);
    _playbackEndTimer = Timer.periodic(tick, (timer) {
      final remaining = state.playbackEndRemaining - tick;
      if (remaining <= Duration.zero) {
        timer.cancel();
        state = state.copyWith(
          isVisible: false,
          playbackEndRemaining: Duration.zero,
        );
        return;
      }
      state = state.copyWith(playbackEndRemaining: remaining);
    });
  }

  Future<void> _playAdjacentSelection(
    int offset, {
    bool startAtEnd = false,
  }) async {
    final currentPlaybackNumber = state.activePlaybackNumber;
    if (currentPlaybackNumber == null) return;
    final targetPlaybackNumber = currentPlaybackNumber + offset;
    if (targetPlaybackNumber < 1 ||
        targetPlaybackNumber > state.lastPlaybackNumber) {
      return;
    }

    if (state.playbackScope == QuranPlaybackScope.juz) {
      int? startAyahGlobalNumber;
      if (startAtEnd) {
        final quranData = await ref.read(quranDataProvider.future);
        startAyahGlobalNumber = quranData.ayahs
            .where((ayah) => ayah.juz == targetPlaybackNumber)
            .lastOrNull
            ?.number;
      }
      await playJuz(
        juzNumber: targetPlaybackNumber,
        startAyahGlobalNumber: startAyahGlobalNumber,
      );
      return;
    }

    final quranData = await ref.read(quranDataProvider.future);
    final targetSurah = quranData.surah.firstWhere(
      (surah) => surah.surahNumber == targetPlaybackNumber,
    );
    _cancelPlaybackEndCountdown();
    await playSurah(
      surahNumber: targetSurah.surahNumber,
      surahName: targetSurah.englishName,
      surahArabicName: targetSurah.name,
      ayahs: targetSurah.ayahs,
      startAyahNumber: startAtEnd ? targetSurah.ayahs.last.numberInSurah : 1,
    );
  }

  void _cancelPlaybackEndCountdown() {
    _playbackEndTimer?.cancel();
    _playbackEndTimer = null;
  }
}
