// Tests de la migración del modelo de datos a tomas (MealSlot).
// Protegen que los datos antiguos (lunches/dinners, isLunch/isDinner, formato
// Android esAlmuerzo/esCena) se sigan leyendo sin pérdida.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';
import 'package:mealplanner_flutter/models/week.dart';

void main() {
  group('Food', () {
    test('formato antiguo isLunch/isDinner', () {
      final f = Food.fromJson(
          {'name': 'A', 'ingredients': 'x', 'isLunch': true, 'isDinner': false});
      expect(f.slots, {MealSlot.lunch});
    });

    test('formato Android esAlmuerzo/esCena', () {
      final f = Food.fromJson({
        'name': 'A',
        'ingredients': 'x',
        'esAlmuerzo': false,
        'esCena': true,
      });
      expect(f.slots, {MealSlot.dinner});
    });

    test('ambas tomas falsas => vale para almuerzo y cena', () {
      final f = Food.fromJson(
          {'name': 'A', 'ingredients': 'x', 'isLunch': false, 'isDinner': false});
      expect(f.slots, {MealSlot.lunch, MealSlot.dinner});
    });

    test('formato nuevo slots', () {
      final f = Food.fromJson({
        'name': 'A',
        'ingredients': 'x',
        'slots': ['breakfast', 'snack'],
      });
      expect(f.slots, {MealSlot.breakfast, MealSlot.snack});
    });

    test('round-trip conserva slots y compatibilidad legacy', () {
      const f = Food(
        name: 'A',
        ingredients: 'x',
        slots: {MealSlot.breakfast, MealSlot.dinner},
      );
      final j = f.toJson();
      expect(j['isDinner'], true);
      expect(j['isLunch'], false);
      final back = Food.fromJson(j);
      expect(back.slots, {MealSlot.breakfast, MealSlot.dinner});
    });
  });

  group('Week', () {
    test('migración desde lunches/dinners', () {
      final w = Week.fromJson({
        'lunches': ['L0', null, null, null, null, null, null],
        'dinners': [null, 'D1', null, null, null, null, null],
        'checked': <String>[],
      });
      expect(w.mealAt(MealSlot.lunch, 0), 'L0');
      expect(w.mealAt(MealSlot.dinner, 1), 'D1');
      expect(w.mealAt(MealSlot.lunch, 1), isNull);
    });

    test('formato nuevo plan', () {
      final w = Week.fromJson({
        'plan': {
          'breakfast': ['B0', null, null, null, null, null, null],
          'lunch': [null, 'L1', null, null, null, null, null],
        },
      });
      expect(w.mealAt(MealSlot.breakfast, 0), 'B0');
      expect(w.mealAt(MealSlot.lunch, 1), 'L1');
    });

    test('round-trip conserva el plan', () {
      final w = Week();
      w.setMeal(MealSlot.snack, 3, 'S3');
      w.setMeal(MealSlot.dinner, 6, 'D6');
      final back = Week.fromJson(w.toJson());
      expect(back.mealAt(MealSlot.snack, 3), 'S3');
      expect(back.mealAt(MealSlot.dinner, 6), 'D6');
    });

    test('assignedNames recoge todas las tomas', () {
      final w = Week();
      w.setMeal(MealSlot.breakfast, 0, 'Avena');
      w.setMeal(MealSlot.lunch, 0, 'Pollo');
      expect(w.assignedNames(), {'Avena', 'Pollo'});
    });
  });
}
