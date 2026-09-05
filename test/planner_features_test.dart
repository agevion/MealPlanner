// Tests de las funciones nuevas: edición manual del plan, bloqueo de días,
// conteo de usos e ítems manuales de la lista de compra.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';
import 'package:mealplanner_flutter/state/meal_provider.dart';

void main() {
  group('Edición manual del plan', () {
    test('setMeal y clearDay', () {
      final p = MealProvider();
      p.setMeal(0, MealSlot.lunch, 'Pollo');
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Pollo');
      p.clearDay(0);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), isNull);
    });

    test('setMeal con cadena vacía vacía la celda', () {
      final p = MealProvider();
      p.setMeal(1, MealSlot.dinner, 'Algo');
      p.setMeal(1, MealSlot.dinner, '');
      expect(p.activeWeek.mealAt(MealSlot.dinner, 1), isNull);
    });
  });

  group('Días bloqueados', () {
    test('el randomizador no toca los días bloqueados', () {
      final p = MealProvider();
      p.addFood(const Food(
          name: 'Almuerzo1', ingredients: 'a', slots: {MealSlot.lunch}));
      p.addFood(const Food(
          name: 'Cena1', ingredients: 'b', slots: {MealSlot.dinner}));

      // Fijamos a mano el lunes y lo bloqueamos.
      p.setMeal(0, MealSlot.lunch, 'FIJADO');
      p.toggleDayLock(0);
      expect(p.isDayLocked(0), isTrue);

      final error = p.randomizeActiveWeek(const [MealSlot.lunch, MealSlot.dinner]);
      expect(error, isNull);

      // El día bloqueado se conserva; el resto se rellena.
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'FIJADO');
      expect(p.activeWeek.mealAt(MealSlot.lunch, 1), 'Almuerzo1');
    });
  });

  group('Conteo de usos', () {
    test('foodUsageCounts cuenta cada aparición', () {
      final p = MealProvider();
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.setMeal(1, MealSlot.lunch, 'Pasta');
      p.setMeal(2, MealSlot.dinner, 'Pollo');
      final counts = p.foodUsageCounts();
      expect(counts['Pasta'], 2);
      expect(counts['Pollo'], 1);
    });
  });

  group('Ítems manuales de la compra', () {
    test('se añaden, no se duplican y se borran', () {
      final p = MealProvider();
      p.addManualShoppingItem('Servilletas');
      p.addManualShoppingItem('servilletas'); // duplicado (otra capitalización)
      var groups = p.shoppingListForActiveWeek();
      final manual = groups.where((g) => g.manual).toList();
      expect(manual.length, 1);
      expect(manual.single.name, 'Servilletas');

      p.removeManualShoppingItem('Servilletas');
      groups = p.shoppingListForActiveWeek();
      expect(groups.where((g) => g.manual), isEmpty);
    });
  });
}
