import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/models/namaz_prayer.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class NamazGuideScreen extends StatelessWidget {
  const NamazGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final steps = _buildGuideSteps();
    final playerVisible = QuranPlayerVisibility.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: isUrdu ? 'مکمل نماز گائیڈ' : 'Complete Namaz Guide',
        palette: palette,
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
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
              itemCount: steps.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _WuduTile(palette: palette, isUrdu: isUrdu),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _GuideStepCard(
                    item: steps[index - 1],
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

class _WuduTile extends StatelessWidget {
  const _WuduTile({required this.palette, required this.isUrdu});
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.selectedCard,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: const ValueKey('wudu_guide_tile'),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.wuduProcedure),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'وضو کا طریقہ' : 'Wudu Guide',
                    style: _guideStyle(
                      isUrdu,
                      palette.selectedTitle,
                      15,
                      FontWeight.w700,
                    ),
                  ),
                  Text(
                    isUrdu
                        ? 'نماز سے پہلے وضو کے مراحل'
                        : 'Step-by-step ablution before prayer',
                    style: _guideStyle(
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
              size: 17,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GuideStepCard extends StatelessWidget {
  const _GuideStepCard({
    required this.item,
    required this.number,
    required this.palette,
    required this.isUrdu,
  });
  final _GuideStep item;
  final int number;
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('namaz_guide_step_$number'),
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
            Expanded(
              child: Text(
                '${number.toLocalizedNumber(context)}- ${isUrdu ? item.urduTitle : item.englishTitle}',
                style: _guideStyle(isUrdu, palette.title, 15, FontWeight.w700),
              ),
            ),
            if ((item.component.repeatCount ?? 1) > 1)
              Text(
                '${item.component.repeatCount}×',
                style: TextStyle(
                  color: palette.accent,
                  fontFamily: 'GoogleSans',
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        if (item.component.arabicText?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Text(
              item.component.arabicText!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: palette.title,
                fontFamily: 'Muhammadi Uthmanic',
                fontSize: 30,
                height: 1.75,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          isUrdu ? item.urduTranslation : item.englishTranslation,
          textAlign: isUrdu ? TextAlign.right : TextAlign.left,
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          style: _guideStyle(
            isUrdu,
            palette.subtitle,
            isUrdu ? 20 : 17,
            FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _GuideStep {
  const _GuideStep({
    required this.component,
    required this.englishTitle,
    required this.urduTitle,
    required this.englishTranslation,
  });

  final NamazComponent component;
  final String englishTitle;
  final String urduTitle;
  final String englishTranslation;
  String get urduTranslation => component.urduTranslation ?? '';
}

List<_GuideStep> _buildGuideSteps() {
  if (kNamazPrayers.isEmpty) return const [];
  final components = {
    for (final component in kNamazPrayers.first.components)
      component.id: component,
  };
  _GuideStep step(
    String id,
    String englishTitle,
    String urduTitle,
    String englishTranslation,
  ) => _GuideStep(
    component: components[id]!,
    englishTitle: englishTitle,
    urduTitle: urduTitle,
    englishTranslation: englishTranslation,
  );

  return [
    step('takbeer', 'Takbeer', 'تکبیر', 'Allah is the Greatest.'),
    step(
      'thana',
      'Sana',
      'ثناء',
      'Glory and praise are Yours, O Allah. Blessed is Your name, exalted is Your majesty, and there is no deity besides You.',
    ),
    step(
      'tauz',
      "Ta'awwuz",
      'تعوذ',
      'I seek refuge in Allah from Satan, the rejected.',
    ),
    step(
      'tasmiah',
      'Tasmiah',
      'تسمیہ',
      'In the name of Allah, the Most Compassionate, the Most Merciful.',
    ),
    step(
      'fatiha',
      'Al-Fatiha',
      'الفاتحہ',
      'All praise belongs to Allah, Lord of all worlds, the Most Compassionate, the Most Merciful, Master of the Day of Judgment. You alone we worship and You alone we ask for help. Guide us to the straight path, the path of those You have blessed, not those who earned anger nor those who went astray.',
    ),
    step('ameen', 'Aameen', 'آمین', 'O Allah, accept this prayer.'),
    step(
      'surah_ikhlas',
      'Al-Ikhlas',
      'الاخلاص',
      'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, and none is comparable to Him.',
    ),
    step('ruku', 'Ruku', 'رکوع', 'Glory be to my Lord, the Magnificent.'),
    step(
      'qiyam_ruku',
      'Standing From Ruku',
      'رکوع سے قیام',
      'Allah hears the one who praises Him.',
    ),
    step(
      'response_qiyam',
      'Response',
      'جواب',
      'Our Lord, all praise belongs to You.',
    ),
    step(
      'sajdah_1',
      'First Sajdah',
      'پہلا سجدہ',
      'Glory be to my Lord, the Most High.',
    ),
    step('jalsa_1', 'Jalsa', 'جلسہ', 'Allah is the Greatest.'),
    step(
      'sajdah_2',
      'Second Sajdah',
      'دوسرا سجدہ',
      'Glory be to my Lord, the Most High.',
    ),
    step(
      'second_rakat',
      'Second Raka - Standing',
      'دوسری رکعت کے لیے قیام',
      'Allah is the Greatest.',
    ),
    step(
      'fatiha_2',
      'Al-Fatiha',
      'الفاتحہ',
      'All praise belongs to Allah, Lord of all worlds, the Most Compassionate, the Most Merciful, Master of the Day of Judgment. You alone we worship and You alone we ask for help. Guide us to the straight path, the path of those You have blessed, not those who earned anger nor those who went astray.',
    ),
    step(
      'surah_ikhlas',
      'Al-Ikhlas',
      'الاخلاص',
      'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, and none is comparable to Him.',
    ),
    step('ruku_2', 'Ruku', 'رکوع', 'Glory be to my Lord, the Magnificent.'),
    step(
      'qiyam_ruku_2',
      'Standing From Ruku',
      'رکوع سے قیام',
      'Allah hears the one who praises Him.',
    ),
    step(
      'response_qiyam_2',
      'Response',
      'جواب',
      'Our Lord, all praise belongs to You.',
    ),
    step(
      'sajdah_1_2',
      'First Sajdah',
      'پہلا سجدہ',
      'Glory be to my Lord, the Most High.',
    ),
    step('jalsa_2', 'Jalsa', 'جلسہ', 'Allah is the Greatest.'),
    step(
      'sajdah_2_2',
      'Second Sajdah',
      'دوسرا سجدہ',
      'Glory be to my Lord, the Most High.',
    ),
    step(
      'tashahhud',
      'Tashahhud',
      'تشہد',
      'All greetings, prayers, and pure words belong to Allah. Peace, mercy, and blessings of Allah be upon you, O Prophet. Peace be upon us and upon the righteous servants of Allah. I testify that there is no deity but Allah, and Muhammad ﷺ is His servant and messenger.',
    ),
    step(
      'darood',
      'Darood Sharif',
      'درود شریف',
      'O Allah, send mercy and blessings upon Muhammad ﷺ and the family of Muhammad ﷺ as You sent mercy and blessings upon Ibrahim and the family of Ibrahim. Surely You are Praiseworthy and Glorious.',
    ),
    step(
      'dua',
      'Dua',
      'دعا',
      'O Allah, I seek refuge in You from the punishment of Hell, the punishment of the grave, the trials of life and death, and the evil trial of the Dajjal.',
    ),
    step(
      'salam_right',
      'Salam - Turn Right',
      'سلام - دائیں جانب',
      'Peace and the mercy of Allah be upon you.',
    ),
    step(
      'salam_left',
      'Salam - Turn Left',
      'سلام - بائیں جانب',
      'Peace and the mercy of Allah be upon you.',
    ),
  ];
}

TextStyle _guideStyle(
  bool isUrdu,
  Color color,
  double fontSize,
  FontWeight fontWeight,
) => TextStyle(
  color: color,
  fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
  fontSize: fontSize,
  height: isUrdu ? 1.5 : 1.4,
  fontWeight: fontWeight,
);
