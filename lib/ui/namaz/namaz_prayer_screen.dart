import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/models/namaz_prayer.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class NamazPrayerScreen extends StatelessWidget {
  const NamazPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final playerVisible = QuranPlayerVisibility.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: isUrdu ? 'نماز' : 'Namaz',
        palette: palette,
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                quranPlayerAwareBottomPadding(
                  context,
                  playerVisible: playerVisible,
                ),
              ),
              children: [
                _GuideCard(palette: palette, isUrdu: isUrdu),
                const SizedBox(height: 8),
                if (kNamazPrayers.isEmpty)
                  _EmptyCard(palette: palette, isUrdu: isUrdu)
                else
                  ...kNamazPrayers.map(
                    (prayer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PrayerTile(
                        prayer: prayer,
                        palette: palette,
                        isUrdu: isUrdu,
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.palette, required this.isUrdu});
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.selectedCard,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: const ValueKey('complete_namaz_guide_tile'),
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.completeNamazGuide),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'مکمل نماز گائیڈ' : 'Complete Namaz Guide',
                    style: _style(
                      isUrdu,
                      palette.selectedTitle,
                      16,
                      FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isUrdu
                        ? 'وضو، اذکار، دعائیں اور نماز کا طریقہ'
                        : 'Wudu, recitations, duas and prayer method',
                    style: _style(
                      isUrdu,
                      palette.selectedSubtitle,
                      13,
                      FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              color: palette.selectedSubtitle,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
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
    final total = parts.fold<int>(0, (sum, part) => sum + part.count);
    return Material(
      key: ValueKey('namaz_prayer_${prayer.id}'),
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isUrdu ? prayer.nameUr : prayer.nameEn} (${total.toLocalizedNumber(context)})',
              style: _style(isUrdu, palette.title, 15, FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              runSpacing: 4,
              children: [
                for (var index = 0; index < parts.length; index++) ...[
                  Text(
                    '${parts[index].count.toLocalizedNumber(context)} ${parts[index].label(isUrdu)}',
                    style: _style(
                      isUrdu,
                      palette.subtitle,
                      13,
                      FontWeight.w400,
                    ),
                  ),
                  if (index != parts.length - 1)
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: palette.subtitle,
                      size: 12,
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.palette, required this.isUrdu});
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      isUrdu
          ? 'نماز کی معلومات لوڈ نہیں ہو سکیں'
          : 'Prayer guide is unavailable',
      style: _style(isUrdu, palette.subtitle, 14, FontWeight.w400),
    ),
  );
}

class PrayerRakatPart {
  const PrayerRakatPart(this.type, this.count);
  final String type;
  final int count;

  String label(bool isUrdu) => switch (type) {
    'sunnah' => isUrdu ? 'سنت' : 'Sunnah',
    'fard' => isUrdu ? 'فرض' : 'Fard',
    'nafl' => isUrdu ? 'نفل' : 'Nafl',
    'witr' => isUrdu ? 'وتر' : 'Witr',
    _ => type,
  };
}

List<PrayerRakatPart> prayerBreakdown(
  NamazPrayer prayer,
) => switch (prayer.id) {
  'fajr' => const [PrayerRakatPart('sunnah', 2), PrayerRakatPart('fard', 2)],
  'duhr' => const [
    PrayerRakatPart('sunnah', 4),
    PrayerRakatPart('fard', 4),
    PrayerRakatPart('sunnah', 2),
    PrayerRakatPart('nafl', 2),
  ],
  'asr' => const [PrayerRakatPart('sunnah', 4), PrayerRakatPart('fard', 4)],
  'maghrib' => const [
    PrayerRakatPart('fard', 3),
    PrayerRakatPart('sunnah', 2),
    PrayerRakatPart('nafl', 2),
  ],
  'isha' => const [
    PrayerRakatPart('sunnah', 4),
    PrayerRakatPart('fard', 4),
    PrayerRakatPart('sunnah', 2),
    PrayerRakatPart('nafl', 2),
    PrayerRakatPart('witr', 3),
    PrayerRakatPart('nafl', 2),
  ],
  _ => [
    if (prayer.rakaatSunnah > 0) PrayerRakatPart('sunnah', prayer.rakaatSunnah),
    if (prayer.rakaatFard > 0) PrayerRakatPart('fard', prayer.rakaatFard),
  ],
};

TextStyle _style(
  bool isUrdu,
  Color color,
  double fontSize,
  FontWeight fontWeight,
) => TextStyle(
  color: color,
  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
  fontSize: fontSize,
  height: isUrdu ? 1.45 : 1.25,
  fontWeight: fontWeight,
);
