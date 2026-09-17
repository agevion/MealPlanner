import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';
import '../state/settings_provider.dart';
import 'shopping_list_screen.dart';

/// Una celda del plan: día + toma. Es lo que se arrastra.
class _Cell {
  final int day;
  final MealSlot slot;
  const _Cell(this.day, this.slot);
}

/// Planificador semanal: rejilla de 7 días con las tomas activas, semanas
/// atadas al calendario real, randomización (completa o solo huecos),
/// arrastrar y soltar comidas, días bloqueados y días fuera de casa.
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  bool _onlyWithMacros = false;
  bool _onlyEmpty = false;
  bool _aimForTarget = false;
  bool _compact = false;
  bool _useLeftovers = false;
  final Set<int> _busyDays = {};

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final clean = context.clean;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.plannerTitle),
        actions: [
          if (!clean)
            IconButton(
              icon: Icon(
                _compact ? Icons.view_agenda_outlined : Icons.grid_view,
              ),
              tooltip: _compact ? t.viewNormal : t.viewCompact,
              onPressed: () => setState(() => _compact = !_compact),
            ),
          PopupMenuButton<String>(
            tooltip: t.more,
            onSelected: (v) {
              final provider = context.read<MealProvider>();
              switch (v) {
                case 'import':
                  _import(context);
                case 'export':
                  _export(context);
                case 'text':
                  _shareAsText(context);
                case 'duplicate':
                  _duplicate(context);
                case 'date':
                  _setWeekDate(context);
                case 'today':
                  _goToday(context);
                case 'compact':
                  setState(() => _compact = !_compact);
                case 'addweek':
                  addWeekWithFeedback(context, provider);
                case 'delweek':
                  confirmDeleteWeek(context, provider);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'today', child: Text(t.menuGoToThisWeek)),
              PopupMenuItem(value: 'date', child: Text(t.menuWeekDate)),
              PopupMenuItem(
                value: 'duplicate',
                child: Text(t.menuDuplicateWeek),
              ),
              // Con la interfaz limpia desaparecen el botón de vista y los de
              // añadir/borrar semana: sus acciones se recogen aquí.
              if (clean) ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'compact',
                  child: Text(_compact ? t.viewNormal : t.viewCompact),
                ),
                PopupMenuItem(value: 'addweek', child: Text(t.addWeek)),
                PopupMenuItem(
                  value: 'delweek',
                  child: Text(t.deleteCurrentWeek),
                ),
              ],
              const PopupMenuDivider(),
              PopupMenuItem(value: 'import', child: Text(t.menuImportWeek)),
              PopupMenuItem(value: 'export', child: Text(t.menuExportWeek)),
              PopupMenuItem(value: 'text', child: Text(t.menuShareAsText)),
            ],
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, provider, _) {
          final gym = context.watch<GymProvider>();
          final slots = gym.activeMealSlots;
          return Column(
            children: [
              _WeekSelector(provider: provider),
              const Divider(height: 1),
              Expanded(
                child: _compact
                    ? _CompactGrid(provider: provider, slots: slots)
                    : _DaysList(
                        provider: provider,
                        slots: slots,
                        showMacros: gym.enabled,
                        busyDays: _busyDays,
                        onToggleBusy: (day) => setState(() {
                          if (!_busyDays.remove(day)) _busyDays.add(day);
                        }),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // El acceso a la compra ya está en la barra de abajo: en modo
                  // limpio no hace falta repetirlo aquí.
                  if (!clean) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openShoppingList(context),
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: Text(t.tabShopping),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Las opciones del randomizador viven en una hoja aparte: en
                  // pantallas pequeñas no cabían y tapaban el plan.
                  _OptionsButton(
                    activeCount: _activeOptionCount,
                    onPressed: _openOptions,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _randomize(context),
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(t.randomize),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cuántas opciones del randomizador están activas: se enseña en el botón
  /// para que no haga falta abrir la hoja para saberlo.
  int get _activeOptionCount =>
      (_onlyEmpty ? 1 : 0) +
      (_useLeftovers ? 1 : 0) +
      (_onlyWithMacros ? 1 : 0) +
      (_aimForTarget ? 1 : 0) +
      (_busyDays.isEmpty ? 0 : 1);

  Future<void> _openOptions() async {
    final gymEnabled = context.read<GymProvider>().enabled;
    final t = context.t;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          // Cambia el estado de la pantalla y el de la hoja a la vez.
          void toggle(void Function() change) {
            setState(change);
            setSheetState(() {});
          }

          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    t.howToRandomize,
                    style: Theme.of(sheetCtx).textTheme.titleMedium,
                  ),
                ),
                SwitchListTile(
                  value: _onlyEmpty,
                  onChanged: (v) => toggle(() => _onlyEmpty = v),
                  secondary: const Icon(Icons.grid_goldenratio),
                  title: Text(t.onlyFillGaps),
                  subtitle: Text(t.onlyFillGapsSubtitle),
                ),
                SwitchListTile(
                  value: _useLeftovers,
                  onChanged: (v) => toggle(() => _useLeftovers = v),
                  secondary: const Icon(Icons.restaurant_outlined),
                  title: Text(t.useLeftovers),
                  subtitle: Text(t.useLeftoversSubtitle),
                ),
                if (gymEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _onlyWithMacros,
                    onChanged: (v) => toggle(() => _onlyWithMacros = v),
                    secondary: const Icon(Icons.local_fire_department_outlined),
                    title: Text(t.onlyDishesWithMacros),
                  ),
                  SwitchListTile(
                    value: _aimForTarget,
                    onChanged: (v) => toggle(() => _aimForTarget = v),
                    secondary: const Icon(Icons.track_changes),
                    title: Text(t.aimForMyCalories),
                    subtitle: Text(t.aimForMyCaloriesSubtitle),
                  ),
                ],
                if (_busyDays.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bolt),
                    title: Text(t.busyDaysMarked(_busyDays.length)),
                    subtitle: Text(t.busyDaysSubtitle),
                    trailing: TextButton(
                      onPressed: () => toggle(_busyDays.clear),
                      child: Text(t.remove),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _randomize(BuildContext context) {
    final provider = context.read<MealProvider>();
    final gym = context.read<GymProvider>();
    final repeat = context.read<PantryProvider>().repeatabilityByName();
    HapticFeedback.mediumImpact();
    final error = provider.randomizeActiveWeek(
      gym.activeMealSlots,
      repeatByIngredient: repeat,
      onlyWithMacros: _onlyWithMacros,
      onlyEmpty: _onlyEmpty,
      targetKcal: _aimForTarget ? gym.targetKcal : null,
      useLeftovers: _useLeftovers,
      busyDays: _busyDays,
      t: context.t,
    );
    if (error != null) _snack(context, error);
  }

  void _openShoppingList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShoppingListScreen()),
    );
  }

  void _duplicate(BuildContext context) {
    final provider = context.read<MealProvider>();
    final ok = provider.duplicateWeek(provider.activeWeekIndex);
    _snack(
      context,
      ok ? context.t.weekDuplicated : context.t.weekDuplicateFailed,
    );
  }

  void _goToday(BuildContext context) {
    final provider = context.read<MealProvider>();
    final ok = provider.goToCurrentWeek();
    if (!ok) _snack(context, context.t.noWeekIsToday);
  }

  Future<void> _setWeekDate(BuildContext context) async {
    final provider = context.read<MealProvider>();
    final current = provider.activeWeek.startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: context.t.pickAnyDayOfWeek,
    );
    if (picked == null || !context.mounted) return;
    provider.setWeekStart(provider.activeWeekIndex, picked);
  }

  Future<void> _export(BuildContext context) async {
    final provider = context.read<MealProvider>();
    final t = context.t;
    if (!provider.activeWeek.hasMeals) {
      _snack(context, t.noMealsToExport);
      return;
    }
    final json = provider.exportActiveWeekJson();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/mealplan_semana_${provider.activeWeekIndex + 1}.json',
    );
    await file.writeAsString(json);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json'),
    ], subject: t.weekShareSubject);
  }

  Future<void> _shareAsText(BuildContext context) async {
    final provider = context.read<MealProvider>();
    final slots = context.read<GymProvider>().activeMealSlots;
    final t = context.t;
    await Share.share(
      provider.weekAsText(slots, t: t),
      subject: t.weekMenuSubject,
    );
  }

  Future<void> _import(BuildContext context) async {
    final provider = context.read<MealProvider>();
    final t = context.t;
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    if (!context.mounted) return;

    final error = provider.importWeekFromJson(content, t: t);
    _snack(context, error ?? t.importedIntoWeek(provider.activeWeekIndex + 1));
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// Acciones de semana
//
// Viven sueltas porque tienen dos entradas: los botones del selector de
// semanas y, cuando la interfaz limpia los esconde, el menú de la barra.
// ---------------------------------------------------------------------------

void addWeekWithFeedback(BuildContext context, MealProvider provider) {
  if (provider.addWeek()) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.t.maxWeeks(kMaxWeeks))));
}

/// Borrar una semana era un toque sin vuelta atrás. Ahora se confirma, y solo
/// se pregunta si la semana tiene algo dentro.
void confirmDeleteWeek(BuildContext context, MealProvider provider) {
  final t = context.t;
  final label = provider.weekLabel(provider.activeWeekIndex, t: t);

  void delete() {
    if (provider.removeActiveWeek()) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.cannotDeleteOnlyWeek)));
  }

  if (!provider.activeWeek.hasMeals) {
    delete();
    return;
  }
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.deleteWeekTitle),
      content: Text(t.deleteWeekBody(label)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            delete();
          },
          child: Text(t.delete),
        ),
      ],
    ),
  );
}

/// Botón de opciones del randomizador, con un puntito y el número de opciones
/// activas para que se vea de un vistazo sin abrirlo.
class _OptionsButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onPressed;
  const _OptionsButton({required this.activeCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text('$activeCount'),
      child: IconButton.outlined(
        onPressed: onPressed,
        tooltip: context.t.randomizerOptions,
        icon: const Icon(Icons.tune),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(14),
          foregroundColor: activeCount > 0 ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selector de semanas
// ---------------------------------------------------------------------------

class _WeekSelector extends StatelessWidget {
  final MealProvider provider;
  const _WeekSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    final weeks = provider.weeks;
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (var i = 0; i < weeks.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          weeks[i].imported
                              ? '${provider.weekLabel(i, t: t)} ★'
                              : provider.weekLabel(i, t: t),
                        ),
                        selected: i == provider.activeWeekIndex,
                        onSelected: (_) => provider.setActiveWeek(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // En modo limpio estos dos botones se van al menú de la barra: el
          // selector se queda solo con las pestañas de semana.
          if (!context.clean) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: t.addWeek,
              onPressed: () => addWeekWithFeedback(context, provider),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: t.deleteCurrentWeek,
              onPressed: () => confirmDeleteWeek(context, provider),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista de días
// ---------------------------------------------------------------------------

class _DaysList extends StatelessWidget {
  final MealProvider provider;
  final List<MealSlot> slots;
  final bool showMacros;
  final Set<int> busyDays;
  final ValueChanged<int> onToggleBusy;
  const _DaysList({
    required this.provider,
    required this.slots,
    required this.showMacros,
    required this.busyDays,
    required this.onToggleBusy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final week = provider.activeWeek;
    final todayIndex = week.containsDate(DateTime.now())
        ? DateTime.now().weekday - 1
        : -1;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      itemCount: kDays.length,
      itemBuilder: (context, dayIndex) {
        final isToday = dayIndex == todayIndex;
        final away = week.isAway(dayIndex);
        final date = week.dateOfDay(dayIndex);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: isToday ? theme.colorScheme.primaryContainer : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (week.isLocked(dayIndex)) ...[
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (away) ...[
                      Icon(
                        Icons.luggage_outlined,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (busyDays.contains(dayIndex)) ...[
                      Icon(
                        Icons.bolt,
                        size: 16,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      date == null
                          ? t.weekdays[dayIndex]
                          : '${t.weekdays[dayIndex]} ${date.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.primary,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t.todayBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: t.dayOptions,
                      onSelected: (v) {
                        switch (v) {
                          case 'lock':
                            provider.toggleDayLock(dayIndex);
                          case 'away':
                            provider.toggleDayAway(dayIndex);
                          case 'busy':
                            onToggleBusy(dayIndex);
                          case 'clear':
                            _clearWithUndo(context, dayIndex);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'lock',
                          child: Text(
                            week.isLocked(dayIndex) ? t.unlockDay : t.lockDay,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'busy',
                          child: Text(
                            busyDays.contains(dayIndex)
                                ? t.clearBusyDay
                                : t.markBusyDay,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'away',
                          child: Text(
                            away ? t.eatingInAgain : t.eatingOutThisDay,
                          ),
                        ),
                        PopupMenuItem(value: 'clear', child: Text(t.clearDay)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (away)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      t.eatingOutNotice,
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                else ...[
                  for (final slot in slots)
                    _MealRow(
                      provider: provider,
                      dayIndex: dayIndex,
                      slot: slot,
                      value: week.mealAt(slot, dayIndex),
                    ),
                  if (showMacros)
                    _DayMacroSummary(
                      provider: provider,
                      day: dayIndex,
                      slots: slots,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearWithUndo(BuildContext context, int dayIndex) {
    final t = context.t;
    final week = provider.activeWeek;
    final backup = <MealSlot, String?>{
      for (final slot in week.plan.keys) slot: week.mealAt(slot, dayIndex),
    };
    provider.clearDay(dayIndex);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.dayClearedNamed(t.weekdays[dayIndex])),
          action: SnackBarAction(
            label: t.undo,
            onPressed: () {
              backup.forEach((slot, name) {
                if (name != null) provider.setMeal(dayIndex, slot, name);
              });
            },
          ),
        ),
      );
  }
}

/// Vista compacta: toda la semana en una tabla, para verlo de un vistazo.
class _CompactGrid extends StatelessWidget {
  final MealProvider provider;
  final List<MealSlot> slots;
  const _CompactGrid({required this.provider, required this.slots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final week = provider.activeWeek;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 34,
          dataRowMaxHeight: 52,
          columnSpacing: 18,
          columns: [
            const DataColumn(label: Text('')),
            for (final slot in slots) DataColumn(label: Text(t.mealSlot(slot))),
          ],
          rows: [
            for (var day = 0; day < kDays.length; day++)
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      t.weekdaysShort[day],
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final slot in slots)
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          week.isAway(day)
                              ? t.awayShort
                              : (week.mealAt(slot, day) ?? '—'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Resumen de macros del día (suma de las tomas planificadas). Solo en Modo Gym.
class _DayMacroSummary extends StatelessWidget {
  final MealProvider provider;
  final int day;
  final List<MealSlot> slots;
  const _DayMacroSummary({
    required this.provider,
    required this.day,
    required this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gym = context.watch<GymProvider>();
    final m = provider.dayMacros(day, slots);
    if (m.kcal <= 0 && m.protein <= 0) return const SizedBox.shrink();

    final target = gym.targetKcal;
    final diff = target != null ? m.kcal - target : null;
    final prefix = m.complete ? '' : '≈ ';

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: Row(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$prefix${context.t.macros(m.kcal, m.protein)}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (diff != null && diff.abs() > 150)
            Text(
              diff > 0 ? '+$diff' : '$diff',
              style: theme.textTheme.labelMedium?.copyWith(
                color: diff > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealProvider provider;
  final int dayIndex;
  final MealSlot slot;
  final String? value;

  const _MealRow({
    required this.provider,
    required this.dayIndex,
    required this.slot,
    required this.value,
  });

  Future<void> _pick(BuildContext context) async {
    final t = context.t;
    // Los botones de dado y marcador solo están fuera cuando la interfaz no es
    // limpia; si no están, sus acciones entran en la hoja.
    final clean = context.read<SettingsProvider>().cleanMode;
    final pool = provider.foods.where((f) => f.fitsSlot(slot)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (pool.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.noMealsFor(t.mealSlot(slot)))));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => _FoodPickerSheet(
        title: '${t.mealSlot(slot)} · ${t.weekdays[dayIndex]}',
        icon: slot.icon,
        pool: pool,
        current: value,
        onShuffle: clean
            ? () {
                Navigator.pop(sheetCtx);
                _rotate(context);
              }
            : null,
        onAddToCatalog:
            clean && value != null && provider.canAddToCatalog(value!)
            ? () {
                Navigator.pop(sheetCtx);
                _addToCatalog(context);
              }
            : null,
        onClear: value == null
            ? null
            : () {
                provider.setMeal(dayIndex, slot, null);
                Navigator.pop(sheetCtx);
              },
        onPick: (f) {
          provider.setMeal(dayIndex, slot, f.name);
          Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  void _addToCatalog(BuildContext context) {
    provider.addMealToCatalog(value!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.t.addedToCatalog(value!))));
  }

  void _rotate(BuildContext context) {
    final t = context.t;
    HapticFeedback.selectionClick();
    final result = provider.rotateMeal(dayIndex, slot);
    final message = switch (result) {
      RotateResult.ok => null,
      RotateResult.noFoods => t.noMealsFor(t.mealSlot(slot)),
      RotateResult.locked => t.dayIsLocked,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final hasMeal = value != null && value!.isNotEmpty;
    final clean = context.clean;
    final canAdd = hasMeal && !clean && provider.canAddToCatalog(value!);

    // La celda es a la vez origen de arrastre y destino: así se pueden mover e
    // intercambiar comidas entre días y tomas.
    return DragTarget<_Cell>(
      onWillAcceptWithDetails: (d) =>
          d.data.day != dayIndex || d.data.slot != slot,
      onAcceptWithDetails: (d) {
        provider.moveMeal(d.data.day, d.data.slot, dayIndex, slot);
        HapticFeedback.selectionClick();
      },
      builder: (context, candidate, _) {
        final highlighted = candidate.isNotEmpty;
        final row = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(slot.icon, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _pick(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.mealSlot(slot),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          hasMeal ? value! : t.tapToChoose,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontStyle: hasMeal
                                ? FontStyle.normal
                                : FontStyle.italic,
                            color: hasMeal
                                ? null
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (canAdd)
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: t.addToMyCatalog,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _addToCatalog(context),
                ),
              // Dos iconos por toma y siete días son muchos iconos: en modo
              // limpio la fila se queda solo con el nombre del plato.
              if (!clean)
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  tooltip: t.shuffleThisOne,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _rotate(context),
                ),
            ],
          ),
        );

        final decorated = Container(
          decoration: highlighted
              ? BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: row,
        );

        if (!hasMeal) return decorated;

        return LongPressDraggable<_Cell>(
          data: _Cell(dayIndex, slot),
          hapticFeedbackOnStart: true,
          feedback: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value!,
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: decorated),
          child: decorated,
        );
      },
    );
  }
}

/// Hoja para elegir un plato, con buscador. Antes era una lista larga sin filtro.
class _FoodPickerSheet extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Food> pool;
  final String? current;
  final VoidCallback? onClear;
  final ValueChanged<Food> onPick;

  /// Acciones que en modo normal son botones de la fila del plan. Nulas cuando
  /// ya están fuera, para no ofrecerlas dos veces.
  final VoidCallback? onShuffle;
  final VoidCallback? onAddToCatalog;

  const _FoodPickerSheet({
    required this.title,
    required this.icon,
    required this.pool,
    required this.current,
    required this.onClear,
    required this.onPick,
    this.onShuffle,
    this.onAddToCatalog,
  });

  @override
  State<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends State<_FoodPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.pool
        : widget.pool
              .where(
                (f) =>
                    f.name.toLowerCase().contains(q) ||
                    f.ingredients.toLowerCase().contains(q),
              )
              .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(widget.icon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: t.searchDishOrIngredient,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (widget.onShuffle != null)
                ListTile(
                  leading: const Icon(Icons.shuffle),
                  title: Text(t.shuffleThisOne),
                  onTap: widget.onShuffle,
                ),
              if (widget.onAddToCatalog != null)
                ListTile(
                  leading: const Icon(Icons.bookmark_add_outlined),
                  title: Text(t.addToMyCatalog),
                  onTap: widget.onAddToCatalog,
                ),
              if (widget.onClear != null)
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: Text(t.clearThisMeal),
                  onTap: widget.onClear,
                ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final f = list[i];
                    final selected = f.name == widget.current;
                    return ListTile(
                      title: Text(f.name),
                      subtitle: f.hasMacros
                          ? Text(t.macros(f.kcal!, f.protein!))
                          : null,
                      selected: selected,
                      trailing: selected ? const Icon(Icons.check) : null,
                      onTap: () => widget.onPick(f),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
