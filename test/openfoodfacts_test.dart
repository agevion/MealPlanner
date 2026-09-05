// Tests del parseo de la respuesta de OpenFoodFacts (sin red).

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/data/openfoodfacts_service.dart';
import 'package:mealplanner_flutter/l10n/app_strings_es.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';

void main() {
  group('OpenFoodFacts parseProduct', () {
    test('producto no encontrado (status 0) => null', () {
      final r = OpenFoodFactsService.parseProduct({'status': 0}, '000');
      expect(r, isNull);
    });

    test('prefiere macros por ración', () {
      final r = OpenFoodFactsService.parseProduct({
        'status': 1,
        'product': {
          'product_name': 'Monster Energy',
          'nutriments': {
            'energy-kcal_serving': 210,
            'proteins_serving': 0,
            'energy-kcal_100g': 42,
            'proteins_100g': 0,
          },
        },
      }, '5060337');
      expect(r, isNotNull);
      expect(r!.food.name, 'Monster Energy');
      expect(r.food.kcal, 210);
      expect(r.food.protein, 0);
      expect(r.basis, 'serving');
      expect(r.food.slots, {MealSlot.snack});
    });

    test('cae a por 100 g si no hay por ración', () {
      final r = OpenFoodFactsService.parseProduct({
        'status': 1,
        'product': {
          'product_name': 'Atún en lata',
          'nutriments': {
            'energy-kcal_100g': 116,
            'proteins_100g': 25.5,
          },
        },
      }, '111');
      expect(r!.food.kcal, 116);
      expect(r.food.protein, 26); // redondeo
      expect(r.basis, 'per100');
    });

    test('prefiere el nombre en el idioma del usuario', () {
      const producto = {
        'status': 1,
        'product': {
          'product_name': 'Tuna',
          'product_name_es': 'Atún',
          'nutriments': {'energy-kcal_100g': 100, 'proteins_100g': 20},
        },
      };
      final es =
          OpenFoodFactsService.parseProduct(producto, '222', t: const AppStringsEs());
      expect(es!.food.name, 'Atún');

      // En inglés no hay product_name_en, así que cae al genérico.
      final en = OpenFoodFactsService.parseProduct(producto, '222');
      expect(en!.food.name, 'Tuna');
    });

    test('sin nutrientes => basis "none" y macros null', () {
      final r = OpenFoodFactsService.parseProduct({
        'status': 1,
        'product': {'product_name': 'Algo', 'nutriments': {}},
      }, '333');
      expect(r!.basis, 'none');
      expect(r.food.hasMacros, isFalse);
    });
  });
}
