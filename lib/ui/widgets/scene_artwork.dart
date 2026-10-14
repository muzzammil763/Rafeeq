import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/art_painter.dart';

/// Painted scenes used across the app in place of bitmap illustrations.
enum SceneArt { makkah, madinah, sunrise, noon, sunset, mosque }

class SceneArtwork extends StatelessWidget {
  const SceneArtwork({
    super.key,
    required this.scene,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final SceneArt scene;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = ArtColors.of(SettingsPalette.of(context));
    final painter = switch (scene) {
      SceneArt.makkah => _MakkahPainter(colors),
      SceneArt.madinah => _MadinahPainter(colors),
      SceneArt.sunrise => _SunrisePainter(colors),
      SceneArt.noon => _NoonPainter(colors),
      SceneArt.sunset => _SunsetPainter(colors),
      SceneArt.mosque => _MosquePainter(colors),
    };
    final paint = CustomPaint(painter: painter);
    final Widget sized = width != null && height != null
        ? SizedBox(width: width, height: height, child: paint)
        : AspectRatio(aspectRatio: 3 / 2, child: paint);
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: sized,
    );
  }
}

abstract class _ScenePainter extends ArtPainter {
  const _ScenePainter(super.colors);

  /// Light masonry used for mosque walls and minarets.
  Color get stone => Color.lerp(goldLight, Colors.white, .55)!;
  Color get silhouette => Color.lerp(tealDark, Colors.black, .45)!;

  void verticalGradient(
    Canvas canvas,
    Rect rect,
    List<Color> colors, [
    List<double>? stops,
  ]) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(rect),
    );
  }

  void palm(
    Canvas canvas,
    Offset base,
    double height,
    double lean,
    Color color,
  ) {
    final top = base + Offset(lean, -height);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + lean * .2,
          base.dy - height * .5,
          top.dx,
          top.dy,
        ),
      stroke(color, height * .07),
    );
    final length = height * .55;
    for (final degrees in const [195.0, 228.0, 258.0, 288.0, 318.0, 348.0]) {
      final a = degrees * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      final tip = top + dir * length + Offset(0, length * .3);
      final mid = top + dir * length * .5;
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(mid.dx, mid.dy - length * .22, tip.dx, tip.dy)
          ..quadraticBezierTo(mid.dx, mid.dy + length * .04, top.dx, top.dy)
          ..close(),
        fill(color),
      );
    }
  }

  void minaret(
    Canvas canvas, {
    required double x,
    required double base,
    required double height,
    required double width,
    required Color body,
    required Color cap,
    bool pointed = false,
  }) {
    final top = base - height;
    final half = width / 2;
    canvas.drawRect(Rect.fromLTRB(x - half, top, x + half, base), fill(body));
    for (final f in const [.38, .72]) {
      final y = base - height * f;
      canvas.drawRect(
        Rect.fromLTRB(x - half - 2, y - 2.5, x + half + 2, y + 1),
        fill(cap),
      );
    }
    final double finial;
    if (pointed) {
      finial = top - width * 2.6;
      canvas.drawPath(
        Path()
          ..moveTo(x - half, top)
          ..lineTo(x, finial)
          ..lineTo(x + half, top)
          ..close(),
        fill(cap),
      );
    } else {
      finial = top - width * 1.4;
      canvas.drawPath(
        Path()
          ..moveTo(x - half - 1, top)
          ..cubicTo(
            x - half - 1,
            top - width * .9,
            x - 1,
            top - width * .9,
            x,
            finial,
          )
          ..cubicTo(
            x + 1,
            top - width * .9,
            x + half + 1,
            top - width * .9,
            x + half + 1,
            top,
          )
          ..close(),
        fill(cap),
      );
    }
    canvas.drawLine(
      Offset(x, finial),
      Offset(x, finial - 5),
      stroke(gold, 1.2),
    );
    crescent(canvas, Offset(x, finial - 7.5), 2.6, gold);
  }

  /// The soft cloud-shaped backdrop behind the Makkah and Madinah scenes.
  void backdrop(Canvas canvas) {
    final color = dark
        ? Color.lerp(palette.card, gold, .1)!
        : Color.lerp(palette.card, palette.background, .25)!;
    final path = Path()
      ..addOval(Rect.fromCircle(center: const Offset(150, 96), radius: 72))
      ..addOval(Rect.fromCircle(center: const Offset(88, 118), radius: 48))
      ..addOval(Rect.fromCircle(center: const Offset(212, 118), radius: 48))
      ..addOval(Rect.fromCircle(center: const Offset(46, 144), radius: 30))
      ..addOval(Rect.fromCircle(center: const Offset(254, 144), radius: 30))
      ..addRect(const Rect.fromLTRB(46, 140, 254, 174));
    canvas.drawPath(path, fill(color));
  }

  void floor(Canvas canvas, Offset center, double width) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: 26),
      fill(
        dark
            ? Color.lerp(palette.card, palette.subtitle, .18)!
            : Color.lerp(palette.card, Colors.white, .45)!,
      ),
    );
  }

  /// A row of arched openings between [left] and [right].
  void arcade(
    Canvas canvas, {
    required double left,
    required double right,
    required double top,
    required double bottom,
    required int count,
    required Color wall,
    required Color opening,
  }) {
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), fill(wall));
    canvas.drawRect(Rect.fromLTRB(left, top, right, top + 2), fill(gold));
    final pitch = (right - left) / count;
    for (var i = 0; i < count; i++) {
      final l = left + i * pitch + pitch * .2;
      final r = left + (i + 1) * pitch - pitch * .2;
      final w = r - l;
      canvas.drawPath(
        Path()
          ..moveTo(l, bottom)
          ..lineTo(l, top + 6 + w * .5)
          ..quadraticBezierTo(l, top + 6, (l + r) / 2, top + 5)
          ..quadraticBezierTo(r, top + 6, r, top + 6 + w * .5)
          ..lineTo(r, bottom)
          ..close(),
        fill(opening),
      );
    }
  }
}

/// The Kaaba in the Masjid al-Haram, flanked by arcades and two minarets.
class _MakkahPainter extends _ScenePainter {
  const _MakkahPainter(super.colors);

  @override
  void draw(Canvas canvas) {
    backdrop(canvas);
    glow(canvas, const Offset(150, 74), 70, gold);
    canvas.drawCircle(
      const Offset(150, 74),
      32,
      fill(goldLight.withValues(alpha: .55)),
    );
    cloud(canvas, const Offset(84, 92), 1, stone.withValues(alpha: .7));
    cloud(canvas, const Offset(220, 84), .9, stone.withValues(alpha: .7));

    minaret(
      canvas,
      x: 64,
      base: 146,
      height: 70,
      width: 10,
      body: stone,
      cap: gold,
    );
    minaret(
      canvas,
      x: 236,
      base: 146,
      height: 70,
      width: 10,
      body: stone,
      cap: gold,
    );
    final opening = Color.lerp(tealDark, palette.background, .15)!;
    arcade(
      canvas,
      left: 22,
      right: 116,
      top: 140,
      bottom: 166,
      count: 5,
      wall: stone,
      opening: opening,
    );
    arcade(
      canvas,
      left: 184,
      right: 278,
      top: 140,
      bottom: 166,
      count: 5,
      wall: stone,
      opening: opening,
    );
    floor(canvas, const Offset(150, 170), 236);

    // The Kaaba as an isometric cube.
    const a = Offset(106, 90);
    const b = Offset(150, 102);
    const e = Offset(196, 88);
    const g = Offset(152, 78);
    const h = 66.0;
    const down = Offset(0, h);
    final black = SettingsPalette.light.title;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(152, 166), width: 110, height: 14),
      fill(Colors.black.withValues(alpha: dark ? .4 : .14)),
    );
    final left = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(b.dx, b.dy + h)
      ..lineTo(a.dx, a.dy + h)
      ..close();
    final right = Path()
      ..moveTo(b.dx, b.dy)
      ..lineTo(e.dx, e.dy)
      ..lineTo(e.dx, e.dy + h)
      ..lineTo(b.dx, b.dy + h)
      ..close();
    final top = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(g.dx, g.dy)
      ..lineTo(e.dx, e.dy)
      ..lineTo(b.dx, b.dy)
      ..close();
    canvas.drawPath(left, fill(black));
    canvas.drawPath(right, fill(Color.lerp(black, Colors.white, .1)!));
    canvas.drawPath(top, fill(Color.lerp(black, Colors.white, .2)!));

    // The gold band (hizam) wrapping both faces.
    Path band(Offset from, Offset to, double y0, double y1) => Path()
      ..moveTo(from.dx, from.dy + y0)
      ..lineTo(to.dx, to.dy + y0)
      ..lineTo(to.dx, to.dy + y1)
      ..lineTo(from.dx, from.dy + y1)
      ..close();
    canvas.drawPath(band(a, b, 13, 20), fill(gold));
    canvas.drawPath(band(b, e, 13, 20), fill(gold));
    // Calligraphy panels hanging below the band.
    Offset onFace(Offset from, Offset to, double u, double v) =>
        Offset.lerp(from, to, u)! + Offset(0, v);
    for (final u in const [.2, .5, .8]) {
      for (final face in [(a, b), (b, e)]) {
        final p = onFace(face.$1, face.$2, u, 26);
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 3.5, height: 3.5),
          fill(gold),
        );
        canvas.restore();
      }
    }
    // Door on the right face.
    final door = Path()
      ..moveTo(onFace(b, e, .55, 32).dx, onFace(b, e, .55, 32).dy)
      ..lineTo(onFace(b, e, .74, 32).dx, onFace(b, e, .74, 32).dy)
      ..lineTo(onFace(b, e, .74, 58).dx, onFace(b, e, .74, 58).dy)
      ..lineTo(onFace(b, e, .55, 58).dx, onFace(b, e, .55, 58).dy)
      ..close();
    canvas.drawPath(door, fill(gold));
    // Marble base (shadharwan).
    canvas.drawPath(band(a, b, h - 3, h), fill(stone));
    canvas.drawPath(band(b, e, h - 3, h), fill(stone));
    canvas.drawLine(b, b + down, stroke(gold.withValues(alpha: .35), .8));
  }
}

/// Masjid an-Nabawi with the Green Dome, minarets, umbrellas and lanterns.
class _MadinahPainter extends _ScenePainter {
  const _MadinahPainter(super.colors);

  void _umbrella(Canvas canvas, Offset top, double span) {
    canvas.drawRect(
      Rect.fromLTWH(top.dx - 1.2, top.dy + 9, 2.4, 168 - top.dy - 9),
      fill(wood),
    );
    final canopy = Path()
      ..moveTo(top.dx - span / 2, top.dy)
      ..quadraticBezierTo(top.dx, top.dy + 4, top.dx + span / 2, top.dy)
      ..lineTo(top.dx, top.dy + 11)
      ..close();
    canvas.drawPath(canopy, fill(stone));
    for (final f in const [-.3, 0.0, .3]) {
      canvas.drawLine(
        top + Offset(span * f, 1.5),
        top + const Offset(0, 11),
        stroke(creamDark, .8),
      );
    }
  }

  void _lantern(Canvas canvas, double x, double height) {
    const base = 168.0;
    final top = base - height;
    canvas.drawRect(Rect.fromLTWH(x - 1.6, top, 3.2, height), fill(wood));
    canvas.drawRect(Rect.fromLTWH(x - 3.5, base - 3, 7, 3), fill(wood));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4, top - 9, 8, 9),
        const Radius.circular(1.5),
      ),
      fill(gold),
    );
    canvas.drawRect(Rect.fromLTWH(x - 2.4, top - 7.5, 4.8, 6), fill(goldLight));
    canvas.drawPath(
      Path()
        ..moveTo(x - 4.5, top - 9)
        ..lineTo(x, top - 14)
        ..lineTo(x + 4.5, top - 9)
        ..close(),
      fill(gold),
    );
  }

  @override
  void draw(Canvas canvas) {
    backdrop(canvas);
    glow(canvas, const Offset(178, 80), 70, gold);
    canvas.drawCircle(
      const Offset(178, 80),
      36,
      fill(goldLight.withValues(alpha: .55)),
    );
    cloud(canvas, const Offset(112, 100), 1, stone.withValues(alpha: .7));
    cloud(canvas, const Offset(236, 104), .9, stone.withValues(alpha: .7));

    for (final m in const [(56.0, 82.0), (98.0, 70.0), (220.0, 68.0)]) {
      minaret(
        canvas,
        x: m.$1,
        base: 132,
        height: m.$2,
        width: 9,
        body: stone,
        cap: teal,
        pointed: true,
      );
    }
    minaret(
      canvas,
      x: 260,
      base: 132,
      height: 88,
      width: 12,
      body: stone,
      cap: gold,
    );

    // Small white dome.
    canvas.drawPath(
      Path()
        ..moveTo(110, 128)
        ..cubicTo(110, 112, 132, 112, 132, 128)
        ..close(),
      fill(stone),
    );

    // The Green Dome on its drum.
    canvas.drawRect(const Rect.fromLTRB(152, 110, 204, 128), fill(stone));
    canvas.drawRect(const Rect.fromLTRB(150, 108, 206, 113), fill(tealDark));
    final dome = Path()
      ..moveTo(152, 109)
      ..cubicTo(148, 82, 170, 76, 178, 60)
      ..cubicTo(186, 76, 208, 82, 204, 109)
      ..close();
    canvas.drawPath(dome, fill(teal));
    canvas.save();
    canvas.clipPath(dome);
    for (final x in const [160.0, 169.0, 178.0, 187.0, 196.0]) {
      canvas.drawLine(
        Offset(x, 110),
        Offset(178 + (x - 178) * .2, 62),
        stroke(tealDark.withValues(alpha: .45), 1),
      );
    }
    canvas.restore();
    canvas.drawPath(
      Path()
        ..moveTo(158, 100)
        ..quadraticBezierTo(158, 84, 170, 76),
      stroke(Colors.white.withValues(alpha: .3), 2.5),
    );
    canvas.drawLine(
      const Offset(178, 60),
      const Offset(178, 52),
      stroke(gold, 1.4),
    );
    crescent(canvas, const Offset(178, 48), 3.4, gold);

    // Main facade with a crenellated parapet and arched windows.
    canvas.drawRect(const Rect.fromLTRB(64, 128, 244, 166), fill(stone));
    for (var x = 64.0; x < 244; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 125, 3.5, 3), fill(stone));
    }
    canvas.drawRect(
      const Rect.fromLTRB(64, 133, 244, 134.5),
      fill(creamDark.withValues(alpha: .8)),
    );
    final window = Color.lerp(stone, wood, .35)!;
    for (var i = 0; i < 12; i++) {
      final x = 72 + i * 14.5;
      if ((x - 147).abs() < 8) continue;
      canvas.drawPath(
        Path()
          ..moveTo(x, 160)
          ..lineTo(x, 146)
          ..quadraticBezierTo(x, 140, x + 4, 139)
          ..quadraticBezierTo(x + 8, 140, x + 8, 146)
          ..lineTo(x + 8, 160)
          ..close(),
        fill(window),
      );
    }
    canvas.drawRect(const Rect.fromLTRB(144, 148, 156, 166), fill(wood));
    floor(canvas, const Offset(150, 170), 250);

    _umbrella(canvas, const Offset(30, 138), 52);
    _umbrella(canvas, const Offset(270, 138), 52);
    for (final x in const [86.0, 128.0, 186.0, 228.0]) {
      _lantern(canvas, x, 26);
    }
  }
}

/// The sun breaking over the hills, rays rising, with a mosque on the
/// skyline.
class _SunrisePainter extends _ScenePainter {
  const _SunrisePainter(super.colors);

  @override
  void draw(Canvas canvas) {
    const frame = Rect.fromLTWH(0, 0, 300, 200);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(frame, const Radius.circular(26)));
    verticalGradient(canvas, frame, [
      dark
          ? Color.lerp(palette.background, teal, .3)!
          : Color.lerp(palette.background, teal, .14)!,
      dark
          ? Color.lerp(palette.background, gold, .45)!
          : Color.lerp(palette.background, goldLight, .75)!,
    ]);

    const sun = Offset(120, 148);
    glow(canvas, sun, 130, gold);
    for (var i = 0; i < 9; i++) {
      final a = math.pi + (i + .5) * math.pi / 9;
      final dir = Offset(math.cos(a), math.sin(a));
      final side = Offset(-dir.dy, dir.dx) * 5;
      final reach = i.isEven ? 100.0 : 76.0;
      canvas.drawPath(
        Path()
          ..moveTo(
            sun.dx + dir.dx * 40 + side.dx,
            sun.dy + dir.dy * 40 + side.dy,
          )
          ..lineTo(sun.dx + dir.dx * reach, sun.dy + dir.dy * reach)
          ..lineTo(
            sun.dx + dir.dx * 40 - side.dx,
            sun.dy + dir.dy * 40 - side.dy,
          )
          ..close(),
        fill(gold.withValues(alpha: .5)),
      );
    }
    canvas.drawCircle(sun, 32, fill(gold));
    canvas.drawCircle(sun, 24, fill(goldLight.withValues(alpha: .6)));

    final cloudColor = dark
        ? Color.lerp(palette.card, gold, .3)!
        : Colors.white.withValues(alpha: .85);
    cloud(canvas, const Offset(236, 50), 1.1, cloudColor);
    cloud(canvas, const Offset(46, 64), .8, cloudColor);

    hills(canvas, const [
      Offset(0, 146),
      Offset(60, 130),
      Offset(124, 150),
      Offset(196, 124),
      Offset(260, 140),
      Offset(300, 132),
    ], Color.lerp(teal, palette.background, .45)!);
    hills(canvas, const [
      Offset(0, 166),
      Offset(70, 150),
      Offset(150, 168),
      Offset(230, 152),
      Offset(300, 164),
    ], teal);
    mosque(canvas, const Offset(232, 156), .95, tealDark);
    minaret(
      canvas,
      x: 262,
      base: 158,
      height: 50,
      width: 7,
      body: tealDark,
      cap: tealDark,
    );
    hills(canvas, const [
      Offset(0, 186),
      Offset(80, 174),
      Offset(170, 190),
      Offset(250, 178),
      Offset(300, 186),
    ], tealDark);
    palm(canvas, const Offset(34, 186), 42, -4, tealDark);
    palm(canvas, const Offset(58, 190), 30, 5, tealDark);
    canvas.restore();
  }
}

/// The sun at its zenith directly above a mosque, its shadow barely visible.
class _NoonPainter extends _ScenePainter {
  const _NoonPainter(super.colors);

  @override
  void draw(Canvas canvas) {
    const frame = Rect.fromLTWH(0, 0, 300, 200);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(frame, const Radius.circular(26)));
    verticalGradient(canvas, frame, [
      dark
          ? Color.lerp(palette.background, teal, .45)!
          : Color.lerp(Colors.white, teal, .3)!,
      dark
          ? Color.lerp(palette.background, teal, .15)!
          : Color.lerp(palette.background, teal, .06)!,
    ]);

    const sun = Offset(150, 42);
    // A beam falling straight down marks the sun at its highest point.
    canvas.drawPath(
      Path()
        ..moveTo(138, 60)
        ..lineTo(162, 60)
        ..lineTo(196, 172)
        ..lineTo(104, 172)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            goldLight.withValues(alpha: .45),
            goldLight.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTRB(104, 60, 196, 172)),
    );
    glow(canvas, sun, 90, gold);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(sun + dir * 28, sun + dir * 38, stroke(gold, 3.5));
    }
    canvas.drawCircle(sun, 22, fill(gold));
    canvas.drawCircle(sun, 15, fill(goldLight.withValues(alpha: .6)));

    final cloudColor = dark
        ? Color.lerp(palette.card, palette.subtitle, .3)!
        : Colors.white;
    cloud(canvas, const Offset(58, 54), 1, cloudColor);
    cloud(canvas, const Offset(246, 70), .85, cloudColor);

    // Ground.
    canvas.drawRect(
      const Rect.fromLTRB(0, 170, 300, 200),
      fill(Color.lerp(palette.card, gold, dark ? .15 : .25)!),
    );
    palm(canvas, const Offset(46, 174), 46, -3, teal);
    palm(canvas, const Offset(256, 174), 46, 3, teal);

    // Mosque directly beneath the sun.
    minaret(
      canvas,
      x: 100,
      base: 172,
      height: 68,
      width: 10,
      body: stone,
      cap: teal,
    );
    minaret(
      canvas,
      x: 200,
      base: 172,
      height: 68,
      width: 10,
      body: stone,
      cap: teal,
    );
    canvas.drawRect(const Rect.fromLTRB(112, 134, 188, 172), fill(stone));
    canvas.drawRect(const Rect.fromLTRB(124, 128, 176, 136), fill(stone));
    canvas.drawPath(
      Path()
        ..moveTo(126, 130)
        ..cubicTo(124, 108, 142, 104, 150, 92)
        ..cubicTo(158, 104, 176, 108, 174, 130)
        ..close(),
      fill(teal),
    );
    canvas.drawLine(
      const Offset(150, 92),
      const Offset(150, 84),
      stroke(gold, 1.4),
    );
    crescent(canvas, const Offset(150, 80), 3.2, gold);
    canvas.drawPath(
      Path()
        ..moveTo(141, 172)
        ..lineTo(141, 156)
        ..quadraticBezierTo(141, 148, 150, 146)
        ..quadraticBezierTo(159, 148, 159, 156)
        ..lineTo(159, 172)
        ..close(),
      fill(tealDark),
    );
    for (final x in const [120.0, 170.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3.5, 146, 7, 12),
          const Radius.circular(3.5),
        ),
        fill(tealDark),
      );
    }
    // The shortest shadow of the day, right under the building.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(150, 173), width: 96, height: 5),
      fill(Colors.black.withValues(alpha: dark ? .35 : .14)),
    );
    canvas.restore();
  }
}

/// The sun sinking into the water behind a mosque silhouette at dusk.
class _SunsetPainter extends _ScenePainter {
  const _SunsetPainter(super.colors);

  @override
  void draw(Canvas canvas) {
    const frame = Rect.fromLTWH(0, 0, 300, 200);
    const horizon = 140.0;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(frame, const Radius.circular(26)));
    verticalGradient(
      canvas,
      const Rect.fromLTRB(0, 0, 300, horizon),
      [
        Color.lerp(tealDark, Colors.black, dark ? .35 : .05)!,
        Color.lerp(wood, gold, .35)!,
        Color.lerp(gold, goldLight, .3)!,
      ],
      const [0, .62, 1],
    );

    for (final star in const [
      Offset(30, 26),
      Offset(84, 18),
      Offset(120, 34),
      Offset(250, 22),
    ]) {
      canvas.drawCircle(star, 1.3, fill(goldLight));
    }
    crescent(canvas, const Offset(54, 38), 8, goldLight);

    const sun = Offset(196, horizon);
    glow(canvas, sun, 110, gold);
    canvas.drawCircle(sun, 34, fill(Color.lerp(gold, goldLight, .2)!));

    final streak = fill(goldLight.withValues(alpha: .45));
    for (final r in const [
      Rect.fromLTWH(46, 92, 92, 6),
      Rect.fromLTWH(178, 84, 84, 6),
      Rect.fromLTWH(150, 104, 66, 5),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        streak,
      );
    }

    hills(
      canvas,
      const [
        Offset(0, 134),
        Offset(90, 122),
        Offset(160, 138),
        Offset(300, 139),
      ],
      Color.lerp(tealDark, wood, .45)!.withValues(alpha: .85),
      bottom: horizon,
    );

    // Water with the sun's reflection.
    verticalGradient(canvas, const Rect.fromLTRB(0, horizon, 300, 200), [
      Color.lerp(tealDark, gold, .3)!,
      Color.lerp(tealDark, Colors.black, .3)!,
    ]);
    for (var i = 0; i < 6; i++) {
      final width = 64.0 - i * 10;
      final y = horizon + 6 + i * 7;
      canvas.drawLine(
        Offset(sun.dx - width / 2, y),
        Offset(sun.dx + width / 2, y),
        stroke(goldLight.withValues(alpha: .8 - i * .11), 2.4),
      );
    }

    // Shore with a mosque silhouette.
    hills(
      canvas,
      const [
        Offset(0, 148),
        Offset(70, 144),
        Offset(130, 146),
        Offset(150, 156),
      ],
      silhouette,
      bottom: 162,
    );
    canvas.drawRect(const Rect.fromLTRB(0, 156, 150, 162), fill(silhouette));
    mosque(canvas, const Offset(70, 148), 1.3, silhouette);
    for (final x in const [60.0, 70.0, 80.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2, 136, 4, 8),
          const Radius.circular(2),
        ),
        fill(goldLight),
      );
    }
    minaret(
      canvas,
      x: 116,
      base: 150,
      height: 66,
      width: 8,
      body: silhouette,
      cap: silhouette,
    );
    palm(canvas, const Offset(22, 152), 46, -4, silhouette);
    palm(canvas, const Offset(138, 154), 34, 4, silhouette);
    canvas.restore();
  }
}

/// A mosque among palms and dunes, anchored to the bottom-right corner so it
/// can sit behind text.
class _MosquePainter extends _ScenePainter {
  const _MosquePainter(super.colors);

  @override
  void draw(Canvas canvas) {
    const sun = Offset(206, 118);
    glow(canvas, sun, 50, gold);
    canvas.drawCircle(sun, 22, fill(Color.lerp(gold, goldLight, .25)!));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(160, 124, 44, 4),
        const Radius.circular(2),
      ),
      fill(goldLight.withValues(alpha: .8)),
    );

    hills(canvas, const [
      Offset(120, 200),
      Offset(170, 170),
      Offset(232, 162),
      Offset(300, 150),
    ], Color.lerp(teal, palette.background, .35)!);

    // Mosque body.
    canvas.drawRect(const Rect.fromLTRB(194, 146, 256, 186), fill(stone));
    canvas.drawRect(const Rect.fromLTRB(200, 138, 250, 147), fill(stone));
    canvas.drawRect(const Rect.fromLTRB(198, 136, 252, 139), fill(tealDark));
    canvas.drawPath(
      Path()
        ..moveTo(202, 137)
        ..cubicTo(198, 112, 218, 108, 225, 92)
        ..cubicTo(232, 108, 252, 112, 248, 137)
        ..close(),
      fill(teal),
    );
    canvas.drawLine(
      const Offset(225, 92),
      const Offset(225, 84),
      stroke(gold, 1.4),
    );
    crescent(canvas, const Offset(225, 80), 3.2, gold);
    for (final x in const [206.0, 214.0, 236.0, 244.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2, 140, 4, 6),
          const Radius.circular(2),
        ),
        fill(gold),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(216, 186)
        ..lineTo(216, 166)
        ..quadraticBezierTo(216, 156, 225, 152)
        ..quadraticBezierTo(234, 156, 234, 166)
        ..lineTo(234, 186)
        ..close(),
      fill(tealDark),
    );
    canvas.drawPath(
      Path()
        ..moveTo(220, 186)
        ..lineTo(220, 168)
        ..quadraticBezierTo(220, 161, 225, 158)
        ..quadraticBezierTo(230, 161, 230, 168)
        ..lineTo(230, 186)
        ..close(),
      fill(goldLight),
    );

    minaret(
      canvas,
      x: 276,
      base: 186,
      height: 116,
      width: 14,
      body: stone,
      cap: teal,
    );
    canvas.drawRect(const Rect.fromLTWH(273.5, 98, 5, 9), fill(goldLight));

    palm(canvas, const Offset(182, 190), 62, -6, tealDark);
    palm(canvas, const Offset(262, 192), 70, 8, teal);

    hills(canvas, const [
      Offset(110, 200),
      Offset(170, 182),
      Offset(240, 190),
      Offset(300, 184),
    ], Color.lerp(gold, palette.background, .25)!);
    hills(canvas, const [
      Offset(210, 200),
      Offset(256, 188),
      Offset(300, 194),
    ], tealDark);
  }
}
