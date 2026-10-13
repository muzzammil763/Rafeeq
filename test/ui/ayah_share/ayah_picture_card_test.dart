import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_card.dart';

const _longArabic =
    'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ إِلَىٰ أَجَلٍ '
    'مُّسَمًّى فَاكْتُبُوهُ وَلْيَكْتُب بَّيْنَكُمْ كَاتِبٌ بِالْعَدْلِ '
    'وَلَا يَأْبَ كَاتِبٌ أَن يَكْتُبَ كَمَا عَلَّمَهُ اللَّهُ';

const _longTranslation =
    'Believers, when you contract a debt for a fixed period, write it down. '
    'Let a scribe write it faithfully between you, and no scribe should '
    'refuse to write as Allah has taught him.';

const _ayah = Ayah(
  number: 282,
  numberInSurah: 282,
  text: '$_longArabic $_longArabic $_longArabic',
  juz: 3,
  surahNumber: 2,
);

void main() {
  Widget card({
    bool showArabic = true,
    bool showTranslation = true,
    bool isLoading = false,
    Ayah ayah = _ayah,
    String translation = '$_longTranslation $_longTranslation',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 320,
            child: AyahPictureCard(
              ayah: ayah,
              translation: translation,
              translationEditionId: 'en.asad',
              palette: SettingsPalette.light,
              showArabic: showArabic,
              showTranslation: showTranslation,
              isLoading: isLoading,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('fits a long Ayah and translation inside the square', (
    tester,
  ) async {
    await tester.pumpWidget(card());

    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers short Arabic and translation as one compact group', (
    tester,
  ) async {
    await tester.pumpWidget(
      card(
        ayah: const Ayah(
          number: 1,
          numberInSurah: 1,
          text: 'بِسْمِ اللَّهِ',
          juz: 1,
          surahNumber: 1,
        ),
        translation: 'In the name of Allah',
      ),
    );

    final arabicRect = tester.getRect(
      find.byKey(const ValueKey('ayah_picture_arabic')),
    );
    final translationRect = tester.getRect(
      find.byKey(const ValueKey('ayah_picture_translation')),
    );
    final cardRect = tester.getRect(
      find.byKey(const ValueKey('ayah_picture_preview')),
    );
    final groupCenter = (arabicRect.top + translationRect.bottom) / 2;

    expect(groupCenter, closeTo(cardRect.top + 152, 12));
    expect(translationRect.top - arabicRect.bottom, closeTo(8, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('gives all content space to the enabled text type', (
    tester,
  ) async {
    await tester.pumpWidget(card(showTranslation: false));
    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(card(showArabic: false));
    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsNothing);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a centered round-cap indicator until content is ready', (
    tester,
  ) async {
    await tester.pumpWidget(card(isLoading: true));

    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsNothing);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsNothing,
    );
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byKey(const ValueKey('ayah_picture_loading_indicator')),
    );
    expect(indicator.strokeWidth, 2);
    expect(indicator.strokeCap, StrokeCap.round);

    final cardRect = tester.getRect(
      find.byKey(const ValueKey('ayah_picture_preview')),
    );
    final indicatorCenter = tester.getCenter(
      find.byKey(const ValueKey('ayah_picture_loading_indicator')),
    );
    expect(indicatorCenter.dx, closeTo(cardRect.center.dx, 1));
    expect(indicatorCenter.dy, closeTo(cardRect.top + 152, 1));
    expect(tester.takeException(), isNull);
  });
}
