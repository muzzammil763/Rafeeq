import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/models/hijri_correction.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/utils/hijri_date_formatter.dart';

class HijriCorrectionScreen extends ConsumerWidget {
  const HijriCorrectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCorrection = ref.watch(
      appSettingsNotifierProvider.select(
        (settings) => settings.hijriCorrection,
      ),
    );
    final today = DateTime.now();

    return SettingsPickerScaffold(
      title: context.loc.hijriCorrection,
      itemCount: HijriCorrection.values.length,
      itemBuilder: (context, index, palette) {
        final correction = HijriCorrection.values[index];
        final hijriDate = HijriCalendar.fromDate(
          correction.getAdjustedDate(today),
        );

        return SettingsPickerTile(
          title: correction.getLabel(context),
          subtitle: HijriDateFormatter.formatShort(context, hijriDate),
          selected: correction == selectedCorrection,
          palette: palette,
          onTap: () {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setHijriCorrection(correction);
            ref
                .read(analyticsServiceProvider)
                .logSettingsHijriCorrectionChanged(correction.name);
          },
        );
      },
    );
  }
}
