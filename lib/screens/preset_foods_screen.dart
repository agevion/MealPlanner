import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/preset_foods.dart';
import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';

/// Muestrario de comidas caseras predefinidas. El usuario marca las que le
/// gusten y las añade a su catálogo. Las que ya tenga aparecen marcadas y
/// deshabilitadas para no duplicar.
class PresetFoodsScreen extends StatefulWidget {
  const PresetFoodsScreen({super.key});

  @override
  State<PresetFoodsScreen> createState() => _PresetFoodsScreenState();
}

class _PresetFoodsScreenState extends State<PresetFoodsScreen> {
  final Set<int> _selected = {};

  List<MealSlot> _sortedSlots(Food f) =>
      f.slots.toList()..sort((a, b) => a.index.compareTo(b.index));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();
    final gymEnabled = context.watch<GymProvider>().enabled;
    final t = context.t;
    final existing = provider.foods.map((f) => f.name).toSet();

    final addable = [
      for (var i = 0; i < kPresetFoods.length; i++)
        if (!existing.contains(kPresetFoods[i].name)) i,
    ];
    final allSelected =
        addable.isNotEmpty && _selected.length == addable.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.exampleMealsTitle),
        actions: [
          TextButton(
            onPressed: addable.isEmpty
                ? null
                : () => setState(() {
                    if (allSelected) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(addable);
                    }
                  }),
            child: Text(allSelected ? t.unselectAll : t.selectAll),
          ),
        ],
      ),
      body: Column(
        children: [
          const _EditableNotice(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              itemCount: kPresetFoods.length,
              itemBuilder: (context, i) {
                final food = kPresetFoods[i];
                final already = existing.contains(food.name);
                final selected = _selected.contains(i);
                final theme = Theme.of(context);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: already || selected,
                    onChanged: already
                        ? null
                        : (v) => setState(() {
                            if (v ?? false) {
                              _selected.add(i);
                            } else {
                              _selected.remove(i);
                            }
                          }),
                    controlAffinity: ListTileControlAffinity.leading,
                    isThreeLine: true,
                    title: Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(food.ingredients),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final slot in _sortedSlots(food))
                              Chip(
                                label: Text(t.mealSlot(slot)),
                                avatar: Icon(slot.icon, size: 16),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (gymEnabled && food.hasMacros)
                              Text(
                                t.macrosShort(food.kcal!, food.protein!),
                                style: theme.textTheme.bodySmall,
                              ),
                            if (already)
                              Text(
                                t.alreadyInCatalog,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty ? null : () => _add(context),
            icon: const Icon(Icons.playlist_add),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            label: Text(
              _selected.isEmpty ? t.selectMeals : t.addNMeals(_selected.length),
            ),
          ),
        ),
      ),
    );
  }

  void _add(BuildContext context) {
    final provider = context.read<MealProvider>();
    final toAdd = [for (final i in _selected) kPresetFoods[i]];
    provider.addFoods(toAdd);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.t.addedNMeals(toAdd.length))),
      );
    Navigator.pop(context);
  }
}

/// Avisillo de que las comidas del muestrario son orientativas y editables.
class _EditableNotice extends StatelessWidget {
  const _EditableNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.presetNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
