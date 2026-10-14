import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/services/app_update_service.dart';
import 'package:rafeeq/ui/app_home/home/home_event_dialog.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';

/// Debug-only tools for testing app states that are hard to reach naturally.
class DeveloperPanelScreen extends ConsumerWidget {
  const DeveloperPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final previews = ref.watch(appSettingsNotifierProvider).eventPreviews;

    // Turning a preview on clears its "seen" mark, so home shows the dialog
    // again even if it was closed before.
    Future<void> setPreview(HomeEvent event, bool enabled) async {
      if (enabled) await ref.read(homeEventDialogTrackerProvider).reset(event);
      ref
          .read(appSettingsNotifierProvider.notifier)
          .setEventPreview(event, enabled);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: 'Developer Panel', palette: palette),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SettingsCard(
            icon: Icons.bug_report_outlined,
            title: 'Test Update Dialog',
            subtitle: 'Show the update ready dialog',
            palette: palette,
            onTap: () => AppUpdateService.showUpdateReadyDialog(context),
          ),
          const SizedBox(height: 8),
          SettingsCard(
            icon: Icons.data_object_rounded,
            title: 'Shared Preferences',
            subtitle: 'View and manage local keys',
            palette: palette,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.developerSharedPrefs),
          ),
          const SizedBox(height: 8),
          for (final (event, icon, title) in const [
            (HomeEvent.friday, Icons.mosque_outlined, 'Friday'),
            (HomeEvent.ramadan, Icons.nightlight_outlined, 'Ramadan'),
            (HomeEvent.eid, Icons.celebration_outlined, 'Eid'),
          ]) ...[
            SettingsCard(
              key: Key('event-preview-${event.name}'),
              icon: icon,
              title: 'Preview $title Dialog',
              subtitle: 'Show the $title dialog on home as if it were today',
              palette: palette,
              switchValue: previews.contains(event),
              onSwitchChanged: (enabled) => setPreview(event, enabled),
            ),
            if (event != HomeEvent.eid) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
