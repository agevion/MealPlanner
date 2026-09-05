// Tests de lo que entra en la V2: renombrado de platos, normalización de texto,
// fechas de semana, lista de la compra con cantidades y pasillos, registro
// diario ampliado y copia de seguridad.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mealplanner_flutter/data/achievements.dart';
import 'package:mealplanner_flutter/l10n/app_strings_es.dart';
import 'package:mealplanner_flutter/data/backup_service.dart';
import 'package:mealplanner_flutter/data/text_utils.dart';
import 'package:mealplanner_flutter/models/ai_estimate.dart';
import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/logged_item.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';
import 'package:mealplanner_flutter/models/pantry_ingredient.dart';
import 'package:mealplanner_flutter/models/week.dart';
import 'package:mealplanner_flutter/state/diary_provider.dart';
import 'package:mealplanner_flutter/state/gym_provider.dart';
import 'package:mealplanner_flutter/state/meal_provider.dart';
import 'package:mealplanner_flutter/state/pantry_provider.dart';

void main() {
  group('Normalización de texto', () {
    test('quita acentos y respeta la ñ', () {
      expect(normalizeText('Atún'), 'atun');
      expect(normalizeText('  JAMÓN Serrano '), 'jamon serrano');
      expect(normalizeText('Piña'), 'piña');
    });

    test('keywordsOf descarta relleno y palabras cortas', () {
      expect(keywordsOf('Atún en lata (al natural)'),
          containsAll(<String>['atun', 'lata', 'natural']));
      expect(keywordsOf('Atún en lata'), isNot(contains('en')));
    });

    test('ingredientsMatch cruza nombres parciales', () {
      expect(ingredientsMatch('Pechuga de pollo', 'pollo'), isTrue);
      expect(ingredientsMatch('pollo', 'Pechuga de pollo'), isTrue);
      expect(ingredientsMatch('Atún', 'atun'), isTrue);
      expect(ingredientsMatch('Pechuga de pollo', 'ternera'), isFalse);
    });

    test('splitIngredients limpia y descarta vacíos', () {
      expect(splitIngredients('tomate, , pasta ,queso'),
          ['tomate', 'pasta', 'queso']);
    });
  });

  group('Renombrar platos', () {
    test('renombrar actualiza el catálogo y las semanas planificadas', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta, tomate'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.setMeal(3, MealSlot.dinner, 'Pasta');

      p.addOrReplaceFood(
        const Food(name: 'Pasta con tomate', ingredients: 'pasta, tomate'),
        previousName: 'Pasta',
      );

      // El viejo desaparece y no queda duplicado.
      expect(p.foods.length, 1);
      expect(p.foods.first.name, 'Pasta con tomate');
      expect(p.catalogContains('Pasta'), isFalse);

      // Y el plan apunta al nombre nuevo, no a un plato fantasma.
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Pasta con tomate');
      expect(p.activeWeek.mealAt(MealSlot.dinner, 3), 'Pasta con tomate');
    });

    test('guardar sin cambiar el nombre no borra nada', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.addOrReplaceFood(
        const Food(name: 'Pasta', ingredients: 'pasta, atún'),
        previousName: 'Pasta',
      );
      expect(p.foods.length, 1);
      expect(p.foods.first.ingredients, 'pasta, atún');
    });

    test('fusionar mueve el plan al plato destino', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.addFood(const Food(name: 'Macarrones', ingredients: 'pasta'));
      p.setMeal(1, MealSlot.lunch, 'Pasta');

      expect(p.mergeFoods('Pasta', 'Macarrones'), isTrue);
      expect(p.catalogContains('Pasta'), isFalse);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 1), 'Macarrones');
    });
  });

  group('Semanas atadas al calendario', () {
    test('mondayOf devuelve siempre el lunes de esa semana', () {
      // 2026-08-09 es domingo; su lunes es el 3.
      final monday = Week.mondayOf(DateTime(2026, 8, 9));
      expect(monday, DateTime(2026, 8, 3));
      expect(Week.mondayOf(DateTime(2026, 8, 3)), DateTime(2026, 8, 3));
    });

    test('containsDate reconoce los días de su semana', () {
      final w = Week(startDate: DateTime(2026, 8, 3));
      expect(w.containsDate(DateTime(2026, 8, 5)), isTrue);
      expect(w.containsDate(DateTime(2026, 8, 9)), isTrue);
      expect(w.containsDate(DateTime(2026, 8, 10)), isFalse);
    });

    test('dateOfDay mapea lunes→domingo', () {
      final w = Week(startDate: DateTime(2026, 8, 3));
      expect(w.dateOfDay(0), DateTime(2026, 8, 3));
      expect(w.dateOfDay(6), DateTime(2026, 8, 9));
      expect(w.dateOfDay(7), isNull);
    });

    test('la fecha sobrevive al round-trip JSON', () {
      final w = Week(startDate: DateTime(2026, 8, 3), away: {2});
      final copy = Week.fromJson(w.toJson());
      expect(copy.startDate, DateTime(2026, 8, 3));
      expect(copy.isAway(2), isTrue);
    });

    test('weekForDate cae en la semana activa si ninguna cubre la fecha', () {
      final p = MealProvider();
      expect(p.weekForDate(DateTime(2030, 1, 1)), p.activeWeek);
    });

    test('duplicar semana copia el plan sin tocar el original', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');

      expect(p.duplicateWeek(0), isTrue);
      expect(p.weeks.length, 2);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Pasta');

      p.setMeal(0, MealSlot.lunch, null);
      expect(p.weeks[0].mealAt(MealSlot.lunch, 0), 'Pasta');
    });
  });

  group('Días fuera de casa', () {
    test('marcar un día como fuera lo vacía y el randomizador lo salta', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(2, MealSlot.lunch, 'Pasta');

      p.toggleDayAway(2);
      expect(p.activeWeek.isAway(2), isTrue);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 2), isNull);

      p.randomizeActiveWeek(kStandardSlots);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 2), isNull);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), isNotNull);
    });
  });

  group('Randomizar solo huecos', () {
    test('no toca lo que ya estaba puesto', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.addFood(const Food(name: 'Arroz', ingredients: 'arroz'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');

      p.randomizeActiveWeek(kStandardSlots, onlyEmpty: true);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Pasta');
      expect(p.activeWeek.mealAt(MealSlot.dinner, 0), isNotNull);
    });
  });

  group('Rotación de una comida', () {
    test('no toca un día bloqueado', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.toggleDayLock(0);

      expect(p.rotateMeal(0, MealSlot.lunch), RotateResult.locked);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Pasta');
    });

    test('avisa si no hay comidas para esa toma', () {
      final p = MealProvider();
      expect(p.rotateMeal(0, MealSlot.lunch), RotateResult.noFoods);
    });

    test('no repite el plato que ya está en otra toma del mismo día', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.addFood(const Food(name: 'Arroz', ingredients: 'arroz'));
      p.setMeal(0, MealSlot.dinner, 'Pasta');

      expect(p.rotateMeal(0, MealSlot.lunch), RotateResult.ok);
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Arroz');
    });
  });

  group('Lista de la compra', () {
    test('agrupa por pasillo usando la despensa', () {
      final p = MealProvider();
      p.addFood(const Food(
          name: 'Pollo con arroz', ingredients: 'pechuga de pollo, arroz'));
      p.setMeal(0, MealSlot.lunch, 'Pollo con arroz');

      const pantry = [
        PantryIngredient(
            name: 'Pechuga de pollo',
            category: 'Proteínas',
            unit: 'filete',
            kcal: 155,
            protein: 29),
      ];

      final groups = p.shoppingListForActiveWeek(pantry: pantry);
      final pollo = groups.firstWhere((g) => g.name.contains('ollo'));
      expect(pollo.category, 'Proteínas');
      // El arroz no está en la despensa: cae en "Otros".
      final arroz = groups.firstWhere((g) => g.name.toLowerCase() == 'arroz');
      expect(arroz.category, 'Otros');
    });

    test('cuenta las veces que se cocina un plato', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta, tomate'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.setMeal(1, MealSlot.lunch, 'Pasta');
      p.setMeal(2, MealSlot.dinner, 'Pasta');

      final groups = p.shoppingListForActiveWeek();
      final pasta = groups.firstWhere((g) => g.name.toLowerCase() == 'pasta');
      expect(pasta.quantityLabel, '×3');
      // El plato aparece una sola vez en "quién lo usa".
      expect(pasta.dishes, ['Pasta']);
    });

    test('los días fuera de casa no entran en la compra', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.toggleDayAway(0);

      expect(p.shoppingListForActiveWeek(), isEmpty);
    });

    test('suma unidades reales de un plato compuesto', () {
      final p = MealProvider();
      p.addFood(const Food(
        name: 'Tortilla',
        ingredients: 'huevo, patata',
        components: [
          FoodComponent(name: 'huevo', kcal: 70, protein: 6, quantity: 3),
          FoodComponent(name: 'patata', kcal: 90, protein: 2, quantity: 2),
        ],
      ));
      p.setMeal(0, MealSlot.dinner, 'Tortilla');
      p.setMeal(1, MealSlot.dinner, 'Tortilla');

      final groups = p.shoppingListForActiveWeek();
      final huevo = groups.firstWhere((g) => g.name.toLowerCase() == 'huevo');
      // 3 huevos × 2 veces que se cocina.
      expect(huevo.quantityLabel, contains('6'));
    });

    test('re-randomizar limpia los checks de ingredientes que ya no están', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.toggleChecked('Pasta', true);
      expect(p.isChecked('Pasta'), isTrue);

      p.clearDay(0);
      expect(p.isChecked('Pasta'), isFalse);
    });

    test('el texto plano lleva pasillos y marcas', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.toggleChecked('Pasta', true);

      final text = p.shoppingListAsText(t: const AppStringsEs());
      expect(text, contains('Lista de la compra'));
      expect(text, contains('[x] Pasta'));
    });
  });

  group('Cocinar con lo que tengo', () {
    test('solo salen los platos cuyos ingredientes están en stock', () {
      final p = MealProvider();
      p.addFood(const Food(
          name: 'Pollo con arroz', ingredients: 'pechuga de pollo, arroz'));
      p.addFood(const Food(name: 'Salmón', ingredients: 'salmón, limón'));

      const pantry = [
        PantryIngredient(
            name: 'Pechuga de pollo',
            category: 'Proteínas',
            unit: 'filete',
            kcal: 155,
            protein: 29,
            stock: 2),
        PantryIngredient(
            name: 'Arroz blanco',
            category: 'Carbohidratos',
            unit: 'plato',
            kcal: 260,
            protein: 5,
            stock: 1),
      ];

      final cookable = p.cookableNow(pantry);
      expect(cookable.map((f) => f.name), contains('Pollo con arroz'));
      expect(cookable.map((f) => f.name), isNot(contains('Salmón')));
    });

    test('sin stock no se puede cocinar nada', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      expect(p.cookableNow(const []), isEmpty);
    });
  });

  group('Despensa', () {
    test('un preset borrado no vuelve al mezclar los presets nuevos', () async {
      SharedPreferences.setMockInitialValues({});
      final p = PantryProvider();
      await p.load();

      final preset = p.presets.first;
      final total = p.items.length;
      p.remove(preset);
      expect(p.items.length, total - 1);

      // Simulamos un arranque posterior con los mismos datos guardados.
      final p2 = PantryProvider();
      await p2.load();
      expect(p2.items.any((i) => i.name == preset.name), isFalse);

      // Y se pueden recuperar a propósito.
      p2.restorePresets();
      expect(p2.items.any((i) => i.name == preset.name), isTrue);
    });

    test('match encuentra por nombre parcial', () async {
      SharedPreferences.setMockInitialValues({});
      final p = PantryProvider();
      await p.load();
      p.addOrReplace(const PantryIngredient(
          name: 'Pechuga de pollo',
          category: 'Proteínas',
          unit: 'filete',
          kcal: 155,
          protein: 29));
      expect(p.match('pollo')?.name, 'Pechuga de pollo');
      expect(p.match('kiwi de marte'), isNull);
    });

    test('stock y caducidad sobreviven al JSON', () {
      final item = PantryIngredient(
        name: 'Yogur',
        category: 'Lácteos y huevos',
        unit: 'unidad',
        kcal: 60,
        protein: 4,
        stock: 3,
        expiry: DateTime(2026, 8, 11),
      );
      final copy = PantryIngredient.fromJson(item.toJson());
      expect(copy.stock, 3);
      expect(copy.expiry, DateTime(2026, 8, 11));
    });
  });

  group('Registro diario', () {
    test('las raciones multiplican las macros', () {
      const item = LoggedItem(name: 'Pasta', kcal: 500, protein: 20, servings: 1.5);
      expect(item.totalKcal, 750);
      expect(item.totalProtein, 30);
    });

    test('toma, hora y raciones sobreviven al JSON', () {
      const item = LoggedItem(
        name: 'Avena',
        kcal: 350,
        protein: 14,
        slot: MealSlot.breakfast,
        minutesOfDay: 8 * 60 + 30,
        servings: 2,
      );
      final copy = LoggedItem.fromJson(item.toJson());
      expect(copy.slot, MealSlot.breakfast);
      expect(copy.timeLabel, '08:30');
      expect(copy.servings, 2);
    });

    test('la racha cuenta días seguidos cumpliendo proteína', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();

      final today = DateTime.now();
      for (var i = 0; i < 3; i++) {
        d.addEntry(today.subtract(Duration(days: i)),
            const LoggedItem(name: 'Pollo', kcal: 400, protein: 60));
      }
      expect(d.proteinStreak(50), 3);
      // Con un objetivo que no se cumple, no hay racha.
      expect(d.proteinStreak(200), 0);
    });

    test('la racha no se rompe porque hoy aún no hayas comido', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      d.addEntry(yesterday,
          const LoggedItem(name: 'Pollo', kcal: 400, protein: 60));
      expect(d.proteinStreak(50), 1);
    });

    test('copiar un día duplica sus entradas en otro', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();

      final a = DateTime(2026, 8, 1);
      final b = DateTime(2026, 8, 2);
      d.addEntry(a, const LoggedItem(name: 'Avena', kcal: 350, protein: 14));
      expect(d.copyDay(a, b), 1);
      expect(d.entriesFor(b).length, 1);
      expect(d.kcalFor(b), 350);
    });

    test('el CSV lleva cabecera y una línea por entrada', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();
      d.addEntry(DateTime(2026, 8, 1),
          const LoggedItem(name: 'Avena', kcal: 350, protein: 14));

      final csv = d.toCsv();
      expect(csv, startsWith('date,meal,dish,servings,kcal,protein_g'));
      expect(csv, contains('2026-08-01'));
      expect(csv, contains('Avena'));
    });

    test('agua, peso y nota se guardan por día', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();
      final day = DateTime(2026, 8, 1);

      d.setWater(day, 5);
      d.setWeight(day, 78.4);
      d.setNote(day, 'Entrené piernas');

      expect(d.waterFor(day), 5);
      expect(d.weightFor(day), 78.4);
      expect(d.noteFor(day), 'Entrené piernas');

      d.setWeight(day, null);
      expect(d.weightFor(day), isNull);
    });
  });

  group('Copia de seguridad', () {
    test('exporta e importa el estado completo', () async {
      SharedPreferences.setMockInitialValues({
        'mealplanner_data_v1': '{"foods":[]}',
        'gym_mode_enabled': true,
        'gym_weight': 78.5,
        'gym_meal_slots': ['lunch', 'dinner'],
        'ai_gemini_api_key': 'SECRETO',
      });

      final json = await BackupService.export();
      expect(json, contains('mealplanner_data_v1'));
      // La clave de la IA no viaja en la copia.
      expect(json, isNot(contains('SECRETO')));

      SharedPreferences.setMockInitialValues({});
      expect(await BackupService.import(json), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('gym_mode_enabled'), isTrue);
      expect(prefs.getDouble('gym_weight'), 78.5);
      expect(prefs.getStringList('gym_meal_slots'), ['lunch', 'dinner']);
    });

    test('rechaza archivos que no son copias de la app', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await BackupService.import('no soy json'), isNotNull);
      expect(await BackupService.import('{"app":"otra"}'), isNotNull);
    });
  });

  group('Ficha de plato ampliada', () {
    test('los campos nuevos sobreviven al JSON', () {
      final food = Food(
        name: 'Lentejas',
        ingredients: 'lentejas, chorizo',
        tags: const {'Legumbres', 'De aprovechar'},
        prepMinutes: 45,
        servingsMade: 4,
        rating: 5,
        favorite: true,
        notes: 'A fuego lento.',
        costPerServing: 1.2,
        snoozedUntil: DateTime(2026, 9, 1),
      );
      final copy = Food.fromJson(food.toJson());
      expect(copy.tags, containsAll(<String>['Legumbres', 'De aprovechar']));
      expect(copy.prepMinutes, 45);
      expect(copy.servingsMade, 4);
      expect(copy.rating, 5);
      expect(copy.favorite, isTrue);
      expect(copy.notes, 'A fuego lento.');
      expect(copy.costPerServing, 1.2);
      expect(copy.snoozedUntil, DateTime(2026, 9, 1));
      expect(copy.hasLeftovers, isTrue);
    });

    test('un plato antiguo sin campos nuevos sigue leyéndose', () {
      final copy = Food.fromJson(const {
        'name': 'Pasta',
        'ingredients': 'pasta',
        'isLunch': true,
        'isDinner': false,
      });
      expect(copy.tags, isEmpty);
      expect(copy.servingsMade, 1);
      expect(copy.rating, 0);
      expect(copy.favorite, isFalse);
      expect(copy.isSnoozed, isFalse);
      expect(copy.hasLeftovers, isFalse);
    });

    test('el JSON no engorda si no usas los campos nuevos', () {
      final json = const Food(name: 'Pasta', ingredients: 'pasta').toJson();
      expect(json.containsKey('tags'), isFalse);
      expect(json.containsKey('rating'), isFalse);
      expect(json.containsKey('servingsMade'), isFalse);
    });

    test('isQuick e isSnoozed', () {
      const rapido = Food(name: 'A', ingredients: 'x', prepMinutes: 10);
      expect(rapido.isQuick, isTrue);
      const lento = Food(name: 'B', ingredients: 'x', prepMinutes: 60);
      expect(lento.isQuick, isFalse);

      final dormido = Food(
        name: 'C',
        ingredients: 'x',
        snoozedUntil: DateTime.now().add(const Duration(days: 3)),
      );
      expect(dormido.isSnoozed, isTrue);
      final despierto = Food(
        name: 'D',
        ingredients: 'x',
        snoozedUntil: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(despierto.isSnoozed, isFalse);
    });
  });

  group('Randomizador consciente del plato', () {
    test('no propone platos en pausa si hay alternativa', () {
      final p = MealProvider();
      p.addFood(Food(
        name: 'Aparcado',
        ingredients: 'x',
        snoozedUntil: DateTime.now().add(const Duration(days: 7)),
      ));
      p.addFood(const Food(name: 'Disponible', ingredients: 'y'));

      p.randomizeActiveWeek(kStandardSlots);
      final names = p.activeWeek.assignedNames();
      expect(names, contains('Disponible'));
      expect(names, isNot(contains('Aparcado')));
    });

    test('en un día con prisa solo entran platos rápidos', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Rápido', ingredients: 'x', prepMinutes: 10));
      p.addFood(const Food(name: 'Lento', ingredients: 'y', prepMinutes: 90));

      p.randomizeActiveWeek(kStandardSlots, busyDays: {0});
      expect(p.activeWeek.mealAt(MealSlot.lunch, 0), 'Rápido');
      expect(p.activeWeek.mealAt(MealSlot.dinner, 0), 'Rápido');
    });

    test('las sobras ocupan la toma siguiente', () {
      final p = MealProvider();
      p.addFood(const Food(
          name: 'Puchero', ingredients: 'garbanzos', servingsMade: 3));

      p.randomizeActiveWeek(kStandardSlots, useLeftovers: true);
      // Al haber un único plato, se ve claro que la cena repite el almuerzo.
      expect(p.activeWeek.mealAt(MealSlot.dinner, 0), 'Puchero');
    });

    test('aparcar un plato le pone fecha de vuelta', () {
      final p = MealProvider();
      const food = Food(name: 'Pasta', ingredients: 'pasta');
      p.addFood(food);
      p.snoozeFood(food, weeks: 2);
      expect(p.foods.first.isSnoozed, isTrue);
    });

    test('el coste de la semana suma las raciones planificadas', () {
      final p = MealProvider();
      p.addFood(const Food(
          name: 'Pasta', ingredients: 'pasta', costPerServing: 1.5));
      expect(p.weekCost(), isNull);

      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.setMeal(1, MealSlot.lunch, 'Pasta');
      expect(p.weekCost(), closeTo(3.0, 0.001));
    });
  });

  group('Logros', () {
    test('se desbloquean al alcanzar la cifra', () {
      const stats = AchievementStats(
        foods: 12,
        streak: 8,
        loggedDays: 3,
        plannedWeeks: 1,
        photos: 0,
        daysProteinMet: 2,
        perfectWeeks: 0,
      );
      final list = computeAchievements(stats);
      final byId = {for (final a in list) a.id: a};

      expect(byId['cocinero']!.unlocked, isTrue); // 12 >= 10
      expect(byId['chef']!.unlocked, isFalse); // 12 < 50
      expect(byId['racha7']!.unlocked, isTrue); // 8 >= 7
      expect(byId['racha30']!.unlocked, isFalse);
      // El progreso parcial se refleja.
      expect(byId['chef']!.progress, closeTo(12 / 50, 0.001));
      // Los conseguidos van primero.
      expect(list.first.unlocked, isTrue);
    });

    test('semana perfecta cuenta solo semanas completas', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      expect(p.completeWeeks(kStandardSlots), 0);

      p.randomizeActiveWeek(kStandardSlots);
      expect(p.completeWeeks(kStandardSlots), 1);

      // Un hueco la rompe.
      p.setMeal(3, MealSlot.dinner, null);
      expect(p.completeWeeks(kStandardSlots), 0);
    });
  });

  group('Propuestas de la IA', () {
    test('parsea el JSON del modelo con claves en español', () {
      final s = AiSuggestion.fromJson(const {
        'nombre': 'Pollo al horno',
        'ingredientes': 'pollo, patata, romero',
        'kcal': 520,
        'proteina_g': 45,
        'minutos': 40,
        'etiquetas': ['Carne'],
        'receta': 'Al horno 40 minutos.',
      });
      expect(s.name, 'Pollo al horno');
      expect(s.kcal, 520);
      expect(s.protein, 45);
      expect(s.prepMinutes, 40);
      expect(s.tags, contains('Carne'));

      final food = s.toFood();
      expect(food.name, 'Pollo al horno');
      expect(food.kcal, 520);
      expect(food.notes, 'Al horno 40 minutos.');
      expect(food.prepMinutes, 40);
    });

    test('tolera ingredientes como lista y macros ausentes', () {
      final s = AiSuggestion.fromJson(const {
        'name': 'Ensalada',
        'ingredients': ['lechuga', 'tomate'],
      });
      expect(s.ingredients, 'lechuga, tomate');
      expect(s.kcal, 0);
      // Sin macros, el Food no las inventa.
      expect(s.toFood().kcal, isNull);
    });
  });

  group('Ajuste automático del objetivo', () {
    test('en volumen, si no subes de peso propone comer más', () {
      final gym = GymProvider()
        ..setGoal(GymGoal.custom)
        ..setCustomTargets(kcal: 2500, protein: 160);
      // Custom no se ajusta solo; lo probamos con volumen.
      gym.setGoal(GymGoal.volume);
      gym.saveProfile(
        weightKg: 75,
        heightCm: 178,
        age: 25,
        sex: Sex.male,
        activity: ActivityLevel.moderate,
      );

      final subida = gym.suggestKcalAdjustment(0.0);
      expect(subida, isNotNull);
      expect(subida!.newKcal, gym.targetKcal! + 150);

      // Si sube al ritmo esperado, no propone nada.
      expect(gym.suggestKcalAdjustment(0.3), isNull);
    });

    test('en definición, si no bajas propone comer menos', () {
      final gym = GymProvider()..setGoal(GymGoal.definition);
      gym.saveProfile(
        weightKg: 85,
        heightCm: 178,
        age: 30,
        sex: Sex.male,
        activity: ActivityLevel.light,
      );
      final bajada = gym.suggestKcalAdjustment(0.0);
      expect(bajada!.newKcal, gym.targetKcal! - 150);
    });

    test('sin datos de peso no propone nada', () {
      final gym = GymProvider()..setGoal(GymGoal.volume);
      expect(gym.suggestKcalAdjustment(null), isNull);
    });

    test('el cambio semanal necesita al menos dos semanas', () async {
      SharedPreferences.setMockInitialValues({});
      final d = DiaryProvider();
      await d.load();

      d.setWeight(DateTime(2026, 8, 1), 80);
      d.setWeight(DateTime(2026, 8, 5), 79.5);
      expect(d.weightChangePerWeek(), isNull); // solo 4 días

      d.setWeight(DateTime(2026, 8, 22), 79);
      final change = d.weightChangePerWeek();
      expect(change, isNotNull);
      expect(change! < 0, isTrue); // ha bajado
    });
  });

  group('Menú en texto', () {
    test('lista los días con comidas y marca los de fuera', () {
      final p = MealProvider();
      p.addFood(const Food(name: 'Pasta', ingredients: 'pasta'));
      p.setMeal(0, MealSlot.lunch, 'Pasta');
      p.toggleDayAway(1);

      final text = p.weekAsText(kStandardSlots, t: const AppStringsEs());
      expect(text, contains('Lunes'));
      expect(text, contains('Almuerzo: Pasta'));
      expect(text, contains('Martes: fuera de casa'));
    });
  });
}
