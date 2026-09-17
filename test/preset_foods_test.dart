// Comprueba la integridad del muestrario de comidas predefinidas.

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/data/preset_foods.dart';

void main() {
  group('Muestrario de comidas', () {
    test('no está vacío', () {
      expect(kPresetFoods, isNotEmpty);
    });

    test('todos tienen nombre, ingredientes, toma y macros válidas', () {
      for (final f in kPresetFoods) {
        expect(f.name.trim(), isNotEmpty, reason: 'nombre vacío');
        expect(
          f.ingredients.trim(),
          isNotEmpty,
          reason: '${f.name} sin ingredientes',
        );
        expect(f.slots, isNotEmpty, reason: '${f.name} sin tomas');
        expect(f.hasMacros, isTrue, reason: '${f.name} sin macros');
        expect(
          f.kcal! > 0 && f.protein! >= 0,
          isTrue,
          reason: '${f.name} macros no válidas',
        );
      }
    });

    test('no hay nombres duplicados', () {
      final names = kPresetFoods.map((f) => f.name).toList();
      expect(
        names.toSet().length,
        names.length,
        reason: 'hay nombres repetidos',
      );
    });
  });
}
