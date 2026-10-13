import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/themed_card.dart';
import 'package:rafeeq/data/daily_prayers_data.dart';
import 'package:rafeeq/data/models/daily_prayer.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class PrayerCategoryScreen extends HookConsumerWidget {
  final String categoryId;
  final String categoryName;

  const PrayerCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final prayers = getPrayersByCategory(categoryId);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            onPressed: () {
              _showPrayersListSheet(
                context,
                prayers,
                theme,
                colorScheme,
                isUrdu,
              );
            },
            icon: const Icon(Icons.list),
            tooltip: 'View List',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: prayers.length,
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          return _PrayerCard(
            prayer: prayer,
            index: index,
            theme: theme,
            colorScheme: colorScheme,
            isUrdu: isUrdu,
            onTap: () {
              di.appRouter.pushNamed(
                AppRoutes.prayerDetail,
                arguments: {'prayer': prayer},
              );
            },
          );
        },
      ),
    );
  }

  void _showPrayersListSheet(
    BuildContext context,
    List<DailyPrayer> prayers,
    RafeeqTheme theme,
    ColorScheme colorScheme,
    bool isUrdu,
  ) {
    final palette = SettingsPalette.of(context);
    AppInfoDialog.show(
      context,
      title: 'Prayers in this Category (${prayers.length})',
      iconAsset: 'assets/logo.png',
      useImage: true,
      contentWidgets: [
        ...prayers.indexed.map((entry) {
          final (index, prayer) = entry;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: palette.selectedTitle.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  di.appRouter.pushNamed(
                    AppRoutes.prayerDetail,
                    arguments: {'prayer': prayer},
                  );
                },
                leading: Text(
                  (index + 1).toLocalizedNumber(context),
                  style: TextStyle(
                    color: palette.selectedTitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                title: Text(
                  prayer.arabicText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: palette.selectedTitle,
                    fontFamily: 'Muhammadi Uthmanic',
                    fontSize: 17,
                  ),
                ),
                subtitle: Text(
                  isUrdu ? prayer.urduTranslation : prayer.englishTranslation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.selectedSubtitle),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final DailyPrayer prayer;
  final int index;
  final RafeeqTheme theme;
  final ColorScheme colorScheme;
  final bool isUrdu;
  final VoidCallback onTap;

  const _PrayerCard({
    required this.prayer,
    required this.index,
    required this.theme,
    required this.colorScheme,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ThemedCard(
            borderRadius: 16,
            blurRadius: 8,
            shadowOffset: const Offset(0, 3),
            shadowAlpha: 0.12,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toLocalizedNumber(context),
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (prayer.recommendedCount != null &&
                        prayer.recommendedCount! > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 12,
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${prayer.recommendedCount?.toLocalizedNumber(context) ?? "1"}x',
                              style: TextStyle(
                                color: colorScheme.onSecondary.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colorScheme.onSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prayer.arabicText,
                  style: TextStyle(
                    fontFamily: 'Muhammadi Uthmanic',
                    fontSize: 20,
                    height: 1.6,
                    color: colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isUrdu ? prayer.urduTranslation : prayer.englishTranslation,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSecondary.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
