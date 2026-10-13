import 'package:flutter/material.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final titleColor = SettingsPalette.of(context).title;
    return OutlinedButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: titleColor,
        side: BorderSide(color: titleColor.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        context.loc.cancel,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }
}
