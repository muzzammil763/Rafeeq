import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/data/models/hijri_correction.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/utils/hijri_date_formatter.dart';

final playStoreUri = Uri.parse(
  'https://play.google.com/store/apps/details?id=com.satechdev.rafeeqapp',
);

final feedbackFormUri = Uri.parse('https://forms.gle/cDLne2RtGvfmqrJn9');

final repositoryUri = Uri.parse('https://github.com/muzzammil763/Rafeeq');

final reportIssueUri = Uri.parse(
  'https://github.com/muzzammil763/Rafeeq/issues/new',
);

void showHijriCorrectionModalSheet(BuildContext context) {
  final theme = context.mainTheme;

  AppInfoDialog.show(
    context,
    title: context.loc.hijriCorrection,
    iconAsset: 'assets/logo.svg',
    gradientColors: [theme.secondaryColor, theme.primaryColor],
    contentWidgets: [
      Consumer(
        builder: (context, ref, child) {
          final hijriCorrection = ref.watch(
            appSettingsNotifierProvider.select((e) => e.hijriCorrection),
          );
          final analyticsService = ref.read(analyticsServiceProvider);
          final colorScheme = Theme.of(context).colorScheme;
          final today = DateTime.now();
          final correctionLabels = {
            HijriCorrection.minus2Days: '-2',
            HijriCorrection.minus1Day: '-1',
            HijriCorrection.none: context.loc.auto,
            HijriCorrection.plus1Day: '+1',
            HijriCorrection.plus2Days: '+2',
          };

          return Column(
            children: HijriCorrection.values.map((correction) {
              final selected = correction == hijriCorrection;
              final adjustedDate = correction.getAdjustedDate(today);
              final hijriDate = HijriCalendar.fromDate(adjustedDate);
              final hijriDateString = HijriDateFormatter.formatShort(
                context,
                hijriDate,
              );

              return GestureDetector(
                onTap: () {
                  analyticsService.logSettingsHijriCorrectionChanged(
                    correction.name,
                  );
                  ref
                      .read(appSettingsNotifierProvider.notifier)
                      .setHijriCorrection(correction);
                  di.appRouter.maybePop();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.1),
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (selected)
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          correctionLabels[correction] ?? '',
                          maxFontSize: 20,
                          minFontSize: 12,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hijriDateString,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? colorScheme.primary
                                    : theme.textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              correction.getLabel(context),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSecondary.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: colorScheme.primary,
                          child: Icon(
                            CupertinoIcons.check_mark_circled,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}
