import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locales.dart';
import '../theme/app_themes.dart';

/// Estado de los ajustes de la app (idioma, apariencia, tema de color…). Va
/// aparte del `MealProvider` para mantener separada la lógica de comidas de la
/// de preferencias. Persiste cada ajuste en SharedPreferences con su propia
/// clave.
class SettingsProvider extends ChangeNotifier {
  static const _kThemeId = 'settings_theme_id';
  static const _kThemeMode = 'settings_theme_mode';
  static const _kAmoled = 'settings_amoled';
  static const _kIntensity = 'settings_color_intensity';
  static const _kStartTab = 'settings_start_tab';
  static const _kLanguage = 'settings_language';
  static const _kOnboardingDone = 'settings_onboarding_done';
  static const _kCleanMode = 'settings_clean_mode';

  /// Niveles del slider de intensidad: de menos a más vivos. Cada uno es una
  /// variante del algoritmo de Material 3 (mismo tono base, distinta saturación).
  static const List<DynamicSchemeVariant> _variants = [
    DynamicSchemeVariant.neutral, // Suave
    DynamicSchemeVariant.tonalSpot, // Equilibrado (por defecto de M3)
    DynamicSchemeVariant.vibrant, // Vivo
    DynamicSchemeVariant.fidelity, // Intenso (fiel a la semilla, muy saturado)
  ];
  static int get maxIntensity => _variants.length - 1;

  SharedPreferences? _prefs;

  String _themeId = kAppThemes.first.id;
  ThemeMode _themeMode = ThemeMode.system;
  bool _amoled = false;
  int _intensity = 1; // Equilibrado

  /// Pestaña con la que abre la app. null = automática (Hoy si llevas Modo
  /// Gym, la semana si no).
  int? _startTab;

  /// Idioma elegido por el usuario. null = todavía no ha elegido (la app usa el
  /// del sistema hasta que lo haga en el tutorial o en Ajustes).
  AppLanguage? _language;

  /// Si ya ha visto el tutorial de bienvenida.
  bool _onboardingDone = false;

  /// Interfaz limpia: esconde los controles secundarios de cada pantalla
  /// (botones sueltos, filtros, tarjetas de extras) y los deja dentro de los
  /// menús. No quita ninguna función, solo deja de tenerlas todas a la vista.
  bool _cleanMode = false;

  String get themeId => _themeId;
  ThemeMode get themeMode => _themeMode;
  bool get amoled => _amoled;
  int get intensity => _intensity;
  int? get startTab => _startTab;
  AppLanguage? get language => _language;
  bool get onboardingDone => _onboardingDone;
  bool get cleanMode => _cleanMode;

  /// El `Locale` para el `MaterialApp`. null deja que Flutter resuelva con el
  /// idioma del teléfono (y caiga en inglés si no es ninguno de los cinco).
  Locale? get locale => _language?.locale;

  void setStartTab(int? tab) {
    _startTab = tab;
    if (tab == null) {
      _prefs?.remove(_kStartTab);
    } else {
      _prefs?.setInt(_kStartTab, tab);
    }
    notifyListeners();
  }

  AppTheme get currentTheme => appThemeById(_themeId);

  DynamicSchemeVariant get _variant =>
      _variants[_intensity.clamp(0, maxIntensity)];

  // ---------------------- CARGA / GUARDADO ----------------------

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _themeId = _prefs!.getString(_kThemeId) ?? _themeId;

    final modeIndex = _prefs!.getInt(_kThemeMode);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    _amoled = _prefs!.getBool(_kAmoled) ?? false;
    _intensity = (_prefs!.getInt(_kIntensity) ?? _intensity).clamp(
      0,
      maxIntensity,
    );
    _startTab = _prefs!.getInt(_kStartTab);
    _language = appLanguageFromCode(_prefs!.getString(_kLanguage));
    _onboardingDone = _prefs!.getBool(_kOnboardingDone) ?? false;
    _cleanMode = _prefs!.getBool(_kCleanMode) ?? false;
    notifyListeners();
  }

  void setCleanMode(bool value) {
    if (value == _cleanMode) return;
    _cleanMode = value;
    _prefs?.setBool(_kCleanMode, value);
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (language == _language) return;
    _language = language;
    _prefs?.setString(_kLanguage, language.code);
    notifyListeners();
  }

  void setOnboardingDone(bool done) {
    if (done == _onboardingDone) return;
    _onboardingDone = done;
    _prefs?.setBool(_kOnboardingDone, done);
    notifyListeners();
  }

  void setThemeId(String id) {
    if (id == _themeId) return;
    _themeId = id;
    _prefs?.setString(_kThemeId, id);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _prefs?.setInt(_kThemeMode, mode.index);
    notifyListeners();
  }

  void setAmoled(bool value) {
    if (value == _amoled) return;
    _amoled = value;
    _prefs?.setBool(_kAmoled, value);
    notifyListeners();
  }

  void setIntensity(int value) {
    final v = value.clamp(0, maxIntensity);
    if (v == _intensity) return;
    _intensity = v;
    _prefs?.setInt(_kIntensity, v);
    notifyListeners();
  }

  // ---------------------- THEMEDATA ----------------------

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: currentTheme.seed,
      dynamicSchemeVariant: _variant,
    ),
  );

  ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: currentTheme.seed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: _variant,
    );

    if (!_amoled) {
      return ThemeData(useMaterial3: true, colorScheme: scheme);
    }

    // Variante AMOLED: negros puros para que los píxeles se apaguen en pantallas
    // OLED. Mantenemos el acento del tema pero llevamos las superficies a negro.
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(surface: Colors.black),
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
    );
  }
}

extension CleanModeContext on BuildContext {
  /// Si la interfaz limpia está activa. Se usa como `context.clean` en cualquier
  /// pantalla; al ser un `watch`, cambiar el ajuste repinta todo al momento.
  bool get clean => watch<SettingsProvider>().cleanMode;
}
