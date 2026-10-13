import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/daily_prayers_data.dart';
import 'package:rafeeq/data/models/daily_prayer.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class DailyPrayerScreen extends HookConsumerWidget {
  const DailyPrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.loc.dailyPrayer),
        actions: [
          IconButton(
            onPressed: () {
              _showPrayerInfoSheet(context, theme, colorScheme);
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Daily Prayers',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(context, theme, colorScheme, isUrdu),
            const SizedBox(height: 24),
            // Categories section
            _buildCategoriesList(context, theme, colorScheme, isUrdu),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
    bool isUrdu,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FlutterIslamicIcons.prayer,
                  color: colorScheme.onSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.dailyPrayer,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: isUrdu ? 26 : 22,
                        fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.loc.dailyPrayerSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondary.withValues(alpha: 0.8),
                        fontSize: isUrdu ? 16 : 14,
                        fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 16,
                  color: colorScheme.onSecondary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  '${kAllDailyPrayers.length.toLocalizedNumber(context)} ${context.loc.dailyPrayer}',
                  style: TextStyle(
                    color: colorScheme.onSecondary.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
    bool isUrdu,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Categories'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: kPrayerCategories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = kPrayerCategories[index];
            final prayersInCategory = getPrayersByCategory(category.id);

            return _CategoryCard(
              category: category,
              prayerCount: prayersInCategory.length,
              theme: theme,
              colorScheme: colorScheme,
              isUrdu: isUrdu,
              onTap: () {
                di.appRouter.pushNamed(
                  AppRoutes.prayerCategory,
                  arguments: {
                    'categoryId': category.id,
                    'categoryName': isUrdu ? category.nameUr : category.nameEn,
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showPrayerInfoSheet(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    final palette = SettingsPalette.of(context);
    AppInfoDialog.show(
      context,
      title: 'About Daily Prayers',
      iconAsset: 'assets/logo.png',
      useImage: true,
      contentWidgets: [
        Text(
          'This collection includes authentic daily supplications from the Quran and Sunnah, recited at specific times of the day.',
          style: TextStyle(color: palette.selectedSubtitle, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Each prayer includes:\n• Arabic text\n• Transliteration\n• English translation\n• Urdu translation\n• Reference',
          style: TextStyle(color: palette.selectedSubtitle, height: 1.5),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.selectedTitle,
              side: BorderSide(color: palette.selectedTitle),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it'),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final PrayerCategory category;
  final int prayerCount;
  final RafeeqTheme theme;
  final ColorScheme colorScheme;
  final bool isUrdu;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.prayerCount,
    required this.theme,
    required this.colorScheme,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primaryColor, theme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.textColor.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _getCategoryIcon(category.icon, colorScheme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrdu ? category.nameUr : category.nameEn,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: isUrdu ? 18 : 16,
                              fontFamily: isUrdu
                                  ? 'Jameel Noori Nastaleeq'
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${prayerCount.toLocalizedNumber(context)} prayers',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondary.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSecondary.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String iconName, ColorScheme colorScheme) {
    IconData iconData;
    switch (iconName) {
      case 'wb_sunny':
        iconData = Icons.wb_sunny_outlined;
        break;
      case 'nights_stay':
        iconData = Icons.nights_stay_outlined;
        break;
      case 'bedtime':
        iconData = Icons.bedtime_outlined;
        break;
      case 'prayer':
        iconData = FlutterIslamicIcons.prayer;
        break;
      default:
        iconData = Icons.menu_book_outlined;
    }

    return Icon(iconData, color: colorScheme.onSecondary, size: 24);
  }
}
