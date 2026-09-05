// Tests de las dos cosas nuevas: los widgets de la pantalla de inicio (qué
// datos enseñan y adónde llevan) y la interfaz limpia.
//
// Lo que no se puede probar aquí es el render a PNG ni el lado de Android: eso
// necesita un dispositivo. Sí se prueba lo que sí es nuestro: qué se elige para
// enseñar, y que las caras se dibujan sin depender de nada del árbol de la app
// (que es la trampa fácil, porque se pintan fuera de él).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mealplanner_flutter/data/home_widget_service.dart';
import 'package:mealplanner_flutter/l10n/app_strings_es.dart';
import 'package:mealplanner_flutter/l10n/l10n.dart';
import 'package:mealplanner_flutter/main.dart';
import 'package:mealplanner_flutter/models/food.dart';
import 'package:mealplanner_flutter/models/logged_item.dart';
import 'package:mealplanner_flutter/models/meal_slot.dart';
import 'package:mealplanner_flutter/models/week.dart';
import 'package:mealplanner_flutter/state/ai_provider.dart';
import 'package:mealplanner_flutter/state/diary_provider.dart';
import 'package:mealplanner_flutter/state/gym_provider.dart';
import 'package:mealplanner_flutter/state/meal_provider.dart';
import 'package:mealplanner_flutter/state/pantry_provider.dart';
import 'package:mealplanner_flutter/state/settings_provider.dart';
import 'package:mealplanner_flutter/widgets/home_widget_faces.dart';

/// Un servicio con providers vacíos, listo para que cada test los llene.
({
  HomeWidgetService service,
  MealProvider meals,
  DiaryProvider diary,
  GymProvider gym,
}) _build() {
  final meals = MealProvider();
  final diary = DiaryProvider();
  final gym = GymProvider();
  return (
    service: HomeWidgetService(
      meals: meals,
      diary: diary,
      gym: gym,
      pantry: PantryProvider(),
      settings: SettingsProvider(),
    ),
    meals: meals,
    diary: diary,
    gym: gym,
  );
}

void main() {
  group('Enlaces de los widgets', () {
    test('mealplanner://tab/N abre la pestaña N', () {
      expect(HomeWidgetService.tabFromUri(Uri.parse('mealplanner://tab/0')),
          HomeTab.today);
      expect(HomeWidgetService.tabFromUri(Uri.parse('mealplanner://tab/3')),
          HomeTab.shopping);
    });

    test('un enlace de otro sitio o con basura no abre nada', () {
      expect(HomeWidgetService.tabFromUri(null), isNull);
      expect(HomeWidgetService.tabFromUri(Uri.parse('https://example.com/1')),
          isNull);
      expect(HomeWidgetService.tabFromUri(Uri.parse('mealplanner://tab/nueve')),
          isNull);
      // Fuera de rango: la app tiene cinco pestañas.
      expect(HomeWidgetService.tabFromUri(Uri.parse('mealplanner://tab/9')),
          isNull);
    });
  });

  group('Widget "Lo siguiente"', () {
    /// Ata la semana activa a hoy para que el plan caiga en el día de verdad.
    void anchorToToday(MealProvider meals) {
      meals.setWeekStart(meals.activeWeekIndex, Week.mondayOf(DateTime.now()));
    }

    test('propone la primera comida del plan que no has registrado', () {
      final env = _build();
      anchorToToday(env.meals);
      final today = DateTime.now().weekday - 1;
      env.meals.setMeal(today, MealSlot.lunch, 'Pollo con arroz');
      env.meals.setMeal(today, MealSlot.dinner, 'Crema de calabacín');

      final data = env.service.nextMealData();
      expect(data.slot, MealSlot.lunch);
      expect(data.name, 'Pollo con arroz');
      // Y de paso enseña la de después.
      expect(data.thenName, 'Crema de calabacín');
    });

    test('lo ya registrado se salta, aunque sea a deshora', () {
      final env = _build();
      anchorToToday(env.meals);
      final today = DateTime.now().weekday - 1;
      env.meals.setMeal(today, MealSlot.lunch, 'Pollo con arroz');
      env.meals.setMeal(today, MealSlot.dinner, 'Crema de calabacín');
      env.diary.addEntry(
        DateTime.now(),
        const LoggedItem(name: 'Pollo con arroz', kcal: 500, protein: 40),
      );

      expect(env.service.nextMealData().name, 'Crema de calabacín');
    });

    test('lleva las macros del plato si las tiene', () {
      final env = _build();
      anchorToToday(env.meals);
      env.meals.addFood(const Food(
        name: 'Pollo con arroz',
        ingredients: 'pollo, arroz',
        slots: {MealSlot.lunch},
        kcal: 620,
        protein: 45,
      ));
      env.meals
          .setMeal(DateTime.now().weekday - 1, MealSlot.lunch, 'Pollo con arroz');

      final data = env.service.nextMealData();
      expect(data.kcal, 620);
      expect(data.protein, 45);
    });

    test('sin nada planificado se queda vacío, no inventa', () {
      final env = _build();
      anchorToToday(env.meals);
      final data = env.service.nextMealData();
      expect(data.slot, isNull);
      expect(data.name, isNull);
    });

    test('un día fuera de casa no propone nada de ese día', () {
      final env = _build();
      anchorToToday(env.meals);
      final today = DateTime.now().weekday - 1;
      env.meals.setMeal(today, MealSlot.lunch, 'Pollo con arroz');
      env.meals.toggleDayAway(today);

      expect(env.service.nextMealData().name, isNot('Pollo con arroz'));
    });
  });

  group('Widget de la compra', () {
    test('cuenta lo que falta y adelanta los primeros', () {
      final env = _build();
      env.meals.addManualShoppingItem('Café');
      env.meals.addManualShoppingItem('Papel de cocina');
      env.meals.addManualShoppingItem('Leche');

      final data = env.service.shoppingData(const AppStrings());
      expect(data.total, 3);
      expect(data.pending, 3);
      expect(data.preview.length, 3);

      env.meals.toggleChecked(data.preview.first, true);
      final after = env.service.shoppingData(const AppStrings());
      expect(after.total, 3);
      expect(after.pending, 2);
    });
  });

  group('Widget "Hoy"', () {
    test('recoge lo comido y los objetivos del Modo Gym', () {
      final env = _build();
      env.diary.addEntry(
        DateTime.now(),
        const LoggedItem(name: 'Tortilla', kcal: 300, protein: 20),
      );
      env.diary.setWater(DateTime.now(), 4);

      final data = env.service.todayData();
      expect(data.kcal, 300);
      expect(data.protein, 20);
      expect(data.water, 4);
      // Sin perfil de gimnasio no hay objetivos que enseñar.
      expect(data.targetKcal, isNull);
    });
  });

  group('Las caras se dibujan solas', () {
    // Al renderizarse a PNG no hay MaterialApp encima: si alguna cara pidiera
    // Theme, Localizations o MediaQuery, reventaría en el móvil y no aquí. Este
    // test las monta igual de desnudas que el render de verdad.
    Widget bare(Widget child) => Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        );

    const scheme = ColorScheme.light();
    const t = AppStrings();

    testWidgets('Hoy, con y sin objetivos', (tester) async {
      await tester.pumpWidget(bare(const TodayFace(
        data: TodayFaceData(
          kcal: 1450,
          protein: 98,
          targetKcal: 2200,
          targetProtein: 150,
          water: 3,
          streak: 5,
        ),
        scheme: scheme,
        t: t,
      )));
      expect(find.text('1450'), findsOneWidget);

      await tester.pumpWidget(bare(const TodayFace(
        data: TodayFaceData(
          kcal: 900,
          protein: 40,
          targetKcal: null,
          targetProtein: null,
          water: 0,
          streak: 0,
        ),
        scheme: scheme,
        t: t,
      )));
      expect(find.text('900'), findsOneWidget);
    });

    testWidgets('Lo siguiente, con plan y sin plan', (tester) async {
      await tester.pumpWidget(bare(const NextMealFace(
        data: NextMealFaceData(
          slot: MealSlot.lunch,
          name: 'Pollo con arroz',
          kcal: 620,
          protein: 45,
          thenSlot: MealSlot.dinner,
          thenName: 'Crema',
        ),
        scheme: scheme,
        t: t,
      )));
      expect(find.text('Pollo con arroz'), findsOneWidget);

      await tester.pumpWidget(bare(const NextMealFace(
        data: NextMealFaceData(),
        scheme: scheme,
        t: t,
      )));
      expect(find.text(t.widgetNoPlan), findsOneWidget);
    });

    testWidgets('Compra, pendiente y terminada', (tester) async {
      await tester.pumpWidget(bare(const ShoppingFace(
        data: ShoppingFaceData(
          pending: 7,
          total: 12,
          preview: ['Pollo', 'Arroz', 'Tomate'],
        ),
        scheme: scheme,
        t: t,
      )));
      expect(find.text('Pollo'), findsOneWidget);

      await tester.pumpWidget(bare(const ShoppingFace(
        data: ShoppingFaceData(pending: 0, total: 12, preview: []),
        scheme: scheme,
        t: t,
      )));
      expect(find.text(t.widgetAllBought), findsOneWidget);
    });
  });

  group('Interfaz limpia', () {
    test('empieza apagada y se recuerda encendida', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsProvider();
      await settings.load();
      expect(settings.cleanMode, isFalse);

      settings.setCleanMode(true);
      expect(settings.cleanMode, isTrue);

      final again = SettingsProvider();
      await again.load();
      expect(again.cleanMode, isTrue);
    });

    /// Arranca la app en la pestaña "Hoy", con o sin interfaz limpia.
    Future<void> pumpToday(WidgetTester tester, {required bool clean}) async {
      SharedPreferences.setMockInitialValues({
        'settings_onboarding_done': true,
        'settings_language': 'es',
        'settings_start_tab': 0,
        'settings_clean_mode': clean,
      });
      final settings = SettingsProvider();
      await settings.load();
      await tester.pumpWidget(MealPlannerApp(
        mealProvider: MealProvider(),
        settings: settings,
        gym: GymProvider(),
        diary: DiaryProvider(),
        ai: AiProvider(),
        pantry: PantryProvider(),
      ));
      await tester.pumpAndSettle();
    }

    const es = AppStringsEs();

    testWidgets('apagada, el agua y el peso tienen su tarjeta', (tester) async {
      await pumpToday(tester, clean: false);
      expect(find.text(es.water), findsOneWidget);
      expect(find.text(es.logWeight), findsOneWidget);
    });

    testWidgets('encendida, se van de la pantalla pero no de la app',
        (tester) async {
      await pumpToday(tester, clean: true);
      expect(find.text(es.water), findsNothing);
      expect(find.text(es.logWeight), findsNothing);

      // Siguen estando: en el menú de la barra.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text(es.water), findsOneWidget);
      expect(find.text(es.logWeight), findsOneWidget);
    });
  });
}
