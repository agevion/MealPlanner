import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Porción recordada para un producto: si lo mediste en unidades caseras
/// (loncha, filete…) o en gramos, y con qué valores. Así, la segunda vez que
/// escaneas tu queso de siempre, el selector aparece ya con "2 lonchas".
class RememberedPortion {
  /// Etiqueta de la unidad ("loncha", "filete"…). Vacío = se midió en gramos.
  final String unit;

  /// Peso típico de una unidad (solo si [unit] no está vacío).
  final double gramsPerUnit;

  /// Nº de unidades (modo unidades) o gramos totales (modo gramos).
  final double value;

  const RememberedPortion({
    this.unit = '',
    this.gramsPerUnit = 0,
    this.value = 0,
  });

  bool get isGrams => unit.isEmpty;

  Map<String, dynamic> toJson() => {
    'unit': unit,
    'gramsPerUnit': gramsPerUnit,
    'value': value,
  };

  factory RememberedPortion.fromJson(Map<String, dynamic> j) =>
      RememberedPortion(
        unit: j['unit'] as String? ?? '',
        gramsPerUnit: (j['gramsPerUnit'] as num?)?.toDouble() ?? 0,
        value: (j['value'] as num?)?.toDouble() ?? 0,
      );
}

/// Recuerda por código de barras la última porción elegida. Es un almacén
/// minúsculo y tolerante a fallos: si algo va mal, simplemente no recuerda nada.
class PortionMemory {
  static const _prefix = 'portion_v2_';

  static Future<RememberedPortion?> last(String barcode) async {
    if (barcode.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$barcode');
      if (raw == null || raw.isEmpty) return null;
      return RememberedPortion.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> remember(
    String barcode,
    RememberedPortion portion,
  ) async {
    if (barcode.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$barcode', jsonEncode(portion.toJson()));
    } catch (_) {
      // Sin memoria de porción no pasa nada: el usuario la vuelve a poner.
    }
  }
}
