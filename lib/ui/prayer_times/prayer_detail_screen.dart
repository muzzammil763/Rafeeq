import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/data/models/daily_prayer.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class PrayerDetailScreen extends HookConsumerWidget {
  final DailyPrayer prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

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
              _copyPrayer(context, prayer);
            },
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy Prayer',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prayer Counter Card
              _buildCounterCard(context, theme, colorScheme),
              const SizedBox(height: 24),
              // Arabic Text
              _buildArabicCard(context, theme, colorScheme),
              const SizedBox(height: 16),
              // Transliteration
              _buildTransliterationCard(context, theme, colorScheme),
              const SizedBox(height: 16),
              // Translation
              _buildTranslationCard(context, theme, colorScheme, isUrdu),
              const SizedBox(height: 16),
              // Reference
              if (prayer.reference != null)
                _buildReferenceCard(context, theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
          const SizedBox(height: 16),
          if (prayer.recommendedCount != null && prayer.recommendedCount! > 1)
            Column(
              children: [
                Text(
                  'Recommended to recite',
                  style: TextStyle(
                    color: colorScheme.onSecondary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 18,
                        color: colorScheme.onSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${prayer.recommendedCount!.toLocalizedNumber(context)} times',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              'Daily Prayer',
              style: TextStyle(
                color: colorScheme.onSecondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArabicCard(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              _buildSectionLabel('Arabic', colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prayer.arabicText,
            style: TextStyle(
              fontFamily: 'Muhammadi Uthmanic',
              fontSize: 26,
              height: 1.8,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildTransliterationCard(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              _buildSectionLabel('Transliteration', colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prayer.transliteration,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
    bool isUrdu,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              _buildSectionLabel(
                isUrdu ? 'Urdu Translation' : 'English Translation',
                colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isUrdu ? prayer.urduTranslation : prayer.englishTranslation,
            style: TextStyle(
              fontSize: isUrdu ? 18 : 16,
              height: 1.6,
              color: colorScheme.onSurface,
              fontFamily: isUrdu ? 'Alvi' : null,
            ),
          ),
          if (!isUrdu) ...[
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                _buildSectionLabel(
                  'Urdu Translation',
                  colorScheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prayer.urduTranslation,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
                fontFamily: 'Alvi',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
    String text,
    Color color, {
    double fontSize = 12,
    double letterSpacing = 1,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }

  Widget _buildReferenceCard(
    BuildContext context,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.book_outlined, size: 20, color: theme.textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(
                  'Reference',
                  theme.textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
                const SizedBox(height: 4),
                Text(
                  prayer.reference!,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textColor,
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

  void _copyPrayer(BuildContext context, DailyPrayer prayer) {
    final text =
        '''${prayer.arabicText}

Transliteration: ${prayer.transliteration}

English: ${prayer.englishTranslation}

Urdu: ${prayer.urduTranslation}

${prayer.reference != null ? 'Reference: ${prayer.reference}' : ''}''';
    Clipboard.setData(ClipboardData(text: text));

    showRafeeqToast(context, 'Prayer copied to clipboard');
  }
}
