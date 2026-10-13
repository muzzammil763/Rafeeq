import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({
    super.key,
    required this.title,
    required this.iconAsset,
    required this.contentWidgets,
    this.useImage = false,
  });

  final String title;
  final String iconAsset;
  final List<Widget> contentWidgets;
  final bool useImage;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String iconAsset,
    required List<Widget> contentWidgets,
    List<Color>? gradientColors,
    bool useImage = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AppInfoDialog(
          title: title,
          iconAsset: iconAsset,
          contentWidgets: contentWidgets,
          useImage: useImage,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
              child: Row(
                children: [
                  _DialogAsset(asset: iconAsset, useImage: useImage),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                        fontSize: 17,
                        height: isUrdu ? 1.45 : 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: palette.selectedTitle,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: palette.title.withValues(alpha: 0.12)),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: contentWidgets,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogAsset extends StatelessWidget {
  const _DialogAsset({required this.asset, required this.useImage});
  final String asset;
  final bool useImage;

  @override
  Widget build(BuildContext context) {
    final color = SettingsPalette.of(context).title;
    final resolvedAsset = asset == 'assets/logo.svg'
        ? 'assets/logo.png'
        : asset;
    if (useImage || resolvedAsset.endsWith('.png')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          resolvedAsset,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      );
    }
    return SvgPicture.asset(
      resolvedAsset,
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
