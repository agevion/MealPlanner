import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_locales.dart';
import 'app_strings.dart';
import 'app_strings_de.dart';
import 'app_strings_es.dart';
import 'app_strings_fr.dart';
import 'app_strings_it.dart';

export 'app_locales.dart';
export 'app_strings.dart';

/// La tabla de textos de cada idioma. Son `const`, así que no se crea nada al
/// cambiar de idioma: solo se apunta a otra instancia.
const Map<AppLanguage, AppStrings> kStrings = {
  AppLanguage.en: AppStrings(),
  AppLanguage.es: AppStringsEs(),
  AppLanguage.fr: AppStringsFr(),
  AppLanguage.it: AppStringsIt(),
  AppLanguage.de: AppStringsDe(),
};

AppStrings stringsFor(AppLanguage language) =>
    kStrings[language] ?? const AppStrings();

/// Textos para un `Locale` cualquiera (p. ej. el del sistema). Si el idioma no
/// está entre los cinco, cae en inglés.
AppStrings stringsForLocale(Locale? locale) =>
    stringsFor(appLanguageFromCode(locale?.languageCode) ?? AppLanguage.en);

/// Conecta los textos con el árbol de widgets para que `context.t` funcione y
/// para que Flutter los recargue solo al cambiar de idioma.
class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      appLanguageFromCode(locale.languageCode) != null;

  /// Los textos son `const`: no hay nada que cargar de disco ni de red. Se
  /// devuelven en un `SynchronousFuture` para que estén listos en el primer
  /// fotograma; con un `Future` normal la app pintaría un hueco en blanco al
  /// arrancar y al cambiar de idioma.
  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture(stringsForLocale(locale));

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}

extension AppStringsContext on BuildContext {
  /// Los textos del idioma activo. Se usa como `context.t.save`.
  AppStrings get t =>
      Localizations.of<AppStrings>(this, AppStrings) ?? const AppStrings();
}
