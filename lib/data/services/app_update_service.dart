import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/log.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';

class AppUpdateService {
  /// Checks for updates and handles the flexible update flow.
  /// Call this method in initState of your main screen.
  /// Only runs in release mode to avoid crashes in debug builds.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (!kReleaseMode) return; // Skip update check in debug/profile mode
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      Logger.log("Update info: ${info.updateAvailability}");

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Start flexible update
        await InAppUpdate.startFlexibleUpdate();

        // Once the update is downloaded, show a modal sheet to complete the update.
        if (context.mounted) {
          showUpdateReadyDialog(context);
        }
      }
    } catch (e) {
      Logger.log("Failed to check for update: $e");
    }
  }

  static void showUpdateReadyDialog(BuildContext context) {
    final theme = context.mainTheme;
    final palette = SettingsPalette.of(context);
    AppInfoDialog.show(
      context,
      title: context.loc.updateReady,
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        Center(
          child: Text(
            context.loc.updateDownloadedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: palette.title, height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.title,
                  side: BorderSide(color: palette.title.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.loc.later,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (kReleaseMode) {
                    InAppUpdate.completeFlexibleUpdate().catchError((e) {
                      Logger.log("Failed to complete update: $e");
                    });
                  } else {
                    Logger.log(
                      "Mocking complete flexible update in debug mode",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: palette.card,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.loc.installNow,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: palette.card,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
