import 'dart:math' show cos, min, pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_qiblah_advanced/flutter_qiblah_advanced.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/app_home_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/utils/localized_font.dart';

enum QiblaTurnDirection { aligned, left, right }

@immutable
class QiblaAlignment {
  const QiblaAlignment({required this.direction, required this.degrees});

  factory QiblaAlignment.fromAngle(double qiblahAngle) {
    final angle = _normalizeAngle(qiblahAngle);
    if (angle <= 5 || angle >= 355) {
      return const QiblaAlignment(
        direction: QiblaTurnDirection.aligned,
        degrees: 0,
      );
    }

    if (angle <= 180) {
      return QiblaAlignment(
        direction: QiblaTurnDirection.left,
        degrees: angle.round(),
      );
    }

    return QiblaAlignment(
      direction: QiblaTurnDirection.right,
      degrees: (360 - angle).round(),
    );
  }

  final QiblaTurnDirection direction;
  final int degrees;

  bool get isAligned => direction == QiblaTurnDirection.aligned;
}

class QiblahCompass extends ConsumerStatefulWidget {
  const QiblahCompass({super.key});

  @override
  ConsumerState<QiblahCompass> createState() => _QiblahCompassState();
}

class _QiblahCompassState extends ConsumerState<QiblahCompass> {
  bool _checking = false;

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    setState(() => _checking = true);
    try {
      await ref
          .read(userLocationNotifierProvider.notifier)
          .updateUserLocation();
    } catch (_) {
      // Keep the permission prompt available when the platform request fails.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(userLocationNotifierProvider);
    final palette = SettingsPalette.of(context);

    if (location != null) return const _LiveQiblaCompass();
    return _LocationPermissionState(
      palette: palette,
      isChecking: _checking,
      onGetDirection: _requestPermission,
    );
  }
}

class _LocationPermissionState extends StatelessWidget {
  const _LocationPermissionState({
    required this.palette,
    required this.isChecking,
    required this.onGetDirection,
  });

  final SettingsPalette palette;
  final bool isChecking;
  final VoidCallback onGetDirection;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = min(
          (constraints.maxWidth - 48).clamp(180, 280),
          (constraints.maxHeight - 150).clamp(160, 280),
        ).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.35,
              child: QiblaCompassDial(
                size: diameter,
                heading: 0,
                qiblahAngle: 0,
                palette: palette,
                showQiblaMarker: false,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                context.loc.locationRequiredDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.subtitle,
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isChecking ? null : onGetDirection,
              icon: isChecking
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 20),
              label: Text(
                isChecking
                    ? context.loc.waitingForLocation
                    : context.loc.grantLocationPermission,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: palette.selectedCard,
                foregroundColor: palette.selectedTitle,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LiveQiblaCompass extends ConsumerStatefulWidget {
  const _LiveQiblaCompass();

  @override
  ConsumerState<_LiveQiblaCompass> createState() => _LiveQiblaCompassState();
}

class _LiveQiblaCompassState extends ConsumerState<_LiveQiblaCompass> {
  bool _wasAligned = false;
  QiblahDirection? _lastDirection;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isActive = ref.watch(homeNavigationIndexProvider) == 2;
    final shouldStream = isActive || _lastDirection == null;

    return StreamBuilder<QiblahDirection>(
      stream: shouldStream ? FlutterQiblah.qiblahStream : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _lastDirection = snapshot.data;
          if (!isActive && shouldStream) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }

        final direction = snapshot.data ?? _lastDirection;
        if (direction == null) {
          return Center(
            child: CircularProgressIndicator(color: palette.accent),
          );
        }

        final alignment = QiblaAlignment.fromAngle(direction.qiblah);
        if (alignment.isAligned && !_wasAligned) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            HapticFeedback.mediumImpact();
          });
        }
        _wasAligned = alignment.isAligned;

        final instruction = _instruction(context, alignment);
        return Semantics(
          liveRegion: true,
          label: instruction,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final widthBound = (constraints.maxWidth - 36).clamp(170, 380);
              final heightBound = (constraints.maxHeight - 92).clamp(160, 380);
              final diameter = min(widthBound, heightBound).toDouble();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QiblaCompassDial(
                    size: diameter,
                    heading: direction.direction,
                    qiblahAngle: direction.qiblah,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: alignment.isAligned
                          ? _compassGreen(context)
                          : palette.title,
                      fontFamily: localizedFontFamily(context),
                      fontSize: constraints.maxWidth < 360 ? 20 : 24,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(instruction, textAlign: TextAlign.center),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

String _instruction(BuildContext context, QiblaAlignment alignment) {
  return switch (alignment.direction) {
    QiblaTurnDirection.aligned => context.loc.qiblaFacing,
    QiblaTurnDirection.left => context.loc.qiblaTurnLeft(alignment.degrees),
    QiblaTurnDirection.right => context.loc.qiblaTurnRight(alignment.degrees),
  };
}

class QiblaCompassDial extends StatelessWidget {
  const QiblaCompassDial({
    super.key,
    required this.size,
    required this.heading,
    required this.qiblahAngle,
    required this.palette,
    this.showQiblaMarker = true,
  });

  final double size;
  final double heading;
  final double qiblahAngle;
  final SettingsPalette palette;
  final bool showQiblaMarker;

  @override
  Widget build(BuildContext context) {
    final tickColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF1DCA7)
        : palette.title;
    final compassColor = _compassGreen(context);
    final markerAngle = -_normalizeAngle(qiblahAngle) * pi / 180;
    final markerRadius = size / 2 - 17;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _CompassTicksPainter(color: tickColor),
          ),
          for (final cardinal in _cardinals)
            _CardinalLabel(
              size: size,
              heading: heading,
              cardinal: cardinal,
              color: palette.title,
            ),
          _CompassPointer(
            size: size * 0.23,
            color: compassColor,
            backgroundColor: palette.background,
          ),
          if (showQiblaMarker)
            Transform.translate(
              offset: Offset(
                sin(markerAngle) * markerRadius,
                -cos(markerAngle) * markerRadius,
              ),
              child: Container(
                width: size * 0.17,
                height: size * 0.17,
                decoration: BoxDecoration(
                  color: compassColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  FlutterIslamicIcons.solidKaaba,
                  color: tickColor,
                  size: size * 0.075,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Cardinal {
  const _Cardinal(this.label, this.bearing);

  final String label;
  final double bearing;
}

const _cardinals = [
  _Cardinal('N', 0),
  _Cardinal('E', 90),
  _Cardinal('S', 180),
  _Cardinal('W', 270),
];

class _CardinalLabel extends StatelessWidget {
  const _CardinalLabel({
    required this.size,
    required this.heading,
    required this.cardinal,
    required this.color,
  });

  final double size;
  final double heading;
  final _Cardinal cardinal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final angle = _normalizeAngle(cardinal.bearing - heading) * pi / 180;
    final radius = size * 0.315;
    final labelSize = size * 0.09;

    return Transform.translate(
      offset: Offset(sin(angle) * radius, -cos(angle) * radius),
      child: SizedBox.square(
        dimension: labelSize,
        child: Center(
          child: Text(
            cardinal.label,
            style: TextStyle(
              color: color,
              fontFamily: 'GoogleSans',
              fontSize: size * 0.052,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPointer extends StatelessWidget {
  const _CompassPointer({
    required this.size,
    required this.color,
    required this.backgroundColor,
  });

  final double size;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CompassPointerPainter(
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _CompassTicksPainter extends CustomPainter {
  const _CompassTicksPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide / 2 - 17;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 72; index++) {
      final angle = index * 5 * pi / 180;
      final tickLength = index % 6 == 0 ? 15.0 : 10.0;
      final outer = Offset(
        center.dx + sin(angle) * outerRadius,
        center.dy - cos(angle) * outerRadius,
      );
      final inner = Offset(
        center.dx + sin(angle) * (outerRadius - tickLength),
        center.dy - cos(angle) * (outerRadius - tickLength),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(_CompassTicksPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CompassPointerPainter extends CustomPainter {
  const _CompassPointerPainter({
    required this.color,
    required this.backgroundColor,
  });

  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.width * 0.31;
    final circleCenter = Offset(center.dx, center.dy + size.height * 0.12);
    final paint = Paint()..color = color;

    final pointer = Path()
      ..moveTo(center.dx, size.height * 0.02)
      ..lineTo(center.dx + outerRadius * 0.62, circleCenter.dy)
      ..lineTo(center.dx - outerRadius * 0.62, circleCenter.dy)
      ..close();
    canvas.drawPath(pointer, paint);
    canvas.drawCircle(circleCenter, outerRadius, paint);
    canvas.drawCircle(
      circleCenter,
      outerRadius * 0.61,
      Paint()..color = backgroundColor,
    );
  }

  @override
  bool shouldRepaint(_CompassPointerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}

double _normalizeAngle(double angle) => ((angle % 360) + 360) % 360;

Color _compassGreen(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
    ? const Color(0xFF07524E)
    : const Color.fromARGB(255, 67, 128, 122);
