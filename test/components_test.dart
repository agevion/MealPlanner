// Tests de los platos compuestos (FoodComponent): totales y serialización.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';

void main() {
  group('FoodComponent', () {
    test('totales con cantidad', () {
      const c = FoodComponent(name: 'Pan', kcal: 120, protein: 5, quantity: 2);
      expect(c.totalKcal, 240);
      expect(c.totalProtein, 10);
    });

    test('cantidad decimal', () {
      const c = FoodComponent(name: 'Carne', kcal: 200, protein: 20, quantity: 1.5);
      expect(c.totalKcal, 300);
      expect(c.totalProtein, 30);
    });

    test('round-trip', () {
      const c = FoodComponent(name: 'X', kcal: 50, protein: 3, quantity: 0.5);
      final back = FoodComponent.fromJson(c.toJson());
      expect(back.name, 'X');
      expect(back.kcal, 50);
      expect(back.protein, 3);
      expect(back.quantity, 0.5);
    });
  });

  group('Food compuesto', () {
    final components = [
      const FoodComponent(name: 'Pan', kcal: 250, protein: 9, quantity: 1),
      const FoodComponent(name: 'Carne', kcal: 300, protein: 25, quantity: 1),
    ];

    test('sumas de macros', () {
      expect(Food.sumKcal(components), 550);
      expect(Food.sumProtein(components), 34);
    });

    test('round-trip conserva componentes y macros', () {
      final f = Food(
        name: 'Hamburguesa',
        ingredients: 'Pan, Carne',
        slots: const {MealSlot.lunch, MealSlot.dinner},
        kcal: Food.sumKcal(components),
        protein: Food.sumProtein(components),
        components: components,
      );
      final back = Food.fromJson(f.toJson());
      expect(back.isComposed, isTrue);
      expect(back.components.length, 2);
      expect(back.components.first.name, 'Pan');
      expect(back.kcal, 550);
      expect(back.protein, 34);
    });

    test('plato simple no tiene componentes', () {
      const f = Food(name: 'Tortilla', ingredients: 'huevo');
      expect(f.isComposed, isFalse);
      final back = Food.fromJson(f.toJson());
      expect(back.isComposed, isFalse);
    });
  });
}
