import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna_urdu_meanings.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/localized_font.dart';

class AsmaulHusnaScreen extends ConsumerWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final palette = SettingsPalette.of(context);
    final asmaList = ref.watch(asmaUlHusnaProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.asmaulhusna,
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
              itemCount: asmaList.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AsmaCard(item: asmaList[index], palette: palette),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AsmaCard extends StatelessWidget {
  const _AsmaCard({required this.item, required this.palette});

  final AsmaUlHusna item;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final meaning = isUrdu
        ? asmaUlHusnaUrduMeanings[item.number] ?? item.meaning
        : item.meaning;
    final description = isUrdu
        ? asmaUlHusnaUrduDescription(item.number)
        : item.desc;
    return Container(
      key: ValueKey('asma_name_${item.number}'),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${item.number.toLocalizedNumber(context)}- ${item.transliteration}',
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item.name,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: palette.title,
                      fontFamily: 'Muhammadi Uthmanic',
                      fontSize: 40,
                      height: 1.75,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  meaning,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: palette.subtitle,
                      fontFamily: localizedFontFamily(context),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: palette.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Share name',
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.ayahPictureMaker,
                    arguments: AyahPictureMakerArgs.asma(
                      asmaNumber: item.number,
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.share, size: 22),
                  color: palette.title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
