import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/model/quran_edition.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_maker_screen.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';

class _TestSettingsNotifier extends QuranViewSettingsNotifier {
  @override
  QuranViewSettings build() => QuranViewSettings.defaultSettings;
}

class _TestAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState();
}

const _firstAyah = Ayah(
  number: 1,
  numberInSurah: 1,
  text: 'بِسْمِ اللَّهِ',
  juz: 1,
  surahNumber: 1,
);

const _secondSurahAyahs = [
  Ayah(number: 8, numberInSurah: 1, text: 'الم', juz: 1, surahNumber: 2),
  Ayah(
    number: 9,
    numberInSurah: 2,
    text: 'ذَٰلِكَ الْكِتَابُ',
    juz: 1,
    surahNumber: 2,
  ),
];

final _quranData = QuranData(
  surah: [
    Surah(
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: const [_firstAyah],
    ),
    Surah(
      surahNumber: 2,
      name: 'البقرة',
      englishName: 'Al-Baqarah',
      englishNameTranslation: 'The Cow',
      revelationType: 'Medinan',
      ayahs: _secondSurahAyahs,
    ),
  ],
);

final _edition = QuranEdition(
  identifier: 'en.asad',
  name: 'Muhammad Asad',
  englishName: 'The Message of the Quran',
  format: 'text',
  type: 'translation',
  language: 'en',
);

final _urduEdition = QuranEdition(
  identifier: 'ur.jalandhry',
  name: 'فتح محمد جالندھری',
  englishName: 'Fateh Muhammad Jalandhry',
  format: 'text',
  type: 'translation',
  language: 'ur',
);

void main() {
  Widget testApp({
    Locale locale = const Locale('en'),
    int initialSurahNumber = 1,
    int initialAyahNumber = 1,
    int? initialAsmaNumber,
  }) {
    return ProviderScope(
      overrides: [
        quranDataProvider.overrideWith((ref) async => _quranData),
        quranEditionTextProvider.overrideWith(
          (ref, key) async => {
            if (key.number == 1)
              1: key.editionId.startsWith('ur')
                  ? 'اللہ کے نام سے شروع'
                  : 'In the name of Allah',
            if (key.number == 2) ...{
              8: 'Alif, Lam, Meem.',
              9: 'This is the Book.',
            },
          },
        ),
        editionsProvider.overrideWith((ref) async => [_edition, _urduEdition]),
        quranViewSettingsNotifierProvider.overrideWith(
          _TestSettingsNotifier.new,
        ),
        quranAudioControllerProvider.overrideWith(_TestAudioController.new),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
        home: AyahPictureMakerScreen(
          initialSurahNumber: initialSurahNumber,
          initialAyahNumber: initialAyahNumber,
          initialAsmaNumber: initialAsmaNumber,
        ),
      ),
    );
  }

  testWidgets('shows a square Ayah preview with localized English branding', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspectRatio.aspectRatio, 1);
    final preview = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('ayah_picture_preview')),
    );
    expect(
      (preview.decoration as BoxDecoration).color,
      SettingsPalette.light.card,
    );
    expect(find.text("Qur'an 1:1"), findsOneWidget);
    expect(find.text('بِسْمِ اللَّهِ'), findsOneWidget);
    expect(find.text('In the name of Allah'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ayah_picture_calligraphy')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text(_edition.englishName),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(_edition.englishName), findsOneWidget);
    expect(find.text(_edition.name), findsNothing);
    expect(
      find.byKey(const ValueKey('share_ayah_picture_appbar')),
      findsOneWidget,
    );
  });

  testWidgets('shows the native edition name in the Urdu locale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(locale: const Locale('ur')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ayah_picture_translation_selector')),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(_urduEdition.name), findsOneWidget);
    expect(find.text(_edition.englishName), findsNothing);
  });

  testWidgets('can show Arabic only or translation only', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('ayah_picture_translation_toggle')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('ayah_picture_translation_selector')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('ayah_picture_arabic_toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('ayah_picture_translation_toggle')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ayah_picture_arabic_toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('ayah_picture_arabic')), findsNothing);
    expect(
      find.byKey(const ValueKey('ayah_picture_translation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ayah_picture_surah_selector')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('ayah_picture_ayah_selector')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('ayah_picture_translation_selector')),
      findsOneWidget,
    );
  });

  testWidgets('changes Surah and Ayah through the Quran picker screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('ayah_picture_surah_selector')));
    await tester.pumpAndSettle();
    expect(find.text('Choose Surah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_surah_picker_2')));
    await tester.pumpAndSettle();
    expect(find.text('2 - Al-Baqarah'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ayah_picture_ayah_selector')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ayah 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ayah_picture_ayah_selector')));
    await tester.pumpAndSettle();
    expect(find.text('Jump To Ayah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_9')));
    await tester.pumpAndSettle();
    expect(find.text('Ayah 2'), findsOneWidget);
    expect(find.text('This is the Book.'), findsOneWidget);
  });

  testWidgets('opens with a Quran Details Ayah preselected', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      testApp(initialSurahNumber: 2, initialAyahNumber: 2),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ayah_picture_ayah_selector')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('2 - Al-Baqarah'), findsOneWidget);
    expect(find.text('Ayah 2'), findsOneWidget);
    expect(find.text("Qur'an 2:2"), findsOneWidget);
    expect(find.text('This is the Book.'), findsOneWidget);
  });

  testWidgets('shows an Asma picture and switches its meaning to Urdu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(initialAsmaNumber: 1));
    await tester.pumpAndSettle();

    expect(find.text("Asma'ul Husna 1"), findsOneWidget);
    expect(find.text('الرَّحْمَنُ'), findsOneWidget);
    expect(
      find.text(
        'The Beneficent\n\n'
        'He who wills goodness and mercy for all His creatures',
      ),
      findsOneWidget,
    );
    expect(find.text("Asma'ul Husna Picture"), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('asma_picture_urdu_toggle')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('asma_picture_urdu_toggle')));
    await tester.pump();

    expect(
      find.text(
        'نہایت مہربان\n\n'
        'یہ اللہ تعالیٰ کا صفاتی نام ہے۔ اللہ تعالیٰ نہایت مہربان ہے۔',
      ),
      findsOneWidget,
    );
    expect(find.text('The Beneficent'), findsNothing);
  });

  testWidgets('Urdu Quran mode changes layout and defaults to Urdu edition', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ayah_picture_urdu_toggle')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('ayah_picture_urdu_toggle')),
        matching: find.byType(CupertinoSwitch),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('القرآن ۱:۱'), findsOneWidget);
    expect(find.text('اللہ کے نام سے شروع'), findsOneWidget);
    expect(find.text(_urduEdition.englishName), findsOneWidget);
  });
}
