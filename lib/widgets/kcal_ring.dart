import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anillo de progreso pintado a mano (sin librerías externas).
///
/// Lo usan la tarjeta de "Hoy" y el widget de la pantalla de inicio, que se
/// dibuja fuera del árbol de la app: por eso el pintor no lee nada del `Theme`
/// y recibe todos los colores por parámetro.
class RingPainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color background;
  final double stroke;

  const RingPainter({
    required this.ratio,
    required this.color,
    required this.background,
    this.stroke = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawCircle(center, radius, basePaint);

    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio.clamp(0.0, 1.0),
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.ratio != ratio ||
      old.color != color ||
      old.background != background ||
      old.stroke != stroke;
}
