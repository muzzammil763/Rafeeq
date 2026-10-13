import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:toastification/toastification.dart';

const rafeeqToastKey = ValueKey('rafeeq-toast');

enum RafeeqToastType { success, info, warning, error }

void showRafeeqToast(
  BuildContext context,
  String message, {
  RafeeqToastType type = RafeeqToastType.success,
}) {
  final palette = SettingsPalette.of(context);

  toastification.dismissAll(delayForAnimation: false);
  toastification.show(
    context: context,
    type: switch (type) {
      RafeeqToastType.success => ToastificationType.success,
      RafeeqToastType.info => ToastificationType.info,
      RafeeqToastType.warning => ToastificationType.warning,
      RafeeqToastType.error => ToastificationType.error,
    },
    style: ToastificationStyle.minimal,
    alignment: Alignment.topCenter,
    title: Text(message, key: rafeeqToastKey),
    primaryColor: palette.accent,
    backgroundColor: palette.card,
    foregroundColor: palette.title,
    borderSide: BorderSide(color: palette.divider, width: 1.5),
    autoCloseDuration: const Duration(seconds: 2),
  );
}
