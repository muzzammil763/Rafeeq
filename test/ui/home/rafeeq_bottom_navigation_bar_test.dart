import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/rafeeq_bottom_navigation_bar.dart';

void main() {
  testWidgets('renders four destinations and reports selection', (
    tester,
  ) async {
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RafeeqBottomNavigationBar(
            currentIndex: 0,
            onDestinationSelected: (index) => selectedIndex = index,
            labels: const ['Rafeeq', "Qur'an", 'Qibla', 'Settings'],
          ),
        ),
      ),
    );

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Rafeeq'), findsOneWidget);
    expect(find.text("Qur'an"), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Qibla'));
    await tester.pump();

    expect(selectedIndex, 2);
  });
}
