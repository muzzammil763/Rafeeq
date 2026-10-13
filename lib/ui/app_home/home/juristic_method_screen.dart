import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

class JuristicMethodScreen extends ConsumerWidget {
  const JuristicMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(
      prayerTimesSettingsNotifierProvider.select(
        (settings) => settings.asrCalculationMethod,
      ),
    );

    return SettingsPickerScaffold(
      title: context.loc.juristicMethod,
      itemCount: AsrCalculationMethod.values.length,
      itemBuilder: (context, index, palette) {
        final method = AsrCalculationMethod.values[index];
        return SettingsPickerTile(
          title: method.getLabel(context),
          selected: method == selectedMethod,
          palette: palette,
          onTap: () {
            ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setAsrCalculationMethod(method);
            ref
                .read(analyticsServiceProvider)
                .logSettingsJuristicMethodChanged(method.name);
          },
        );
      },
    );
  }
}
