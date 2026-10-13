import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localizations.dart';

void main() {
  Future<void> pumpAbout(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.about,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Rafeeq story and commitment in English', (
    tester,
  ) async {
    await pumpAbout(tester, const Locale('en'));

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Rafeeq'), findsOneWidget);
    expect(find.text('Your Muslim Companion'), findsOneWidget);
    expect(find.text('How Rafeeq began'), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);

    final story = tester
        .widgetList<Text>(find.byType(Text))
        .firstWhere(
          (text) =>
              text.textSpan?.toPlainText().contains('Muzamil Ghafoor') ?? false,
        );
    final storySpans = (story.textSpan as TextSpan).children!.cast<TextSpan>();
    expect(story.textSpan?.toPlainText(), isNot(contains('Abdushakoor')));
    expect(
      storySpans
          .firstWhere((span) => span.text == 'Muzamil Ghafoor')
          .style
          ?.fontWeight,
      FontWeight.w700,
    );
    expect(
      storySpans
          .firstWhere((span) => span.text == 'Muzamil Ghafoor')
          .recognizer,
      isNotNull,
    );
    final localizations = AppLocalizations.of(
      tester.element(find.byType(Scaffold)),
    )!;
    expect(localizations.aboutUmmahBody, contains('Prophet Muhammad (PBUH)'));

    final closing = find.textContaining('Built by Muslims, for Muslims');
    await tester.scrollUntilVisible(
      closing,
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(closing, findsOneWidget);

    final updatesButton = find.text('Join WhatsApp Channel');
    final communityButton = find.text('Join Community Group');
    await tester.scrollUntilVisible(
      updatesButton,
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Stay connected with Rafeeq'), findsOneWidget);
    expect(updatesButton, findsOneWidget);
    expect(communityButton, findsNothing);
    expect(find.text('Rafeeq - Updates'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('localizes the About page in Urdu', (tester) async {
    await pumpAbout(tester, const Locale('ur'));

    expect(find.text('کے بارے میں'), findsOneWidget);
    expect(find.text('رفیق'), findsOneWidget);
    expect(find.text('آپ کا مسلم ساتھی'), findsOneWidget);
    expect(find.text('رفیق کا آغاز'), findsOneWidget);
    final localizations = AppLocalizations.of(
      tester.element(find.byType(Scaffold)),
    )!;
    expect(
      localizations.aboutUmmahBody,
      contains('حضرت محمد صلی اللہ علیہ وسلم'),
    );

    final closing = find.textContaining('مسلمانوں کے ہاتھوں، مسلمانوں کے لیے');
    await tester.scrollUntilVisible(
      closing,
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(closing, findsOneWidget);

    final communityButton = find.text('کمیونٹی گروپ جوائن کریں');
    final updatesButton = find.text('واٹس ایپ چینل جوائن کریں');
    await tester.scrollUntilVisible(
      updatesButton,
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('رفیق سے جڑے رہیں'), findsOneWidget);
    expect(updatesButton, findsOneWidget);
    expect(communityButton, findsNothing);
    expect(find.text('Rafeeq - Updates'), findsOneWidget);
  });
}
