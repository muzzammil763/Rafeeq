import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/widgets/scrollable_column.dart';

void main() {
  Widget subject({required double contentHeight}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: ScrollableColumn(
            physics: const ClampingScrollPhysics(),
            children: [SizedBox(width: double.infinity, height: contentHeight)],
          ),
        ),
      ),
    );
  }

  testWidgets('does not scroll when its content fits the page', (tester) async {
    await tester.pumpWidget(subject(contentHeight: 200));

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, 0);
    expect(scrollable.position.physics, isA<ClampingScrollPhysics>());

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, 0);
  });

  testWidgets('scrolls with clamping physics when content overflows', (
    tester,
  ) async {
    await tester.pumpWidget(subject(contentHeight: 800));

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(scrollable.position.physics, isA<ClampingScrollPhysics>());

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
  });
}
