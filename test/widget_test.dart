// Smoke test básico: pasado el tutorial, la app muestra la barra de navegación
// con sus cinco destinos y en el idioma elegido.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mealplanner_flutter/l10n/l10n.dart';
import 'package:mealplanner_flutter/main.dart';
import 'package:mealplanner_flutter/state/ai_provider.dart';
import 'package:mealplanner_flutter/state/diary_provider.dart';
import 'package:mealplanner_flutter/state/gym_provider.dart';
import 'package:mealplanner_flutter/state/meal_provider.dart';
import 'package:mealplanner_flutter/state/pantry_provider.dart';
import 'package:mealplanner_flutter/state/settings_provider.dart';

Future<SettingsProvider> _settings({
  required bool onboardingDone,
  required AppLanguage language,
}) async {
  SharedPreferences.setMockInitialValues({
    'settings_onboarding_done': onboardingDone,
    'settings_language': language.code,
  });
  final settings = SettingsProvider();
  await settings.load();
  return settings;
}

Widget _app(SettingsProvider settings) => MealPlannerApp(
      mealProvider: MealProvider(),
      settings: settings,
      gym: GymProvider(),
      diary: DiaryProvider(),
      ai: AiProvider(),
      pantry: PantryProvider(),
    );

void main() {
  testWidgets('la primera vez arranca en el tutorial, eligiendo idioma',
      (WidgetTester tester) async {
    final settings =
        await _settings(onboardingDone: false, language: AppLanguage.es);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    expect(find.text('Elige tu idioma'), findsOneWidget);
    // Los cinco idiomas, cada uno escrito en el suyo.
    for (final language in AppLanguage.values) {
      expect(find.text(language.nativeName), findsOneWidget);
    }
  });

  testWidgets('con el tutorial visto arranca con la barra de navegación',
      (WidgetTester tester) async {
    final settings =
        await _settings(onboardingDone: true, language: AppLanguage.es);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    // Los cinco destinos de la barra inferior. Algunas etiquetas ("Hoy",
    // "Compra") aparecen también dentro de la pantalla activa, así que se
    // comprueba que estén, no que sean únicas.
    expect(find.text('Hoy'), findsWidgets);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Comidas'), findsOneWidget);
    expect(find.text('Compra'), findsWidgets);
    expect(find.text('Más'), findsOneWidget);
  });

  testWidgets('la barra cambia de idioma con el ajuste',
      (WidgetTester tester) async {
    final settings =
        await _settings(onboardingDone: true, language: AppLanguage.de);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    expect(find.text('Woche'), findsOneWidget);
    expect(find.text('Gerichte'), findsOneWidget);
    // "Einkauf" sale también en el botón del planificador, no solo en la barra.
    expect(find.text('Einkauf'), findsWidgets);
    expect(find.text('Semana'), findsNothing);
  });

  testWidgets('elegir idioma en el tutorial traduce el resto del recorrido',
      (WidgetTester tester) async {
    final settings =
        await _settings(onboardingDone: false, language: AppLanguage.es);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // El propio selector ya está en francés, sin salir de la página.
    expect(find.text('Choisis ta langue'), findsOneWidget);
    expect(settings.language, AppLanguage.fr);

    // Y la siguiente página del tutorial también.
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans Meal Planner'), findsOneWidget);
  });

  testWidgets('al terminar el tutorial se entra en la app',
      (WidgetTester tester) async {
    final settings =
        await _settings(onboardingDone: false, language: AppLanguage.es);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    expect(settings.onboardingDone, isTrue);
    expect(find.text('Semana'), findsOneWidget);
  });
}
