import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

class CalculationMethodScreen extends ConsumerWidget {
  const CalculationMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(
      prayerTimesSettingsNotifierProvider.select(
        (settings) => settings.prayerCalcMethod,
      ),
    );

    return SettingsPickerScaffold(
      title: context.loc.calculationMethod,
      itemCount: PrayerCalcMethod.values.length,
      itemBuilder: (context, index, palette) {
        final method = PrayerCalcMethod.values[index];
        return SettingsPickerTile(
          title: method.getLabel(context),
          selected: method == selectedMethod,
          palette: palette,
          onTap: () {
            ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setPrayerCalcMethod(method);
            ref
                .read(analyticsServiceProvider)
                .logSettingsCalculationMethodChanged(method.name);
          },
        );
      },
    );
  }
}
