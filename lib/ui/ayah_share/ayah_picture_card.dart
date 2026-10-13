import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';

class AyahPictureCard extends StatelessWidget {
  const AyahPictureCard({
    super.key,
    required this.ayah,
    required this.translation,
    required this.translationEditionId,
    required this.palette,
    this.showArabic = true,
    this.showTranslation = true,
    this.isLoading = false,
    this.urduMode = false,
  }) : asma = null;

  const AyahPictureCard.asma({
    super.key,
    required this.asma,
    required this.translation,
    required this.palette,
    this.translationEditionId = 'en',
    this.showArabic = true,
    this.showTranslation = true,
    this.urduMode = false,
  }) : ayah = null,
       isLoading = false;

  final Ayah? ayah;
  final AsmaUlHusna? asma;
  final String? translation;
  final String translationEditionId;
  final SettingsPalette palette;
  final bool showArabic;
  final bool showTranslation;
  final bool isLoading;
  final bool urduMode;

  @override
  Widget build(BuildContext context) {
    final arabicText = asma?.name ?? ayah!.text;
    final translationIsRtl = isRtlEdition(translationEditionId);
    final hasArabic = showArabic && arabicText.trim().isNotEmpty;
    final hasTranslation =
        showTranslation && (translation?.trim().isNotEmpty ?? false);
    return DecoratedBox(
      key: const ValueKey('ayah_picture_preview'),
      decoration: BoxDecoration(color: palette.card),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 48),
              child: isLoading
                  ? Center(
                      child: AyahPictureLoadingIndicator(color: palette.accent),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final arabicMaxSize = (constraints.maxHeight * .13)
                            .clamp(22.0, 42.0);
                        final translationMaxSize =
                            (constraints.maxHeight * .065).clamp(12.0, 20.0);
                        final arabicLoad = arabicText.runes.length * 1.25;
                        final translationLoad = translation?.runes.length ?? 0;
                        final combinedLoad = arabicLoad + translationLoad;
                        final arabicFlex = hasArabic && hasTranslation
                            ? ((arabicLoad / combinedLoad) * 10).round().clamp(
                                3,
                                7,
                              )
                            : 1;
                        final translationFlex = hasArabic && hasTranslation
                            ? 10 - arabicFlex
                            : 1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasArabic)
                              Flexible(
                                flex: arabicFlex,
                                fit: FlexFit.loose,
                                child: MediaQuery.withNoTextScaling(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AutoSizeText(
                                      arabicText,
                                      key: const ValueKey(
                                        'ayah_picture_arabic',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 50,
                                      minFontSize: 2,
                                      stepGranularity: .5,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: palette.title,
                                        fontFamily: 'PDMS Saleem Quran',
                                        fontSize: arabicMaxSize,
                                        height: 1.55,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (hasArabic && hasTranslation)
                              const SizedBox(height: 8),
                            if (hasTranslation)
                              Flexible(
                                flex: translationFlex,
                                fit: FlexFit.loose,
                                child: MediaQuery.withNoTextScaling(
                                  child: Directionality(
                                    textDirection: translationIsRtl
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: AutoSizeText(
                                      translation!,
                                      key: const ValueKey(
                                        'ayah_picture_translation',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 50,
                                      minFontSize: 2,
                                      stepGranularity: .5,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: palette.subtitle,
                                        fontFamily: translationIsRtl
                                            ? 'Jameel Noori Nastaleeq'
                                            : 'GoogleSans',
                                        fontSize: translationIsRtl
                                            ? translationMaxSize + 3
                                            : translationMaxSize,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          PositionedDirectional(
            start: urduMode ? null : 12,
            end: urduMode ? 12 : null,
            top: 12,
            child: Text(
              _referenceLabel(),
              textDirection: urduMode ? TextDirection.rtl : TextDirection.ltr,
              textAlign: urduMode ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: urduMode ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
                fontSize: urduMode ? 15 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            ),
          ),
          PositionedDirectional(
            start: urduMode ? 12 : null,
            end: urduMode ? null : 12,
            bottom: 12,
            child: SvgPicture.asset(
              key: const ValueKey('ayah_picture_calligraphy'),
              'assets/calligraphy.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(palette.title, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  String _referenceLabel() {
    if (!urduMode) {
      return asma == null
          ? "Qur'an ${ayah!.surahNumber}:${ayah!.numberInSurah}"
          : "Asma'ul Husna ${asma!.number}";
    }
    final reference = asma == null
        ? '${ayah!.surahNumber}:${ayah!.numberInSurah}'
        : '${asma!.number}';
    return asma == null
        ? 'القرآن ${_toUrduDigits(reference)}'
        : 'اسماء الحسنیٰ ${_toUrduDigits(reference)}';
  }
}

String _toUrduDigits(String value) {
  const western = '0123456789';
  const urdu = '۰۱۲۳۴۵۶۷۸۹';
  return value.split('').map((character) {
    final index = western.indexOf(character);
    return index < 0 ? character : urdu[index];
  }).join();
}

class AyahPictureLoadingIndicator extends StatelessWidget {
  const AyahPictureLoadingIndicator({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CircularProgressIndicator(
        key: const ValueKey('ayah_picture_loading_indicator'),
        color: color,
        strokeWidth: 2,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

@Preview(name: 'Premium Ayah picture', group: 'Quran', size: Size(390, 390))
Widget ayahPictureCardPreview() {
  return MaterialApp(
    home: const Scaffold(
      body: Center(
        child: SizedBox.square(
          dimension: 390,
          child: AyahPictureCard(
            ayah: Ayah(
              number: 1,
              numberInSurah: 1,
              text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              juz: 1,
              surahNumber: 1,
            ),
            translation:
                'In the name of Allah, the Most Compassionate, '
                'the Most Merciful.',
            translationEditionId: 'en.asad',
            palette: SettingsPalette.light,
          ),
        ),
      ),
    ),
  );
}
