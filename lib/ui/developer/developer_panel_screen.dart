import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/services/app_update_service.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';

/// Debug-only tools for testing app states that are hard to reach naturally.
class DeveloperPanelScreen extends ConsumerWidget {
  const DeveloperPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final showAllCards = ref.watch(appSettingsNotifierProvider).showAllCards;
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
          SettingsCard(
            icon: Icons.preview_outlined,
            title: 'Show All Cards',
            subtitle: 'Display Friday, Eid & Ramadan cards',
            palette: palette,
            switchValue: showAllCards,
            onSwitchChanged: ref
                .read(appSettingsNotifierProvider.notifier)
                .toggleShowAllCards,
          ),
        ],
      ),
    );
  }
}
