import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/openfoodfacts_service.dart';
import '../l10n/l10n.dart';
import '../data/portion_memory.dart';
import '../models/food.dart';
import '../models/pantry_ingredient.dart';
import '../state/pantry_provider.dart';

/// Diálogo que resuelve el problema del código de barras: al escanear, la app no
/// sabe CUÁNTO vas a usar. Aquí lo eliges de forma cómoda y calcula las macros
/// reales. Devuelve un [FoodComponent] con los valores ya hechos.
///
/// - Producto con datos por 100 g: eliges en UNIDADES caseras (2 lonchas, 1
///   filete…) sin pesar nada, o en gramos si lo prefieres. Puedes guardarlo en
///   tu despensa para la próxima vez.
/// - Solo "por ración": eliges cuántas raciones.
/// - Sin datos: metes kcal y proteína a mano.
class PortionPickerDialog extends StatefulWidget {
  final ScannedProduct product;
  const PortionPickerDialog({super.key, required this.product});

  static Future<FoodComponent?> show(
      BuildContext context, ScannedProduct product) {
    return showDialog<FoodComponent>(
      context: context,
      builder: (_) => PortionPickerDialog(product: product),
    );
  }

  @override
  State<PortionPickerDialog> createState() => _PortionPickerDialogState();
}

enum _Mode { units, grams, servings, manual }

class _PortionPickerDialogState extends State<PortionPickerDialog> {
  /// Unidades caseras ofrecidas y su peso típico por defecto (editable).
  static const Map<String, double> _unitDefaults = {
    'unidad': 50,
    'loncha': 20,
    'filete': 125,
    'rodaja': 15,
    'cucharada': 15,
    'puñado': 30,
    'ración': 100,
    'vaso': 200,
  };

  late _Mode _mode;

  // Modo unidades.
  String _unit = 'unidad';
  final _gramsPerUnit = TextEditingController(text: '50');
  double _count = 1;

  // Modo gramos.
  double _grams = 100;

  // Modo raciones.
  double _servings = 1;

  // Modo manual (producto sin datos).
  final _manualKcal = TextEditingController();
  final _manualProtein = TextEditingController();
  final _manualQty = TextEditingController(text: '1');

  bool _saveToPantry = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p.hasPer100) {
      _mode = _Mode.units;
      _prefill();
    } else if (p.kcalServing != null || p.proteinServing != null) {
      _mode = _Mode.servings;
    } else {
      _mode = _Mode.manual;
    }
  }

  @override
  void dispose() {
    _gramsPerUnit.dispose();
    _manualKcal.dispose();
    _manualProtein.dispose();
    _manualQty.dispose();
    super.dispose();
  }

  /// Prerrellena unidad/gramos: primero desde la despensa (si ya escaneaste este
  /// producto), luego desde la última porción recordada, y si no un valor
  /// razonable a partir del tamaño de ración declarado.
  void _prefill() {
    final p = widget.product;
    final known = context.read<PantryProvider>().byBarcode(p.barcode);
    if (known != null && known.gramsPerUnit > 0) {
      _unit = known.unit;
      _gramsPerUnit.text = '${known.gramsPerUnit.round()}';
      return;
    }
    final servingGrams = _parseServingGrams(p.servingSize);
    if (servingGrams != null) {
      _unit = 'ración';
      _gramsPerUnit.text = '${servingGrams.round()}';
    }
    // Última porción recordada (asíncrono; ajusta cuando llega).
    PortionMemory.last(p.barcode).then((r) {
      if (r == null || !mounted) return;
      setState(() {
        if (r.isGrams) {
          _mode = _Mode.grams;
          if (r.value > 0) _grams = r.value;
        } else {
          _mode = _Mode.units;
          _unit = r.unit;
          _gramsPerUnit.text = '${r.gramsPerUnit.round()}';
          if (r.value > 0) _count = r.value;
        }
      });
    });
  }

  static double? _parseServingGrams(String serving) {
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*g').firstMatch(serving);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null || value <= 0 || value > 2000) return null;
    return value;
  }

  double get _gpu => double.tryParse(_gramsPerUnit.text.replaceAll(',', '.')) ?? 0;

  /// Gramos totales según el modo (para calcular con los datos por 100 g).
  double get _effectiveGrams => switch (_mode) {
        _Mode.units => _count * _gpu,
        _Mode.grams => _grams,
        _ => 0,
      };

  int get _kcalResult {
    final p = widget.product;
    return switch (_mode) {
      _Mode.units || _Mode.grams =>
        ((p.kcalPer100 ?? 0) * _effectiveGrams / 100).round(),
      _Mode.servings => ((p.kcalServing ?? 0) * _servings).round(),
      _Mode.manual => 0,
    };
  }

  int get _proteinResult {
    final p = widget.product;
    return switch (_mode) {
      _Mode.units || _Mode.grams =>
        ((p.proteinPer100 ?? 0) * _effectiveGrams / 100).round(),
      _Mode.servings => ((p.proteinServing ?? 0) * _servings).round(),
      _Mode.manual => 0,
    };
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);

  void _confirm() {
    final p = widget.product;
    final t = context.t;
    final FoodComponent component;
    switch (_mode) {
      case _Mode.units:
        final gpu = _gpu;
        final perUnitKcal = ((p.kcalPer100 ?? 0) * gpu / 100).round();
        final perUnitProtein = ((p.proteinPer100 ?? 0) * gpu / 100).round();
        if (_saveToPantry) {
          context.read<PantryProvider>().addOrReplace(PantryIngredient(
                name: p.food.name,
                category: 'Otros',
                // Se guarda la palabra en el idioma del usuario: la unidad es
                // texto libre que luego verá en su despensa.
                unit: t.homeUnit(_unit),
                kcal: perUnitKcal,
                protein: perUnitProtein,
                gramsPerUnit: gpu,
                barcode: p.barcode,
              ));
        }
        PortionMemory.remember(
          p.barcode,
          RememberedPortion(unit: _unit, gramsPerUnit: gpu, value: _count),
        );
        component = FoodComponent(
          name: p.food.name,
          kcal: perUnitKcal,
          protein: perUnitProtein,
          quantity: _count <= 0 ? 1 : _count,
        );
      case _Mode.grams:
        PortionMemory.remember(
          p.barcode,
          RememberedPortion(value: _grams),
        );
        component = FoodComponent(
          name: '${p.food.name} (${_num(_grams)} g)',
          kcal: _kcalResult,
          protein: _proteinResult,
          quantity: 1,
        );
      case _Mode.servings:
        component = FoodComponent(
          name: p.food.name,
          kcal: (p.kcalServing ?? 0).round(),
          protein: (p.proteinServing ?? 0).round(),
          quantity: _servings,
        );
      case _Mode.manual:
        final qty = double.tryParse(_manualQty.text.replaceAll(',', '.')) ?? 1;
        component = FoodComponent(
          name: p.food.name,
          kcal: int.tryParse(_manualKcal.text) ?? 0,
          protein: int.tryParse(_manualProtein.text) ?? 0,
          quantity: qty <= 0 ? 1 : qty,
        );
    }
    Navigator.pop(context, component);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final p = widget.product;
    final showToggle = p.hasPer100; // unidades ↔ gramos

    return AlertDialog(
      title: Text(p.food.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showToggle) ...[
              SegmentedButton<_Mode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: _Mode.units, label: Text(t.units)),
                  ButtonSegment(value: _Mode.grams, label: Text(t.grams)),
                ],
                selected: {_mode == _Mode.grams ? _Mode.grams : _Mode.units},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 14),
            ],
            if (_mode == _Mode.units) _buildUnits(theme, t),
            if (_mode == _Mode.grams) _buildGrams(theme, t),
            if (_mode == _Mode.servings) _buildServings(theme, t),
            if (_mode == _Mode.manual) ...[
              Text(t.productHasNoMacros, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              _buildManual(t),
            ],
            if (_mode != _Mode.manual) ...[
              const SizedBox(height: 16),
              _ResultCard(kcal: _kcalResult, protein: _proteinResult),
            ],
            if (_mode == _Mode.units) ...[
              const SizedBox(height: 4),
              CheckboxListTile(
                value: _saveToPantry,
                onChanged: (v) => setState(() => _saveToPantry = v ?? true),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(t.saveToMyIngredients),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(t.add)),
      ],
    );
  }

  Widget _buildUnits(ThemeData theme, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.whichMeasure, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final entry in _unitDefaults.entries)
              ChoiceChip(
                label: Text(t.homeUnit(entry.key)),
                selected: _unit == entry.key,
                onSelected: (_) => setState(() {
                  _unit = entry.key;
                  _gramsPerUnit.text = '${entry.value.round()}';
                }),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 110,
              child: TextField(
                controller: _gramsPerUnit,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: t.gramsPer(t.homeUnit(_unit)),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(t.howMany, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed:
                  () => setState(() => _count = (_count - 1).clamp(0.5, 99)),
            ),
            Text('×${_num(_count)}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => setState(() => _count = (_count + 1).clamp(0.5, 99)),
            ),
            const Spacer(),
            for (final q in const [0.5, 2.0, 3.0])
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ChoiceChip(
                  label: Text('×${_num(q)}'),
                  selected: _count == q,
                  onSelected: (_) => setState(() => _count = q),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrams(ThemeData theme, AppStrings t) {
    const chips = [25.0, 50.0, 75.0, 100.0, 150.0, 200.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.howManyGrams, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final g in chips)
              ChoiceChip(
                label: Text('${g.toInt()} g'),
                selected: _grams == g,
                onSelected: (_) => setState(() => _grams = g),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _grams.clamp(0, 500),
                min: 0,
                max: 500,
                divisions: 100,
                label: '${_grams.round()} g',
                onChanged: (v) => setState(() => _grams = v),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text('${_grams.round()} g',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServings(ThemeData theme, AppStrings t) {
    final p = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.howManyServings, style: theme.textTheme.bodyMedium),
        if (p.servingSize.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(t.oneServingIs(p.servingSize),
                style: theme.textTheme.bodySmall),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in const [0.5, 1.0, 1.5, 2.0, 3.0])
              ChoiceChip(
                label: Text('×${_num(s)}'),
                selected: _servings == s,
                onSelected: (_) => setState(() => _servings = s),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildManual(AppStrings t) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _manualKcal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: t.kcal,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _manualProtein,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: t.proteinGramsShort,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int kcal;
  final int protein;
  const _ResultCard({required this.kcal, required this.protein});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.insights_outlined,
              color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.macros(kcal, protein),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
