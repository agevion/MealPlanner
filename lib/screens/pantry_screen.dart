import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/common_ingredients.dart';
import '../l10n/l10n.dart';
import '../data/openfoodfacts_service.dart';
import '../models/pantry_ingredient.dart';
import '../state/pantry_provider.dart';
import 'scan_food_screen.dart';

/// "Mis ingredientes": la despensa del usuario. Separa los que trae la app ("De
/// la app") de los que ha añadido o escaneado ("Míos"). Todos son editables:
/// puedes cambiar la unidad (loncha, filete, gramos…), las macros y con qué
/// frecuencia conviene repetirlos (para el planificador).
class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(PantryIngredient i) {
    final q = _query.trim().toLowerCase();
    final matchesQuery = q.isEmpty || i.name.toLowerCase().contains(q);
    final matchesCat = _category == null || i.category == _category;
    return matchesQuery && matchesCat;
  }

  Future<void> _edit(PantryIngredient? existing) async {
    final result = await showDialog<PantryIngredient>(
      context: context,
      builder: (_) => _IngredientEditor(existing: existing),
    );
    if (result != null && mounted) {
      context.read<PantryProvider>().addOrReplace(result);
    }
  }

  /// Menú del botón "Añadir": escanear un producto o meterlo a mano. Juntos
  /// para que escanear no quede escondido y se use el camino correcto.
  Future<void> _addMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(context.t.scanProduct),
              subtitle: Text(context.t.scanProductSubtitle),
              onTap: () => Navigator.pop(ctx, 'scan'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.t.addByHand),
              subtitle: Text(context.t.addByHandSubtitle),
              onTap: () => Navigator.pop(ctx, 'manual'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'scan') {
      await _scan();
    } else if (choice == 'manual') {
      await _edit(null);
    }
  }

  /// Escanea un producto y abre el editor prerrellenado con sus datos para que
  /// el usuario ajuste unidad, gramos y macros antes de guardarlo en la despensa.
  Future<void> _scan() async {
    final t = context.t;
    final product = await Navigator.push<ScannedProduct>(
      context,
      MaterialPageRoute(builder: (_) => const ScanFoodScreen(asComponent: true)),
    );
    if (product == null || !mounted) return;
    final result = await showDialog<PantryIngredient>(
      context: context,
      builder: (_) => _IngredientEditor(
        prefill: _prefillFromScan(product),
        kcalPer100: product.kcalPer100,
        proteinPer100: product.proteinPer100,
      ),
    );
    if (result != null && mounted) {
      context.read<PantryProvider>().addOrReplace(result);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.addedToMine(result.name))));
    }
  }

  /// Convierte un producto escaneado en un prerrelleno del editor. La unidad se
  /// deja VACÍA a propósito: el usuario la elige con los chips y de ahí salen
  /// los gramos sugeridos y las macros (nada de inventar 100 g).
  PantryIngredient _prefillFromScan(ScannedProduct p) {
    final servingGrams = _parseGrams(p.servingSize);
    if (p.hasPer100) {
      // Solo prerrellenamos gramos/macros si el paquete declara su ración.
      final known = servingGrams != null;
      return PantryIngredient(
        name: p.food.name,
        category: 'Otros',
        unit: '',
        gramsPerUnit: known ? servingGrams : 0,
        kcal: known ? ((p.kcalPer100 ?? 0) * servingGrams / 100).round() : 0,
        protein:
            known ? ((p.proteinPer100 ?? 0) * servingGrams / 100).round() : 0,
        barcode: p.barcode,
      );
    }
    if (p.kcalServing != null || p.proteinServing != null) {
      // Solo hay datos por ración: la unidad "ración" aquí sí es real.
      return PantryIngredient(
        name: p.food.name,
        category: 'Otros',
        unit: 'ración',
        gramsPerUnit: servingGrams ?? 0,
        kcal: (p.kcalServing ?? 0).round(),
        protein: (p.proteinServing ?? 0).round(),
        barcode: p.barcode,
      );
    }
    return PantryIngredient(
      name: p.food.name,
      category: 'Otros',
      unit: '',
      kcal: 0,
      protein: 0,
      barcode: p.barcode,
    );
  }

  static double? _parseGrams(String serving) {
    final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*g').firstMatch(serving);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    if (v == null || v <= 0 || v > 2000) return null;
    return v;
  }

  Widget _list(List<PantryIngredient> items, {required bool isMine}) {
    final t = context.t;
    if (items.isEmpty) {
      final noFilters = _query.trim().isEmpty && _category == null;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isMine && noFilters ? t.pantryEmptyMine : t.noResults,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, 88 + MediaQuery.viewPaddingOf(context).bottom),
      itemCount: items.length,
      itemBuilder: (_, i) =>
          _IngredientTile(item: items[i], onTap: () => _edit(items[i])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.pantryTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.restore_from_trash_outlined),
              tooltip: t.restoreDeleted,
              onPressed: () {
                context.read<PantryProvider>().restorePresets();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      SnackBar(content: Text(t.presetsRestored)));
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: t.tabFromApp),
              Tab(text: t.tabMine),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addMenu,
          icon: const Icon(Icons.add),
          label: Text(t.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: t.searchIngredientHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(t.all),
                      selected: _category == null,
                      onSelected: (_) => setState(() => _category = null),
                    ),
                  ),
                  for (final cat in kIngredientCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t.ingredientCategory(cat)),
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PantryProvider>(
                builder: (context, pantry, _) {
                  final presets = pantry.presets.where(_matches).toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                  final mine = pantry.mine.where(_matches).toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                  return TabBarView(
                    children: [
                      _list(presets, isMine: false),
                      _list(mine, isMine: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final PantryIngredient item;
  final VoidCallback onTap;
  const _IngredientTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            if (item.stock > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.haveInStock('${item.stock == item.stock.roundToDouble() ? item.stock.toInt() : item.stock}'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.portionLabel(item.unit, item.gramsPerUnit)} · '
                '${t.macrosShort(item.kcal, item.protein)}'),
            if (item.expiry != null)
              Text(
                item.expiresSoon
                    ? t.useSoonExpires(item.daysToExpiry!)
                    : t.expiresInDays(item.daysToExpiry!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: item.expiresSoon
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                  fontWeight: item.expiresSoon ? FontWeight.bold : null,
                ),
              ),
          ],
        ),
        trailing: Tooltip(
          message: t.repeatabilityHint(item.repeat),
          child: Icon(item.repeat.icon,
              size: 20,
              color: item.repeat == Repeatability.limited
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editor de ingrediente
// ---------------------------------------------------------------------------

class _IngredientEditor extends StatefulWidget {
  /// Ingrediente existente (modo edición). Null = alta nueva.
  final PantryIngredient? existing;

  /// Valores iniciales para un alta nueva (p. ej. lo recién escaneado). Se
  /// muestran para revisar/ajustar, pero sigue siendo un ingrediente nuevo.
  final PantryIngredient? prefill;

  /// Macros por 100 g del producto escaneado (si se conocen). Con ellas, al
  /// cambiar los gramos por unidad se recalculan kcal y proteína solas.
  final double? kcalPer100;
  final double? proteinPer100;

  const _IngredientEditor({
    this.existing,
    this.prefill,
    this.kcalPer100,
    this.proteinPer100,
  });

  @override
  State<_IngredientEditor> createState() => _IngredientEditorState();
}

class _IngredientEditorState extends State<_IngredientEditor> {
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _grams;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late String _category;
  late Repeatability _repeat;
  late final TextEditingController _stock;
  DateTime? _expiry;

  bool get _isEdit => widget.existing != null;

  /// Pesos típicos por unidad casera. Al tocar un chip se rellena la unidad y,
  /// si tiene peso sugerido, los gramos (siempre editables). null = sin
  /// sugerencia de gramos.
  static const Map<String, double?> _unitSuggestions = {
    'loncha': 20,
    'filete': 125,
    'unidad': null,
    'rodaja': 15,
    'cucharada': 15,
    'puñado': 30,
    'vaso': 200,
    'ración': 100,
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing ?? widget.prefill;
    // Sin texto por defecto en la unidad: así se ve el hint y los chips guían.
    _unit = TextEditingController(text: e?.unit ?? '');
    _name = TextEditingController(text: e?.name ?? '');
    _grams = TextEditingController(
        text: (e != null && e.gramsPerUnit > 0)
            ? '${e.gramsPerUnit.round()}'
            : '');
    _kcal = TextEditingController(
        text: (e != null && e.kcal > 0) ? '${e.kcal}' : '');
    _protein = TextEditingController(
        text: (e != null && e.protein > 0) ? '${e.protein}' : '');
    _category = e?.category ?? kIngredientCategories.first;
    _repeat = e?.repeat ?? Repeatability.free;
    _stock = TextEditingController(
        text: (e != null && e.stock > 0)
            ? (e.stock == e.stock.roundToDouble()
                ? '${e.stock.toInt()}'
                : '${e.stock}')
            : '');
    _expiry = e?.expiry;
  }

  /// Rellena unidad (y gramos sugeridos, si los hay) desde un chip.
  ///
  /// Lo que se guarda es la palabra traducida, no la clave: la unidad es texto
  /// libre que el usuario ve tal cual en su despensa, así que quien tenga la
  /// app en alemán debe acabar con "Scheibe" y no con "loncha".
  void _applyUnit(String key, String label) {
    setState(() {
      _unit.text = label;
      final g = _unitSuggestions[key];
      if (g != null) {
        _grams.text = '${g.round()}';
        _recalcFromGrams();
      }
    });
  }

  /// Si conocemos las macros por 100 g (producto escaneado), recalcula kcal y
  /// proteína a partir de los gramos por unidad actuales.
  void _recalcFromGrams() {
    final k100 = widget.kcalPer100;
    final p100 = widget.proteinPer100;
    if (k100 == null && p100 == null) return;
    final g = double.tryParse(_grams.text.replaceAll(',', '.'));
    if (g == null || g <= 0) return;
    if (k100 != null) _kcal.text = '${(k100 * g / 100).round()}';
    if (p100 != null) _protein.text = '${(p100 * g / 100).round()}';
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _grams.dispose();
    _kcal.dispose();
    _protein.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final base = widget.existing ?? widget.prefill;
    Navigator.pop(
      context,
      PantryIngredient(
        name: name,
        category: _category,
        unit: _unit.text.trim().isEmpty
          ? context.t.homeUnit('unidad')
          : _unit.text.trim(),
        kcal: int.tryParse(_kcal.text) ?? 0,
        protein: int.tryParse(_protein.text) ?? 0,
        gramsPerUnit: double.tryParse(_grams.text.replaceAll(',', '.')) ?? 0,
        isPreset: widget.existing?.isPreset ?? false,
        repeat: _repeat,
        barcode: base?.barcode ?? '',
        stock: double.tryParse(_stock.text.replaceAll(',', '.')) ?? 0,
        expiry: _expiry,
      ),
    );
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: context.t.expiryDate,
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(_isEdit ? t.editIngredientTitle : t.newIngredient),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
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
                  flex: 3,
                  child: TextField(
                    controller: _unit,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: t.unitLabel,
                      hintText: t.unitHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _grams,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _recalcFromGrams(),
                    decoration: InputDecoration(
                      labelText: t.gramsPerUnitShort,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final u in _unitSuggestions.keys)
                  ChoiceChip(
                    label: Text(t.homeUnit(u)),
                    visualDensity: VisualDensity.compact,
                    selected: _unit.text.trim() == t.homeUnit(u),
                    onSelected: (_) => _applyUnit(u, t.homeUnit(u)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t.unitTip +
                  (widget.kcalPer100 != null || widget.proteinPer100 != null
                      ? t.unitTipRecalc
                      : ''),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kcal,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t.kcalPerUnit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _protein,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t.proteinPerUnit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t.categoryLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final c in kIngredientCategories)
                  DropdownMenuItem(
                      value: c, child: Text(t.ingredientCategory(c))),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            Text(t.repeatQuestion,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final r in Repeatability.values)
                  ChoiceChip(
                    avatar: Icon(r.icon, size: 18),
                    label: Text(t.repeatability(r)),
                    selected: _repeat == r,
                    onSelected: (_) => setState(() => _repeat = r),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.repeatabilityHint(_repeat),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Text(t.haveAtHomeQuestion,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stock,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: t.quantity,
                      helperText: t.stockHelper(_unit.text.isEmpty
                          ? t.unitsFallback
                          : t.homeUnit(_unit.text)),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickExpiry,
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      _expiry == null
                          ? t.expiryShort
                          : '${_expiry!.day}/${_expiry!.month}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (_expiry != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _expiry = null),
                  child: Text(t.removeExpiry),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (_isEdit && !(widget.existing?.isPreset ?? false))
          TextButton(
            onPressed: () {
              context.read<PantryProvider>().remove(widget.existing!);
              Navigator.pop(context);
            },
            child: Text(t.delete),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}
