import 'package:flutter/material.dart';

class SettingsPalette {
  const SettingsPalette({
    required this.background,
    required this.card,
    required this.selectedCard,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.divider,
    required this.checkForeground,
    required this.selectedTitle,
    required this.selectedSubtitle,
  });

  static const light = SettingsPalette(
    background: Color(0xFFFFFEFA),
    card: Color.fromARGB(255, 239, 232, 217),
    selectedCard: Color.fromARGB(255, 99, 78, 37),
    title: Color(0xFF202624),
    subtitle: Color(0xFF46524F),
    accent: Color.fromARGB(255, 21, 126, 123),
    divider: Color(0xFFF2EEE5),
    checkForeground: Color(0xFFFFFEFA),
    selectedTitle: Color(0xFFFFFEFA),
    selectedSubtitle: Color(0xFFE9E1D3),
  );

  static const dark = SettingsPalette(
    background: Color(0xFF111212),
    card: Color(0xFF172021),
    selectedCard: Color.fromARGB(255, 67, 128, 122),
    title: Color(0xFFF6F6F2),
    subtitle: Color(0xFFC4C9C7),
    accent: Color(0xFFC0A35C),
    divider: Color(0xFF242727),
    checkForeground: Color(0xFF1B3030),
    selectedTitle: Color(0xFFF6F6F2),
    selectedSubtitle: Color(0xFFC4C9C7),
  );

  factory SettingsPalette.of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }

  final Color background;
  final Color card;
  final Color selectedCard;
  final Color title;
  final Color subtitle;
  final Color accent;
  final Color divider;
  final Color checkForeground;
  final Color selectedTitle;
  final Color selectedSubtitle;
}
