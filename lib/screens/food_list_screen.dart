import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';
import '../state/settings_provider.dart';
import 'add_food_screen.dart';
import 'preset_foods_screen.dart';
import 'scan_food_screen.dart';

enum _FoodSort { nameAsc, nameDesc, mostUsed }

/// Catálogo de comidas con buscador, filtro por toma y ordenación.
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  _FoodSort _sort = _FoodSort.nameAsc;
  MealSlot? _slotFilter;
  bool? _macrosFilter; // null = todas, true = con macros, false = sin macros
  bool _cookableOnly = false; // solo lo que puedo cocinar con lo que tengo

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Caché de las etiquetas de cada plato. Construirlas era barato por
  /// separado, pero se rehacían para cada fila en cada fotograma de scroll:
  /// ordenar las tomas, formatear textos, decidir iconos… Ahora se calculan
  /// una vez por plato y se reutilizan mientras el catálogo no cambie.
  final Map<String, List<_Badge>> _badgeCache = {};
  int _badgeCacheStamp = -1;

  List<_Badge> _badgesOf(Food food, bool gymEnabled, AppStrings t) {
    return _badgeCache.putIfAbsent(food.name, () {
      final slots = food.slots.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      return [
        for (final slot in slots) _Badge(slot.icon, t.mealSlot(slot)),
        if (food.isComposed)
          _Badge(
            Icons.layers_outlined,
            t.ingredientCount(food.components.length),
          ),
        for (final tag in food.tags) _Badge(null, t.foodTag(tag)),
        if (food.prepMinutes != null)
          _Badge(Icons.timer_outlined, '${food.prepMinutes} ${t.minutesShort}'),
        if (food.hasLeftovers)
          _Badge(Icons.restaurant_outlined,
              t.servingsMadeCount(food.servingsMade)),
        if (gymEnabled && food.hasMacros) ...[
          _Badge(Icons.local_fire_department_outlined, t.kcalValue(food.kcal!)),
          _Badge(Icons.egg_outlined, '${food.protein} ${t.gramShort}'),
          if (food.isHighProtein) _Badge(null, t.highInProtein, strong: true),
        ],
      ];
    });
  }

  /// Invalida la caché cuando el catálogo o el idioma cambian (se llama desde
  /// el `Consumer`).
  void _syncBadgeCache(List<Food> foods, bool gymEnabled, AppStrings t) {
    final stamp = Object.hashAll([
      foods.length,
      gymEnabled,
      t.languageCode,
      for (final f in foods) f.hashCode,
    ]);
    if (stamp != _badgeCacheStamp) {
      _badgeCacheStamp = stamp;
      _badgeCache.clear();
    }
  }

  void _onAction(String value, MealProvider provider, Food food) {
    final t = context.t;
    switch (value) {
      case 'fav':
        provider.addOrReplaceFood(food.copyWith(favorite: !food.favorite));
      case 'snooze':
        provider.snoozeFood(food, weeks: 2);
        _snack(context, t.snoozedMessage(food.name));
      case 'wake':
        provider.addOrReplaceFood(food.copyWith(clearSnooze: true));
      case 'duplicate':
        provider.addOrReplaceFood(
            food.copyWith(name: '${food.name} (${t.copySuffix})'));
      case 'delete':
        _confirmDelete(context, provider, food);
    }
  }

  /// Con [ignoreFilters] solo cuenta el buscador: es lo que hace la interfaz
  /// limpia, que esconde las tiras de filtros. Si se guardaran activos, la
  /// lista saldría recortada sin nada en pantalla que lo explicara.
  List<Food> _apply(
    List<Food> all,
    Map<String, int> usage, {
    Set<String> cookable = const {},
    bool ignoreFilters = false,
  }) {
    final q = _query.trim().toLowerCase();
    final list = all.where((f) {
      final matchesQuery = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.ingredients.toLowerCase().contains(q);
      if (ignoreFilters) return matchesQuery;
      final matchesSlot = _slotFilter == null || f.slots.contains(_slotFilter);
      final matchesMacros = _macrosFilter == null || f.hasMacros == _macrosFilter;
      final matchesStock = !_cookableOnly || cookable.contains(f.name);
      return matchesQuery && matchesSlot && matchesMacros && matchesStock;
    }).toList();

    switch (_sort) {
      case _FoodSort.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _FoodSort.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case _FoodSort.mostUsed:
        list.sort((a, b) {
          final c = (usage[b.name] ?? 0).compareTo(usage[a.name] ?? 0);
          return c != 0
              ? c
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final gymEnabled = context.watch<GymProvider>().enabled;
    final t = context.t;
    final clean = context.clean;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.myMealsTitle),
        actions: [
          // El escáner también está dentro de "Añadir", así que en modo limpio
          // se puede quitar de aquí sin perderlo.
          if (!clean)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: t.scanProduct,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanFoodScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: t.exampleMeals,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresetFoodsScreen()),
            ),
          ),
          PopupMenuButton<_FoodSort>(
            icon: const Icon(Icons.sort),
            tooltip: t.sort,
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: _FoodSort.nameAsc, child: Text(t.sortNameAsc)),
              PopupMenuItem(
                  value: _FoodSort.nameDesc, child: Text(t.sortNameDesc)),
              PopupMenuItem(
                  value: _FoodSort.mostUsed, child: Text(t.sortMostUsed)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFoodScreen()),
        ),
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
                hintText: t.searchByNameOrIngredient,
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
          // Dos tiras de filtros ocupan más que tres platos de la lista: son lo
          // primero que se va con la interfaz limpia.
          if (!clean) ...[
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
                      selected: _slotFilter == null,
                      onSelected: (_) => setState(() => _slotFilter = null),
                    ),
                  ),
                  for (final slot in MealSlot.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t.mealSlot(slot)),
                        avatar: Icon(slot.icon, size: 16),
                        selected: _slotFilter == slot,
                        onSelected: (_) => setState(() => _slotFilter = slot),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(t.canCookNow),
                      avatar: const Icon(Icons.kitchen_outlined, size: 16),
                      selected: _cookableOnly,
                      onSelected: (v) => setState(() => _cookableOnly = v),
                    ),
                  ),
                  if (gymEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t.all),
                        selected: _macrosFilter == null,
                        onSelected: (_) => setState(() => _macrosFilter = null),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t.withMacros),
                        avatar: const Icon(Icons.local_fire_department_outlined,
                            size: 16),
                        selected: _macrosFilter == true,
                        onSelected: (_) => setState(() => _macrosFilter = true),
                      ),
                    ),
                    ChoiceChip(
                      label: Text(t.withoutMacros),
                      avatar: const Icon(Icons.remove_circle_outline, size: 16),
                      selected: _macrosFilter == false,
                      onSelected: (_) => setState(() => _macrosFilter = false),
                    ),
                  ],
                ],
              ),
            ),
          ],
          Expanded(
            child: Consumer<MealProvider>(
              builder: (context, provider, _) {
                final all = provider.foods;
                if (all.isEmpty) return const _EmptyState();

                final usage = _sort == _FoodSort.mostUsed
                    ? provider.foodUsageCounts()
                    : const <String, int>{};
                final cookable = _cookableOnly && !clean
                    ? provider
                        .cookableNow(context.read<PantryProvider>().items)
                        .map((f) => f.name)
                        .toSet()
                    : const <String>{};
                final foods =
                    _apply(all, usage, cookable: cookable, ignoreFilters: clean);
                _syncBadgeCache(all, gymEnabled, t);

                if (foods.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(t.noSearchResults),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      12, 8, 12, 88 + MediaQuery.viewPaddingOf(context).bottom),
                  itemCount: foods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return _FoodCard(
                      food: food,
                      compact: clean,
                      badges:
                          clean ? const [] : _badgesOf(food, gymEnabled, t),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFoodScreen(existing: food),
                        ),
                      ),
                      onAction: (v) => _onAction(v, provider, food),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MealProvider provider, Food food) {
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteMealTitle),
        content: Text(t.deleteMealBody(food.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              provider.removeFood(food);
              Navigator.pop(ctx);
              // Borrar un plato ya no es definitivo: hay unos segundos para
              // recuperarlo si fue un error.
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(t.deletedItem(food.name)),
                  action: SnackBarAction(
                    label: t.undo,
                    onPressed: () => provider.addOrReplaceFood(food),
                  ),
                ));
            },
            child: Text(t.delete),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Una etiqueta ya calculada de un plato (icono opcional + texto).
class _Badge {
  final IconData? icon;
  final String label;
  final bool strong;
  const _Badge(this.icon, this.label, {this.strong = false});
}

/// Tarjeta de un plato del catálogo.
///
/// Está escrita a mano en vez de con `ListTile` + `Chip` a propósito: cada
/// `Chip` es un `Material` con su forma, su tinta y su semántica propia, y una
/// tarjeta llegaba a montar ocho. Con listas largas eso se traducía en tirones
/// al hacer scroll, porque cada fila que entra en pantalla se construye entera.
/// Aquí las etiquetas son `Container`+`Text`, la sombra de la tarjeta está
/// quitada (pintar sombras por fila también cuesta) y el menú contextual solo
/// se materializa al pulsarlo.
class _FoodCard extends StatelessWidget {
  final Food food;
  final List<_Badge> badges;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  /// Versión de la interfaz limpia: sin etiquetas y sin el botón de tres
  /// puntos. Las mismas opciones salen dejando pulsada la tarjeta.
  final bool compact;

  const _FoodCard({
    required this.food,
    required this.badges,
    required this.onTap,
    required this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: compact ? () => _actionSheet(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 10, compact ? 12 : 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(food: food),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (food.favorite)
                          Icon(Icons.favorite,
                              size: 15, color: theme.colorScheme.error),
                        if (food.isSnoozed)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.snooze,
                                size: 15, color: theme.colorScheme.outline),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food.ingredients,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final b in badges) _Pill(badge: b),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!compact)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: t.options,
                  onSelected: onAction,
                  itemBuilder: (_) => [
                    for (final action in _actions(t))
                      PopupMenuItem(
                        value: action.value,
                        child: Text(action.label),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Las opciones del plato, iguales vengan del menú o de la pulsación larga.
  List<({String value, String label, IconData icon})> _actions(AppStrings t) => [
        (
          value: 'fav',
          label: food.favorite ? t.unfavourite : t.markFavourite,
          icon: food.favorite ? Icons.favorite_border : Icons.favorite,
        ),
        (
          value: food.isSnoozed ? 'wake' : 'snooze',
          label: food.isSnoozed ? t.proposeAgain : t.notInTheMood,
          icon: food.isSnoozed ? Icons.alarm_on_outlined : Icons.snooze,
        ),
        (value: 'duplicate', label: t.duplicate, icon: Icons.copy_outlined),
        (value: 'delete', label: t.delete, icon: Icons.delete_outline),
      ];

  void _actionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                food.name,
                style: Theme.of(sheetCtx).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            for (final action in _actions(context.t))
              ListTile(
                leading: Icon(action.icon),
                title: Text(action.label),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onAction(action.value);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta ligera: lo que antes era un `Chip`, sin el peso de Material.
class _Pill extends StatelessWidget {
  final _Badge badge;
  const _Pill({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = badge.strong
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = badge.strong
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.icon != null) ...[
            Icon(badge.icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            badge.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: badge.strong ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniatura del plato: su foto si la tiene, o un icono con su inicial.
class _Thumb extends StatelessWidget {
  final Food food;
  const _Thumb({required this.food});

  /// `existsSync` es E/S de disco: hacerlo en cada `build` de cada fila, y en
  /// cada scroll, es una fuente clara de tirones. Se comprueba una vez por
  /// ruta y se recuerda.
  static final Map<String, bool> _exists = {};

  static bool _photoExists(String path) =>
      _exists[path] ??= File(path).existsSync();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (food.photoPath.isNotEmpty && _photoExists(food.photoPath)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(food.photoPath),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          // Sin esto se descodifica la foto entera (hasta 1200 px) para
          // pintarla en 48: mucha memoria y trabajo por cada fila.
          cacheWidth: 144,
          filterQuality: FilterQuality.low,
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      child: Text(
        food.name.isEmpty ? '?' : food.name[0].toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
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
            Icon(Icons.no_meals, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(context.t.noMealsYet, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.t.noMealsYetSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PresetFoodsScreen()),
              ),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(context.t.seeExampleMeals),
            ),
          ],
        ),
      ),
    );
  }
}
