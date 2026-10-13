import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart'
    show QuranEditionKey, QuranFetchType, quranEditionTextProvider;
import 'package:rafeeq/data/services/bookmark_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/quran/ayah_text_share.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart' hide isRtlEdition;
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/ui/widgets/center_loading_view.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';

class BookmarksScreen extends HookConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bookmarkService = ref.watch(bookmarkServiceProvider);
    // Watch bookmarks state to trigger rebuilds when bookmarks change
    ref.watch(bookmarksStateProvider);
    final bookmarks = bookmarkService.getBookmarks();
    final quranDataValue = ref.watch(quranDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.bookmarks),
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: Icon(CupertinoIcons.trash, color: theme.textColor),
              onPressed: () {
                _showClearAllDialog(context, bookmarkService);
              },
              tooltip: context.loc.clearAllBookmarks,
            ),
        ],
      ),
      body: quranDataValue.when(
        data: (quranData) {
          if (bookmarks.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Parse bookmarks and group by surah
          final Map<int, List<int>> bookmarksBySurah = {};
          for (final bookmark in bookmarks) {
            final parts = bookmark.split(':');
            if (parts.length == 2) {
              final surahNumber = int.tryParse(parts[0]);
              final ayahNumber = int.tryParse(parts[1]);
              if (surahNumber != null && ayahNumber != null) {
                bookmarksBySurah.putIfAbsent(surahNumber, () => []);
                bookmarksBySurah[surahNumber]!.add(ayahNumber);
              }
            }
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              quranPlayerAwareBottomPadding(
                context,
                playerVisible: playerVisible,
              ),
            ),
            itemCount: bookmarksBySurah.length,
            itemBuilder: (context, index) {
              final surahNumber = bookmarksBySurah.keys.elementAt(index);
              final ayahNumbers = bookmarksBySurah[surahNumber]!;
              ayahNumbers.sort();

              // Find the surah
              final surah = quranData.surah.firstWhere(
                (s) => s.surahNumber == surahNumber,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.textColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      collapsedShape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      iconColor: theme.textColor,
                      collapsedIconColor: theme.textColor,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        top: 12,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.secondaryColor.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          surahNumber.toLocalizedNumber(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textColor,
                          ),
                        ),
                      ),
                      title: Text(
                        SurahNamesProvider.getUrduName(surah.surahNumber),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontFamily: "Alvi",
                            ),
                      ),
                      subtitle: Text(
                        "${ayahNumbers.length.toLocalizedNumber(context)} bookmark${ayahNumbers.length > 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      children: ayahNumbers.map((ayahNumber) {
                        return _BookmarkAyahCard(
                          surah: surah,
                          ayahNumber: ayahNumber,
                          theme: theme,
                          allAyahs: quranData.ayahs,
                          onRemove: () {
                            bookmarkService.removeBookmark(
                              surahNumber,
                              ayahNumber,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (err, trace) {
          return Center(
            child: Text(
              "Error loading Quran data",
              style: TextStyle(color: theme.textColor),
            ),
          );
        },
        loading: () => const CenterLoadingView(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, RafeeqTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.3),
                  theme.secondaryColor.withValues(alpha: 0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: theme.textColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.loc.noBookmarksYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              context.loc.bookmarkAyahsPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    BookmarkService bookmarkService,
  ) {
    final theme = context.mainTheme;
    AppInfoDialog.show(
      context,
      title: context.loc.clearAllBookmarksQuestion,
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        Center(
          child: Text(
            context.loc.clearAllBookmarksConfirmation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: CancelButton()),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  bookmarkService.clearAllBookmarks();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.loc.clearAllBookmarks.split(" ")[0],
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Rich ayah card that mirrors the _AyahItem from quran_details_screen.dart
/// but without the play button. Shows full Arabic text, translation,
/// translation (based on Quran view settings), bookmark toggle, and share.
class _BookmarkAyahCard extends ConsumerWidget {
  final Surah surah;
  final int ayahNumber;
  final RafeeqTheme theme;
  final List<Ayah> allAyahs;
  final VoidCallback onRemove;

  const _BookmarkAyahCard({
    required this.surah,
    required this.ayahNumber,
    required this.theme,
    required this.allAyahs,
    required this.onRemove,
  });

  QuranEditionKey _editionKey(String editionId, int surahNumber) {
    return (
      type: QuranFetchType.surah,
      number: surahNumber,
      editionId: editionId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final bookmarkService = ref.watch(bookmarkServiceProvider);
    ref.watch(bookmarksStateProvider);
    final isBookmarked = bookmarkService.isBookmarked(
      surah.surahNumber,
      ayahNumber,
    );
    final ayah = surah.ayahs.firstWhere((a) => a.numberInSurah == ayahNumber);

    // Get Arabic text (remove Bismillah from first ayah of non-Fatiha surahs)
    String ayahText = ayah.text;
    if (ayah.surahNumber != 1 && ayah.numberInSurah == 1) {
      const bismillah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
      if (ayahText.contains(bismillah)) {
        ayahText = ayahText.replaceAll(bismillah, "").trim();
      }
    }

    // Fetch translation using the same provider as the Quran reader.
    final translationAsync = settings.showTranslation
        ? ref.watch(
            quranEditionTextProvider(
              _editionKey(settings.translationEditionId, ayah.surahNumber),
            ),
          )
        : const AsyncValue.data(<int, String>{});

    final translationMap = translationAsync.value ?? {};

    final translation = translationMap[ayah.number];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            di.appRouter.pushNamed(
              AppRoutes.quranDetails,
              arguments: QuranDetailsArgs(
                SurahQuranDetailArgs(surah, allAyahs),
                initialAyahNumber: ayahNumber,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.onSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.onSecondary.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header row: ayah number badge + bookmark/share buttons ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ayah number badge
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.secondaryColor.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ayahNumber.toLocalizedNumber(context),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                    ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bookmark button
                        IconButton(
                          onPressed: () {
                            bookmarkService.toggleBookmark(
                              ayah.surahNumber,
                              ayah.numberInSurah,
                            );
                          },
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 20,
                            color: theme.textColor.withValues(alpha: 0.6),
                          ),
                          splashRadius: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),

                        IconButton(
                          onPressed: () => shareAyahAsText(
                            context,
                            ayah: ayah,
                            surahName: surah.englishName,
                            arabicText: ayahText,
                            translation: translation,
                          ),
                          icon: Icon(
                            Icons.share_rounded,
                            size: 20,
                            color: theme.textColor.withValues(alpha: 0.6),
                          ),
                          splashRadius: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Full Arabic text ──
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    ayahText,
                    textAlign: TextAlign.justify,
                    style: getArabicTextStyle(settings, theme.textColor),
                  ),
                ),

                // ── Translation ──
                if (settings.showTranslation && translation != null) ...[
                  const SizedBox(height: 6),
                  Divider(
                    indent: 40,
                    endIndent: 40,
                    color: theme.textColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: isRtlEdition(settings.translationEditionId)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Text(
                      translation,
                      textAlign: isRtlEdition(settings.translationEditionId)
                          ? TextAlign.right
                          : TextAlign.justify,
                      style: getTranslationTextStyle(
                        settings,
                        theme.textColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
