import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/settings_provider.dart';
import '../widgets/flag_icon.dart';

/// Una página del tutorial: un icono grande, un título y un párrafo.
class _Page {
  final IconData icon;
  final String Function(AppStrings) title;
  final String Function(AppStrings) body;
  const _Page(this.icon, this.title, this.body);
}

/// El repaso de bienvenida que sale la primera vez que se abre la app.
///
/// La primera pantalla es el selector de idioma, y no por capricho: si alguien
/// abre la app y no está en su idioma, el tutorial no le sirve de nada. Se elige
/// idioma y el resto del recorrido ya sale traducido al instante.
///
/// También se puede volver a ver desde Ajustes; en ese caso [replay] es true y
/// al terminar simplemente se cierra la pantalla.
class OnboardingScreen extends StatefulWidget {
  final bool replay;
  const OnboardingScreen({super.key, this.replay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  /// Las páginas de contenido. La del idioma va aparte porque es interactiva.
  static const List<_Page> _pages = [
    _Page(Icons.restaurant_menu, _welcomeTitle, _welcomeBody),
    _Page(Icons.calendar_month, _plannerTitle, _plannerBody),
    _Page(Icons.menu_book_outlined, _mealsTitle, _mealsBody),
    _Page(Icons.shopping_cart_outlined, _shoppingTitle, _shoppingBody),
    _Page(Icons.today_outlined, _todayTitle, _todayBody),
    _Page(Icons.fitness_center, _gymTitle, _gymBody),
    _Page(Icons.celebration_outlined, _readyTitle, _readyBody),
  ];

  // Los `_Page` son const, así que los textos se pasan como funciones de nivel
  // superior en vez de como closures.
  static String _welcomeTitle(AppStrings t) => t.onbWelcomeTitle;
  static String _welcomeBody(AppStrings t) => t.onbWelcomeBody;
  static String _plannerTitle(AppStrings t) => t.onbPlannerTitle;
  static String _plannerBody(AppStrings t) => t.onbPlannerBody;
  static String _mealsTitle(AppStrings t) => t.onbMealsTitle;
  static String _mealsBody(AppStrings t) => t.onbMealsBody;
  static String _shoppingTitle(AppStrings t) => t.onbShoppingTitle;
  static String _shoppingBody(AppStrings t) => t.onbShoppingBody;
  static String _todayTitle(AppStrings t) => t.onbTodayTitle;
  static String _todayBody(AppStrings t) => t.onbTodayBody;
  static String _gymTitle(AppStrings t) => t.onbGymTitle;
  static String _gymBody(AppStrings t) => t.onbGymBody;
  static String _readyTitle(AppStrings t) => t.onbReadyTitle;
  static String _readyBody(AppStrings t) => t.onbReadyBody;

  int get _total => _pages.length + 1; // +1 por la del idioma
  bool get _isLanguagePage => _index == 0;
  bool get _isLastPage => _index == _total - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );

  void _finish() {
    final settings = context.read<SettingsProvider>();
    // Si no llegó a tocar el selector, damos por bueno el idioma que ha estado
    // viendo: así no le cambia solo si algún día cambia el del teléfono.
    if (settings.language == null) {
      final shown =
          appLanguageFromCode(Localizations.localeOf(context).languageCode);
      settings.setLanguage(shown ?? AppLanguage.en);
    }
    settings.setOnboardingDone(true);
    if (widget.replay && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fila de arriba: saltar (o cerrar, si es una repetición).
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(widget.replay ? t.close : t.onbSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  const _LanguagePage(),
                  for (final page in _pages)
                    _ContentPage(
                      icon: page.icon,
                      title: page.title(t),
                      body: page.body(t),
                    ),
                ],
              ),
            ),
            _Dots(count: _total, index: _index),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  // El "Atrás" ocupa sitio siempre para que el botón principal
                  // no baile de posición al pasar de página.
                  SizedBox(
                    width: 96,
                    child: _isLanguagePage
                        ? null
                        : TextButton(
                            onPressed: () => _goTo(_index - 1),
                            child: Text(t.onbBack),
                          ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLastPage ? _finish : () => _goTo(_index + 1),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isLastPage
                            ? t.onbStart
                            : _isLanguagePage
                                ? t.onbLanguageContinue
                                : t.onbNext,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primera página: elegir idioma. Cada opción lleva su banderita y el nombre
/// del idioma escrito en ese mismo idioma.
class _LanguagePage extends StatelessWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    // Antes de elegir, se marca el idioma que la app está usando de verdad.
    final current = settings.language ??
        appLanguageFromCode(Localizations.localeOf(context).languageCode);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      children: [
        Icon(Icons.translate, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          t.onbLanguageTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t.onbLanguageBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 20),
        for (final language in AppLanguage.values)
          _LanguageTile(
            language: language,
            selected: language == current,
            onTap: () => context.read<SettingsProvider>().setLanguage(language),
          ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      color: selected ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: FlagIcon(code: language.code, width: 34),
        title: Text(
          language.nativeName,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? theme.colorScheme.onPrimaryContainer : null,
          ),
        ),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color:
              selected ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _ContentPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ContentPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon,
                size: 54, color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
