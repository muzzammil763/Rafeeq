import 'package:flutter/material.dart';
import 'package:rafeeq/data/models/namaz_prayer.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class WuduScreen extends StatelessWidget {
  const WuduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final playerVisible = QuranPlayerVisibility.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: isUrdu ? 'وضو کا طریقہ' : 'Wudu Guide',
        palette: palette,
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.separated(
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
              itemCount: kWuduSteps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _WuduStepTile(
                step: kWuduSteps[index],
                palette: palette,
                isUrdu: isUrdu,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WuduStepTile extends StatelessWidget {
  const _WuduStepTile({
    required this.step,
    required this.palette,
    required this.isUrdu,
  });
  final WuduStep step;
  final SettingsPalette palette;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('wudu_step_${step.step}'),
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
                '${step.step.toLocalizedNumber(context)}- ${isUrdu ? step.titleUr : step.titleEn}',
                style: TextStyle(
                  color: palette.title,
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
                  fontSize: 15,
                  height: isUrdu ? 1.5 : 1.25,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isUrdu ? step.descriptionUr : step.descriptionEn,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
            fontSize: isUrdu ? 20 : 17,
            height: isUrdu ? 1.55 : 1.4,
          ),
        ),
        if (step.arabicText?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Text(
              step.arabicText!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: palette.title,
                fontFamily: 'PDMS Saleem Quran',
                fontSize: 28,
                height: 1.75,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
