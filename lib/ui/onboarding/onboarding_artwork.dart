import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/art_painter.dart';

/// Hand-painted onboarding illustrations. Every painter draws on a 300x200
/// canvas that is scaled to the available size, so the artwork stays crisp
/// at any resolution without shipping image assets. Colours come from
/// [SettingsPalette], so the artwork follows the app's light and dark theme.
enum OnboardingArt { welcome, notifications, location, theme }

class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({super.key, required this.art});
  final OnboardingArt art;

  @override
  Widget build(BuildContext context) {
    final colors = ArtColors.of(SettingsPalette.of(context));
    final painter = switch (art) {
      OnboardingArt.welcome => _WelcomePainter(colors),
      OnboardingArt.notifications => _NotificationsPainter(colors),
      OnboardingArt.location => _LocationPainter(colors),
      OnboardingArt.theme => _ThemePainter(colors),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: CustomPaint(painter: painter),
      ),
    );
  }
}

/// Open Quran on a wooden rehal, framed by three arches with a hanging
/// crescent.
class _WelcomePainter extends ArtPainter {
  const _WelcomePainter(super.colors);

  Path _arch(
    double left,
    double right,
    double spring,
    double top,
    double base,
  ) {
    final cx = (left + right) / 2;
    final w = right - left;
    return Path()
      ..moveTo(left, base)
      ..lineTo(left, spring)
      ..cubicTo(
        left,
        spring - (spring - top) * .6,
        cx - w * .2,
        top + 10,
        cx,
        top,
      )
      ..cubicTo(
        cx + w * .2,
        top + 10,
        right,
        spring - (spring - top) * .6,
        right,
        spring,
      )
      ..lineTo(right, base)
      ..close();
  }

  void _gate(
    Canvas canvas,
    double left,
    double right,
    double spring,
    double top,
    double base,
  ) {
    final outer = _arch(left, right, spring, top, base);
    shadow(canvas, outer);
    canvas.drawPath(outer, fill(cream));
    canvas.drawPath(outer, stroke(creamDark, 1));
    canvas.drawPath(
      _arch(left + 7, right - 7, spring + 3, top + 9, base),
      fill(teal),
    );
    canvas.drawPath(
      _arch(left + 12, right - 12, spring + 6, top + 16, base),
      fill(palette.background),
    );
    canvas.drawPath(
      _arch(left + 7, right - 7, spring + 3, top + 9, base),
      stroke(gold, 1),
    );
    // Column bands where the arch springs.
    for (final x in [left, right - 9]) {
      canvas.drawRect(Rect.fromLTWH(x - 1, spring, 11, 3), fill(gold));
      canvas.drawRect(Rect.fromLTWH(x - 1, base - 10, 11, 3), fill(gold));
      canvas.drawRect(Rect.fromLTWH(x - 1, base - 7, 11, 4), fill(tealDark));
    }
    // Finial.
    final cx = (left + right) / 2;
    canvas.drawRect(Rect.fromLTWH(cx - 1, top - 6, 2, 6), fill(gold));
    canvas.drawCircle(Offset(cx, top - 8), 3.2, fill(gold));
  }

  @override
  void draw(Canvas canvas) {
    glow(canvas, const Offset(150, 100), 130, goldLight);

    _gate(canvas, 48, 112, 88, 54, 158);
    _gate(canvas, 188, 252, 88, 54, 158);
    _gate(canvas, 92, 208, 72, 16, 150);

    // Hanging crescent.
    canvas.drawLine(
      const Offset(150, 33),
      const Offset(150, 48),
      stroke(gold, 1),
    );
    canvas.drawCircle(const Offset(150, 49), 1.8, fill(gold));
    glow(canvas, const Offset(150, 64), 24, gold);
    crescent(canvas, const Offset(148, 64), 13, gold);

    // Rehal: two crossed wooden boards.
    Path board(Offset a, Offset b, double t) {
      final d = b - a;
      final n = Offset(-d.dy, d.dx) / d.distance * t;
      return Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(b.dx + n.dx, b.dy + n.dy)
        ..lineTo(a.dx + n.dx, a.dy + n.dy)
        ..close();
    }

    final back = board(const Offset(104, 128), const Offset(178, 194), 14);
    final front = board(const Offset(122, 194), const Offset(196, 128), 14);
    shadow(canvas, back);
    canvas.drawPath(back, fill(woodDark));
    canvas.drawPath(front, fill(wood));
    canvas.drawPath(front, stroke(gold.withValues(alpha: .8), 1));

    // Book cover.
    final cover = Path()
      ..moveTo(150, 142)
      ..lineTo(88, 130)
      ..lineTo(94, 104)
      ..lineTo(150, 114)
      ..lineTo(206, 104)
      ..lineTo(212, 130)
      ..close();
    shadow(canvas, cover);
    canvas.drawPath(cover, fill(tealDark));

    // Pages, slightly curled at the top edge.
    Path page(double sign) => Path()
      ..moveTo(150, 136)
      ..lineTo(150 - 58 * sign, 124)
      ..lineTo(150 - 54 * sign, 96)
      ..quadraticBezierTo(150 - 26 * sign, 92, 150, 106)
      ..close();
    for (final sign in [1.0, -1.0]) {
      canvas.drawPath(page(sign), fill(cream));
      final frame = Path()
        ..moveTo(150 - 8 * sign, 128)
        ..lineTo(150 - 50 * sign, 119)
        ..lineTo(150 - 47 * sign, 101)
        ..quadraticBezierTo(150 - 26 * sign, 98, 150 - 8 * sign, 108)
        ..close();
      canvas.drawPath(frame, stroke(teal, 1.2));
      canvas.drawPath(frame, stroke(gold, .5));
      // Central medallion.
      final m = Offset(150 - 28 * sign, 113);
      canvas.save();
      canvas.translate(m.dx, m.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 7, height: 7),
        fill(teal),
      );
      canvas.restore();
      canvas.drawCircle(m, 1.6, fill(gold));
    }
    canvas.drawLine(
      const Offset(150, 106),
      const Offset(150, 136),
      stroke(creamDark, 1),
    );

    // Bookmark ribbon.
    final ribbon = Path()
      ..moveTo(146, 136)
      ..lineTo(154, 136)
      ..lineTo(154, 160)
      ..lineTo(150, 156)
      ..lineTo(146, 160)
      ..close();
    canvas.drawPath(ribbon, fill(teal));
    canvas.drawPath(ribbon, stroke(gold, .8));
  }
}

/// A phone receiving prayer notifications, flanked by a bell and a clock.
class _NotificationsPainter extends ArtPainter {
  const _NotificationsPainter(super.colors);

  void _appIcon(Canvas canvas, Offset topLeft) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, 22, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, fill(tealDark));
    final c = topLeft + const Offset(11, 17);
    final dome = Path()
      ..moveTo(c.dx - 7, c.dy)
      ..cubicTo(c.dx - 7, c.dy - 7, c.dx - 1, c.dy - 7, c.dx, c.dy - 11)
      ..cubicTo(c.dx + 1, c.dy - 7, c.dx + 7, c.dy - 7, c.dx + 7, c.dy)
      ..close();
    canvas.drawPath(dome, fill(cream));
    crescent(canvas, topLeft + const Offset(11, 4.5), 2.6, gold);
  }

  void _notification(Canvas canvas, Rect rect, Color dot) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    shadow(canvas, Path()..addRRect(rrect), blur: 8);
    canvas.drawRRect(rrect, fill(cream));
    _appIcon(canvas, rect.topLeft + const Offset(6, 6));
    final lines = stroke(creamDark, 4);
    canvas.drawLine(
      rect.topLeft + const Offset(36, 12),
      rect.topLeft + Offset(rect.width * .62, 12),
      lines,
    );
    canvas.drawLine(
      rect.topLeft + const Offset(36, 22),
      rect.topLeft + Offset(rect.width * .78, 22),
      lines..strokeWidth = 3,
    );
    canvas.drawCircle(rect.centerRight - const Offset(11, 0), 4, fill(dot));
  }

  void _bell(Canvas canvas, Offset c, double s, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(s);
    final body = Path()
      ..moveTo(-12, 8)
      ..cubicTo(-10, 4, -10, -2, -9, -6)
      ..cubicTo(-8, -14, 8, -14, 9, -6)
      ..cubicTo(10, -2, 10, 4, 12, 8)
      ..close();
    canvas.drawPath(body, fill(color));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, 7, 28, 3.5),
        const Radius.circular(2),
      ),
      fill(color),
    );
    canvas.drawCircle(const Offset(0, 12.5), 3, fill(color));
    canvas.drawCircle(const Offset(0, -13.5), 2, fill(color));
    canvas.restore();
  }

  @override
  void draw(Canvas canvas) {
    glow(canvas, const Offset(150, 100), 135, gold);

    leaf(canvas, const Offset(120, 150), 40, -2.4);
    leaf(canvas, const Offset(118, 160), 34, -2.9);
    leaf(canvas, const Offset(186, 120), 30, -.5);

    // Phone, tilted slightly.
    canvas.save();
    canvas.translate(150, 100);
    canvas.rotate(.12);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 92, height: 178),
      const Radius.circular(18),
    );
    shadow(canvas, Path()..addRRect(body), blur: 10);
    canvas.drawRRect(body, fill(tealDark));
    final screen = body.deflate(4.5);
    canvas.drawRRect(screen, fill(cream));
    canvas.save();
    canvas.clipRRect(screen);
    // Skyline and hills at the bottom of the screen.
    mosque(canvas, const Offset(-8, 70), 1, creamDark);
    mosque(canvas, const Offset(24, 72), .6, creamDark);
    crescent(canvas, const Offset(-6, 26), 4, gold);
    final hills = Path()
      ..moveTo(-50, 72)
      ..quadraticBezierTo(-20, 58, 8, 70)
      ..quadraticBezierTo(30, 80, 50, 66)
      ..lineTo(50, 92)
      ..lineTo(-50, 92)
      ..close();
    canvas.drawPath(hills, fill(teal));
    canvas.restore();
    // Notch, bell and home indicator.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -85, 30, 6),
        const Radius.circular(3),
      ),
      fill(tealDark),
    );
    _bell(canvas, const Offset(0, -56), .9, teal);
    final rays = stroke(gold, 2);
    canvas.drawLine(const Offset(-20, -62), const Offset(-25, -65), rays);
    canvas.drawLine(const Offset(-21, -53), const Offset(-27, -53), rays);
    canvas.drawLine(const Offset(20, -62), const Offset(25, -65), rays);
    canvas.drawLine(const Offset(21, -53), const Offset(27, -53), rays);
    canvas.drawLine(
      const Offset(-14, 80),
      const Offset(14, 80),
      stroke(cream, 2),
    );
    canvas.restore();

    _notification(canvas, const Rect.fromLTWH(92, 52, 116, 34), gold);
    _notification(canvas, const Rect.fromLTWH(118, 98, 116, 34), teal);

    // Golden bell on the left.
    glow(canvas, const Offset(66, 66), 34, gold);
    canvas.save();
    canvas.translate(66, 66);
    canvas.rotate(-.3);
    _bell(canvas, Offset.zero, 1.5, gold);
    canvas.restore();
    final ring = stroke(gold, 2.5);
    canvas.drawLine(const Offset(58, 32), const Offset(55, 24), ring);
    canvas.drawLine(const Offset(70, 31), const Offset(73, 23), ring);

    crescent(canvas, const Offset(56, 118), 11, gold);
    sparkle(canvas, const Offset(40, 148), 6);
    sparkle(canvas, const Offset(232, 34), 6);
    sparkle(canvas, const Offset(262, 150), 7);

    // Clock with a mosque.
    const clock = Offset(254, 92);
    glow(canvas, clock, 40, gold);
    canvas.drawCircle(clock, 25, fill(gold));
    canvas.drawCircle(clock, 21, fill(cream));
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: clock, radius: 21)),
    );
    mosque(canvas, clock + const Offset(6, 21), .55, teal);
    canvas.restore();
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(clock + dir * 16, clock + dir * 18.5, stroke(gold, 1.2));
    }
    canvas.drawLine(clock, clock + const Offset(9, -10), stroke(gold, 1.8));
    canvas.drawLine(clock, clock + const Offset(-4, -7), stroke(gold, 1.8));
    canvas.drawCircle(clock, 2, fill(gold));
  }
}

/// A folded map with a location pin, a dashed route to a mosque and a
/// compass.
class _LocationPainter extends ArtPainter {
  const _LocationPainter(super.colors);

  void _cloud(Canvas canvas, Offset c, double s) {
    final p = fill(dark ? creamDark : palette.background);
    final path = Path()
      ..addOval(
        Rect.fromCircle(center: c + Offset(-9 * s, 2 * s), radius: 7 * s),
      )
      ..addOval(Rect.fromCircle(center: c + Offset(0, -3 * s), radius: 9 * s))
      ..addOval(
        Rect.fromCircle(center: c + Offset(10 * s, 2 * s), radius: 7 * s),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(c.dx - 16 * s, c.dy, c.dx + 17 * s, c.dy + 9 * s),
          Radius.circular(5 * s),
        ),
      );
    shadow(canvas, path, blur: 4, offset: const Offset(0, 2));
    canvas.drawPath(path, p);
  }

  @override
  void draw(Canvas canvas) {
    glow(canvas, const Offset(150, 110), 140, gold);

    // Orbit.
    final orbit = Rect.fromCenter(
      center: const Offset(150, 118),
      width: 268,
      height: 104,
    );
    canvas.drawOval(orbit, stroke(gold.withValues(alpha: .7), 1.2));
    canvas.drawCircle(const Offset(36, 104), 3.5, fill(gold));
    canvas.drawCircle(const Offset(270, 98), 3.5, fill(gold));

    _cloud(canvas, const Offset(68, 54), 1.1);
    _cloud(canvas, const Offset(262, 132), 1);

    // Map sheet.
    final map = Path()
      ..moveTo(52, 104)
      ..quadraticBezierTo(110, 82, 150, 98)
      ..quadraticBezierTo(200, 112, 256, 88)
      ..lineTo(244, 152)
      ..quadraticBezierTo(190, 174, 140, 160)
      ..quadraticBezierTo(90, 146, 38, 168)
      ..close();
    shadow(canvas, map, blur: 8);
    canvas.drawPath(map, fill(cream));
    canvas.save();
    canvas.clipPath(map);
    final river = Path()
      ..moveTo(120, 60)
      ..cubicTo(150, 110, 110, 130, 160, 190)
      ..lineTo(186, 190)
      ..cubicTo(140, 130, 178, 110, 146, 60)
      ..close();
    canvas.drawPath(river, fill(teal.withValues(alpha: .85)));
    final lake = Path()..addOval(const Rect.fromLTWH(40, 140, 48, 26));
    canvas.drawPath(lake, fill(teal.withValues(alpha: .7)));
    final roads = stroke(gold, 1.2);
    canvas.drawPath(
      Path()
        ..moveTo(40, 128)
        ..quadraticBezierTo(120, 116, 250, 124),
      roads,
    );
    canvas.drawPath(
      Path()
        ..moveTo(200, 80)
        ..quadraticBezierTo(214, 130, 196, 180),
      roads,
    );
    canvas.restore();
    canvas.drawPath(map, stroke(creamDark, 1.2));

    // Mosque on a green plot.
    final plot = Path()
      ..moveTo(196, 84)
      ..lineTo(250, 80)
      ..lineTo(246, 98)
      ..lineTo(198, 102)
      ..close();
    canvas.drawPath(plot, fill(teal));
    canvas.drawRect(const Rect.fromLTWH(208, 64, 28, 28), fill(cream));
    canvas.drawPath(
      Path()
        ..moveTo(210, 64)
        ..cubicTo(210, 50, 234, 50, 234, 64)
        ..close(),
      fill(teal),
    );
    canvas.drawRect(const Rect.fromLTWH(238, 44, 7, 48), fill(cream));
    canvas.drawPath(
      Path()
        ..moveTo(237, 44)
        ..lineTo(241.5, 36)
        ..lineTo(246, 44)
        ..close(),
      fill(gold),
    );
    crescent(canvas, const Offset(222, 47), 3, gold);
    crescent(canvas, const Offset(241.5, 32), 2.5, gold);
    final door = Path()
      ..moveTo(217, 92)
      ..lineTo(217, 82)
      ..quadraticBezierTo(222, 74, 227, 82)
      ..lineTo(227, 92)
      ..close();
    canvas.drawPath(door, fill(gold));
    leaf(canvas, const Offset(202, 92), 14, -1.9);
    leaf(canvas, const Offset(202, 92), 14, -1.2);

    // Dashed route from pin to mosque.
    final route = Path()
      ..moveTo(122, 126)
      ..quadraticBezierTo(170, 132, 206, 104);
    for (final metric in route.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 8) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 4, metric.length)),
          stroke(tealDark, 2),
        );
      }
    }
    canvas.drawCircle(const Offset(206, 104), 3, fill(gold));

    // Main pin.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(110, 128), width: 54, height: 16),
      stroke(goldLight.withValues(alpha: .8), 1.4),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(110, 127), width: 30, height: 9),
      fill(gold),
    );
    final pin = Path()
      ..moveTo(110, 124)
      ..cubicTo(98, 104, 82, 86, 82, 64)
      ..arcToPoint(const Offset(138, 64), radius: const Radius.circular(28))
      ..cubicTo(138, 86, 122, 104, 110, 124)
      ..close();
    glow(canvas, const Offset(110, 66), 48, teal);
    shadow(canvas, pin, blur: 8);
    canvas.drawPath(pin, fill(teal));
    canvas.drawPath(
      Path()
        ..moveTo(88, 58)
        ..quadraticBezierTo(92, 42, 106, 38),
      stroke(Colors.white.withValues(alpha: .35), 3),
    );
    canvas.drawCircle(const Offset(110, 64), 13, stroke(gold, 5));
    canvas.drawCircle(
      const Offset(110, 64),
      9,
      fill(goldLight.withValues(alpha: .5)),
    );

    // Compass.
    const compass = Offset(64, 150);
    shadow(
      canvas,
      Path()..addOval(Rect.fromCircle(center: compass, radius: 22)),
    );
    canvas.drawCircle(compass + const Offset(0, -24), 4, stroke(gold, 2));
    canvas.drawCircle(compass, 22, fill(gold));
    canvas.drawCircle(compass, 18, fill(cream));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final len = i.isEven ? 15.0 : 9.0;
      final dir = Offset(math.cos(a), math.sin(a));
      final side = Offset(-dir.dy, dir.dx) * 2.5;
      canvas.drawPath(
        Path()
          ..moveTo(compass.dx + side.dx, compass.dy + side.dy)
          ..lineTo(compass.dx + dir.dx * len, compass.dy + dir.dy * len)
          ..lineTo(compass.dx - side.dx, compass.dy - side.dy)
          ..close(),
        fill(creamDark),
      );
    }
    canvas.save();
    canvas.translate(compass.dx, compass.dy);
    canvas.rotate(.6);
    canvas.drawPath(
      Path()
        ..moveTo(-3, 0)
        ..lineTo(0, -15)
        ..lineTo(3, 0)
        ..close(),
      fill(teal),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-3, 0)
        ..lineTo(0, 15)
        ..lineTo(3, 0)
        ..close(),
      fill(gold),
    );
    canvas.restore();
    canvas.drawCircle(compass, 2, fill(tealDark));

    sparkle(canvas, const Offset(160, 40), 6);
    sparkle(canvas, const Offset(46, 84), 5);
  }
}

/// Light, system and dark phones fanned out between a sun and a moon.
class _ThemePainter extends ArtPainter {
  const _ThemePainter(super.colors);

  void _phone(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required SettingsPalette theme,
    bool castShadow = true,
  }) {
    final night = identical(theme, SettingsPalette.dark);
    final frame = Color.lerp(theme.card, theme.subtitle, .3)!;
    final wave = night ? theme.selectedCard : theme.accent;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 84, height: 158),
      const Radius.circular(16),
    );
    if (castShadow) shadow(canvas, Path()..addRRect(body), blur: 10);
    canvas.drawRRect(body, fill(frame));
    canvas.drawRRect(body.deflate(3), fill(theme.background));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -72, 24, 6),
        const Radius.circular(3),
      ),
      fill(frame),
    );

    final heroRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-33, -58, 66, 62),
      const Radius.circular(10),
    );
    canvas.drawRRect(heroRect, fill(theme.card));
    canvas.save();
    canvas.clipRRect(heroRect);
    canvas.drawPath(
      Path()
        ..moveTo(-34, -14)
        ..quadraticBezierTo(-12, -28, 6, -16)
        ..quadraticBezierTo(22, -6, 34, -22)
        ..lineTo(34, 6)
        ..lineTo(-34, 6)
        ..close(),
      fill(wave.withValues(alpha: .45)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-34, -4)
        ..quadraticBezierTo(-10, -18, 10, -6)
        ..quadraticBezierTo(24, 2, 34, -8)
        ..lineTo(34, 6)
        ..lineTo(-34, 6)
        ..close(),
      fill(wave),
    );
    if (night) {
      crescent(canvas, const Offset(16, -42), 7, gold);
      for (final star in const [
        Offset(-18, -46),
        Offset(-6, -36),
        Offset(2, -50),
      ]) {
        canvas.drawCircle(star, 1, fill(goldLight));
      }
    } else {
      canvas.drawCircle(const Offset(16, -42), 6, fill(gold));
    }
    canvas.restore();

    for (final y in const [12.0, 38.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-33, y, 66, 20),
          const Radius.circular(8),
        ),
        fill(theme.card),
      );
    }
    canvas.drawLine(
      const Offset(-14, 72),
      const Offset(14, 72),
      stroke(frame, 2),
    );
    canvas.restore();
  }

  @override
  void draw(Canvas canvas) {
    glow(canvas, const Offset(150, 100), 140, gold);

    leaf(canvas, const Offset(84, 150), 32, 2.5);
    leaf(canvas, const Offset(86, 138), 28, -2.6);
    leaf(canvas, const Offset(216, 150), 32, .6);
    leaf(canvas, const Offset(214, 138), 28, -.5);

    _phone(
      canvas,
      center: const Offset(98, 104),
      angle: -.16,
      theme: SettingsPalette.light,
    );
    _phone(
      canvas,
      center: const Offset(202, 104),
      angle: .16,
      theme: SettingsPalette.dark,
    );
    glow(canvas, const Offset(150, 100), 70, goldLight);
    // The system phone is split down the middle: light on the left, dark on
    // the right.
    const system = Offset(150, 100);
    _phone(canvas, center: system, angle: 0, theme: SettingsPalette.light);
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(150, 0, 300, 200));
    _phone(
      canvas,
      center: system,
      angle: 0,
      theme: SettingsPalette.dark,
      castShadow: false,
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: system, width: 84, height: 158),
        const Radius.circular(16),
      ),
      stroke(gold, 2),
    );

    // Sun.
    const sun = Offset(34, 84);
    glow(canvas, sun, 34, gold);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(sun + dir * 17, sun + dir * 23, stroke(gold, 4));
    }
    canvas.drawCircle(sun, 13, fill(gold));
    canvas.drawCircle(
      sun - const Offset(4, 4),
      5,
      fill(goldLight.withValues(alpha: .7)),
    );
    canvas.drawCircle(const Offset(30, 124), 2.5, fill(gold));
    canvas.drawCircle(const Offset(44, 136), 2, fill(gold));

    // Moon.
    glow(canvas, const Offset(268, 104), 34, gold);
    crescent(canvas, const Offset(266, 106), 20, gold);
    sparkle(canvas, const Offset(258, 68), 7);
    sparkle(canvas, const Offset(286, 140), 5);
    canvas.drawCircle(const Offset(246, 82), 2, fill(gold));
  }
}
