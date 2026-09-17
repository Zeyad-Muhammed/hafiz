import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class RopeRingPainter extends CustomPainter {
  RopeRingPainter({
    required this.progress,
    required this.color,
    this.darkColor,
    this.strands = 8,
    this.amplitudeFactor = 0.055,
    this.rotation = 0,
  });

  final double progress;
  final Color color;
  final Color? darkColor;
  final int strands;
  final double amplitudeFactor;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;
    final center = size.center(Offset.zero);
    final R = size.shortestSide / 2;
    final stroke = R * 0.17;
    final amp = R * amplitudeFactor;
    final waviness = strands * 2;
    final endAngle = progress * math.pi * 2;
    const steps = 120;

    for (int s = 0; s < strands; s++) {
      final phase = (math.pi * 2 / strands) * s;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = s.isEven ? color : (darkColor ?? color.withValues(alpha: 0.55));
      final path = Path();
      var started = false;
      for (int i = 0; i <= steps; i++) {
        final frac = i / steps;
        final angle = frac * math.pi * 2;
        if (angle > endAngle + 1e-9) break;
        final t = rotation + angle;
        final r = R + math.sin(waviness * t + phase) * amp;
        final pt = center + Offset(math.cos(t), math.sin(t)) * r;
        if (!started) {
          path.moveTo(pt.dx, pt.dy);
          started = true;
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RopeRingPainter old) =>
      old.progress != progress ||
      old.rotation != rotation ||
      old.color != color ||
      old.darkColor != darkColor;
}

class IslamicStarPainter extends CustomPainter {
  const IslamicStarPainter({
    required this.progress,
    required this.color,
    this.edgeColor,
  });

  final double progress;
  final Color color;
  final Color? edgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;
    final center = size.center(Offset.zero);
    final R = size.shortestSide / 2;
    final half = R * 1.18;
    final fill = Paint()..color = color.withValues(alpha: 0.95);
    final line = Paint()
      ..color = (edgeColor ?? ItisamColors.deepGreen).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = R * 0.045
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(progress, progress);

    final square = Path()
      ..addRect(Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2));
    for (final rot in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.rotate(rot);
      canvas.drawPath(square, fill);
      canvas.drawPath(square, line);
      canvas.restore();
    }

    canvas.drawCircle(Offset.zero, R * 0.4, fill);
    canvas.drawCircle(Offset.zero, R * 0.4, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslamicStarPainter old) =>
      old.progress != progress || old.color != color || old.edgeColor != edgeColor;
}