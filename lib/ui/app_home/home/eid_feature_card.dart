import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';

enum EidType { eidUlFitr, eidUlAdha, none }

class EidFeatureCard extends HookConsumerWidget {
  final bool isPreview;
  final EidType? previewEidType;

  const EidFeatureCard({
    super.key,
    this.isPreview = false,
    this.previewEidType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correctedDateTime = ref.watch(correctedDateTimeProvider);
    final hijri = HijriCalendar.fromDate(correctedDateTime);

    // Determine Eid type
    EidType eidType;
    if (isPreview && previewEidType != null) {
      eidType = previewEidType!;
    } else if (!isPreview) {
      // Check for Eid-ul-Fitr: 1 Shawwal (month 10, day 1)
      if (hijri.hMonth == 10 && hijri.hDay == 1) {
        eidType = EidType.eidUlFitr;
      }
      // Check for Eid-ul-Adha: 10 Dhul Hijjah (month 12, day 10)
      else if (hijri.hMonth == 12 && hijri.hDay == 10) {
        eidType = EidType.eidUlAdha;
      } else {
        eidType = EidType.none;
      }
    } else {
      // Default to Fitr in preview without type specified
      eidType = EidType.eidUlFitr;
    }

    // Don't show if not Eid day (and not in preview)
    if (eidType == EidType.none) {
      return const SizedBox.shrink();
    }

    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    // Get content based on Eid type
    final greeting = eidType == EidType.eidUlFitr
        ? context.loc.eidUlFitrGreeting
        : context.loc.eidUlAdhaGreeting;
    final eidName = eidType == EidType.eidUlFitr
        ? context.loc.eidUlFitr
        : context.loc.eidUlAdha;
    final dateText = eidType == EidType.eidUlFitr
        ? context.loc.oneShawwal
        : context.loc.tenDhulHijjah;
    final prayerMessage = eidType == EidType.eidUlFitr
        ? context.loc.prayEidUlFitrToday
        : context.loc.prayEidUlAdhaToday;
    final mainActionLabel = eidType == EidType.eidUlFitr
        ? context.loc.takbeer
        : context.loc.sacrifice;
    final mainActionValue = eidType == EidType.eidUlFitr
        ? context.loc.takbeerText
        : context.loc.qurbaniDay;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              right: -16,
              top: -16,
              child: Icon(
                Icons.celebration,
                size: 120,
                color: Colors.white.withValues(alpha: 0.025),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 32,
                          color: colorScheme.onSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            greeting,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondary,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Eid Greeting Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      prayerMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: colorScheme.onSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Eid Info Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mainActionLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  mainActionValue,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.eidDay,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  dateText,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                        fontFamily: isUrdu
                                            ? 'Jameel Noori Nastaleeq'
                                            : 'GoogleSans',
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.typeLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  eidName,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
