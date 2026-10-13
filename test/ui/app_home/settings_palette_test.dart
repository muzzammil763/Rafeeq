import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

void main() {
  test('palette text colors meet readable contrast targets', () {
    for (final palette in [SettingsPalette.light, SettingsPalette.dark]) {
      expect(_contrast(palette.title, palette.card), greaterThanOrEqualTo(4.5));
      expect(
        _contrast(palette.subtitle, palette.card),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(palette.selectedTitle, palette.selectedCard),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(palette.selectedSubtitle, palette.selectedCard),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrast(palette.accent, palette.card), greaterThanOrEqualTo(3));
    }
  });
}

double _contrast(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
