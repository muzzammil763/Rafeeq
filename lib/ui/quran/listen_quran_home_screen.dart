import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/log.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rafeeq/data/repo/recitors_repo.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/choose_recitor/reciter_state_notifier.dart';

class ListenQuranHomeScreen extends StatefulHookConsumerWidget {
  final List<Surah> surahList;

  const ListenQuranHomeScreen(this.surahList, {super.key});

  @override
  ConsumerState<ListenQuranHomeScreen> createState() =>
      _ListenQuranHomeScreenState();
}

class _ListenQuranHomeScreenState extends ConsumerState<ListenQuranHomeScreen> {
  final audioPlayer = AudioPlayer();

  int? currentIndex;
  bool playing = false;

  StreamSubscription? _audioIndexSubscription;
  StreamSubscription? isPlayingSubscription;

  @override
  void initState() {
    super.initState();

    _audioIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      setState(() {
        currentIndex = index;
      });
    });

    isPlayingSubscription = audioPlayer.playingStream.listen((playing) {
      setState(() {
        this.playing = playing;
      });
    });

    setAudioSource();
  }

  Future<void> setAudioSource() async {
    final reciter = await ref.read(recitersRepoProvider).getSurahReciter();
    final audioSources = widget.surahList.map((surah) {
      var surahLink = reciter.getSurahLink(surah.surahNumber);
      Logger.log(surahLink);
      return AudioSource.uri(Uri.parse(surahLink));
    }).toList();

    await audioPlayer.setAudioSources(audioSources);
  }

  @override
  void dispose() {
    _audioIndexSubscription?.cancel();
    isPlayingSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahRecitor = ref.watch(reciterStateNotifierProvider).surahReciter;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.quran),
          actions: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: SingleChildScrollView(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final reciter = ref
                                .watch(reciterStateNotifierProvider)
                                .surahReciter;
                            return Column(
                              // mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 16),
                                ...SurahReciter.values.map((e) {
                                  final selected =
                                      reciter.identifier == e.identifier;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          ref
                                              .read(recitersRepoProvider)
                                              .setSurahReciter(e);
                                          setAudioSource();
                                          di.appRouter.maybePop();
                                        },
                                        title: Text(
                                          e.name,
                                          style: TextStyle(
                                            color: selected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                        ),
                                        selected: selected,
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: CachedNetworkImage(
                                            imageUrl: e.image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: surahRecitor.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemBuilder: (context, index) {
                  final surah = widget.surahList[index];
                  final selected = currentIndex == index;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: ListTile(
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      onTap: () {
                        audioPlayer
                            .seek(Duration.zero, index: index)
                            .then((value) => audioPlayer.play());
                      },
                      tileColor: selected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2)
                          : null,
                      trailing: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected && playing)
                            SpinKitWave(
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            surah.name,
                            style: const TextStyle(
                              fontFamily: 'Muhammadi Uthmanic',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      title: Text(surah.englishName),
                      subtitle: Text(surah.ayahs.length.toString()),
                      // trailing: Text(surah.ayahs.length.toString()),
                    ),
                  );
                },
                itemCount: widget.surahList.length,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.small(
                    heroTag: "prev",
                    onPressed: () {
                      if (audioPlayer.audioSource != null) {
                        if (currentIndex != null && currentIndex! > 0) {
                          audioPlayer.seekToPrevious();
                        }
                      }
                    },
                    child: Icon(
                      Icons.skip_previous,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FloatingActionButton(
                      heroTag: "play",
                      onPressed: () {
                        if (audioPlayer.audioSource != null) {
                          if (playing) {
                            audioPlayer.pause();
                          } else {
                            audioPlayer.play();
                          }
                        }
                      },
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: "next",
                    onPressed: () {
                      if (audioPlayer.audioSource != null) {
                        if (currentIndex != null &&
                            currentIndex! < widget.surahList.length - 1) {
                          audioPlayer.seekToNext();
                        }
                      }
                    },
                    child: Icon(
                      Icons.skip_next,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
