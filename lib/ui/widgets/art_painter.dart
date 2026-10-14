import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

/// The illustration colours, derived from the app palette. The teal is the
/// light accent / dark selected card and the gold is the dark accent, so both
/// themes use the same two brand colours.
class ArtColors {
  ArtColors.of(this.palette)
    : dark = identical(palette, SettingsPalette.dark),
      primary = identical(palette, SettingsPalette.dark)
          ? palette.selectedCard
          : palette.accent,
      gold = SettingsPalette.dark.accent,
      surface = palette.card,
      surfaceDeep = identical(palette, SettingsPalette.dark)
          ? Color.lerp(palette.card, palette.subtitle, .22)!
          : Color.lerp(palette.card, palette.selectedCard, .2)!,
      wood = identical(palette, SettingsPalette.dark)
          ? Color.lerp(SettingsPalette.dark.accent, Colors.black, .45)!
          : palette.selectedCard;

  final SettingsPalette palette;
  final bool dark;
  final Color primary;
  final Color gold;
  final Color surface;
  final Color surfaceDeep;
  final Color wood;

  Color get primaryDeep => Color.lerp(primary, Colors.black, .3)!;
  Color get goldLight => Color.lerp(gold, Colors.white, .45)!;
  Color get woodDeep => Color.lerp(wood, Colors.black, .3)!;
}

/// Base for the app's hand-painted illustrations. Subclasses draw in
/// [canvasSize] logical units and the canvas is scaled to fit the widget.
abstract class ArtPainter extends CustomPainter {
  const ArtPainter(this.colors);
  final ArtColors colors;

  bool get dark => colors.dark;
  SettingsPalette get palette => colors.palette;
  Color get teal => colors.primary;
  Color get tealDark => colors.primaryDeep;
  Color get gold => colors.gold;
  Color get goldLight => colors.goldLight;
  Color get cream => colors.surface;
  Color get creamDark => colors.surfaceDeep;
  Color get wood => colors.wood;
  Color get woodDark => colors.woodDeep;

  /// The logical size every drawing coordinate is expressed in.
  Size get canvasSize => const Size(300, 200);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / canvasSize.width,
      size.height / canvasSize.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - canvasSize.width * scale) / 2,
      (size.height - canvasSize.height * scale) / 2,
    );
    canvas.scale(scale);
    draw(canvas);
    canvas.restore();
  }

  void draw(Canvas canvas);

  @override
  bool shouldRepaint(covariant ArtPainter oldDelegate) =>
      !identical(oldDelegate.palette, palette);

  Paint fill(Color color) => Paint()
    ..color = color
    ..isAntiAlias = true;

  Paint stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void glow(Canvas canvas, Offset center, double radius, Color color) {
    final alpha = dark ? .45 : .28;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void shadow(Canvas canvas, Path path, {double blur = 6, Offset? offset}) {
    canvas.drawPath(
      path.shift(offset ?? const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? .35 : .12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void sparkle(Canvas canvas, Offset c, double r, [Color? color]) {
    final inner = r * .28;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + inner, c.dy - inner, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + inner, c.dy + inner, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - inner, c.dy + inner, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - inner, c.dy - inner, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, fill(color ?? gold));
  }

  void crescent(Canvas canvas, Offset c, double r, Color color) {
    final path = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(
        Rect.fromCircle(center: c + Offset(r * .45, -r * .3), radius: r * .85),
      ),
    );
    canvas.drawPath(path, fill(color));
  }

  void leaf(Canvas canvas, Offset base, double length, double angle) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * .5, -length * .32, length, 0)
      ..quadraticBezierTo(length * .5, length * .32, 0, 0)
      ..close();
    canvas.drawPath(path, fill(tealDark));
    canvas.drawLine(
      Offset.zero,
      Offset(length * .85, 0),
      stroke(teal.withValues(alpha: .7), 1),
    );
    canvas.restore();
  }

  /// A small mosque silhouette whose dome sits on [base].
  void mosque(Canvas canvas, Offset base, double scale, Color color) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale);
    final paint = fill(color);
    canvas.drawRect(const Rect.fromLTWH(-18, -12, 36, 12), paint);
    final dome = Path()
      ..moveTo(-13, -12)
      ..cubicTo(-13, -26, -2, -26, 0, -34)
      ..cubicTo(2, -26, 13, -26, 13, -12)
      ..close();
    canvas.drawPath(dome, paint);
    canvas.drawRect(const Rect.fromLTWH(-24, -34, 5, 34), paint);
    canvas.drawRect(const Rect.fromLTWH(19, -34, 5, 34), paint);
    canvas.drawPath(
      Path()
        ..moveTo(-24, -34)
        ..lineTo(-21.5, -40)
        ..lineTo(-19, -34)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(19, -34)
        ..lineTo(21.5, -40)
        ..lineTo(24, -34)
        ..close(),
      paint,
    );
    canvas.restore();
  }
}
