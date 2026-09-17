import 'package:flutter/material.dart';

/// Con qué frecuencia conviene repetir un ingrediente en la semana. Alimenta al
/// planificador: la carne o el pescado se pueden comer a menudo ([free]),
/// mientras que embutidos, fritos o dulces conviene [limited]. Es una guía
/// blanda (sesga el azar), no una prohibición.
enum Repeatability { free, moderate, limited }

extension RepeatabilityInfo on Repeatability {
  /// Clave estable para serializar (no cambiar).
  String get id => switch (this) {
    Repeatability.free => 'free',
    Repeatability.moderate => 'moderate',
    Repeatability.limited => 'limited',
  };

  // El rótulo y la explicación de cada nivel están en `AppStrings`
  // (`repeatability` / `repeatabilityHint`), porque dependen del idioma.

  IconData get icon => switch (this) {
    Repeatability.free => Icons.all_inclusive,
    Repeatability.moderate => Icons.trending_flat,
    Repeatability.limited => Icons.warning_amber_outlined,
  };

  /// Objetivo blando de veces por semana. A partir de ahí el planificador
  /// penaliza fuerte los platos que usen el ingrediente. null = sin límite.
  int? get weeklySoftCap => switch (this) {
    Repeatability.free => null,
    Repeatability.moderate => 4,
    Repeatability.limited => 2,
  };
}

Repeatability repeatabilityFromId(String id) => switch (id) {
  'moderate' => Repeatability.moderate,
  'limited' => Repeatability.limited,
  _ => Repeatability.free,
};

/// Un ingrediente de la "despensa" del usuario: algo que tiene/usa, con su
/// medida casera (una loncha, un filete, una cucharada…) y sus macros por esa
/// unidad. Así no hay que pesar nada: eliges cuántas unidades y ya.
///
/// [isPreset] distingue los que trae la app de los que añade el usuario.
class PantryIngredient {
  final String name;
  final String category;

  /// Etiqueta de la unidad casera: "loncha", "filete", "unidad", "cucharada"…
  final String unit;

  /// Macros de UNA unidad.
  final int kcal;
  final int protein;

  /// Peso típico de una unidad en gramos (0 si no aplica). Sirve de referencia
  /// y para convertir desde datos por 100 g al escanear.
  final double gramsPerUnit;

  final bool isPreset;
  final Repeatability repeat;

  /// Código de barras de origen (si vino de un escaneo). Permite reconocerlo.
  final String barcode;

  /// Cuántas unidades tienes en casa ahora mismo. 0 = no lo tienes / no lo
  /// controlas. Alimenta "cocinar con lo que tengo" y la lista de la compra.
  final double stock;

  /// Fecha de caducidad de lo que tienes, si te interesa controlarla.
  final DateTime? expiry;

  const PantryIngredient({
    required this.name,
    required this.category,
    required this.unit,
    required this.kcal,
    required this.protein,
    this.gramsPerUnit = 0,
    this.isPreset = false,
    this.repeat = Repeatability.free,
    this.barcode = '',
    this.stock = 0,
    this.expiry,
  });

  /// Días que quedan para que caduque (negativo si ya caducó), o null.
  int? get daysToExpiry {
    final e = expiry;
    if (e == null) return null;
    final today = DateTime.now();
    return DateTime(
      e.year,
      e.month,
      e.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
  }

  /// True si conviene gastarlo ya (caduca en 3 días o menos).
  bool get expiresSoon {
    final d = daysToExpiry;
    return d != null && d <= 3;
  }

  // El texto de la porción ("1 loncha (≈20 g)") se arma en
  // `AppStrings.portionLabel`, porque la unidad se traduce al mostrarla.

  PantryIngredient copyWith({
    String? name,
    String? category,
    String? unit,
    int? kcal,
    int? protein,
    double? gramsPerUnit,
    bool? isPreset,
    Repeatability? repeat,
    String? barcode,
    double? stock,
    DateTime? expiry,
    bool clearExpiry = false,
  }) {
    return PantryIngredient(
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      gramsPerUnit: gramsPerUnit ?? this.gramsPerUnit,
      isPreset: isPreset ?? this.isPreset,
      repeat: repeat ?? this.repeat,
      barcode: barcode ?? this.barcode,
      stock: stock ?? this.stock,
      expiry: clearExpiry ? null : (expiry ?? this.expiry),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'unit': unit,
    'kcal': kcal,
    'protein': protein,
    'gramsPerUnit': gramsPerUnit,
    'isPreset': isPreset,
    'repeat': repeat.id,
    if (barcode.isNotEmpty) 'barcode': barcode,
    if (stock > 0) 'stock': stock,
    if (expiry != null) 'expiry': expiry!.toIso8601String().substring(0, 10),
  };

  factory PantryIngredient.fromJson(Map<String, dynamic> json) =>
      PantryIngredient(
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'Otros',
        unit: json['unit'] as String? ?? 'unidad',
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        gramsPerUnit: (json['gramsPerUnit'] as num?)?.toDouble() ?? 0,
        isPreset: json['isPreset'] as bool? ?? false,
        repeat: repeatabilityFromId(json['repeat'] as String? ?? 'free'),
        barcode: json['barcode'] as String? ?? '',
        stock: (json['stock'] as num?)?.toDouble() ?? 0,
        expiry: DateTime.tryParse((json['expiry'] as String?) ?? ''),
      );
}
