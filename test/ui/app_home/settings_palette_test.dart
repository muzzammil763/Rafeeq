import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

void main() {
  test('palette text colors meet readable contrast targets', () {
    for (final (name, palette) in [
      ('light', SettingsPalette.light),
      ('dark', SettingsPalette.dark),
    ]) {
      void expectContrast(String pair, Color a, Color b, double minimum) {
        expect(
          _contrast(a, b),
          greaterThanOrEqualTo(minimum),
          reason: '$name $pair',
        );
      }

      expectContrast('title on card', palette.title, palette.card, 4.5);
      expectContrast('subtitle on card', palette.subtitle, palette.card, 4.5);
      expectContrast(
        'title on selected card',
        palette.selectedTitle,
        palette.selectedCard,
        4.5,
      );
      expectContrast(
        'subtitle on selected card',
        palette.selectedSubtitle,
        palette.selectedCard,
        4.5,
      );
      expectContrast('accent on card', palette.accent, palette.card, 3);
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
