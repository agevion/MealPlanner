import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import 'data/home_widget_service.dart';
import 'l10n/l10n.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/ai_provider.dart';
import 'state/diary_provider.dart';
import 'state/gym_provider.dart';
import 'state/meal_provider.dart';
import 'state/pantry_provider.dart';
import 'state/settings_provider.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final mealProvider = MealProvider();
  final settings = SettingsProvider();
  final gym = GymProvider();
  final diary = DiaryProvider();
  final ai = AiProvider();
  final pantry = PantryProvider();
  await Future.wait([
    mealProvider.load(),
    settings.load(),
    gym.load(),
    diary.load(),
    ai.load(),
    pantry.load(),
  ]);

  final widgets = HomeWidgetService(
    meals: mealProvider,
    diary: diary,
    gym: gym,
    pantry: pantry,
    settings: settings,
  );

  // Si la app se abre tocando un widget, se entra directamente en su pestaña.
  if (HomeWidgetService.supported) {
    try {
      homeTabRequest.value =
          HomeWidgetService.tabFromUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } catch (_) {
      // Sin widgets puestos no hay nada que recoger.
    }
  }

  FlutterNativeSplash.remove();
  runApp(MealPlannerApp(
    mealProvider: mealProvider,
    settings: settings,
    gym: gym,
    diary: diary,
    ai: ai,
    pantry: pantry,
    widgets: widgets,
  ));
}

class MealPlannerApp extends StatefulWidget {
  final MealProvider mealProvider;
  final SettingsProvider settings;
  final GymProvider gym;
  final DiaryProvider diary;
  final AiProvider ai;
  final PantryProvider pantry;

  /// Los widgets de la pantalla de inicio. Es opcional porque en los tests no
  /// hay Android al otro lado del canal.
  final HomeWidgetService? widgets;

  const MealPlannerApp({
    super.key,
    required this.mealProvider,
    required this.settings,
    required this.gym,
    required this.diary,
    required this.ai,
    required this.pantry,
    this.widgets,
  });

  @override
  State<MealPlannerApp> createState() => _MealPlannerAppState();
}

class _MealPlannerAppState extends State<MealPlannerApp>
    with WidgetsBindingObserver {
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.widgets != null && HomeWidgetService.supported) {
      // Con la app ya abierta, tocar un widget solo trae el enlace por aquí.
      _widgetClicks = HomeWidget.widgetClicked.listen((uri) {
        final tab = HomeWidgetService.tabFromUri(uri);
        if (tab != null) homeTabRequest.value = tab;
      });
      // Al arrancar puede haber datos nuevos desde la última vez (otro día, la
      // semana que ha cambiado…), así que se repintan en cuanto hay hueco.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.widgets!.refresh();
      });
    }
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El guardado va agrupado para no escribir en disco en cada toque; al salir
  /// de la app forzamos lo que quede pendiente.
  ///
  /// Es también el momento de repintar los widgets: el usuario acaba de irse a
  /// la pantalla de inicio, que es justo donde están.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.mealProvider.flushPendingSave();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      widget.widgets?.refresh();
    }
  }

  /// El PNG del widget lleva los colores cocidos dentro: si el sistema pasa a
  /// modo oscuro hay que volver a dibujarlo.
  @override
  void didChangePlatformBrightness() {
    if (widget.settings.themeMode == ThemeMode.system) {
      widget.widgets?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.mealProvider),
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.gym),
        ChangeNotifierProvider.value(value: widget.diary),
        ChangeNotifierProvider.value(value: widget.ai),
        ChangeNotifierProvider.value(value: widget.pantry),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Meal Planner',
          debugShowCheckedModeBanner: false,
          theme: settings.lightTheme,
          darkTheme: settings.darkTheme,
          themeMode: settings.themeMode,
          // null = todavía no ha elegido idioma: manda el del teléfono, y si no
          // es ninguno de los cinco, el primero de la lista (inglés).
          locale: settings.locale,
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // La primera vez se entra por el tutorial (que empieza eligiendo
          // idioma); a partir de ahí, directo a la app.
          home: settings.onboardingDone
              ? const HomeShell()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
