import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/common_ingredients.dart';
import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/pantry_ingredient.dart';
import '../state/pantry_provider.dart';

/// Buscador sobre la despensa ("Mis ingredientes") para construir un plato: eliges
/// un ingrediente y cuántas de sus unidades caseras (2 lonchas, 1 filete…) y
/// devuelve un [FoodComponent] con las macros ya calculadas. Resuelve la comida
/// fresca que el escáner no cubre.
class IngredientPickerScreen extends StatefulWidget {
  const IngredientPickerScreen({super.key});

  @override
  State<IngredientPickerScreen> createState() => _IngredientPickerScreenState();
}

class _IngredientPickerScreenState extends State<IngredientPickerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PantryIngredient> _filtered(List<PantryIngredient> all) {
    final q = _query.trim().toLowerCase();
    final list = all.where((ing) {
      final matchesQuery = q.isEmpty || ing.name.toLowerCase().contains(q);
      final matchesCat = _category == null || ing.category == _category;
      return matchesQuery && matchesCat;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> _pick(PantryIngredient ing) async {
    final component = await showDialog<FoodComponent>(
      context: context,
      builder: (_) => _QuantityDialog(ingredient: ing),
    );
    if (component != null && mounted) Navigator.pop(context, component);
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<PantryProvider>().items;
    final list = _filtered(all);
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.searchIngredientTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: t.searchIngredientPlaceholder,
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
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(t.noResultsTryAnother),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        12, 8, 12, 16 + MediaQuery.viewPaddingOf(context).bottom),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final ing = list[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          title: Text(ing.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            '${t.portionLabel(ing.unit, ing.gramsPerUnit)} · '
                            '${t.macrosShort(ing.kcal, ing.protein)}',
                          ),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => _pick(ing),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Pregunta cuántas unidades caseras del ingrediente se usan y calcula el total.
class _QuantityDialog extends StatefulWidget {
  final PantryIngredient ingredient;
  const _QuantityDialog({required this.ingredient});

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  static const List<double> _chips = [0.5, 1, 2, 3, 4];
  double _qty = 1;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  static String _qtyLabel(double q) =>
      q == q.roundToDouble() ? '${q.toInt()}' : q.toStringAsFixed(1);

  int get _kcal => (widget.ingredient.kcal * _qty).round();
  int get _protein => (widget.ingredient.protein * _qty).round();

  void _confirm() {
    final ing = widget.ingredient;
    Navigator.pop(
      context,
      FoodComponent(
        name: ing.name,
        kcal: ing.kcal,
        protein: ing.protein,
        quantity: _qty <= 0 ? 1 : _qty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final ing = widget.ingredient;
    final unit = t.homeUnit(ing.unit);
    return AlertDialog(
      title: Text(ing.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.oneUnitIs(unit, ing.kcal, ing.protein),
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Text(t.howManyUnits(unit), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final q in _chips)
                ChoiceChip(
                  label: Text('×${_qtyLabel(q)}'),
                  selected: _qty == q && _custom.text.isEmpty,
                  onSelected: (_) => setState(() {
                    _qty = q;
                    _custom.clear();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _custom,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: t.otherQuantity,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null && parsed > 0) setState(() => _qty = parsed);
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              t.macros(_kcal, _protein),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
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
}
