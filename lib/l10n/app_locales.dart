import 'package:flutter/widgets.dart';

/// Los idiomas que habla la app: el estándar EFIGS (English, French, Italian,
/// German, Spanish).
///
/// El nombre de cada idioma va SIEMPRE en su propio idioma ("Deutsch", no
/// "Alemán"): si alguien abre la app en un idioma que no entiende, lo único que
/// le sirve para encontrar el suyo es verlo escrito como él lo escribiría.
enum AppLanguage { en, es, fr, it, de }

extension AppLanguageInfo on AppLanguage {
  /// Código ISO 639-1. Es lo que se guarda en preferencias.
  String get code => switch (this) {
        AppLanguage.en => 'en',
        AppLanguage.es => 'es',
        AppLanguage.fr => 'fr',
        AppLanguage.it => 'it',
        AppLanguage.de => 'de',
      };

  /// El nombre del idioma tal y como lo escribe quien lo habla.
  String get nativeName => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.es => 'Español',
        AppLanguage.fr => 'Français',
        AppLanguage.it => 'Italiano',
        AppLanguage.de => 'Deutsch',
      };

  Locale get locale => Locale(code);
}

AppLanguage? appLanguageFromCode(String? code) {
  if (code == null) return null;
  for (final l in AppLanguage.values) {
    if (l.code == code) return l;
  }
  return null;
}

/// Locales que se declaran en el `MaterialApp`.
final List<Locale> kSupportedLocales =
    AppLanguage.values.map((l) => l.locale).toList(growable: false);
