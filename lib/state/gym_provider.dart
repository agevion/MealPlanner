import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../models/gym_goal.dart';
import '../models/meal_slot.dart';

// Los enums del Modo Gym viven en `models/gym_goal.dart` para que la tabla de
// textos pueda nombrarlos sin importar este fichero. Se reexportan aquí para
// que quien ya importaba el provider los siga viendo.
export '../models/gym_goal.dart';

// ---------------------------------------------------------------------------
// Cálculo de objetivos (funciones puras, reutilizadas por el provider y por la
// vista previa en vivo de la pantalla de perfil).
// ---------------------------------------------------------------------------

/// Metabolismo basal según la fórmula de Mifflin-St Jeor.
double gymBmr(double weightKg, double heightCm, int age, Sex sex) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return sex == Sex.male ? base + 5 : base - 161;
}

/// Gasto energético diario total (BMR × factor de actividad).
int gymTdee(
  double weightKg,
  double heightCm,
  int age,
  Sex sex,
  ActivityLevel activity,
) =>
    (gymBmr(weightKg, heightCm, age, sex) * activity.factor).round();

/// Calorías objetivo a partir del gasto, ajustadas por objetivo.
int gymTargetKcal(int tdee, GymGoal goal) => switch (goal) {
      GymGoal.volume => (tdee * 1.12).round(), // ~+12 %
      GymGoal.definition => (tdee * 0.80).round(), // ~−20 %
      GymGoal.maintenance => tdee,
      GymGoal.custom => tdee,
    };

/// Proteína objetivo en gramos, según objetivo y peso corporal.
int gymTargetProtein(double weightKg, GymGoal goal) {
  final perKg = switch (goal) {
    GymGoal.volume => 2.0,
    GymGoal.definition => 2.2,
    GymGoal.maintenance => 1.8,
    GymGoal.custom => 2.0,
  };
  return (weightKg * perKg).round();
}

/// Estado del Modo Gym: activación, objetivo y perfil del usuario. De aquí
/// salen los objetivos calculados de kcal y proteína. Más adelante colgarán de
/// aquí también las macros por plato, el registro y la gamificación.
class GymProvider extends ChangeNotifier {
  static const _kEnabled = 'gym_mode_enabled';
  static const _kGoal = 'gym_goal';
  static const _kWeight = 'gym_weight';
  static const _kHeight = 'gym_height';
  static const _kAge = 'gym_age';
  static const _kSex = 'gym_sex';
  static const _kActivity = 'gym_activity';
  static const _kCustomKcal = 'gym_custom_kcal';
  static const _kCustomProtein = 'gym_custom_protein';
  static const _kMealSlots = 'gym_meal_slots';

  SharedPreferences? _prefs;

  bool _enabled = false;
  GymGoal? _goal;

  double _weightKg = 0;
  double _heightCm = 0;
  int _age = 0;
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  int? _customKcal;
  int? _customProtein;
  List<MealSlot> _mealSlots = List.of(kDefaultGymSlots);

  bool get enabled => _enabled;
  GymGoal? get goal => _goal;
  List<MealSlot> get mealSlots => List.unmodifiable(_mealSlots);

  /// Tomas que deben mostrarse/planificarse ahora mismo: las configuradas si el
  /// Modo Gym está activo, o las del modo Estándar (almuerzo + cena) si no.
  List<MealSlot> get activeMealSlots =>
      _enabled && _mealSlots.isNotEmpty ? _mealSlots : kStandardSlots;
  double get weightKg => _weightKg;
  double get heightCm => _heightCm;
  int get age => _age;
  Sex get sex => _sex;
  ActivityLevel get activity => _activity;
  int? get customKcal => _customKcal;
  int? get customProtein => _customProtein;

  bool get hasProfile => _weightKg > 0 && _heightCm > 0 && _age > 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _enabled = _prefs!.getBool(_kEnabled) ?? false;

    final g = _prefs!.getInt(_kGoal);
    if (g != null && g >= 0 && g < GymGoal.values.length) {
      _goal = GymGoal.values[g];
    }

    _weightKg = _prefs!.getDouble(_kWeight) ?? 0;
    _heightCm = _prefs!.getDouble(_kHeight) ?? 0;
    _age = _prefs!.getInt(_kAge) ?? 0;

    final s = _prefs!.getInt(_kSex);
    if (s != null && s >= 0 && s < Sex.values.length) _sex = Sex.values[s];

    final a = _prefs!.getInt(_kActivity);
    if (a != null && a >= 0 && a < ActivityLevel.values.length) {
      _activity = ActivityLevel.values[a];
    }

    _customKcal = _prefs!.getInt(_kCustomKcal);
    _customProtein = _prefs!.getInt(_kCustomProtein);

    final slotIds = _prefs!.getStringList(_kMealSlots);
    if (slotIds != null) {
      final parsed =
          slotIds.map(mealSlotFromId).whereType<MealSlot>().toList();
      if (parsed.isNotEmpty) _mealSlots = parsed;
    }

    notifyListeners();
  }

  /// Activa o desactiva una toma. No deja la lista vacía (siempre queda ≥1).
  void toggleMealSlot(MealSlot slot) {
    final next = List<MealSlot>.of(_mealSlots);
    if (next.contains(slot)) {
      if (next.length <= 1) return;
      next.remove(slot);
    } else {
      next.add(slot);
    }
    // Orden canónico según el enum (desayuno → almuerzo → ... → post-entreno).
    next.sort((a, b) => a.index.compareTo(b.index));
    _mealSlots = next;
    _prefs?.setStringList(_kMealSlots, next.map((s) => s.id).toList());
    notifyListeners();
  }

  void setEnabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    _prefs?.setBool(_kEnabled, value);
    notifyListeners();
  }

  void setGoal(GymGoal goal) {
    if (goal == _goal) return;
    _goal = goal;
    _prefs?.setInt(_kGoal, goal.index);
    notifyListeners();
  }

  void saveProfile({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
    required ActivityLevel activity,
  }) {
    _weightKg = weightKg;
    _heightCm = heightCm;
    _age = age;
    _sex = sex;
    _activity = activity;
    _prefs?.setDouble(_kWeight, weightKg);
    _prefs?.setDouble(_kHeight, heightCm);
    _prefs?.setInt(_kAge, age);
    _prefs?.setInt(_kSex, sex.index);
    _prefs?.setInt(_kActivity, activity.index);
    notifyListeners();
  }

  void setCustomTargets({int? kcal, int? protein}) {
    _customKcal = kcal;
    _customProtein = protein;
    if (kcal != null) {
      _prefs?.setInt(_kCustomKcal, kcal);
    } else {
      _prefs?.remove(_kCustomKcal);
    }
    if (protein != null) {
      _prefs?.setInt(_kCustomProtein, protein);
    } else {
      _prefs?.remove(_kCustomProtein);
    }
    notifyListeners();
  }

  /// Gasto energético diario estimado, o null si el perfil está incompleto.
  int? get tdee {
    if (!hasProfile) return null;
    return gymTdee(_weightKg, _heightCm, _age, _sex, _activity);
  }

  /// Calorías objetivo del día según el objetivo actual.
  int? get targetKcal {
    if (_goal == GymGoal.custom) return _customKcal ?? tdee;
    final t = tdee;
    if (t == null || _goal == null) return null;
    return gymTargetKcal(t, _goal!);
  }

  /// Sugiere ajustar las calorías si el peso no se mueve como debería.
  ///
  /// [weightChangePerWeek] es el cambio medio semanal en kg (positivo = subes).
  /// Devuelve null si no hay nada que ajustar o falta información. La app solo
  /// lo sugiere: el cambio lo aplica el usuario.
  ({int newKcal, String reason})? suggestKcalAdjustment(
    double? weightChangePerWeek, {
    AppStrings t = const AppStrings(),
  }) {
    final current = targetKcal;
    final goal = _goal;
    if (current == null || goal == null || weightChangePerWeek == null) {
      return null;
    }

    // Rangos razonables: en volumen se busca subir poco a poco; en definición,
    // bajar despacio para no perder músculo.
    return switch (goal) {
      GymGoal.volume when weightChangePerWeek < 0.1 => (
          newKcal: current + 150,
          reason: t.gymNotGaining,
        ),
      GymGoal.volume when weightChangePerWeek > 0.5 => (
          newKcal: current - 150,
          reason: t.gymGainingTooFast,
        ),
      GymGoal.definition when weightChangePerWeek > -0.1 => (
          newKcal: current - 150,
          reason: t.gymNotLosing,
        ),
      GymGoal.definition when weightChangePerWeek < -1.0 => (
          newKcal: current + 150,
          reason: t.gymLosingTooFast,
        ),
      _ => null,
    };
  }

  /// Proteína objetivo del día (gramos) según el objetivo actual.
  int? get targetProtein {
    if (_goal == GymGoal.custom) {
      return _customProtein ??
          (_weightKg > 0 ? gymTargetProtein(_weightKg, GymGoal.volume) : null);
    }
    if (_weightKg <= 0 || _goal == null) return null;
    return gymTargetProtein(_weightKg, _goal!);
  }
}
