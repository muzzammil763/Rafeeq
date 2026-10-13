import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna_urdu_meanings.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/localized_font.dart';

bool _isUrdu(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ur';

String asmaMeaning(BuildContext context, AsmaUlHusna item) => _isUrdu(context)
    ? asmaUlHusnaUrduMeanings[item.number] ?? item.meaning
    : item.meaning;

String asmaDescription(BuildContext context, AsmaUlHusna item) =>
    _isUrdu(context) ? asmaUlHusnaUrduDescription(item.number) : item.desc;

/// One name per page; swipe between all 99 names.
class AsmaulHusnaDetailScreen extends ConsumerStatefulWidget {
  const AsmaulHusnaDetailScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  ConsumerState<AsmaulHusnaDetailScreen> createState() =>
      _AsmaulHusnaDetailScreenState();
}

class _AsmaulHusnaDetailScreenState
    extends ConsumerState<AsmaulHusnaDetailScreen> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final names = ref.watch(asmaUlHusnaProvider);
    final current = names[_index];
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title:
            '${current.number.toLocalizedNumber(context)} / '
            '${names.length.toLocalizedNumber(context)}',
        palette: palette,
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Share name',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.ayahPictureMaker,
              arguments: AyahPictureMakerArgs.asma(asmaNumber: current.number),
            ),
            icon: const Icon(CupertinoIcons.share, size: 22),
            color: palette.title,
          ),
        ],
      ),
      body: PageView.builder(
        key: const ValueKey('asma_detail_pages'),
        controller: _pages,
        itemCount: names.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) =>
            _AsmaDetailPage(item: names[index], palette: palette),
      ),
    );
  }
}

class _AsmaDetailPage extends ConsumerWidget {
  const _AsmaDetailPage({required this.item, required this.palette});

  final AsmaUlHusna item;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final description = asmaDescription(context, item);
    final fontFamily = localizedFontFamily(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
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
            _DetailCard(
              palette: palette,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Column(
                children: [
                  Text(
                    item.number.toLocalizedNumber(context),
                    style: TextStyle(
                      color: palette.accent,
                      fontFamily: fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.name,
                      maxLines: 1,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: 'PDMS Saleem Quran',
                        fontSize: 88,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.transliteration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.title,
                      fontFamily: latinFontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DetailSection(
              palette: palette,
              title: context.loc.asmaulhusnaMeaning,
              child: Text(
                asmaMeaning(context, item),
                style: TextStyle(
                  color: palette.title,
                  fontFamily: fontFamily,
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailSection(
                palette: palette,
                title: context.loc.asmaulhusnaExplanation,
                child: Text(
                  description,
                  style: TextStyle(
                    color: palette.subtitle,
                    fontFamily: fontFamily,
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.palette,
    required this.title,
    required this.child,
  });

  final SettingsPalette palette;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      palette: palette,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.accent,
              fontFamily: localizedFontFamily(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.palette,
    required this.padding,
    required this.child,
  });

  final SettingsPalette palette;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
