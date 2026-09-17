import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup_service.dart';
import '../l10n/l10n.dart';
import '../state/ai_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_themes.dart';
import '../widgets/flag_icon.dart';
import 'onboarding_screen.dart';

/// Pantalla de ajustes de la app. De momento agrupa la apariencia (modo
/// claro/oscuro, tema de color y AMOLED) y un "Acerca de". Pensada para ir
/// creciendo con los ajustes del Modo Gym más adelante.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: EdgeInsets.only(
              bottom: 24 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            children: [
              // El idioma va el primero a propósito: si alguien abre Ajustes
              // por error en un idioma que no entiende, es lo que necesita
              // encontrar antes que nada.
              _SectionHeader(t.sectionLanguage),
              _LanguagePicker(settings: settings),
              _SectionHeader(t.sectionInterface),
              _CleanModeTile(settings: settings),
              _SectionHeader(t.sectionAppearance),
              _AppearanceMode(settings: settings),
              _AmoledTile(settings: settings),
              _SectionHeader(t.sectionColorTheme),
              _ThemePicker(settings: settings),
              _IntensitySlider(settings: settings),
              _SectionHeader(t.sectionOnOpen),
              _StartTabPicker(settings: settings),
              _SectionHeader(t.sectionAi),
              const _AiSection(),
              _SectionHeader(t.sectionBackup),
              const _BackupSection(),
              _SectionHeader(t.sectionHelp),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(t.replayTutorialTitle),
                subtitle: Text(t.replayTutorialSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(replay: true),
                  ),
                ),
              ),
              _SectionHeader(t.sectionAbout),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: Text(t.appName),
                subtitle: Text(t.aboutSubtitle),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Selector de idioma: una fila por idioma, con su banderita y su nombre
/// escrito en ese mismo idioma (nunca traducido, para que se reconozca).
class _LanguagePicker extends StatelessWidget {
  final SettingsProvider settings;
  const _LanguagePicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Antes de que el usuario elija, se marca el idioma que se está usando de
    // verdad (el del teléfono, o inglés si no lo hablamos).
    final current =
        settings.language ??
        appLanguageFromCode(Localizations.localeOf(context).languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            context.t.languageSubtitle,
            style: theme.textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final language in AppLanguage.values)
                ChoiceChip(
                  avatar: FlagIcon(code: language.code, width: 24),
                  label: Text(language.nativeName),
                  selected: language == current,
                  onSelected: (_) => settings.setLanguage(language),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AppearanceMode extends StatelessWidget {
  final SettingsProvider settings;
  const _AppearanceMode({required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(t.modeSystem)),
            ButtonSegment(value: ThemeMode.light, label: Text(t.modeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(t.modeDark)),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (s) => settings.setThemeMode(s.first),
        ),
      ),
    );
  }
}

/// Interruptor de la interfaz limpia. Al encenderla se explica una vez adónde
/// se han ido los botones: si no, parece que la app ha perdido funciones.
class _CleanModeTile extends StatelessWidget {
  final SettingsProvider settings;
  const _CleanModeTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SwitchListTile(
      secondary: const Icon(Icons.cleaning_services_outlined),
      title: Text(t.cleanModeTitle),
      subtitle: Text(t.cleanModeSubtitle),
      value: settings.cleanMode,
      onChanged: (value) {
        settings.setCleanMode(value);
        if (!value) return;
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.auto_awesome),
            title: Text(t.cleanModeHintTitle),
            content: Text(t.cleanModeHintBody),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t.close),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmoledTile extends StatelessWidget {
  final SettingsProvider settings;
  const _AmoledTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.contrast),
      title: Text(context.t.amoledTitle),
      subtitle: Text(context.t.amoledSubtitle),
      value: settings.amoled,
      onChanged: settings.setAmoled,
    );
  }
}

class _IntensitySlider extends StatelessWidget {
  final SettingsProvider settings;
  const _IntensitySlider({required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final labels = t.intensityLabels;
    final current = settings.intensity.clamp(0, labels.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t.colorIntensity, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                labels[current],
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: current.toDouble(),
            min: 0,
            max: SettingsProvider.maxIntensity.toDouble(),
            divisions: SettingsProvider.maxIntensity,
            label: labels[current],
            onChanged: (v) => settings.setIntensity(v.round()),
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final SettingsProvider settings;
  const _ThemePicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final t in kAppThemes)
            _ThemeSwatch(
              theme: t,
              selected: t.id == settings.themeId,
              onTap: () => settings.setThemeId(t.id),
            ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.seed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Icon(
                selected ? Icons.check : theme.icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.t.themeName(theme.id),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Con qué pestaña abre la app. "Automática" elige según uses o no el Modo Gym.
class _StartTabPicker extends StatelessWidget {
  final SettingsProvider settings;
  const _StartTabPicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tabs = t.tabNames;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ChoiceChip(
            label: Text(t.startTabAuto),
            selected: settings.startTab == null,
            onSelected: (_) => settings.setStartTab(null),
          ),
          for (var i = 0; i < tabs.length; i++)
            ChoiceChip(
              label: Text(tabs[i]),
              selected: settings.startTab == i,
              onSelected: (_) => settings.setStartTab(i),
            ),
        ],
      ),
    );
  }
}

/// Copia de seguridad completa: exportar a un archivo y restaurar desde él.
class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(t.backupIntro, style: theme.textTheme.bodySmall),
        ),
        ListTile(
          leading: const Icon(Icons.save_alt),
          title: Text(t.exportBackup),
          subtitle: Text(t.exportBackupSubtitle),
          onTap: () => _export(context),
        ),
        ListTile(
          leading: const Icon(Icons.settings_backup_restore),
          title: Text(t.restoreBackup),
          subtitle: Text(t.restoreBackupSubtitle),
          onTap: () => _confirmImport(context),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context) async {
    final subject = context.t.backupShareSubject;
    final json = await BackupService.export();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final file = File('${dir.path}/mealplanner_backup_$stamp.json');
    await file.writeAsString(json);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json'),
    ], subject: subject);
  }

  void _confirmImport(BuildContext context) {
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.restoreBackup),
        content: Text(t.restoreConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _import(context);
            },
            child: Text(t.restore),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context) async {
    final t = context.t;
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;
    final content = await File(result.files.single.path!).readAsString();
    final error = await BackupService.import(content, t: t);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? t.backupRestored),
          duration: const Duration(seconds: 5),
        ),
      );
  }
}

/// Ajustes del asistente de IA: la clave de API de Gemini (la pone cada usuario)
/// y el modelo a usar. La clave se guarda solo en este dispositivo.
class _AiSection extends StatefulWidget {
  const _AiSection();

  @override
  State<_AiSection> createState() => _AiSectionState();
}

class _AiSectionState extends State<_AiSection> {
  late final TextEditingController _keyCtrl;
  late final TextEditingController _modelCtrl;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final ai = context.read<AiProvider>();
    _keyCtrl = TextEditingController(text: ai.apiKey);
    _modelCtrl = TextEditingController(text: ai.model);
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final ai = context.watch<AiProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.aiIntro, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: t.apiKeyLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _obscure ? t.show : t.hide,
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            // Se guarda al terminar de escribir, no en cada pulsación: así no
            // se escriben claves a medias en el disco.
            onEditingComplete: () => ai.setApiKey(_keyCtrl.text),
            onTapOutside: (_) => ai.setApiKey(_keyCtrl.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelCtrl,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: t.modelLabel,
              helperText: t.modelHelper(AiProvider.defaultModel),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.smart_toy_outlined),
            ),
            onChanged: ai.setModel,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                ai.isConfigured
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 18,
                color: ai.isConfigured
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ai.isConfigured ? t.aiEnabled : t.aiDisabled,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
