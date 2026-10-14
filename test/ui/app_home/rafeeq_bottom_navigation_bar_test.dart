import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/rafeeq_bottom_navigation_bar.dart';

void main() {
  testWidgets('home tab uses the Rafeeq calligraphy as its icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RafeeqBottomNavigationBar(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            labels: const ['Rafeeq', "Qur'an", 'Qibla', 'Settings'],
          ),
        ),
      ),
    );

    final calligraphy = find.byKey(const Key('nav-home-calligraphy'));
    expect(calligraphy, findsOneWidget);
    expect(tester.widget(calligraphy), isA<SvgPicture>());
    expect(find.byIcon(CupertinoIcons.house_fill), findsNothing);
    expect(find.byIcon(CupertinoIcons.home), findsNothing);
  });
}
