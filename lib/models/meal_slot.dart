import 'package:flutter/material.dart';

/// Las posibles tomas de comida del día. En modo Estándar solo se usan
/// [lunch] y [dinner] (como la app original); el Modo Gym puede activar más.
enum MealSlot { breakfast, lunch, snack, dinner, preWorkout, postWorkout }

extension MealSlotInfo on MealSlot {
  /// Clave estable para serializar (no cambiar: rompe datos guardados).
  String get id => switch (this) {
        MealSlot.breakfast => 'breakfast',
        MealSlot.lunch => 'lunch',
        MealSlot.snack => 'snack',
        MealSlot.dinner => 'dinner',
        MealSlot.preWorkout => 'pre_workout',
        MealSlot.postWorkout => 'post_workout',
      };

  // El nombre visible de cada toma vive en `AppStrings.mealSlot`, porque cambia
  // con el idioma. Aquí solo queda lo que no cambia: la clave y el icono.

  IconData get icon => switch (this) {
        MealSlot.breakfast => Icons.free_breakfast_outlined,
        MealSlot.lunch => Icons.wb_sunny_outlined,
        MealSlot.snack => Icons.cookie_outlined,
        MealSlot.dinner => Icons.nightlight_outlined,
        MealSlot.preWorkout => Icons.bolt_outlined,
        MealSlot.postWorkout => Icons.self_improvement_outlined,
      };
}

MealSlot? mealSlotFromId(String id) {
  for (final s in MealSlot.values) {
    if (s.id == id) return s;
  }
  return null;
}

/// Tomas del modo Estándar (idénticas a la app original).
const List<MealSlot> kStandardSlots = [MealSlot.lunch, MealSlot.dinner];

/// Tomas por defecto al activar el Modo Gym.
const List<MealSlot> kDefaultGymSlots = [
  MealSlot.breakfast,
  MealSlot.lunch,
  MealSlot.snack,
  MealSlot.dinner,
];
