import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/app_theme.dart';

void main() {
  group('AppTheme Constants', () {
    test('Verify kSubtleBoxShadow properties', () {
      expect(kSubtleBoxShadow.length, 1);
      final shadow = kSubtleBoxShadow[0];
      expect(shadow.color, const Color(0x0D000000));
      expect(shadow.blurRadius, 4.0);
      expect(shadow.offset, const Offset(0, 2));
    });
  });
}
