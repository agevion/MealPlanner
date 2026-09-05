import 'package:flutter/material.dart';

/// Los objetivos del Modo Gym, en lenguaje plano (sin "V"/"Df").
///
/// Viven aquí, y no en `GymProvider`, para que la tabla de textos
/// (`lib/l10n`) pueda nombrarlos sin depender del estado de la app: si los
/// enums estuvieran en el provider y el provider necesitase los textos, los dos
/// ficheros se importarían en círculo.
enum GymGoal { volume, definition, maintenance, custom }

extension GymGoalInfo on GymGoal {
  // El nombre y la descripción de cada objetivo están en `AppStrings.gymGoal` y
  // `AppStrings.gymGoalDescription`, porque cambian con el idioma.

  IconData get icon => switch (this) {
        GymGoal.volume => Icons.trending_up,
        GymGoal.definition => Icons.local_fire_department,
        GymGoal.maintenance => Icons.balance,
        GymGoal.custom => Icons.tune,
      };
}

enum Sex { male, female }

/// Nivel de actividad para estimar el gasto calórico. Su nombre y su
/// descripción (pensadas para alguien que va al gimnasio) están en
/// `AppStrings.activity` y `AppStrings.activityDescription`.
enum ActivityLevel { sedentary, light, moderate, active, veryActive }

extension ActivityInfo on ActivityLevel {
  double get factor => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}
