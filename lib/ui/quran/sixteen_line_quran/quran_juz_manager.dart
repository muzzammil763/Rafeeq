import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:hooks_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_download_service.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_pages_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _juzDownloadedKeyPrefix = 'sixteen_line_juz_downloaded_';
const String _downloadDirectory = '16_line_quran_images';

class JuzDownloadStatus {
  final bool isDownloaded;
  final double progress;
  final bool isDownloading;
  final String? error;
  final int downloadedPages;
  final int totalPages;

  const JuzDownloadStatus({
    this.isDownloaded = false,
    this.progress = 0.0,
    this.isDownloading = false,
    this.error,
    this.downloadedPages = 0,
    this.totalPages = 0,
  });

  JuzDownloadStatus copyWith({
    bool? isDownloaded,
    double? progress,
    bool? isDownloading,
    String? error,
    int? downloadedPages,
    int? totalPages,
  }) {
    return JuzDownloadStatus(
      isDownloaded: isDownloaded ?? this.isDownloaded,
      progress: progress ?? this.progress,
      isDownloading: isDownloading ?? this.isDownloading,
      error: error ?? this.error,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

/// Provider to track overall download progress for all Juz
final overallDownloadProgressProvider =
    StateNotifierProvider<
      OverallDownloadProgressNotifier,
      OverallDownloadProgress
    >((ref) {
      return OverallDownloadProgressNotifier();
    });

class OverallDownloadProgress {
  final bool isDownloading;
  final int totalJuz;
  final int downloadedJuz;
  final int totalPages;
  final int downloadedPages;
  final String? currentJuzName;
  final String? currentPageName;
  final double currentPageProgress;
  final String? error;

  const OverallDownloadProgress({
    this.isDownloading = false,
    this.totalJuz = 30,
    this.downloadedJuz = 0,
    this.totalPages = 0,
    this.downloadedPages = 0,
    this.currentJuzName,
    this.currentPageName,
    this.currentPageProgress = 0.0,
    this.error,
  });

  double get overallProgress =>
      totalPages > 0 ? downloadedPages / totalPages : 0.0;

  OverallDownloadProgress copyWith({
    bool? isDownloading,
    int? totalJuz,
    int? downloadedJuz,
    int? totalPages,
    int? downloadedPages,
    String? currentJuzName,
    String? currentPageName,
    double? currentPageProgress,
    String? error,
  }) {
    return OverallDownloadProgress(
      isDownloading: isDownloading ?? this.isDownloading,
      totalJuz: totalJuz ?? this.totalJuz,
      downloadedJuz: downloadedJuz ?? this.downloadedJuz,
      totalPages: totalPages ?? this.totalPages,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      currentJuzName: currentJuzName ?? this.currentJuzName,
      currentPageName: currentPageName ?? this.currentPageName,
      currentPageProgress: currentPageProgress ?? this.currentPageProgress,
      error: error ?? this.error,
    );
  }
}

class OverallDownloadProgressNotifier
    extends StateNotifier<OverallDownloadProgress> {
  OverallDownloadProgressNotifier() : super(const OverallDownloadProgress());

  void startDownload(int totalPages) {
    state = OverallDownloadProgress(
      isDownloading: true,
      totalPages: totalPages,
      totalJuz: 30,
    );
    developer.log(
      'Starting download of all Quran pages: $totalPages pages',
      name: 'QuranDownload',
    );
  }

  void updateProgress({
    required int downloadedPages,
    String? currentJuzName,
    String? currentPageName,
    double? currentPageProgress,
    required int downloadedJuz,
  }) {
    state = state.copyWith(
      downloadedPages: downloadedPages,
      currentJuzName: currentJuzName,
      currentPageName: currentPageName,
      currentPageProgress: currentPageProgress ?? state.currentPageProgress,
      downloadedJuz: downloadedJuz,
    );

    if (currentPageName != null && currentPageProgress == 1.0) {
      developer.log(
        'Downloaded: $currentPageName ($downloadedPages/${state.totalPages})',
        name: 'QuranDownload',
      );
    }
  }

  void completeDownload() {
    developer.log(
      'All downloads completed! ${state.downloadedPages}/${state.totalPages} pages',
      name: 'QuranDownload',
    );
    state = state.copyWith(
      isDownloading: false,
      currentJuzName: null,
      currentPageName: null,
      currentPageProgress: 0.0,
    );
  }

  void setError(String error) {
    developer.log('Download error: $error', name: 'QuranDownload');
    state = state.copyWith(error: error, isDownloading: false);
  }

  void reset() {
    state = const OverallDownloadProgress();
  }
}

class QuranJuzManager extends StateNotifier<Map<int, JuzDownloadStatus>> {
  final SharedPreferences _prefs;
  final AnalyticsService _analytics;
  final QuranDownloadService _downloadService = QuranDownloadService();

  // Stream subscriptions for cleanup
  StreamSubscription? _progressSubscription;
  StreamSubscription? _bulkProgressSubscription;

  QuranJuzManager(this._prefs, this._analytics) : super({}) {
    _initializeStatuses();
    _listenToDownloadService();
  }

  void _initializeStatuses() {
    // Initialize with basic state, then check files asynchronously
    final Map<int, JuzDownloadStatus> initialStatuses = {};
    for (int i = 1; i <= 30; i++) {
      final isDownloaded =
          _prefs.getBool('$_juzDownloadedKeyPrefix$i') ?? false;
      final pageCount = QuranPagesConfig.getJuzPageCount(i);
      initialStatuses[i] = JuzDownloadStatus(
        isDownloaded: isDownloaded,
        totalPages: pageCount,
        downloadedPages: isDownloaded ? pageCount : 0,
      );
    }
    state = initialStatuses;

    // Check actual file counts asynchronously
    _checkActualDownloadedPages();
  }

  Future<void> _checkActualDownloadedPages() async {
    try {
      final directory = await _getDownloadDirectory();
      final Map<int, JuzDownloadStatus> updatedStatuses = {};

      for (int i = 1; i <= 30; i++) {
        final pages = QuranPagesConfig.getJuzPages(i);

        // Parallelize file existence checks for this juz
        final existenceChecks = pages.map((page) {
          final filename = QuranPagesConfig.getPageFilename(page);
          final file = File('$directory/$filename');
          return file.exists();
        });
        final results = await Future.wait(existenceChecks);
        final downloadedCount = results.where((exists) => exists).length;

        final isFullyDownloaded = downloadedCount == pages.length;
        final wasMarkedDownloaded =
            _prefs.getBool('$_juzDownloadedKeyPrefix$i') ?? false;

        // Update SharedPreferences if state doesn't match reality
        if (isFullyDownloaded && !wasMarkedDownloaded) {
          await _prefs.setBool('$_juzDownloadedKeyPrefix$i', true);
        } else if (!isFullyDownloaded && wasMarkedDownloaded) {
          await _prefs.setBool('$_juzDownloadedKeyPrefix$i', false);
        }

        updatedStatuses[i] = JuzDownloadStatus(
          isDownloaded: isFullyDownloaded,
          totalPages: pages.length,
          downloadedPages: downloadedCount,
          progress: pages.isNotEmpty ? downloadedCount / pages.length : 0.0,
        );

        if (downloadedCount > 0 && downloadedCount < pages.length) {
          developer.log(
            'Juz $i: $downloadedCount/${pages.length} pages downloaded (${(downloadedCount / pages.length * 100).toStringAsFixed(1)}%)',
            name: 'QuranDownload',
          );
        }
      }

      state = updatedStatuses;
      developer.log(
        'Initialized with actual file counts - Total: ${updatedStatuses.values.fold<int>(0, (sum, s) => sum + s.downloadedPages)}/${updatedStatuses.values.fold<int>(0, (sum, s) => sum + s.totalPages)} pages',
        name: 'QuranDownload',
      );
    } catch (e) {
      developer.log(
        'Error checking downloaded pages: $e',
        name: 'QuranDownload',
      );
    }
  }

  void _listenToDownloadService() {
    // Listen to single Juz progress
    _progressSubscription = _downloadService.progressStream.listen((progress) {
      final currentStatus =
          state[progress.juzNumber] ?? const JuzDownloadStatus();
      state = {
        ...state,
        progress.juzNumber: currentStatus.copyWith(
          isDownloading: true,
          progress: progress.progress,
          downloadedPages: progress.downloadedPages,
          totalPages: progress.totalPages,
        ),
      };
    });

    // Listen to bulk download progress
    _bulkProgressSubscription = _downloadService.bulkProgressStream.listen((
      bulkProgress,
    ) {
      developer.log(
        'Bulk progress: ${bulkProgress.completedJuz}/${bulkProgress.totalJuz} Juz, '
        '${bulkProgress.downloadedPages}/${bulkProgress.totalPages} pages',
        name: 'QuranDownload',
      );

      // Mark just completed Juz as downloaded
      final completedJuz = bulkProgress.justCompletedJuzNumber;
      if (completedJuz != null && state[completedJuz]?.isDownloaded != true) {
        _prefs.setBool('$_juzDownloadedKeyPrefix$completedJuz', true);
        final pages = QuranPagesConfig.getJuzPages(completedJuz);
        state = {
          ...state,
          completedJuz: JuzDownloadStatus(
            isDownloaded: true,
            isDownloading: false,
            progress: 1.0,
            totalPages: pages.length,
            downloadedPages: pages.length,
          ),
        };
      }
    });
  }

  Future<void> downloadJuz(int juzNumber) async {
    if (state[juzNumber]?.isDownloading == true) return;

    final pages = QuranPagesConfig.getJuzPages(juzNumber);
    final totalPages = pages.length;

    _analytics.logQuranJuzDownloadStarted(juzNumber);

    // Start download - progress is handled by stream listener
    final success = await _downloadService.downloadJuz(juzNumber);

    // Update final state based on success
    if (success) {
      _prefs.setBool('$_juzDownloadedKeyPrefix$juzNumber', true);
      state = {
        ...state,
        juzNumber: JuzDownloadStatus(
          isDownloaded: true,
          progress: 1.0,
          isDownloading: false,
          downloadedPages: totalPages,
          totalPages: totalPages,
        ),
      };
      _analytics.logQuranJuzDownloadCompleted(juzNumber);
      developer.log(
        'Juz $juzNumber fully downloaded! ($totalPages pages)',
        name: 'QuranDownload',
      );
    } else {
      // Preserve the downloaded pages count on failure
      final currentStatus = state[juzNumber] ?? const JuzDownloadStatus();
      state = {
        ...state,
        juzNumber: JuzDownloadStatus(
          isDownloaded: false,
          isDownloading: false,
          totalPages: totalPages,
          downloadedPages: currentStatus.downloadedPages,
          progress: currentStatus.progress,
        ),
      };
    }
  }

  /// Download all Juz - streams progress and updates providers
  Future<void> downloadAllJuz() async {
    // Calculate pending downloads
    int totalPagesAll = 0;
    int pendingJuzCount = 0;
    for (int i = 1; i <= 30; i++) {
      if (state[i]?.isDownloaded != true) {
        pendingJuzCount++;
        totalPagesAll += QuranPagesConfig.getJuzPageCount(i);
      }
    }

    if (pendingJuzCount == 0) {
      return;
    }

    developer.log(
      'Starting download of $pendingJuzCount Juz ($totalPagesAll pages)',
      name: 'QuranDownload',
    );

    // Reset download service state to ensure clean start
    _downloadService.resetAllDownloads();

    developer.log('Download service reset complete', name: 'QuranDownload');

    // Mark pending Juz as downloading, preserving existing progress
    for (int i = 1; i <= 30; i++) {
      if (state[i]?.isDownloaded != true) {
        final pages = QuranPagesConfig.getJuzPages(i);
        final currentStatus = state[i] ?? const JuzDownloadStatus();
        state = {
          ...state,
          i: JuzDownloadStatus(
            isDownloaded: false,
            isDownloading: true,
            progress: currentStatus.progress,
            totalPages: pages.length,
            downloadedPages: currentStatus.downloadedPages,
          ),
        };
      }
    }

    developer.log(
      'Marked $pendingJuzCount Juz as downloading',
      name: 'QuranDownload',
    );

    // Start the bulk download and listen to progress
    developer.log(
      'Calling downloadAllJuz service method...',
      name: 'QuranDownload',
    );
    await _downloadService.downloadAllJuz();
    developer.log(
      'downloadAllJuz service method completed',
      name: 'QuranDownload',
    );
  }

  Future<void> deleteJuz(int juzNumber) async {
    final pages = QuranPagesConfig.getJuzPages(juzNumber);
    final directory = await _getDownloadDirectory();

    for (final page in pages) {
      final filename = QuranPagesConfig.getPageFilename(page);
      final file = File('$directory/$filename');
      if (await file.exists()) {
        await file.delete();
      }
    }

    await _prefs.setBool('$_juzDownloadedKeyPrefix$juzNumber', false);
    state = {...state, juzNumber: const JuzDownloadStatus(isDownloaded: false)};
  }

  Future<List<String>?> getJuzImagePaths(int juzNumber) async {
    final isDownloaded = state[juzNumber]?.isDownloaded ?? false;
    if (!isDownloaded) {
      _analytics.logQuranJuzFileChecked(juzNumber, false);
      return null;
    }

    final pages = QuranPagesConfig.getJuzPages(juzNumber);
    final directory = await _getDownloadDirectory();
    final List<String> paths = [];
    bool allExist = true;

    for (final page in pages) {
      final filename = QuranPagesConfig.getPageFilename(page);
      final filePath = '$directory/$filename';
      final file = File(filePath);

      if (await file.exists()) {
        paths.add(filePath);
      } else {
        allExist = false;
        break;
      }
    }

    _analytics.logQuranJuzFileChecked(juzNumber, allExist);

    if (allExist) {
      return paths;
    }

    // Some files missing - reset download status
    await _prefs.setBool('$_juzDownloadedKeyPrefix$juzNumber', false);
    state = {...state, juzNumber: const JuzDownloadStatus(isDownloaded: false)};
    _analytics.logQuranJuzCacheSync(juzNumber, true, false);
    return null;
  }

  Future<String?> getPageImagePath(int pageNumber) async {
    final juzNumber = QuranPagesConfig.getJuzForPage(pageNumber);
    if (juzNumber == null) return null;

    final isDownloaded = state[juzNumber]?.isDownloaded ?? false;
    if (!isDownloaded) return null;

    final directory = await _getDownloadDirectory();
    final filename = QuranPagesConfig.getPageFilename(pageNumber);
    final filePath = '$directory/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }

    return null;
  }

  Future<void> checkAllJuzFiles() async {
    final directory = await _getDownloadDirectory();

    for (int i = 1; i <= 30; i++) {
      final pages = QuranPagesConfig.getJuzPages(i);
      if (pages.isEmpty) continue;

      int existingCount = 0;
      for (final page in pages) {
        final filename = QuranPagesConfig.getPageFilename(page);
        final file = File('$directory/$filename');
        if (await file.exists()) {
          existingCount++;
        }
      }

      final wasMarkedDownloaded =
          _prefs.getBool('$_juzDownloadedKeyPrefix$i') ?? false;
      final allExist = existingCount == pages.length;

      // Always update the state with actual file counts
      final currentStatus = state[i] ?? const JuzDownloadStatus();
      final shouldUpdateState =
          currentStatus.downloadedPages != existingCount ||
          currentStatus.isDownloaded != allExist;

      if (shouldUpdateState) {
        state = {
          ...state,
          i: JuzDownloadStatus(
            isDownloaded: allExist,
            downloadedPages: existingCount,
            totalPages: pages.length,
            progress: pages.isNotEmpty ? existingCount / pages.length : 0.0,
          ),
        };
      }

      // Update preferences if needed
      if (wasMarkedDownloaded && !allExist) {
        await _prefs.setBool('$_juzDownloadedKeyPrefix$i', false);
        _analytics.logQuranJuzCacheSync(i, true, false);
      } else if (!wasMarkedDownloaded && allExist) {
        await _prefs.setBool('$_juzDownloadedKeyPrefix$i', true);
        _analytics.logQuranJuzCacheSync(i, false, true);
      }

      // Log partial progress
      if (existingCount > 0 && !allExist) {
        developer.log(
          'checkAllJuzFiles: Juz $i has $existingCount/${pages.length} pages downloaded',
          name: 'QuranDownload',
        );
      }
    }
  }

  Future<String> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$_downloadDirectory';
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _bulkProgressSubscription?.cancel();
    _downloadService.dispose();
    super.dispose();
  }
}

final quranJuzManagerProvider =
    StateNotifierProvider<QuranJuzManager, Map<int, JuzDownloadStatus>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      final analytics = ref.watch(analyticsServiceProvider);
      return QuranJuzManager(prefs, analytics);
    });
