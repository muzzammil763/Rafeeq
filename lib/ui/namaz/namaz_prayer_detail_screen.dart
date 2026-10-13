import 'package:flutter/material.dart';
import 'package:rafeeq/data/models/namaz_prayer.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/namaz/namaz_prayer_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class NamazPrayerDetailScreen extends StatelessWidget {
  const NamazPrayerDetailScreen({super.key, required this.prayerId});

  final String prayerId;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final prayer = getNamazById(prayerId);
    if (prayer == null) {
      return Scaffold(
        backgroundColor: palette.background,
        appBar: RafeeqAppBar(
          title: isUrdu ? 'نماز' : 'Prayer',
          palette: palette,
          showBackButton: true,
        ),
        body: Center(
          child: Text(
            isUrdu ? 'نماز کی معلومات نہیں ملیں' : 'Prayer not found',
            style: _bodyStyle(isUrdu, palette.subtitle),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: isUrdu ? prayer.nameUr : prayer.nameEn,
        palette: palette,
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: prayer.components.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PrayerHeader(
                      prayer: prayer,
                      palette: palette,
                      isUrdu: isUrdu,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PrayerStepCard(
                    step: prayer.components[index - 1],
                    number: index,
                    palette: palette,
                    isUrdu: isUrdu,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerHeader extends StatelessWidget {
  const _PrayerHeader({
    required this.prayer,
    required this.palette,
    required this.isUrdu,
  });
  final NamazPrayer prayer;
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final parts = prayerBreakdown(prayer);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.selectedCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu ? prayer.nameUr : prayer.nameEn,
                      style: TextStyle(
                        color: palette.selectedTitle,
                        fontFamily: isUrdu
                            ? 'Jameel Noori Nastaleeq'
                            : 'GoogleSans',
                        fontSize: 18,
                        height: isUrdu ? 1.5 : 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isUrdu ? prayer.descriptionUr : prayer.descriptionEn,
                      style: _bodyStyle(isUrdu, palette.selectedSubtitle),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                prayer.arabicName,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: palette.selectedTitle,
                  fontFamily: 'PDMS Saleem Quran',
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: parts
                .map(
                  (part) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.selectedTitle.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${part.count.toLocalizedNumber(context)} ${part.label(isUrdu)}',
                      style: _bodyStyle(
                        isUrdu,
                        palette.selectedSubtitle,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PrayerStepCard extends StatelessWidget {
  const _PrayerStepCard({
    required this.step,
    required this.number,
    required this.palette,
    required this.isUrdu,
  });
  final NamazComponent step;
  final int number;
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('namaz_step_${step.id}'),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                number.toLocalizedNumber(context),
                style: TextStyle(
                  color: palette.accent,
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isUrdu ? step.titleUr : step.titleEn,
                style: TextStyle(
                  color: palette.title,
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
                  fontSize: 15,
                  height: isUrdu ? 1.45 : 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if ((step.repeatCount ?? 1) > 1)
              Text(
                '${step.repeatCount}×',
                style: TextStyle(
                  color: palette.accent,
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        if (step.arabicText?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              step.arabicText!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: palette.title,
                fontFamily: 'PDMS Saleem Quran',
                fontSize: 25,
                height: 1.75,
              ),
            ),
          ),
        ],
        if (step.transliteration?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Text(
            step.transliteration!,
            style: _bodyStyle(false, palette.subtitle),
          ),
        ],
        if (step.urduTranslation?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(
            step.urduTranslation!,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: _bodyStyle(true, palette.subtitle).copyWith(fontSize: 16),
          ),
        ],
        if (step.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(step.description!, style: _bodyStyle(false, palette.subtitle)),
        ],
      ],
    ),
  );
}

TextStyle _bodyStyle(bool isUrdu, Color color) => TextStyle(
  color: color,
  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
  fontSize: 13,
  height: isUrdu ? 1.55 : 1.4,
);
