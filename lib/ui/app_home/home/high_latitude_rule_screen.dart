import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

class HighLatitudeRuleScreen extends ConsumerWidget {
  const HighLatitudeRuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRule = ref.watch(
      prayerTimesSettingsNotifierProvider.select(
        (settings) => settings.highLatitudeAdjustment,
      ),
    );

    return SettingsPickerScaffold(
      title: context.loc.highLatitudeRule,
      itemCount: HLAdjustment.values.length,
      itemBuilder: (context, index, palette) {
        final rule = HLAdjustment.values[index];
        return SettingsPickerTile(
          title: rule.getLabel(context),
          selected: rule == selectedRule,
          palette: palette,
          onTap: () {
            ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setHighLatitudeAdjustment(rule);
            ref
                .read(analyticsServiceProvider)
                .logSettingsHighLatitudeRuleChanged(rule.name);
          },
        );
      },
    );
  }
}
