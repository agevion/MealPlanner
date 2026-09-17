import 'package:flutter/material.dart';

/// Banderitas dibujadas a mano para el selector de idioma.
///
/// Se pintan con `CustomPaint` en vez de usar emojis (🇬🇧, 🇪🇸…) a propósito:
/// los emojis de bandera no se renderizan en Windows ni en algunas fuentes de
/// Android, y ahí se verían como dos letras sueltas ("GB"). Así se ven igual en
/// todas partes y se pueden escalar sin perder nitidez.
class FlagIcon extends StatelessWidget {
  /// Código de idioma: en, es, fr, it, de.
  final String code;
  final double width;

  const FlagIcon({super.key, required this.code, this.width = 30});

  @override
  Widget build(BuildContext context) {
    final height = width * 2 / 3;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _FlagPainter(
            code: code,
            border: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final String code;
  final Color border;
  const _FlagPainter({required this.code, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    switch (code) {
      case 'es':
        _horizontal(canvas, size, const [
          (0.25, Color(0xFFAA151B)),
          (0.50, Color(0xFFF1BF00)),
          (0.25, Color(0xFFAA151B)),
        ]);
      case 'de':
        _horizontal(canvas, size, const [
          (1 / 3, Color(0xFF000000)),
          (1 / 3, Color(0xFFDD0000)),
          (1 / 3, Color(0xFFFFCE00)),
        ]);
      case 'fr':
        _vertical(canvas, size, const [
          Color(0xFF002395),
          Color(0xFFFFFFFF),
          Color(0xFFED2939),
        ]);
      case 'it':
        _vertical(canvas, size, const [
          Color(0xFF008C45),
          Color(0xFFF4F5F0),
          Color(0xFFCD212A),
        ]);
      default:
        _unionJack(canvas, size);
    }

    // Un borde finito para que el blanco de las banderas no se funda con el
    // fondo de la tarjeta en modo claro.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );
  }

  /// Bandas horizontales: cada una con su fracción de la altura y su color.
  void _horizontal(Canvas canvas, Size size, List<(double, Color)> bands) {
    var y = 0.0;
    for (final (fraction, color) in bands) {
      final h = size.height * fraction;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, h + 0.5),
        Paint()..color = color,
      );
      y += h;
    }
  }

  /// Tricolor vertical (tres franjas iguales).
  void _vertical(Canvas canvas, Size size, List<Color> colors) {
    final w = size.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * w, 0, w + 0.5, size.height),
        Paint()..color = colors[i],
      );
    }
  }

  /// Union Jack simplificada: fondo azul, aspa blanca, aspa roja encima y la
  /// cruz de San Jorge (roja con ribete blanco) por delante.
  void _unionJack(Canvas canvas, Size size) {
    const blue = Color(0xFF012169);
    const red = Color(0xFFC8102E);
    const white = Color(0xFFFFFFFF);
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = blue);
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    void diagonals(Color color, double stroke) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset.zero, Offset(w, h), paint);
      canvas.drawLine(Offset(w, 0), Offset(0, h), paint);
    }

    diagonals(white, h * 0.30);
    diagonals(red, h * 0.13);

    // Cruz de San Jorge: primero el ribete blanco, luego la cruz roja.
    void cross(Color color, double thickness) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(0, (h - thickness) / 2, w, thickness),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH((w - thickness) / 2, 0, thickness, h),
        paint,
      );
    }

    cross(white, h * 0.34);
    cross(red, h * 0.20);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlagPainter old) =>
      old.code != code || old.border != border;
}
