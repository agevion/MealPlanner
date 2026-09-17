import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/common_ingredients.dart';
import '../l10n/l10n.dart';
import '../models/ingredient_group.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';
import '../state/settings_provider.dart';

/// Lista de la compra de la semana activa. Agrupa los ingredientes por pasillo
/// del súper, estima cantidades, permite marcarlos, añadir ítems a mano,
/// compartirla como texto y activar un "modo súper" con letra grande.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _superMode = false;
  bool _hideChecked = false;

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final t = context.t;
    final clean = context.clean;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.shoppingListTitle),
        actions: [
          if (!clean)
            IconButton(
              icon: Icon(_superMode ? Icons.zoom_out_map : Icons.zoom_in_map),
              tooltip: _superMode ? t.viewNormal : t.superMarketMode,
              onPressed: () => setState(() => _superMode = !_superMode),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _onMenu(v, pantry),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'all', child: Text(t.checkAll)),
              PopupMenuItem(value: 'none', child: Text(t.uncheckAll)),
              PopupMenuItem(
                value: 'hide',
                child: Text(_hideChecked ? t.showBought : t.hideBought),
              ),
              // El modo súper pierde su botón con la interfaz limpia.
              if (clean)
                PopupMenuItem(
                  value: 'super',
                  child: Text(_superMode ? t.viewNormal : t.superMarketMode),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'share', child: Text(t.shareList)),
              PopupMenuItem(value: 'copy', child: Text(t.copyToClipboard)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'recurring', child: Text(t.recurringItems)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItemDialog(context),
        icon: const Icon(Icons.add),
        label: Text(t.add),
      ),
      body: Consumer<MealProvider>(
        builder: (context, provider, _) {
          final groups = provider.shoppingListForActiveWeek(
            pantry: pantry.items,
            t: t,
          );
          if (groups.isEmpty) return const _EmptyState();

          final visible = _hideChecked
              ? groups.where((g) => !provider.isChecked(g.name)).toList()
              : groups;

          // Agrupamos por pasillo, en el orden en que están en la despensa.
          final byCategory = <String, List<IngredientGroup>>{};
          for (final g in visible) {
            byCategory.putIfAbsent(g.category, () => []).add(g);
          }
          final categories = byCategory.keys.toList()
            ..sort((a, b) {
              final ia = kIngredientCategories.indexOf(a);
              final ib = kIngredientCategories.indexOf(b);
              return (ia < 0 ? 999 : ia).compareTo(ib < 0 ? 999 : ib);
            });

          final total = groups.length;
          final done = groups.where((g) => provider.isChecked(g.name)).length;

          return Column(
            children: [
              _ProgressHeader(done: done, total: total),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    8,
                    0,
                    8,
                    88 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  children: [
                    for (final category in categories) ...[
                      _CategoryHeader(
                        title: t.ingredientCategory(category),
                        count: byCategory[category]!.length,
                      ),
                      for (final group
                          in byCategory[category]!..sort(
                            (a, b) => a.name.toLowerCase().compareTo(
                              b.name.toLowerCase(),
                            ),
                          ))
                        _ItemTile(
                          group: group,
                          checked: provider.isChecked(group.name),
                          big: _superMode,
                          showDishes: !clean,
                          onToggle: (v) =>
                              provider.toggleChecked(group.name, v),
                          onDelete: group.manual
                              ? () => provider.removeManualShoppingItem(
                                  group.name,
                                )
                              : null,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onMenu(String value, PantryProvider pantry) async {
    final provider = context.read<MealProvider>();
    final t = context.t;
    switch (value) {
      case 'all':
        provider.setAllChecked(
          provider
              .shoppingListForActiveWeek(pantry: pantry.items, t: t)
              .map((g) => g.name)
              .toList(),
        );
      case 'none':
        provider.clearChecks();
      case 'hide':
        setState(() => _hideChecked = !_hideChecked);
      case 'super':
        setState(() => _superMode = !_superMode);
      case 'share':
        await Share.share(
          provider.shoppingListAsText(pantry: pantry.items, t: t),
          subject: t.shoppingShareSubject,
        );
      case 'copy':
        await Clipboard.setData(
          ClipboardData(
            text: provider.shoppingListAsText(pantry: pantry.items, t: t),
          ),
        );
        if (mounted) _snack(t.listCopied);
      case 'recurring':
        if (mounted) _recurringDialog();
    }
  }

  /// Ítems que siempre acabas comprando (café, papel de cocina…): se añaden a
  /// la lista de la semana de un toque.
  void _recurringDialog() {
    final provider = context.read<MealProvider>();
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.recurringItems),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.recurringItemsBody, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in t.recurringItemsList)
                    ActionChip(
                      label: Text(item),
                      onPressed: () {
                        provider.addManualShoppingItem(item);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.close)),
        ],
      ),
    );
  }

  void _addItemDialog(BuildContext context) {
    final controller = TextEditingController();
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.addToListTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: t.ingredientOrProduct,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _confirmAdd(dialogContext, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => _confirmAdd(dialogContext, controller),
            child: Text(t.add),
          ),
        ],
      ),
    );
  }

  void _confirmAdd(
    BuildContext dialogContext,
    TextEditingController controller,
  ) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      context.read<MealProvider>().addManualShoppingItem(text);
    }
    Navigator.pop(dialogContext);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------

class _ProgressHeader extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressHeader({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total > 0 ? done / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            done == total && total > 0
                ? context.t.listComplete
                : context.t.inCart(done, total),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final int count;
  const _CategoryHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          const SizedBox(width: 8),
          Text('$count', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final IngredientGroup group;
  final bool checked;
  final bool big;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  /// De qué platos sale el ingrediente. Es la línea que sobra cuando lo único
  /// que quieres es tachar cosas en el súper.
  final bool showDishes;

  const _ItemTile({
    required this.group,
    required this.checked,
    required this.big,
    required this.onToggle,
    this.onDelete,
    this.showDishes = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        (big ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)
            ?.copyWith(
              decoration: checked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontWeight: FontWeight.w500,
              color: checked ? theme.colorScheme.outline : null,
            );

    return CheckboxListTile(
      value: checked,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        onToggle(v ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.symmetric(horizontal: big ? 16 : 8),
      visualDensity: big ? VisualDensity.comfortable : VisualDensity.standard,
      title: Row(
        children: [
          Expanded(child: Text(group.name, style: titleStyle)),
          if (group.quantityLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                group.quantityLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: big || !showDishes || group.dishes.isEmpty
          ? (group.isRecurring ? Text(context.t.addedByHand) : null)
          : Text(
              group.dishes.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
      secondary: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.t.remove,
              onPressed: onDelete,
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(context.t.emptyListTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.t.emptyListSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
