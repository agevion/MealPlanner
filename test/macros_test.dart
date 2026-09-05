// Tests de las macros (kcal/proteína) por plato y la etiqueta automática.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';

void main() {
  group('Food macros', () {
    test('plato antiguo sin macros => hasMacros false', () {
      final f = Food.fromJson({'name': 'A', 'ingredients': 'x'});
      expect(f.hasMacros, isFalse);
      expect(f.kcal, isNull);
      expect(f.protein, isNull);
    });

    test('round-trip conserva kcal y proteína', () {
      const f = Food(
        name: 'Pollo con arroz',
        ingredients: 'pollo, arroz',
        slots: {MealSlot.lunch},
        kcal: 600,
        protein: 45,
      );
      final back = Food.fromJson(f.toJson());
      expect(back.kcal, 600);
      expect(back.protein, 45);
      expect(back.hasMacros, isTrue);
    });

    test('toJson omite las macros cuando son null', () {
      const f = Food(name: 'A', ingredients: 'x');
      final j = f.toJson();
      expect(j.containsKey('kcal'), isFalse);
      expect(j.containsKey('protein'), isFalse);
    });

    test('isHighProtein: pechuga de pollo es alta en proteína', () {
      // 165 kcal, 31 g proteína => 31*4/165 = 0.75 (>= 0.30)
      const f = Food(
        name: 'Pechuga',
        ingredients: 'pollo',
        kcal: 165,
        protein: 31,
      );
      expect(f.isHighProtein, isTrue);
    });

    test('isHighProtein: plato calórico bajo en proteína => false', () {
      // 800 kcal, 15 g proteína => 15*4/800 = 0.075 (< 0.30)
      const f = Food(
        name: 'Pasta carbonara',
        ingredients: 'pasta, nata',
        kcal: 800,
        protein: 15,
      );
      expect(f.isHighProtein, isFalse);
    });

    test('isHighProtein: sin macros => false', () {
      const f = Food(name: 'A', ingredients: 'x');
      expect(f.isHighProtein, isFalse);
    });
  });
}
