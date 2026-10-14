import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/services/bookmark_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';

const _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

/// The Bookmarks tab of the Quran screen: bookmarked ayahs in mushaf order,
/// each opening the reader at that ayah.
class QuranBookmarksTab extends ConsumerWidget {
  const QuranBookmarksTab({
    super.key,
    required this.quranData,
    required this.palette,
    required this.padding,
  });

  final QuranData quranData;
  final SettingsPalette palette;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bookmarksStateProvider);
    final bookmarkService = ref.watch(bookmarkServiceProvider);
    final bookmarks = _resolve(bookmarkService.getBookmarks());

    if (bookmarks.isEmpty) return _EmptyBookmarks(palette: palette);

    return ListView.separated(
      key: const Key('quran-bookmarks-list'),
      physics: const BouncingScrollPhysics(),
      padding: padding,
      itemCount: bookmarks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (surah, ayah) = bookmarks[index];
        return _BookmarkCard(
          surah: surah,
          ayah: ayah,
          palette: palette,
          onOpen: () => di.appRouter.pushNamed(
            AppRoutes.quranDetails,
            arguments: QuranDetailsArgs(
              SurahQuranDetailArgs(surah, quranData.ayahs),
              initialAyahNumber: ayah.numberInSurah,
            ),
          ),
          onRemove: () => bookmarkService.removeBookmark(
            surah.surahNumber,
            ayah.numberInSurah,
          ),
        );
      },
    );
  }

  /// Turns stored "surah:ayah" keys into ayahs, sorted by surah then ayah and
  /// skipping any that no longer resolve.
  List<(Surah, Ayah)> _resolve(List<String> keys) {
    final surahs = {for (final s in quranData.surah) s.surahNumber: s};
    final resolved = <(Surah, Ayah)>[];
    for (final key in keys) {
      final parts = key.split(':');
      if (parts.length != 2) continue;
      final surah = surahs[int.tryParse(parts[0])];
      final ayahNumber = int.tryParse(parts[1]);
      if (surah == null || ayahNumber == null) continue;
      final ayah = surah.ayahs
          .where((a) => a.numberInSurah == ayahNumber)
          .firstOrNull;
      if (ayah != null) resolved.add((surah, ayah));
    }
    resolved.sort(
      (a, b) => a.$1.surahNumber != b.$1.surahNumber
          ? a.$1.surahNumber.compareTo(b.$1.surahNumber)
          : a.$2.numberInSurah.compareTo(b.$2.numberInSurah),
    );
    return resolved;
  }
}

class _BookmarkCard extends ConsumerWidget {
  const _BookmarkCard({
    required this.surah,
    required this.ayah,
    required this.palette,
    required this.onOpen,
    required this.onRemove,
  });

  final Surah surah;
  final Ayah ayah;
  final SettingsPalette palette;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final fontFamily = isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans';
    final surahName = isUrdu
        ? SurahNamesProvider.getUrduName(surah.surahNumber)
        : surah.englishName;
    var text = ayah.text;
    if (surah.surahNumber != 1 && ayah.numberInSurah == 1) {
      text = text.replaceAll(_bismillah, '').trim();
    }

    return Material(
      key: ValueKey('bookmark-${surah.surahNumber}:${ayah.numberInSurah}'),
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: surahName,
                            style: TextStyle(
                              color: palette.title,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                '  ·  ${context.loc.ayahNumber(ayah.numberInSurah.toLocalizedNumber(context))}',
                            style: TextStyle(color: palette.subtitle),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: fontFamily, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    tooltip: context.loc.removeBookmark,
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.bookmark_rounded,
                      color: palette.accent,
                      size: 22,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Text(
                  text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getArabicTextStyle(
                    settings,
                    palette.title,
                    customFontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final fontFamily = isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans';
    return Center(
      key: const Key('quran-bookmarks-empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: palette.subtitle.withValues(alpha: .6),
            ),
            const SizedBox(height: 16),
            Text(
              context.loc.noBookmarksYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.title,
                fontFamily: fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.bookmarkAyahsPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: fontFamily,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
