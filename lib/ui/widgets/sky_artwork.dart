import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/art_painter.dart';

/// Where the sun or moon is in the sky at [time].
class SkyPhase {
  const SkyPhase({
    required this.isDay,
    required this.progress,
    required this.time,
  });

  /// Works out the phase from the day's sunrise and sunset. Missing times fall
  /// back to 6 AM and 6 PM so the sky still reads sensibly without a location.
  factory SkyPhase.at(
    DateTime now, {
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? previousSunset,
    DateTime? nextSunrise,
  }) {
    final midnight = DateTime(now.year, now.month, now.day);
    final dawn = sunrise ?? midnight.add(const Duration(hours: 6));
    final dusk = sunset ?? midnight.add(const Duration(hours: 18));
    if (!now.isBefore(dawn) && now.isBefore(dusk)) {
      return SkyPhase(
        isDay: true,
        progress: _fraction(now, dawn, dusk),
        time: now,
      );
    }
    final (start, end) = now.isBefore(dawn)
        ? (previousSunset ?? dusk.subtract(const Duration(days: 1)), dawn)
        : (dusk, nextSunrise ?? dawn.add(const Duration(days: 1)));
    return SkyPhase(
      isDay: false,
      progress: _fraction(now, start, end),
      time: now,
    );
  }

  final bool isDay;

  /// Runs from 0 at sunrise (or sunset at night) to 1 at sunset (or the next
  /// sunrise).
  final double progress;
  final DateTime time;

  /// Height of the sun from -1 (midnight) through 0 (horizon) to 1 (noon).
  double get elevation => (isDay ? 1 : -1) * math.sin(math.pi * progress);

  /// The night the stars belong to, so they stay put from dusk until dawn.
  int get nightSeed {
    final night = !isDay && time.hour < 12
        ? time.subtract(const Duration(days: 1))
        : time;
    return night.year * 10000 + night.month * 100 + night.day;
  }

  static double _fraction(DateTime now, DateTime start, DateTime end) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
  }
}

/// A live sky: the sun travels its arc through the day, the sky warms at
/// sunrise and sunset, and at night the moon rises in its real phase among
/// the stars.
class SkyArtwork extends StatelessWidget {
  const SkyArtwork({super.key, required this.phase});

  final SkyPhase phase;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkyPainter(ArtColors.of(SettingsPalette.of(context)), phase),
      size: Size.infinite,
    );
  }
}

class _SkyPainter extends ArtPainter {
  const _SkyPainter(super.colors, this.phase);

  final SkyPhase phase;

  static const _lightDay = [Color(0xFFC8EDF7), Color(0xFFE6F6FA)];
  static const _lightTwilight = [Color(0xFFF6DCC6), Color(0xFFFCEBD3)];
  static const _lightNight = [Color(0xFFD6DAEE), Color(0xFFE9E7F3)];
  static const _darkDay = [Color(0xFF193438), Color(0xFF214448)];
  static const _darkTwilight = [Color(0xFF3B2B36), Color(0xFF4A3628)];
  static const _darkNight = [Color(0xFF0E1829), Color(0xFF182235)];

  /// A known new moon (6 Jan 2000, 18:14 UTC) and the synodic month length.
  static final _newMoon = DateTime.utc(2000, 1, 6, 18, 14);
  static const _synodicDays = 29.530588;

  /// The sun and moon peak below the prayer labels at the top of the card.
  static const _peak = 78.0;
  static const _horizonInset = 26.0;

  double get _dayness =>
      phase.elevation > 0 ? _smooth(phase.elevation / .35) : 0;
  double get _nightness =>
      phase.elevation < 0 ? _smooth(-phase.elevation / .3) : 0;

  static double _smooth(double x) {
    final c = x.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  List<Color> get _skyColors {
    final day = dark ? _darkDay : _lightDay;
    final twilight = dark ? _darkTwilight : _lightTwilight;
    final night = dark ? _darkNight : _lightNight;
    final target = phase.elevation >= 0 ? day : night;
    final t = phase.elevation >= 0 ? _dayness : _nightness;
    return [for (var i = 0; i < 2; i++) Color.lerp(twilight[i], target[i], t)!];
  }

  Offset _arcPoint(Size size, double t) {
    final horizon = size.height - _horizonInset;
    return Offset(
      lerpDouble(size.width * .5, size.width - 26, t)!,
      horizon - math.sin(math.pi * t) * (horizon - _peak),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sky = _skyColors;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ).createShader(rect),
    );

    _stars(canvas, size);
    _clouds(canvas, size, sky.last);
    _track(canvas, size);
    if (phase.isDay) {
      _sun(canvas, size);
    } else {
      _moon(canvas, size);
    }
    _ground(canvas, size, sky.last);
  }

  // Painting happens at the card's real size, not the fixed art canvas.
  @override
  void draw(Canvas canvas) {}

  void _stars(Canvas canvas, Size size) {
    if (_nightness == 0) return;
    final random = math.Random(phase.nightSeed);
    final color = dark ? goldLight : palette.subtitle;
    for (var i = 0; i < 28; i++) {
      final position = Offset(
        random.nextDouble() * size.width,
        8 + random.nextDouble() * (size.height - 60),
      );
      final radius = .6 + random.nextDouble() * 1.1;
      final alpha = (.3 + random.nextDouble() * .6) * _nightness;
      if (radius > 1.45) {
        sparkle(canvas, position, radius * 2.6, color.withValues(alpha: alpha));
      } else {
        canvas.drawCircle(
          position,
          radius,
          fill(color.withValues(alpha: alpha)),
        );
      }
    }
  }

  void _clouds(Canvas canvas, Size size, Color horizonColor) {
    final random = math.Random(
      phase.time.year * 400 + phase.time.month * 32 + phase.time.day,
    );
    final minutes = phase.time.hour * 60 + phase.time.minute;
    final base = dark
        ? Color.lerp(horizonColor, Colors.white, .14)!
        : Colors.white;
    final alpha = .35 + .5 * _dayness;
    for (var i = 0; i < 3; i++) {
      final start = random.nextDouble() * size.width;
      final speed = .25 + random.nextDouble() * .25;
      final span = size.width + 80;
      final x = (start + minutes * speed) % span - 40;
      final y = 66 + random.nextDouble() * 46;
      final scale = .7 + random.nextDouble() * .4;
      cloud(canvas, Offset(x, y), scale, base.withValues(alpha: alpha));
    }
  }

  /// The dotted path across the sky, solid where the sun or moon has been.
  void _track(Canvas canvas, Size size) {
    final dots = fill(palette.title.withValues(alpha: .16));
    const steps = 36;
    for (var i = 0; i <= steps; i++) {
      canvas.drawCircle(_arcPoint(size, i / steps), 1.1, dots);
    }
    final travelled = Path();
    final end = (phase.progress * steps).ceil();
    for (var i = 0; i <= end; i++) {
      final t = math.min(i / steps, phase.progress);
      final p = _arcPoint(size, t);
      i == 0 ? travelled.moveTo(p.dx, p.dy) : travelled.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      travelled,
      stroke(
        (phase.isDay ? gold : palette.subtitle).withValues(alpha: .5),
        1.6,
      ),
    );
  }

  void _sun(Canvas canvas, Size size) {
    final center = _arcPoint(size, phase.progress);
    // The sun warms towards orange as it nears the horizon.
    final warmth = 1 - _dayness;
    final color = Color.lerp(gold, Colors.deepOrange, .4 * warmth)!;
    glow(canvas, center, 58, color);
    canvas.drawCircle(center, 13, fill(color));
    canvas.drawCircle(
      center - const Offset(3, 3),
      6,
      fill(Color.lerp(goldLight, Colors.white, .3)!.withValues(alpha: .55)),
    );
  }

  void _moon(Canvas canvas, Size size) {
    final center = _arcPoint(size, phase.progress);
    const radius = 11.0;
    final light = dark ? Color.lerp(goldLight, Colors.white, .5)! : gold;
    glow(canvas, center, 40, light);
    canvas.drawCircle(
      center,
      radius,
      fill(palette.title.withValues(alpha: dark ? .12 : .08)),
    );

    final days =
        phase.time.toUtc().difference(_newMoon).inMinutes / 1440 % _synodicDays;
    final cycle = days / _synodicDays;
    final waxing = cycle < .5;
    // 1 at new moon, -1 at full moon: how far the terminator bulges.
    final bulge = math.cos(2 * math.pi * cycle);
    final top = center - const Offset(0, radius);
    final bottom = center + const Offset(0, radius);
    final lit = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(
        bottom,
        radius: const Radius.circular(radius),
        clockwise: waxing,
      )
      ..arcToPoint(
        top,
        radius: Radius.elliptical(math.max(bulge.abs() * radius, .01), radius),
        clockwise: waxing ? bulge < 0 : bulge > 0,
      )
      ..close();
    canvas.drawPath(lit, fill(light));
  }

  void _ground(Canvas canvas, Size size, Color horizonColor) {
    final w = size.width;
    final h = size.height;
    hills(
      canvas,
      [
        Offset(0, h - 18),
        Offset(w * .25, h - 30),
        Offset(w * .5, h - 20),
        Offset(w * .75, h - 34),
        Offset(w, h - 24),
      ],
      Color.lerp(horizonColor, teal, dark ? .3 : .22)!,
      bottom: h,
    );

    final silhouette = Color.lerp(horizonColor, tealDark, dark ? .75 : .55)!;
    final mosqueBase = Offset(w - 92, h - 24);
    const scale = .85;
    mosque(canvas, mosqueBase, scale, silhouette);
    final minaretX = w - 56;
    canvas.drawRect(
      Rect.fromLTRB(minaretX - 3, h - 76, minaretX + 3, h - 24),
      fill(silhouette),
    );
    canvas.drawRect(
      Rect.fromLTRB(minaretX - 5, h - 60, minaretX + 5, h - 57),
      fill(silhouette),
    );
    canvas.drawPath(
      Path()
        ..moveTo(minaretX - 4, h - 76)
        ..quadraticBezierTo(minaretX - 4, h - 84, minaretX, h - 88)
        ..quadraticBezierTo(minaretX + 4, h - 84, minaretX + 4, h - 76)
        ..close(),
      fill(silhouette),
    );
    crescent(canvas, Offset(minaretX, h - 92), 2.4, gold);

    // Windows light up as evening falls.
    final glowAlpha = 1 - _dayness;
    if (glowAlpha > 0) {
      for (final dx in const [-8.0, 0.0, 8.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: mosqueBase + Offset(dx * scale, -5 * scale),
              width: 2.6,
              height: 5,
            ),
            const Radius.circular(1.3),
          ),
          fill(goldLight.withValues(alpha: .9 * glowAlpha)),
        );
      }
    }

    hills(
      canvas,
      [
        Offset(0, h - 8),
        Offset(w * .3, h - 16),
        Offset(w * .62, h - 6),
        Offset(w, h - 14),
      ],
      Color.lerp(horizonColor, tealDark, dark ? .5 : .35)!,
      bottom: h,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.phase.progress != phase.progress ||
      oldDelegate.phase.isDay != phase.isDay ||
      oldDelegate.phase.time.minute != phase.time.minute ||
      !identical(oldDelegate.palette, palette);
}
