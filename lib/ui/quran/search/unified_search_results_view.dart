import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/model/quran_search_result.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_search_provider.dart';
import 'package:rafeeq/ui/quran/search/transliteration_matcher.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';
import 'package:shimmer/shimmer.dart';

class UnifiedSearchResultsView extends HookConsumerWidget {
  final QuranData quranData;

  // Pre-compiled RegExp patterns for performance
  static final _diacriticsPattern = RegExp(r'[\u0610-\u061A\u064B-\u065F]');
  static final _nonAlphaPattern = RegExp(r'[^a-z]');
  static final _vowelsPattern = RegExp(r'[aeiou]');
  static final _leadingLPattern = RegExp(r'^l');

  const UnifiedSearchResultsView({super.key, required this.quranData});

  String _normalizeInput(String input) {
    const arabicDigits = "٠١٢٣٤٥٦٧٨٩";
    const easternArabicDigits = "۰۱۲۳۴۵۶۷۸۹";
    String output = input;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(arabicDigits[i], i.toString());
      output = output.replaceAll(easternArabicDigits[i], i.toString());
    }
    return output;
  }

  String _removeDiacritics(String input) {
    return input.replaceAll(_diacriticsPattern, '');
  }

  String _removeVowelsAndSpecial(String input) {
    return input
        .toLowerCase()
        .replaceAll(_nonAlphaPattern, '')
        .replaceAll(_vowelsPattern, '')
        .replaceFirst(_leadingLPattern, '');
  }

  String _getRevelationType(BuildContext context, String type) {
    if (type.toLowerCase() == 'meccan') {
      return context.loc.meccan;
    } else {
      return context.loc.medinan;
    }
  }

  TextStyle _getTextStyle(
    BuildContext context, {
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) {
    return TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final searchState = ref.watch(quranSearchProvider);
    final rawSearchQuery = searchState.searchQuery.trim().toLowerCase();
    final searchQuery = _normalizeInput(rawSearchQuery);
    final qArabic = _removeDiacritics(searchQuery);
    final qVowelLess = _removeVowelsAndSpecial(searchQuery);

    final searchResults = useState<List<SearchMatch>>([]);
    final isSearching = useState(false);
    final error = useState<String?>(null);
    final viewSettings = ref.watch(quranViewSettingsNotifierProvider);

    final searchDebouncer = useMemoized(() => _Debouncer(milliseconds: 500));

    // Lookups used to build SearchMatch objects for local transliteration hits
    final ayahByNumber = useMemoized(
      () => {for (final a in quranData.ayahs) a.number: a},
      [quranData],
    );
    final surahByNumber = useMemoized(
      () => {for (final s in quranData.surah) s.surahNumber: s},
      [quranData],
    );

    // Start loading the local transliteration index as soon as search opens
    // so the first keystroke doesn't pay the one-time download/build cost.
    useEffect(() {
      ref
          .read(transliterationIndexProvider.future)
          .then((_) {}, onError: (_) {});
      return null;
    }, []);

    // Scroll-to-top FAB
    final scrollController = useScrollController();
    final showScrollToTop = useState(false);

    useEffect(() {
      void listener() {
        final pageHeight = MediaQuery.of(context).size.height;
        showScrollToTop.value = scrollController.offset >= pageHeight;
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    useEffect(() {
      return () => searchDebouncer.dispose();
    }, [searchDebouncer]);

    Future<void> performSearch(String rawQuery) async {
      final query = _normalizeInput(rawQuery.trim().toLowerCase());
      if (query.isEmpty) {
        searchResults.value = [];
        isSearching.value = false;
        return;
      }

      isSearching.value = true;
      error.value = null;

      try {
        final List<SearchMatch> localMatches = [];
        List<SearchMatch> apiMatches = [];
        List<TranslitMatch> translitMatches = const [];

        // 1. Local Search (Arabic Quran Text & Numbers)
        bool hasArabicChars = RegExp(r'[\u0600-\u06FF]').hasMatch(query);
        final intQuery = int.tryParse(query);
        final colonMatch = RegExp(r'^(\d+)[\:\-\/\s]+(\d+)$').firstMatch(query);

        if (colonMatch != null) {
          final sNum = int.parse(colonMatch.group(1)!);
          final aNum = int.parse(colonMatch.group(2)!);
          for (var surah in quranData.surah) {
            if (surah.surahNumber == sNum) {
              for (var ayah in surah.ayahs) {
                if (ayah.numberInSurah == aNum || ayah.number == aNum) {
                  localMatches.add(
                    SearchMatch(
                      number: ayah.number,
                      text: ayah.text,
                      numberInSurah: ayah.numberInSurah,
                      surah: SearchSurah(
                        number: surah.surahNumber,
                        name: surah.name,
                        englishName: surah.englishName,
                        englishNameTranslation: surah.englishNameTranslation,
                        revelationType: surah.revelationType,
                      ),
                    ),
                  );
                  break;
                }
              }
              break;
            }
          }
        } else if (hasArabicChars) {
          final queryNoDiacritics = _removeDiacritics(query);
          for (var surah in quranData.surah) {
            for (var ayah in surah.ayahs) {
              if (_removeDiacritics(ayah.text).contains(queryNoDiacritics)) {
                localMatches.add(
                  SearchMatch(
                    number: ayah.number,
                    text: ayah.text,
                    numberInSurah: ayah.numberInSurah,
                    surah: SearchSurah(
                      number: surah.surahNumber,
                      name: surah.name,
                      englishName: surah.englishName,
                      englishNameTranslation: surah.englishNameTranslation,
                      revelationType: surah.revelationType,
                    ),
                  ),
                );
              }
            }
          }
        } else if (intQuery != null) {
          int count = 0;
          for (var surah in quranData.surah) {
            for (var ayah in surah.ayahs) {
              if (ayah.numberInSurah == intQuery || ayah.number == intQuery) {
                localMatches.add(
                  SearchMatch(
                    number: ayah.number,
                    text: ayah.text,
                    numberInSurah: ayah.numberInSurah,
                    surah: SearchSurah(
                      number: surah.surahNumber,
                      name: surah.name,
                      englishName: surah.englishName,
                      englishNameTranslation: surah.englishNameTranslation,
                      revelationType: surah.revelationType,
                    ),
                  ),
                );
                count++;
                if (count >= 115) break;
              }
            }
          }
        }

        // 2. API Search (Translation + Transliteration editions)
        // We ALWAYS search both editions for Latin queries,
        // unless it's strictly a Surah number search.
        bool isNumeric = intQuery != null || colonMatch != null;
        if (!isNumeric && !hasArabicChars) {
          final repo = ref.read(quranApiRepoProvider);
          final editionIds = {
            viewSettings.translationEditionId,
            viewSettings.transliterationEditionId,
          }.toList();

          var failedEditions = 0;
          Future<QuranSearchResult> searchEdition(String q, String editionId) {
            return repo.searchTranslation(q, editionId).catchError((Object e) {
              failedEditions++;
              debugPrint('Search failed for edition $editionId: $e');
              return QuranSearchResult(count: 0, matches: <SearchMatch>[]);
            });
          }

          final results = await Future.wait([
            for (final editionId in editionIds) searchEdition(query, editionId),
          ]);

          // Preserve the error UI when every edition search fails (e.g. offline)
          // and there is nothing local to show.
          if (failedEditions == editionIds.length && localMatches.isEmpty) {
            throw Exception('Search failed for all editions');
          }

          // Translation matches first so the dedupe below prefers them
          // over transliteration matches for the same ayah.
          apiMatches = [for (var res in results) ...res.matches];

          if (apiMatches.isEmpty && query.contains(' ')) {
            final words = query
                .split(RegExp(r'\s+'))
                .where((w) => w.length > 2) // avoid too short words
                .toSet()
                .toList();

            if (words.isNotEmpty) {
              final searchWords = words.take(3).toList();
              final results = await Future.wait([
                for (final w in searchWords)
                  for (final editionId in editionIds)
                    searchEdition(w, editionId),
              ]);

              final Map<int, SearchMatch> fallbackMerged = {};
              for (var res in results) {
                for (var m in res.matches) {
                  if (!fallbackMerged.containsKey(m.number)) {
                    fallbackMerged[m.number] = m;
                  }
                }
              }
              apiMatches = fallbackMerged.values.toList();
            }
          }

          // 2b. Local transliteration search (exact + fuzzy).
          // Handles joined words ("alhamdulillah"), apostrophes/hyphens,
          // and one-letter-off spellings ("haitalac") that the API
          // substring search cannot match. Skipped silently when the
          // index isn't available (e.g. offline before first download).
          try {
            final matcher = await ref.read(transliterationIndexProvider.future);
            translitMatches = matcher.search(query);
          } catch (e) {
            debugPrint('Local transliteration search unavailable: $e');
          }
        }

        // 3. Merge and Deduplicate
        final Map<int, SearchMatch> merged = {};

        // Prioritize local matches (original Arabic text)
        for (var m in localMatches) {
          merged[m.number] = m;
        }

        // Add API matches if not already present
        for (var m in apiMatches) {
          if (!merged.containsKey(m.number)) {
            merged[m.number] = m;
          }
        }

        // Add local transliteration matches last (exact hits come before
        // fuzzy ones — the matcher returns them in that order)
        for (final tm in translitMatches) {
          if (merged.containsKey(tm.entry.number)) continue;
          final ayah = ayahByNumber[tm.entry.number];
          final surah = ayah != null ? surahByNumber[ayah.surahNumber] : null;
          if (ayah == null || surah == null) continue;
          merged[tm.entry.number] = SearchMatch(
            number: tm.entry.number,
            text: tm.entry.text,
            numberInSurah: ayah.numberInSurah,
            surah: SearchSurah(
              number: surah.surahNumber,
              name: surah.name,
              englishName: surah.englishName,
              englishNameTranslation: surah.englishNameTranslation,
              revelationType: surah.revelationType,
            ),
            editionIdentifier: viewSettings.transliterationEditionId,
          );
        }

        final sortedResult = merged.values.toList()
          ..sort((a, b) => a.number.compareTo(b.number));

        searchResults.value = sortedResult;
      } catch (e) {
        debugPrint('Search error: $e');
        error.value = e.toString();
      } finally {
        isSearching.value = false;
      }
    }

    // Trigger Ayah search
    useEffect(
      () {
        if (searchState.searchQuery.isNotEmpty) {
          // Show shimmer immediately while debouncing
          isSearching.value = true;
          searchResults.value = [];
          error.value = null;
          searchDebouncer.run(() => performSearch(searchState.searchQuery));
        } else {
          searchResults.value = [];
          isSearching.value = false;
          error.value = null;
        }
        return null;
      },
      [
        searchState.searchQuery,
        viewSettings.translationEditionId,
        viewSettings.transliterationEditionId,
      ],
    );

    // Surah Matching
    List<Surah> surahList = quranData.surah;
    if (searchQuery.isNotEmpty) {
      surahList = surahList.where((surah) {
        final urduName = SurahNamesProvider.getUrduName(surah.surahNumber);
        final englishName = surah.englishName.toLowerCase();
        final arabicName = _removeDiacritics(surah.name);
        final nVowelLess = _removeVowelsAndSpecial(englishName);

        final ayahCountString = surah.ayahs.length.toString();
        final localizedAyahCountString = surah.ayahs.length.toLocalizedNumber(
          context,
        );
        final translatedRevelation = _getRevelationType(
          context,
          surah.revelationType,
        ).toLowerCase();
        final rawRevelation = surah.revelationType.toLowerCase();

        return englishName.contains(searchQuery) ||
            arabicName.contains(qArabic) ||
            urduName.contains(searchQuery) ||
            surah.englishNameTranslation.toLowerCase().contains(searchQuery) ||
            surah.surahNumber.toString() == searchQuery || // surah number
            ayahCountString == searchQuery || // total ayahs
            localizedAyahCountString == searchQuery || // total ayahs localized
            translatedRevelation.contains(
              searchQuery,
            ) || // meccan/medinan localized
            rawRevelation.contains(searchQuery) || // meccan/medinan english
            (qVowelLess.length >= 2 && nVowelLess.contains(qVowelLess));
      }).toList();
    }

    // Juz Matching
    List<Juz> juzList = Juz.values;
    if (searchQuery.isNotEmpty) {
      juzList = juzList.where((juz) {
        final urduName = JuzNamesProvider.getUrduName(juz.number);
        final englishName = JuzNamesProvider.getEnglishName(
          juz.number,
        ).toLowerCase();
        final arabicName = _removeDiacritics(juz.startWord);

        return englishName.contains(searchQuery) ||
            urduName.contains(searchQuery) ||
            arabicName.contains(qArabic) ||
            juz.number.toString() == searchQuery;
      }).toList();
    }

    final bool isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    // ======= SECTION BUILDERS =======

    List<Widget> buildSurahSlivers() {
      if (surahList.isEmpty) return [];
      return [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final surah = surahList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    di.appRouter.pushNamed(
                      AppRoutes.quranDetails,
                      arguments: QuranDetailsArgs(
                        SurahQuranDetailArgs(surah, quranData.ayahs),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      // borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.textColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        top: BorderSide(
                          color: theme.textColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.secondaryColor.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              style: _getTextStyle(
                                context,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: theme.textColor,
                              ),
                              children: _buildHighlightedText(
                                surah.surahNumber.toLocalizedNumber(context),
                                rawSearchQuery,
                                _getTextStyle(
                                  context,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: colorScheme.onSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                  children: _buildHighlightedText(
                                    surah.englishName,
                                    rawSearchQuery,
                                    Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ) ??
                                        const TextStyle(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: _getTextStyle(
                                    context,
                                    color: theme.textColor.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 11,
                                  ),
                                  children: _buildHighlightedText(
                                    '${surah.ayahs.length.toLocalizedNumber(context)}${isUrdu ? '  ' : ' '}${context.loc.ayahs} (${_getRevelationType(context, surah.revelationType)})',
                                    rawSearchQuery,
                                    _getTextStyle(
                                      context,
                                      color: theme.textColor.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              // surah meaning
                              RichText(
                                text: TextSpan(
                                  style: _getTextStyle(
                                    context,
                                    color: theme.textColor.withValues(
                                      alpha: 0.75,
                                    ),
                                    fontSize: 13,
                                  ),
                                  children: _buildHighlightedText(
                                    surah.englishNameTranslation,
                                    rawSearchQuery,
                                    _getTextStyle(
                                      context,
                                      color: theme.textColor.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Hero(
                          tag: 'surah_search_${surah.name}',
                          child: Text(
                            surah.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PDMS Saleem Quran',
                              fontSize: 22,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }, childCount: surahList.length),
        ),
      ];
    }

    List<Widget> buildJuzSlivers() {
      if (juzList.isEmpty) return [];
      return [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final juz = juzList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    di.appRouter.pushNamed(
                      AppRoutes.quranDetails,
                      arguments: QuranDetailsArgs(
                        JuzQuranDetailArgs(juz, quranData.ayahs),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.textColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        top: BorderSide(
                          color: theme.textColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.secondaryColor.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              style: _getTextStyle(
                                context,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: theme.textColor,
                              ),
                              children: _buildHighlightedText(
                                juz.number.toLocalizedNumber(context),
                                rawSearchQuery,
                                _getTextStyle(
                                  context,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: colorScheme.onSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                  children: _buildHighlightedText(
                                    isUrdu
                                        ? JuzNamesProvider.getUrduName(
                                            juz.number,
                                          )
                                        : JuzNamesProvider.getEnglishName(
                                            juz.number,
                                          ),
                                    rawSearchQuery,
                                    Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ) ??
                                        const TextStyle(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          JuzNamesProvider.getUrduName(juz.number),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Jameel Noori Nastaleeq",
                            fontSize: 22,
                            color: theme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }, childCount: juzList.length),
        ),
      ];
    }

    List<Widget> buildAyahSlivers() {
      if (searchQuery.isEmpty) return [];
      if (!isSearching.value &&
          error.value == null &&
          searchResults.value.isEmpty) {
        return [];
      }

      return [
        if (isSearching.value)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const _ShimmerAyahCard(),
              childCount: 6, // Show 4 placeholders while loading
            ),
          )
        else if (error.value != null)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Text(
                  context.loc.searchErrorHelp,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final match = searchResults.value[index];
              return _AyahSearchResultTile(
                match: match,
                quranData: quranData,
                searchQuery: rawSearchQuery,
              );
            }, childCount: searchResults.value.length),
          ),
      ];
    }

    // ======= DYNAMIC REORDERING =======

    final List<Widget> finalSlivers = [];
    if (searchQuery.isEmpty) {
      finalSlivers.add(const SliverPadding(padding: EdgeInsets.only(top: 8)));
      finalSlivers.addAll(buildSurahSlivers());
      finalSlivers.addAll(buildJuzSlivers());
    } else {
      bool allEmpty =
          surahList.isEmpty &&
          juzList.isEmpty &&
          searchResults.value.isEmpty &&
          !isSearching.value &&
          error.value == null;

      if (allEmpty) {
        finalSlivers.add(
          SliverFillRemaining(
            child: _CombinedNoResultsView(keyword: rawSearchQuery),
          ),
        );
      } else {
        // Collect only sections that have content
        final activeSections = <List<Widget>>[];

        final surahSlivers = buildSurahSlivers();
        if (surahSlivers.isNotEmpty) activeSections.add(surahSlivers);

        final juzSlivers = buildJuzSlivers();
        if (juzSlivers.isNotEmpty) activeSections.add(juzSlivers);

        final ayahSlivers = buildAyahSlivers();
        if (ayahSlivers.isNotEmpty) activeSections.add(ayahSlivers);

        // Add top padding before the first section
        if (activeSections.isNotEmpty) {
          finalSlivers.add(
            const SliverPadding(padding: EdgeInsets.only(top: 8)),
          );
        }

        // Insert spacing sliver between each section
        for (int i = 0; i < activeSections.length; i++) {
          finalSlivers.addAll(activeSections[i]);
          if (i < activeSections.length - 1) {
            finalSlivers.add(const SliverPadding(padding: EdgeInsets.zero));
          }
        }
      }
    }

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ...finalSlivers,
            const SliverPadding(padding: EdgeInsets.only(bottom: 112)),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 112,
          child: AnimatedScale(
            scale: showScrollToTop.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: FloatingActionButton.small(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              heroTag: 'search_scroll_top',
              backgroundColor: theme.textColor,
              onPressed: () {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AyahSearchResultTile extends HookConsumerWidget {
  final SearchMatch match;
  final QuranData quranData;
  final String searchQuery;

  const _AyahSearchResultTile({
    required this.match,
    required this.quranData,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isUrduLocale = Localizations.localeOf(context).languageCode == 'ur';
    final viewSettings = ref.watch(quranViewSettingsNotifierProvider);

    final isLocalArabicMatch = RegExp(r'[\u0600-\u06FF]').hasMatch(match.text);

    AsyncValue<Map<int, String>>? translationAsync;
    if (isLocalArabicMatch &&
        !viewSettings.translationEditionId.contains('ar.')) {
      translationAsync = ref.watch(
        quranEditionTextProvider((
          type: QuranFetchType.surah,
          number: match.surah.number,
          editionId: viewSettings.translationEditionId,
        )),
      );
    }

    String displayText = match.text;
    bool isLoadingTranslation = false;

    if (translationAsync != null) {
      if (translationAsync.isLoading && !translationAsync.hasValue) {
        isLoadingTranslation = true;
      } else if (translationAsync.hasValue) {
        displayText = translationAsync.value![match.number] ?? match.text;
      }
    }

    final isArabicScript = RegExp(r'[\u0600-\u06FF]').hasMatch(displayText);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // borderRadius: BorderRadius.circular(16),
          onTap: () {
            final surah = quranData.surah.firstWhere(
              (s) => s.surahNumber == match.surah.number,
              orElse: () => quranData.surah.first,
            );

            di.appRouter.pushNamed(
              AppRoutes.quranDetails,
              arguments: QuranDetailsArgs(
                SurahQuranDetailArgs(surah, quranData.ayahs),
                initialAyahNumber: match.numberInSurah,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              // borderRadius: BorderRadius.circular(16),
              border: Border(
                bottom: BorderSide(
                  color: theme.textColor.withValues(alpha: 0.1),
                  width: 1,
                ),
                top: BorderSide(
                  color: theme.textColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.secondaryColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.textColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor,
                          ),
                          children: _buildHighlightedText(
                            '${match.surah.englishName} (${match.surah.number}:${match.numberInSurah})',
                            searchQuery.trim(),
                            TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (match.editionIdentifier?.contains('transliteration') ??
                        false) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.textColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.textColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          context.loc.transliteration,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.textColor.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                isLoadingTranslation
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Align(
                          alignment: isUrduLocale
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: theme.textColor.withValues(alpha: 0.5),
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                      )
                    : RichText(
                        textAlign: isArabicScript || isUrduLocale
                            ? TextAlign.right
                            : TextAlign.left,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: isArabicScript
                              ? TextStyle(
                                  fontSize: 22,
                                  color: theme.textColor,
                                  height: 1.8,
                                )
                              : TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSecondary,
                                  height: 1.5,
                                ),
                          children: _buildHighlightedText(
                            displayText,
                            searchQuery.trim(),
                            isArabicScript
                                ? TextStyle(
                                    fontSize: 22,
                                    color: theme.textColor,
                                    height: 1.8,
                                  )
                                : TextStyle(
                                    fontSize: 15,
                                    color: colorScheme.onSecondary,
                                    height: 1.5,
                                  ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class _CombinedNoResultsView extends StatelessWidget {
  final String keyword;

  const _CombinedNoResultsView({required this.keyword});

  @override
  Widget build(BuildContext context) {
    final theme = context.mainTheme;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            // wanna replace with cupertino icon
            CupertinoIcons.search,
            size: 64,
            color: theme.textColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            isUrdu ? 'کوئی نتیجہ نہیں ملا' : 'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: theme.textColor.withValues(alpha: 0.6),
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: isUrdu
                      ? 'ہمیں '
                      : 'We couldn\'t find any Surah, Juz, or Ayah matching ',
                ),
                TextSpan(
                  text: '"$keyword"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                TextSpan(
                  text: isUrdu
                      ? ' سے متعلق کوئی سورت، پارہ یا آیت نہیں ملی۔ براہ کرم مختلف الفاظ کے ساتھ دوبارہ کوشش کریں۔'
                      : '.\nPlease check your spelling or try different keywords.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerAyahCard extends StatelessWidget {
  const _ShimmerAyahCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.mainTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.secondaryColor],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.textColor.withValues(alpha: 0.1),
            width: 1,
          ),
          top: BorderSide(
            color: theme.textColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildShimmerBlock(
                  context,
                  width: 120,
                  height: 24,
                  borderRadius: 8,
                  baseColor: baseColor,
                ),
                const Spacer(),
                _buildShimmerBlock(
                  context,
                  width: 32,
                  height: 24,
                  borderRadius: 6,
                  baseColor: baseColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBlock(
                  context,
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                  baseColor: baseColor,
                ),
                const SizedBox(height: 6),
                _buildShimmerBlock(
                  context,
                  width: "80%", // Can't use string directly, handle below
                  height: 16,
                  borderRadius: 4,
                  baseColor: baseColor,
                  fractionalWidth: 0.8,
                ),
                const SizedBox(height: 6),
                _buildShimmerBlock(
                  context,
                  width: "60%",
                  height: 16,
                  borderRadius: 4,
                  baseColor: baseColor,
                  fractionalWidth: 0.6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBlock(
    BuildContext context, {
    required double height,
    dynamic width,
    required double borderRadius,
    required Color baseColor,
    double? fractionalWidth,
  }) {
    return FractionallySizedBox(
      widthFactor: fractionalWidth,
      child: Container(
        width: fractionalWidth == null ? (width as num?)?.toDouble() : null,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Matches everything except lowercase a-z; used to normalise transliteration
/// text before substring matching.
final _nonAlphaRe = RegExp(r'[^a-z]');

/// Returns [start, end) spans in [text] where [keyword] matches after both
/// are squashed (lowercased, non-alpha stripped).
List<_Span> _findSquashedSpans(String text, String keyword) {
  final squashedKeyword = keyword.toLowerCase().replaceAll(_nonAlphaRe, '');
  if (squashedKeyword.isEmpty) return [];

  final squashedText = text.toLowerCase().replaceAll(_nonAlphaRe, '');
  final spans = <_Span>[];
  var searchFrom = 0;

  while (searchFrom < squashedText.length) {
    final matchIdx = squashedText.indexOf(squashedKeyword, searchFrom);
    if (matchIdx == -1) break;

    // Walk original [text] in sync with the squashed form to map positions.
    int origStart = 0, squashPos = 0;
    while (squashPos < matchIdx && origStart < text.length) {
      if (!_nonAlphaRe.hasMatch(text[origStart].toLowerCase())) squashPos++;
      origStart++;
    }

    int origEnd = origStart;
    var squashEnd = squashPos;
    while (squashEnd < squashPos + squashedKeyword.length &&
        origEnd < text.length) {
      if (!_nonAlphaRe.hasMatch(text[origEnd].toLowerCase())) squashEnd++;
      origEnd++;
    }

    spans.add(_Span(origStart, origEnd));
    searchFrom = matchIdx + squashedKeyword.length;
  }

  return spans;
}

/// Builds [InlineSpan]s for the ranges in [orderedSpans], highlighting
/// the matched substrings with a yellow background.
List<InlineSpan> _buildSpansFromRanges(
  String text,
  List<_Span> orderedSpans,
  TextStyle baseStyle,
) {
  final spans = <InlineSpan>[];
  var lastEnd = 0;
  for (final s in orderedSpans) {
    if (s.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, s.start)));
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text.substring(s.start, s.end),
            style: baseStyle.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
    lastEnd = s.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd)));
  }
  return spans;
}

/// Top-level highlight function used by all search tiles.
///
/// Tries literal regex matching first; if that yields nothing and the text
/// is Latin (transliteration), falls back to squashed substring matching
/// so queries like "waqalat haitalak" still highlight "wa qaalat haita lak".
List<InlineSpan> _buildHighlightedText(
  String text,
  String query,
  TextStyle baseStyle,
) {
  if (query.trim().isEmpty) return [TextSpan(text: text)];

  final keywords = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((k) => k.isNotEmpty)
      .toList();

  if (keywords.isEmpty) return [TextSpan(text: text)];

  // 1. Literal regex matching (existing behaviour).
  final pattern = keywords.map(RegExp.escape).join('|');
  final regExp = RegExp(pattern, caseSensitive: false);
  final regexMatches = regExp.allMatches(text).toList();

  if (regexMatches.isNotEmpty) {
    final ordered = regexMatches.map((m) => _Span(m.start, m.end)).toList();
    return _buildSpansFromRanges(text, ordered, baseStyle);
  }

  // 2. Squashed fallback for Latin / transliteration text.
  if (!RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
    final squashedSpans = <_Span>[];
    for (final keyword in keywords) {
      squashedSpans.addAll(_findSquashedSpans(text, keyword));
    }

    if (squashedSpans.isNotEmpty) {
      squashedSpans.sort((a, b) => a.start.compareTo(b.start));
      final merged = <_Span>[];
      for (final s in squashedSpans) {
        if (merged.isEmpty || s.start > merged.last.end) {
          merged.add(s);
        } else if (s.end > merged.last.end) {
          merged.last = _Span(merged.last.start, s.end);
        }
      }
      return _buildSpansFromRanges(text, merged, baseStyle);
    }
  }

  return [TextSpan(text: text)];
}

/// Simple immutable span.
class _Span {
  final int start;
  final int end;
  const _Span(this.start, this.end);
}
