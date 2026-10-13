import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';

class SixteenLineQuranCard extends ConsumerWidget {
  const SixteenLineQuranCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    const iconSize = 40.0;
    const padding = EdgeInsets.all(12);
    const titleFontSize = 15.0;
    const subtitleFontSize = 11.0;
    const iconSpacing = 12.0;
    const borderRadius = 16.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          di.appRouter.pushNamed(AppRoutes.sixteenLineQuranJuzIndex);
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.primaryColor, theme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: theme.textColor.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      FlutterIslamicIcons.quran2,
                      size: iconSize,
                      color: theme.textColor,
                    ),
                    SizedBox(height: iconSpacing),
                    Text(
                      context.loc.sixteenLineQuran,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.loc.sixteenLineQuranSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSecondary.withValues(alpha: 0.65),
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: isRtl ? null : 8,
              left: isRtl ? 8 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.secondaryColor, theme.primaryColor],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(16),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.textColor.withValues(alpha: 0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(
                  isRtl ? Icons.arrow_back : Icons.arrow_forward,
                  color: theme.textColor.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
