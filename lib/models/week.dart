import 'food.dart';
import 'meal_slot.dart';

/// Una semana del planificador (el equivalente a un "layer" de la app original).
///
/// El plan se guarda como un mapa de toma → lista de 7 días (lunes→domingo).
/// En modo Estándar solo habrá [MealSlot.lunch] y [MealSlot.dinner]; el Modo Gym
/// puede tener más tomas. Se conserva la migración desde el formato antiguo
/// (`lunches`/`dinners`).
class Week {
  final Map<MealSlot, List<String?>> plan;
  final Set<String> checked; // ingredientes marcados en la lista de compra
  final Set<int> locked; // días bloqueados (el randomizador no los toca)
  final Set<int> away; // días fuera de casa (ni se planifican ni se compran)
  final List<String> manualItems; // ítems añadidos a mano a la lista de compra
  bool imported;
  List<Food> embeddedFoods;

  /// Lunes al que corresponde esta semana en el calendario real, si está atada
  /// a él. null = semana suelta (comportamiento antiguo, "Semana N" sin fecha).
  DateTime? startDate;

  Week({
    Map<MealSlot, List<String?>>? plan,
    Set<String>? checked,
    Set<int>? locked,
    Set<int>? away,
    List<String>? manualItems,
    this.imported = false,
    List<Food>? embeddedFoods,
    this.startDate,
  })  : plan = plan ?? <MealSlot, List<String?>>{},
        checked = checked ?? <String>{},
        locked = locked ?? <int>{},
        away = away ?? <int>{},
        manualItems = manualItems ?? <String>[],
        embeddedFoods = embeddedFoods ?? <Food>[];

  /// El lunes de la semana en la que cae [d], a medianoche.
  static DateTime mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  /// True si [date] cae dentro de esta semana (solo si tiene fecha asignada).
  bool containsDate(DateTime date) {
    final start = startDate;
    if (start == null) return false;
    return mondayOf(date) == mondayOf(start);
  }

  /// Fecha del día [index] (0 = lunes), o null si la semana no tiene fecha.
  DateTime? dateOfDay(int index) {
    final start = startDate;
    if (start == null || index < 0 || index > 6) return null;
    return start.add(Duration(days: index));
  }

  bool isAway(int day) => away.contains(day);

  /// Lista de 7 días de una toma; la crea vacía si todavía no existía.
  List<String?> slotList(MealSlot slot) =>
      plan.putIfAbsent(slot, () => List<String?>.filled(7, null));

  String? mealAt(MealSlot slot, int day) {
    final list = plan[slot];
    if (list == null || day < 0 || day >= list.length) return null;
    return list[day];
  }

  void setMeal(MealSlot slot, int day, String? name) {
    final list = slotList(slot);
    if (day >= 0 && day < list.length) list[day] = name;
  }

  bool isLocked(int day) => locked.contains(day);

  /// Todos los nombres de platos asignados, en cualquier toma.
  Set<String> assignedNames() {
    final names = <String>{};
    for (final list in plan.values) {
      for (final n in list) {
        if (n != null) names.add(n);
      }
    }
    return names;
  }

  bool get hasMeals => plan.values.any((l) => l.any((e) => e != null));

  Map<String, dynamic> toJson() => {
        'plan': {
          for (final e in plan.entries) e.key.id: e.value,
        },
        'checked': checked.toList(),
        'locked': locked.toList(),
        'away': away.toList(),
        'manualItems': manualItems,
        'imported': imported,
        'embeddedFoods': embeddedFoods.map((f) => f.toJson()).toList(),
        if (startDate != null)
          'startDate': startDate!.toIso8601String().substring(0, 10),
      };

  factory Week.fromJson(Map<String, dynamic> json) {
    List<String?> read7(dynamic raw) {
      final list = (raw as List?)?.map((e) => e as String?).toList() ?? const [];
      final result = List<String?>.filled(7, null);
      for (var i = 0; i < 7 && i < list.length; i++) {
        result[i] = list[i];
      }
      return result;
    }

    final plan = <MealSlot, List<String?>>{};
    final rawPlan = json['plan'] as Map<String, dynamic>?;
    if (rawPlan != null) {
      for (final entry in rawPlan.entries) {
        final slot = mealSlotFromId(entry.key);
        if (slot != null) plan[slot] = read7(entry.value);
      }
    } else {
      // Migración desde el formato antiguo (lunches/dinners).
      if (json.containsKey('lunches')) {
        plan[MealSlot.lunch] = read7(json['lunches']);
      }
      if (json.containsKey('dinners')) {
        plan[MealSlot.dinner] = read7(json['dinners']);
      }
    }

    return Week(
      plan: plan,
      checked: ((json['checked'] as List?)?.map((e) => e as String).toSet()) ??
          <String>{},
      locked: ((json['locked'] as List?)?.map((e) => (e as num).toInt()).toSet()) ??
          <int>{},
      away: ((json['away'] as List?)?.map((e) => (e as num).toInt()).toSet()) ??
          <int>{},
      startDate: DateTime.tryParse((json['startDate'] as String?) ?? ''),
      manualItems:
          ((json['manualItems'] as List?)?.map((e) => e as String).toList()) ??
              <String>[],
      imported: json['imported'] as bool? ?? false,
      embeddedFoods: ((json['embeddedFoods'] as List?)
              ?.map((e) => Food.fromJson(e as Map<String, dynamic>))
              .toList()) ??
          <Food>[],
    );
  }
}
