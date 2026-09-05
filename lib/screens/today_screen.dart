import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/logged_item.dart';
import '../models/meal_slot.dart';
import '../state/diary_provider.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/kcal_ring.dart';
import 'roulette_screen.dart';

/// Pantalla "Hoy": el usuario registra lo que ha comido y ve su progreso frente
/// a los objetivos de kcal y proteína.
///
/// A diferencia de la primera versión, se puede navegar a cualquier día (para
/// corregir ayer o mirar atrás), el registro va agrupado por tomas y se pueden
/// marcar las comidas planificadas de una en una.
class TodayScreen extends StatefulWidget {
  /// Día que se muestra al abrir. Por defecto, hoy.
  final DateTime? initialDate;
  const TodayScreen({super.key, this.initialDate});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDate ?? DateTime.now();
    _date = DateTime(d.year, d.month, d.day);
  }

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  bool get _isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return _date.year == y.year && _date.month == y.month && _date.day == y.day;
  }

  String _prettyDate(AppStrings t) {
    if (_isToday) return t.today;
    if (_isYesterday) return t.yesterday;
    return t.longDate(_date);
  }

  void _shiftDay(int delta) =>
      setState(() => _date = _date.add(Duration(days: delta)));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: context.t.chooseDay,
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final diary = context.watch<DiaryProvider>();
    final gym = context.watch<GymProvider>();
    final meals = context.watch<MealProvider>();
    final t = context.t;

    final entries = diary.entriesFor(_date);
    final kcal = diary.kcalFor(_date);
    final protein = diary.proteinFor(_date);
    final targetKcal = gym.targetKcal;
    final targetProtein = gym.targetProtein;
    final slots = gym.activeMealSlots;
    final clean = context.clean;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.todayScreenTitle),
        actions: [
          // Con la interfaz limpia el calendario se abre tocando la fecha, que
          // está justo debajo.
          if (!clean)
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: t.chooseDay,
              onPressed: _pickDate,
            ),
          PopupMenuButton<String>(
            tooltip: t.more,
            onSelected: (v) {
              switch (v) {
                case 'yesterday':
                  _copyYesterday();
                case 'clear':
                  _confirmClearDay();
                case 'note':
                  _editNote(diary.noteFor(_date));
                case 'fits':
                  _whatFits(targetKcal, kcal);
                case 'water':
                  _waterSheet();
                case 'weight':
                  _editWeight(diary.weightFor(_date));
                case 'roulette':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RouletteScreen()),
                  );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'yesterday', child: Text(t.menuCopyYesterday)),
              PopupMenuItem(value: 'note', child: Text(t.menuDayNote)),
              PopupMenuItem(value: 'fits', child: Text(t.menuWhatFits)),
              PopupMenuItem(value: 'roulette', child: Text(t.menuRoulette)),
              // El agua y el peso pierden su tarjeta en modo limpio, así que
              // pasan aquí para no quedarse sin sitio.
              if (clean) ...[
                const PopupMenuDivider(),
                PopupMenuItem(value: 'water', child: Text(t.water)),
                PopupMenuItem(value: 'weight', child: Text(t.logWeight)),
              ],
              const PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: Text(t.menuClearDay)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(null),
        icon: const Icon(Icons.add),
        label: Text(t.add),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 16 + MediaQuery.viewPaddingOf(context).bottom + 80),
        children: [
          _DayNav(
            label: _prettyDate(t),
            onPrev: () => _shiftDay(-1),
            onNext: _isToday ? null : () => _shiftDay(1),
            onPickDate: _pickDate,
            onToday: _isToday
                ? null
                : () => setState(() {
                      final n = DateTime.now();
                      _date = DateTime(n.year, n.month, n.day);
                    }),
          ),
          const SizedBox(height: 12),
          _ProgressCard(
            kcal: kcal,
            protein: protein,
            targetKcal: targetKcal,
            targetProtein: targetProtein,
            streak: diary.proteinStreak(targetProtein),
            showBadges: !clean,
          ),
          if (!clean) ...[
            const SizedBox(height: 12),
            _WaterRow(
              glasses: diary.waterFor(_date),
              onChanged: (v) => diary.setWater(_date, v),
            ),
            const SizedBox(height: 8),
            _WeightTile(
              weight: diary.weightFor(_date),
              onTap: () => _editWeight(diary.weightFor(_date)),
            ),
          ],
          if (diary.noteFor(_date).isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sticky_note_2_outlined),
                title: Text(diary.noteFor(_date)),
                onTap: () => _editNote(diary.noteFor(_date)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _PlanSection(date: _date, slots: slots, meals: meals, diary: diary),
          const SizedBox(height: 16),
          Text(
            t.whatYouveHad,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                t.nothingLoggedYet,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ..._buildGrouped(entries, slots),
        ],
      ),
    );
  }

  /// Agrupa las entradas por toma, en el orden natural del día. Las que no
  /// tienen toma van al final, como "Otros".
  List<Widget> _buildGrouped(List<LoggedItem> entries, List<MealSlot> slots) {
    final t = context.t;
    final indexed = <int, LoggedItem>{
      for (var i = 0; i < entries.length; i++) i: entries[i],
    };

    // Primero las tomas configuradas, luego el resto (por si hay registros de
    // una toma que el usuario ya desactivó).
    final order = <MealSlot>{
      ...MealSlot.values.where(slots.contains),
      ...MealSlot.values,
    }.toList();

    final widgets = <Widget>[];
    for (final slot in order) {
      final items = indexed.entries.where((e) => e.value.slot == slot).toList();
      if (items.isEmpty) continue;
      widgets.add(_SlotHeader(
        icon: slot.icon,
        label: t.mealSlot(slot),
        kcal: items.fold(0, (a, b) => a + b.value.totalKcal),
      ));
      widgets.addAll(items.map((e) => _entryTile(e.key, e.value)));
    }

    final loose = indexed.entries.where((e) => e.value.slot == null).toList();
    if (loose.isNotEmpty) {
      widgets.add(_SlotHeader(
        icon: Icons.more_horiz,
        label: t.otherSlot,
        kcal: loose.fold(0, (a, b) => a + b.value.totalKcal),
      ));
      widgets.addAll(loose.map((e) => _entryTile(e.key, e.value)));
    }
    return widgets;
  }

  Widget _entryTile(int index, LoggedItem item) {
    final t = context.t;
    final servingsLabel = item.servings == 1
        ? ''
        : ' · ×${item.servings == item.servings.roundToDouble() ? item.servings.toInt() : item.servings.toStringAsFixed(1)}';
    return Dismissible(
      key: ValueKey('$index-${item.name}-${item.minutesOfDay}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => _removeWithUndo(index, item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(item.name),
          subtitle: Text(
              '${t.macros(item.totalKcal, item.totalProtein)}$servingsLabel'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.timeLabel.isNotEmpty)
                Text(item.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall),
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: t.adjustAmount,
                onPressed: () => _adjustServings(index, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- ACCIONES ----------------------

  void _removeWithUndo(int index, LoggedItem item) {
    final diary = context.read<DiaryProvider>();
    final t = context.t;
    diary.removeEntryAt(_date, index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(t.removedItem(item.name)),
        action: SnackBarAction(
          label: t.undo,
          onPressed: () => diary.insertEntryAt(_date, index, item),
        ),
      ));
  }

  Future<void> _adjustServings(int index, LoggedItem item) async {
    final t = context.t;
    final value = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(t.howMuchOf(item.name),
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final v in const [0.5, 1.0, 1.5, 2.0, 3.0])
              ListTile(
                leading: Icon(v == item.servings
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked),
                title: Text(v == 1
                    ? t.oneServing
                    : t.servingsCount(
                        '${v == v.roundToDouble() ? v.toInt() : v}')),
                subtitle: Text(t.macros(
                    (item.kcal * v).round(), (item.protein * v).round())),
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    if (value == null || !mounted) return;
    context
        .read<DiaryProvider>()
        .replaceEntryAt(_date, index, item.copyWith(servings: value));
  }

  /// "Me quedan X kcal, ¿qué me cabe?": lista los platos del catálogo que
  /// entran en lo que queda del día, del que más llena al que menos.
  void _whatFits(int? targetKcal, int eaten) {
    final t = context.t;
    if (targetKcal == null) {
      _snack(t.needTargetForFits);
      return;
    }
    final left = targetKcal - eaten;
    final candidates = context
        .read<MealProvider>()
        .foods
        .where((f) => f.hasMacros && f.kcal! <= left && !f.isSnoozed)
        .toList()
      ..sort((a, b) => b.protein!.compareTo(a.protein!));

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  left <= 0 ? t.alreadyOverToday : t.kcalLeftFits(left),
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
              ),
              if (candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(t.nothingFitsCatalog),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (_, i) {
                      final f = candidates[i];
                      return ListTile(
                        title: Text(f.name),
                        subtitle: Text(t.macros(f.kcal!, f.protein!)),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          Navigator.pop(ctx);
                          _logFood(f, null);
                        },
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

  void _copyYesterday() {
    final diary = context.read<DiaryProvider>();
    final t = context.t;
    final yesterday = _date.subtract(const Duration(days: 1));
    final n = diary.copyDay(yesterday, _date);
    _snack(n == 0 ? t.yesterdayWasEmpty : t.copiedMeals(n));
  }

  void _confirmClearDay() {
    final diary = context.read<DiaryProvider>();
    final t = context.t;
    final backup = diary.entriesFor(_date).toList();
    if (backup.isEmpty) {
      _snack(t.dayAlreadyEmpty);
      return;
    }
    diary.clearDay(_date);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(t.dayCleared),
        action: SnackBarAction(
          label: t.undo,
          onPressed: () => diary.addEntries(_date, backup),
        ),
      ));
  }

  /// El contador de agua cuando su tarjeta no está a la vista (interfaz limpia).
  void _waterSheet() {
    final diary = context.read<DiaryProvider>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // El propio provider avisa del cambio, pero la hoja vive fuera de
          // este árbol: se reconstruye ella sola.
          child: AnimatedBuilder(
            animation: diary,
            builder: (_, _) => _WaterRow(
              glasses: diary.waterFor(_date),
              onChanged: (v) => diary.setWater(_date, v),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editWeight(double? current) async {
    final t = context.t;
    final ctrl = TextEditingController(
        text: current != null ? current.toStringAsFixed(1) : '');
    final value = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.weightToday),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: t.weight,
            suffixText: 'kg',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, -1.0),
            child: Text(t.remove),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
                ctx, double.tryParse(ctrl.text.replaceAll(',', '.'))),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    context.read<DiaryProvider>().setWeight(_date, value < 0 ? null : value);
  }

  Future<void> _editNote(String current) async {
    final t = context.t;
    final ctrl = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.menuDayNote),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: t.noteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    context.read<DiaryProvider>().setNote(_date, value);
  }

  /// Hoja para añadir algo al registro. [slot] preselecciona la toma.
  void _showAddSheet(MealSlot? slot) {
    final mealProvider = context.read<MealProvider>();
    final diary = context.read<DiaryProvider>();
    final foods = mealProvider.foods;

    // Los más registrados últimamente salen primero: es lo que más se repite.
    final frequency = <String, int>{};
    for (final d in diary.loggedDates.take(30)) {
      for (final e in diary.entriesFor(d)) {
        frequency[e.name] = (frequency[e.name] ?? 0) + 1;
      }
    }
    final sorted = List<Food>.of(foods)
      ..sort((a, b) {
        final c = (frequency[b.name] ?? 0).compareTo(frequency[a.name] ?? 0);
        return c != 0
            ? c
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _AddEntrySheet(
        foods: sorted,
        frequency: frequency,
        onManual: () {
          Navigator.pop(sheetContext);
          _showManualDialog(slot);
        },
        onPick: (food) {
          Navigator.pop(sheetContext);
          _logFood(food, slot);
        },
      ),
    );
  }

  void _logFood(Food food, MealSlot? slot) {
    final now = DateTime.now();
    context.read<DiaryProvider>().addEntry(
          _date,
          LoggedItem(
            name: food.name,
            kcal: food.kcal ?? 0,
            protein: food.protein ?? 0,
            slot: slot ?? food.slots.firstOrNull,
            minutesOfDay: now.hour * 60 + now.minute,
          ),
        );
    _snack(context.t.addedItem(food.name));
  }

  void _showManualDialog(MealSlot? slot) {
    final diary = context.read<DiaryProvider>();
    final t = context.t;
    final nameCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.manualEntry),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: kcalCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t.calories,
                      suffixText: t.kcal,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: proteinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t.protein,
                      suffixText: t.gramShort,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                Navigator.pop(dialogContext);
                return;
              }
              final now = DateTime.now();
              diary.addEntry(
                _date,
                LoggedItem(
                  name: name,
                  kcal: int.tryParse(kcalCtrl.text) ?? 0,
                  protein: int.tryParse(proteinCtrl.text) ?? 0,
                  slot: slot,
                  minutesOfDay: now.hour * 60 + now.minute,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(t.add),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// Piezas de la pantalla
// ---------------------------------------------------------------------------

class _DayNav extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final VoidCallback onPickDate;

  const _DayNav({
    required this.label,
    required this.onPrev,
    required this.onPickDate,
    this.onNext,
    this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: t.previousDay,
          onPressed: onPrev,
        ),
        // La fecha es también el botón del calendario: es donde se busca.
        Expanded(
          child: InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        if (onToday != null)
          TextButton(onPressed: onToday, child: Text(t.today)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: t.nextDay,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Comidas planificadas para ese día, con un toque para registrarlas. Sustituye
/// al antiguo botón "Cargar plan de hoy", que duplicaba entradas si lo pulsabas
/// dos veces.
class _PlanSection extends StatelessWidget {
  final DateTime date;
  final List<MealSlot> slots;
  final MealProvider meals;
  final DiaryProvider diary;

  const _PlanSection({
    required this.date,
    required this.slots,
    required this.meals,
    required this.diary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final week = meals.weekForDate(date);
    final dayIndex = date.weekday - 1;
    final logged = diary.entriesFor(date).map((e) => e.name).toSet();

    final rows = <Widget>[];
    for (final slot in slots) {
      final name = week.mealAt(slot, dayIndex);
      if (name == null) continue;
      final food = meals.resolveFood(name);
      final already = logged.contains(name);
      rows.add(
        CheckboxListTile(
          value: already,
          onChanged: already
              ? null
              : (_) {
                  final now = DateTime.now();
                  diary.addEntry(
                    date,
                    LoggedItem(
                      name: name,
                      kcal: food?.kcal ?? 0,
                      protein: food?.protein ?? 0,
                      slot: slot,
                      minutesOfDay: now.hour * 60 + now.minute,
                    ),
                  );
                },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          secondary: Icon(slot.icon),
          title: Text(name),
          subtitle: Text(
            food != null && food.hasMacros
                ? '${t.mealSlot(slot)} · '
                    '${t.macrosShort(food.kcal!, food.protein!)}'
                : t.mealSlot(slot),
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.event_busy_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(t.nothingPlannedThisDay)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  t.plannedForThisDay,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int kcal;
  const _SlotHeader({
    required this.icon,
    required this.label,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(context.t.kcalValue(kcal), style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _WaterRow extends StatelessWidget {
  final int glasses;
  final ValueChanged<int> onChanged;
  const _WaterRow({required this.glasses, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(Icons.local_drink_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                glasses == 0
                    ? context.t.water
                    : context.t.waterGlasses(glasses),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: glasses > 0 ? () => onChanged(glasses - 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(glasses + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightTile extends StatelessWidget {
  final double? weight;
  final VoidCallback onTap;
  const _WeightTile({required this.weight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.monitor_weight_outlined),
        title: Text(weight == null
            ? context.t.logWeight
            : '${weight!.toStringAsFixed(1)} kg'),
        subtitle: Text(context.t.weightSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  final List<Food> foods;
  final Map<String, int> frequency;
  final VoidCallback onManual;
  final ValueChanged<Food> onPick;

  const _AddEntrySheet({
    required this.foods,
    required this.frequency,
    required this.onManual,
    required this.onPick,
  });

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.foods
        : widget.foods
            .where((f) => f.name.toLowerCase().contains(q))
            .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: t.searchYourMeals,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(t.manualEntry),
                subtitle: Text(t.manualEntrySubtitle),
                onTap: widget.onManual,
              ),
              const Divider(height: 1),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            t.noResultsUseManual,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final f = list[i];
                          final freq = widget.frequency[f.name] ?? 0;
                          return ListTile(
                            title: Text(f.name),
                            subtitle: f.hasMacros
                                ? Text(t.macros(f.kcal!, f.protein!))
                                : Text(t.noMacrosLoggedAsZero),
                            leading: freq > 0
                                ? Tooltip(
                                    message: t.youEatThisOften,
                                    child: Icon(Icons.star,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  )
                                : const Icon(Icons.restaurant, size: 18),
                            trailing: const Icon(Icons.add),
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

/// Tarjeta de progreso: anillo de calorías + barra de proteína + racha.
class _ProgressCard extends StatelessWidget {
  final int kcal;
  final int protein;
  final int? targetKcal;
  final int? targetProtein;
  final int streak;

  /// Las medallas de "proteína cumplida" y racha. Se apagan con la interfaz
  /// limpia: son felicitaciones, no información que haga falta.
  final bool showBadges;

  const _ProgressCard({
    required this.kcal,
    required this.protein,
    required this.targetKcal,
    required this.targetProtein,
    required this.streak,
    this.showBadges = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final hasTargets = targetKcal != null && targetProtein != null;
    final proteinMet =
        targetProtein != null && targetProtein! > 0 && protein >= targetProtein!;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasTargets) ...[
              Text(
                t.hadKcalAndProtein(kcal, protein),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(t.setUpGymProfile, style: theme.textTheme.bodySmall),
            ] else ...[
              Row(
                children: [
                  _KcalRing(value: kcal, target: targetKcal!),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bar(
                          label: t.protein,
                          value: protein,
                          target: targetProtein!,
                          unit: t.gramShort,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          kcal <= targetKcal!
                              ? t.kcalLeft(targetKcal! - kcal)
                              : t.kcalOver(kcal - targetKcal!),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showBadges && (proteinMet || streak > 0)) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (proteinMet)
                      _Badge(
                        icon: Icons.check_circle,
                        text: t.proteinMet,
                        color: theme.colorScheme.primary,
                      ),
                    if (streak > 0)
                      _Badge(
                        icon: Icons.local_fire_department,
                        text: t.streakBadge(streak),
                        color: theme.colorScheme.tertiary,
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Badge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Anillo de calorías. Se pinta a mano para no depender de ninguna librería.
class _KcalRing extends StatelessWidget {
  final int value;
  final int target;
  const _KcalRing({required this.value, required this.target});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = target > 0 ? value / target : 0.0;
    return SizedBox(
      width: 104,
      height: 104,
      child: CustomPaint(
        painter: RingPainter(
          ratio: ratio,
          color: ratio > 1.1
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          background: theme.colorScheme.surface,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(context.t.ofTarget(target),
                  style: theme.textTheme.labelSmall),
              Text(context.t.kcal, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final String unit;
  final Color color;

  const _Bar({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const Spacer(),
            Text('$value / $target $unit', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surface,
            color: color,
          ),
        ),
      ],
    );
  }
}
