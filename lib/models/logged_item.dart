import 'meal_slot.dart';

/// Una entrada del registro diario: algo que el usuario marcó como comido.
/// Guarda una copia de las macros (no una referencia al plato) para que el
/// registro sea estable aunque luego se edite o borre el plato del catálogo.
///
/// [slot] dice en qué toma se comió (null = suelto, p. ej. un picoteo) y
/// [minutesOfDay] a qué hora, para poder ordenar el día de forma natural.
/// [servings] permite registrar media ración o ración doble sin recalcular a
/// mano: [kcal] y [protein] son SIEMPRE los de una ración.
class LoggedItem {
  final String name;
  final int kcal;
  final int protein;
  final MealSlot? slot;
  final int? minutesOfDay;
  final double servings;

  const LoggedItem({
    required this.name,
    required this.kcal,
    required this.protein,
    this.slot,
    this.minutesOfDay,
    this.servings = 1,
  });

  /// Calorías realmente comidas (ración × cantidad).
  int get totalKcal => (kcal * servings).round();
  int get totalProtein => (protein * servings).round();

  /// "12:30", o cadena vacía si no se guardó la hora.
  String get timeLabel {
    final m = minutesOfDay;
    if (m == null) return '';
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final min = (m % 60).toString().padLeft(2, '0');
    return '$h:$min';
  }

  LoggedItem copyWith({
    String? name,
    int? kcal,
    int? protein,
    MealSlot? slot,
    int? minutesOfDay,
    double? servings,
  }) {
    return LoggedItem(
      name: name ?? this.name,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      slot: slot ?? this.slot,
      minutesOfDay: minutesOfDay ?? this.minutesOfDay,
      servings: servings ?? this.servings,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'kcal': kcal,
    'protein': protein,
    if (slot != null) 'slot': slot!.id,
    if (minutesOfDay != null) 'minutesOfDay': minutesOfDay,
    if (servings != 1) 'servings': servings,
  };

  factory LoggedItem.fromJson(Map<String, dynamic> json) => LoggedItem(
    name: json['name'] as String? ?? '',
    kcal: (json['kcal'] as num?)?.toInt() ?? 0,
    protein: (json['protein'] as num?)?.toInt() ?? 0,
    slot: mealSlotFromId(json['slot'] as String? ?? ''),
    minutesOfDay: (json['minutesOfDay'] as num?)?.toInt(),
    servings: (json['servings'] as num?)?.toDouble() ?? 1,
  );
}
