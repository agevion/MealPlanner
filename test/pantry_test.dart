// Tests de la despensa: modelo PantryIngredient, mapa de repetibilidad y el
// sesgo del randomizador para no repetir ingredientes marcados.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/l10n/app_strings.dart';
import 'package:mealplanner_flutter/l10n/app_strings_es.dart';

import 'package:mealplanner_flutter/data/common_ingredients.dart';
import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';
import 'package:mealplanner_flutter/models/pantry_ingredient.dart';
import 'package:mealplanner_flutter/state/meal_provider.dart';
import 'package:mealplanner_flutter/state/pantry_provider.dart';

void main() {
  group('Modelo PantryIngredient', () {
    test('round trip JSON', () {
      const ing = PantryIngredient(
        name: 'Queso havarti',
        category: 'Lácteos y huevos',
        unit: 'loncha',
        kcal: 65,
        protein: 4,
        gramsPerUnit: 18,
        repeat: Repeatability.moderate,
        barcode: '12345',
      );
      final back = PantryIngredient.fromJson(ing.toJson());
      expect(back.name, ing.name);
      expect(back.unit, 'loncha');
      expect(back.kcal, 65);
      expect(back.gramsPerUnit, 18);
      expect(back.repeat, Repeatability.moderate);
      expect(back.barcode, '12345');
    });

    test('portionLabel con y sin gramos, traducido', () {
      const es = AppStringsEs();
      expect(es.portionLabel('loncha', 20), '1 loncha (≈20 g)');
      expect(es.portionLabel('unidad', 0), '1 unidad');
      // El mismo ingrediente guardado se enseña en el idioma activo.
      const en = AppStrings();
      expect(en.portionLabel('loncha', 20), '1 slice (≈20 g)');
    });

    test('repeatabilityFromId tolera valores desconocidos', () {
      expect(repeatabilityFromId('limited'), Repeatability.limited);
      expect(repeatabilityFromId('???'), Repeatability.free);
    });
  });

  group('Semilla de la despensa', () {
    test('no está vacía y todos son válidos', () {
      expect(kPresetIngredients, isNotEmpty);
      for (final i in kPresetIngredients) {
        expect(i.name.trim(), isNotEmpty);
        expect(i.unit.trim(), isNotEmpty);
        expect(i.isPreset, isTrue);
        expect(kIngredientCategories, contains(i.category));
      }
    });
  });

  group('PantryProvider.repeatabilityByName', () {
    test('ante nombres duplicados se queda con el más restrictivo', () {
      final p = PantryProvider();
      p.addOrReplace(
        const PantryIngredient(
          name: 'Atún',
          category: 'Proteínas',
          unit: 'lata',
          kcal: 60,
          protein: 14,
          repeat: Repeatability.moderate,
        ),
      );
      // Mismo nombre normalizado con repetibilidad más restrictiva.
      p.addOrReplace(
        const PantryIngredient(
          name: 'atún',
          category: 'Proteínas',
          unit: 'lata',
          kcal: 60,
          protein: 14,
          repeat: Repeatability.limited,
        ),
      );
      // Las claves van normalizadas SIN acentos, para que "atún" y "atun"
      // se traten como el mismo ingrediente.
      final map = p.repeatabilityByName();
      expect(map['atun'], Repeatability.limited);
      expect(map.containsKey('atún'), isFalse);
    });
  });

  group('Repetibilidad en el randomizador', () {
    test('un ingrediente "limitar" aparece menos que uno libre', () {
      const repeat = {
        'chorizo': Repeatability.limited,
        'pollo': Repeatability.free,
      };
      var chorizo = 0;
      var pollo = 0;
      for (var run = 0; run < 60; run++) {
        final p = MealProvider();
        p.addFood(
          const Food(
            name: 'Plato de chorizo',
            ingredients: 'chorizo, arroz',
            slots: {MealSlot.lunch},
          ),
        );
        p.addFood(
          const Food(
            name: 'Plato de pollo',
            ingredients: 'pollo, arroz',
            slots: {MealSlot.lunch},
          ),
        );
        p.randomizeActiveWeek(const [
          MealSlot.lunch,
        ], repeatByIngredient: repeat);
        for (var d = 0; d < 7; d++) {
          switch (p.activeWeek.mealAt(MealSlot.lunch, d)) {
            case 'Plato de chorizo':
              chorizo++;
            case 'Plato de pollo':
              pollo++;
          }
        }
      }
      // Con la penalización, el plato con chorizo (limitado) debe salir
      // claramente menos que el de pollo (libre).
      expect(pollo, greaterThan(chorizo));
    });
  });
}
