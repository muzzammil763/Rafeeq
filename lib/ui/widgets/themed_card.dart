import 'package:flutter/material.dart';
import 'package:rafeeq/core/app_theme.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurRadius;
  final Offset shadowOffset;
  final double shadowAlpha;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showShadow;

  const ThemedCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blurRadius = 8,
    this.shadowOffset = const Offset(0, 3),
    this.shadowAlpha = 0.12,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.mainTheme;
    return Container(
      margin: margin,
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
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowAlpha),
                  blurRadius: blurRadius,
                  offset: shadowOffset,
                ),
              ]
            : null,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
