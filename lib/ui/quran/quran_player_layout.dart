import 'package:flutter/widgets.dart';

const double quranMiniPlayerContentHeight = 56;
const double standardScreenBottomPadding = 60;
const double screenBottomPaddingWithPlayer = 112;
const double navigationScreenBottomPadding = 128;
const double navigationScreenBottomPaddingWithPlayer = 12;

class QuranPlayerVisibility extends InheritedWidget {
  const QuranPlayerVisibility({
    super.key,
    required this.isVisible,
    required super.child,
  });

  final bool isVisible;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<QuranPlayerVisibility>()
          ?.isVisible ??
      false;

  @override
  bool updateShouldNotify(QuranPlayerVisibility oldWidget) =>
      isVisible != oldWidget.isVisible;
}

double quranPlayerAwareBottomPadding(
  BuildContext context, {
  required bool playerVisible,
  double spacing = standardScreenBottomPadding,
}) {
  return playerVisible ? screenBottomPaddingWithPlayer : spacing;
}

double navigationScreenPlayerAwareBottomPadding({
  required bool playerVisible,
}) => playerVisible
    ? navigationScreenBottomPaddingWithPlayer
    : navigationScreenBottomPadding;
