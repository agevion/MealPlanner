import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/meal_slot.dart';
import '../state/diary_provider.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/home_widget_faces.dart';

/// Los tres widgets de la pantalla de inicio, con el nombre completo de su
/// `AppWidgetProvider` de Android (el que aparece en el AndroidManifest).
enum HomeWidgetKind {
  today(
    'TodayWidgetProvider',
    'widget_today_image',
    kTodayFaceSize,
    HomeTab.today,
  ),
  nextMeal(
    'NextMealWidgetProvider',
    'widget_next_image',
    kNextMealFaceSize,
    HomeTab.today,
  ),
  shopping(
    'ShoppingWidgetProvider',
    'widget_shopping_image',
    kShoppingFaceSize,
    HomeTab.shopping,
  );

  const HomeWidgetKind(this.className, this.imageKey, this.faceSize, this.tab);

  /// Clase del proveedor, sin el paquete.
  final String className;

  /// Clave bajo la que se guarda la ruta del PNG. La lee el código Kotlin.
  final String imageKey;

  final Size faceSize;

  /// Pestaña que abre la app al tocar el widget.
  final HomeTab tab;

  static const _package = 'com.ergutih.mealplanner';

  String get qualifiedName => '$_package.$className';
}

/// Pestañas de la barra inferior, en el orden en que están en `HomeShell`.
/// Sirven para traducir el enlace del widget a la pantalla que hay que abrir.
enum HomeTab { today, week, meals, shopping, more }

/// Enlaza los widgets de la pantalla de inicio con los datos de la app.
///
/// El dibujo lo hace Flutter (ver `home_widget_faces.dart`) y aquí se decide
/// **qué** se dibuja y **cuándo**: se renderiza cada cara a un PNG, se guarda su
/// ruta donde el código nativo pueda leerla y se avisa a Android de que
/// repinte. Los widgets no se actualizan solos en segundo plano a propósito
/// (eso pediría un servicio y batería); se refrescan cada vez que sales de la
/// app, que es justo cuando vas a verlos.
class HomeWidgetService {
  final MealProvider meals;
  final DiaryProvider diary;
  final GymProvider gym;
  final PantryProvider pantry;
  final SettingsProvider settings;

  HomeWidgetService({
    required this.meals,
    required this.diary,
    required this.gym,
    required this.pantry,
    required this.settings,
  });

  /// El servicio no guarda estado propio (solo mira a los providers), así que
  /// cualquier pantalla puede montarse el suyo sin pasarlo de mano en mano.
  factory HomeWidgetService.of(BuildContext context) => HomeWidgetService(
    meals: context.read<MealProvider>(),
    diary: context.read<DiaryProvider>(),
    gym: context.read<GymProvider>(),
    pantry: context.read<PantryProvider>(),
    settings: context.read<SettingsProvider>(),
  );

  /// Los widgets son cosa de Android: en iOS harían falta extensiones nativas
  /// y en los tests no hay canal de plataforma al que hablar.
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool _busy = false;

  /// Vuelve a dibujar los widgets que el usuario tenga puestos.
  ///
  /// Con [force] se dibujan aunque parezca que no hay ninguno: hace falta justo
  /// después de añadir uno, porque Android lo pinta antes de que el sistema lo
  /// dé por instalado.
  Future<void> refresh({bool force = false}) async {
    if (!supported || _busy) return;
    _busy = true;
    try {
      final installed = force ? null : await _installedClassNames();
      final t = _strings;
      final scheme = _scheme;

      for (final kind in HomeWidgetKind.values) {
        if (installed != null && !installed.contains(kind.className)) continue;
        // Cada widget va por su cuenta: si uno falla, los otros dos se pintan
        // igual. Y que ninguno pueda tirar la app abajo, que solo son adornos.
        try {
          await HomeWidget.renderFlutterWidget(
            _faceFor(kind, scheme: scheme, t: t),
            key: kind.imageKey,
            logicalSize: kind.faceSize,
          );
          await HomeWidget.updateWidget(
            qualifiedAndroidName: kind.qualifiedName,
          );
        } catch (e) {
          debugPrint('No se pudo actualizar el widget ${kind.className}: $e');
        }
      }
    } catch (e) {
      debugPrint('No se pudieron actualizar los widgets: $e');
    } finally {
      _busy = false;
    }
  }

  /// Pide a Android que coloque [kind] en la pantalla de inicio. Devuelve false
  /// si el launcher no lo permite (bastantes no lo hacen).
  Future<bool> pin(HomeWidgetKind kind) async {
    if (!supported) return false;
    try {
      if (await HomeWidget.isRequestPinWidgetSupported() != true) return false;
      await HomeWidget.requestPinWidget(
        qualifiedAndroidName: kind.qualifiedName,
      );
      // El widget nace vacío: hay que darle contenido aunque todavía no conste
      // como instalado.
      await refresh(force: true);
      return true;
    } catch (e) {
      debugPrint('No se pudo añadir el widget: $e');
      return false;
    }
  }

  Future<Set<String>?> _installedClassNames() async {
    final widgets = await HomeWidget.getInstalledWidgets();
    return {
      for (final w in widgets)
        if (w.androidClassName != null) w.androidClassName!.split('.').last,
    };
  }

  // ---------------------- QUÉ SE DIBUJA ----------------------

  Widget _faceFor(
    HomeWidgetKind kind, {
    required ColorScheme scheme,
    required AppStrings t,
  }) => switch (kind) {
    HomeWidgetKind.today => TodayFace(data: todayData(), scheme: scheme, t: t),
    HomeWidgetKind.nextMeal => NextMealFace(
      data: nextMealData(),
      scheme: scheme,
      t: t,
    ),
    HomeWidgetKind.shopping => ShoppingFace(
      data: shoppingData(t),
      scheme: scheme,
      t: t,
    ),
  };

  /// Los datos del widget "Hoy". Los usa también la vista previa de la
  /// pantalla de widgets, que enseña la cara de verdad y no un dibujo.
  TodayFaceData todayData() {
    final today = DateTime.now();
    return TodayFaceData(
      kcal: diary.kcalFor(today),
      protein: diary.proteinFor(today),
      targetKcal: gym.targetKcal,
      targetProtein: gym.targetProtein,
      water: diary.waterFor(today),
      streak: diary.proteinStreak(gym.targetProtein),
    );
  }

  /// La comida que toca ahora y la de después.
  ///
  /// "La que toca" no es la de la hora que sea, sino la primera del plan de hoy
  /// que todavía no has registrado: si te saltas el desayuno y son las cinco,
  /// lo que te interesa ver es la comida, no el desayuno de esta mañana. Si ya
  /// no queda nada del día, se asoma al de mañana.
  NextMealFaceData nextMealData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logged = diary.entriesFor(today).map((e) => e.name).toSet();

    final upcoming = <({MealSlot slot, String name})>[
      ..._plannedFor(today, skip: logged),
      ..._plannedFor(today.add(const Duration(days: 1))),
    ];
    if (upcoming.isEmpty) return const NextMealFaceData();

    final first = upcoming.first;
    final food = meals.resolveFood(first.name);
    final then = upcoming.length > 1 ? upcoming[1] : null;
    return NextMealFaceData(
      slot: first.slot,
      name: first.name,
      kcal: food != null && food.hasMacros ? food.kcal : null,
      protein: food != null && food.hasMacros ? food.protein : null,
      thenSlot: then?.slot,
      thenName: then?.name,
    );
  }

  /// Comidas planificadas de un día, en el orden natural de las tomas.
  List<({MealSlot slot, String name})> _plannedFor(
    DateTime date, {
    Set<String> skip = const {},
  }) {
    final week = meals.weekForDate(date);
    final dayIndex = date.weekday - 1;
    if (week.isAway(dayIndex)) return const [];
    return [
      for (final slot in gym.activeMealSlots)
        if (week.mealAt(slot, dayIndex) case final name?)
          if (name.isNotEmpty && !skip.contains(name)) (slot: slot, name: name),
    ];
  }

  ShoppingFaceData shoppingData(AppStrings t) {
    final groups = meals.shoppingListForActiveWeek(pantry: pantry.items, t: t);
    final pending = groups
        .where((g) => !meals.isChecked(g.name))
        .map((g) => g.name)
        .toList();
    return ShoppingFaceData(
      pending: pending.length,
      total: groups.length,
      preview: pending.take(3).toList(),
    );
  }

  // ---------------------- APARIENCIA ----------------------

  /// Los colores con los que se pinta: los mismos que está usando la app, para
  /// que el widget no desentone con ella ni con el tema del sistema.
  ColorScheme get _scheme {
    final systemDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final dark = switch (settings.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => systemDark,
    };
    return (dark ? settings.darkTheme : settings.lightTheme).colorScheme;
  }

  AppStrings get _strings =>
      stringsForLocale(settings.locale ?? PlatformDispatcher.instance.locale);

  // ---------------------- ENLACES ----------------------

  /// La pestaña a la que lleva un enlace de widget (`mealplanner://tab/3`).
  static HomeTab? tabFromUri(Uri? uri) {
    if (uri == null || uri.scheme != 'mealplanner') return null;
    final raw = uri.pathSegments.isEmpty ? null : uri.pathSegments.last;
    final index = int.tryParse(raw ?? '');
    if (index == null || index < 0 || index >= HomeTab.values.length) {
      return null;
    }
    return HomeTab.values[index];
  }
}
