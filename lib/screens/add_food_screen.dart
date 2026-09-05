import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/openfoodfacts_service.dart';
import '../l10n/l10n.dart';
import '../models/ai_estimate.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';
import '../widgets/portion_picker_dialog.dart';
import 'ai_estimate_screen.dart';
import 'ingredient_picker_screen.dart';
import 'scan_food_screen.dart';

/// Resultado del diálogo de componente: guardar uno nuevo/editado o eliminarlo.
class _CompResult {
  final FoodComponent? component;
  final bool delete;
  const _CompResult({this.component, this.delete = false});
}

/// Formulario para crear (o editar) un plato.
///
/// - [existing]: modo edición.
/// - [prefill]: valores iniciales para un plato nuevo (p. ej. al escanear).
/// - [prefillNote]: avisillo sobre el origen de los datos prerrellenados.
///
/// Un plato puede tener "componentes" (ingredientes con macros propias); si los
/// hay, las calorías, la proteína y el texto de ingredientes se calculan de
/// ellos (p. ej. hamburguesa = pan + carne).
class AddFoodScreen extends StatefulWidget {
  final Food? existing;
  final Food? prefill;
  final String? prefillNote;
  const AddFoodScreen({
    super.key,
    this.existing,
    this.prefill,
    this.prefillNote,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _kcalCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _costCtrl;
  late Set<MealSlot> _slots;
  late List<FoodComponent> _components;
  late Set<String> _tags;
  late int _servingsMade;
  late int _rating;
  late bool _favorite;
  late String _photoPath;
  late final Food? _base;

  bool get _isEditing => widget.existing != null;
  bool get _composed => _components.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _base = widget.existing ?? widget.prefill;
    _nameCtrl = TextEditingController(text: _base?.name ?? '');
    _ingredientsCtrl = TextEditingController(text: _base?.ingredients ?? '');
    _kcalCtrl =
        TextEditingController(text: _base?.kcal != null ? '${_base!.kcal}' : '');
    _proteinCtrl = TextEditingController(
        text: _base?.protein != null ? '${_base!.protein}' : '');
    _slots = {...?_base?.slots};
    _components = [...?_base?.components];
    _notesCtrl = TextEditingController(text: _base?.notes ?? '');
    _prepCtrl = TextEditingController(
        text: _base?.prepMinutes != null ? '${_base!.prepMinutes}' : '');
    _costCtrl = TextEditingController(
        text: _base?.costPerServing != null
            ? _base!.costPerServing!.toStringAsFixed(2)
            : '');
    _tags = {...?_base?.tags};
    _servingsMade = _base?.servingsMade ?? 1;
    _rating = _base?.rating ?? 0;
    _favorite = _base?.favorite ?? false;
    _photoPath = _base?.photoPath ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _notesCtrl.dispose();
    _prepCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  /// Foto del plato: se guarda la ruta del archivo que elige el usuario.
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.t.takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.t.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (_photoPath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(context.t.removePhoto),
                onTap: () => Navigator.pop(ctx, null),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (source == null) {
      setState(() => _photoPath = '');
      return;
    }
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200);
    if (picked != null && mounted) {
      setState(() => _photoPath = picked.path);
    }
  }

  /// Lo que se está escribiendo después de la última coma, para autocompletar.
  String _ingredientQuery = '';

  static String _qtyStr(double q) =>
      q == q.roundToDouble() ? '${q.toInt()}' : q.toStringAsFixed(1);

  static String _lastToken(String text) {
    final i = text.lastIndexOf(',');
    return (i < 0 ? text : text.substring(i + 1)).trim();
  }

  /// Sustituye lo que se está escribiendo por el ingrediente elegido de la
  /// despensa. Así el texto casa con la despensa y la lista de la compra
  /// agrupa bien.
  void _completeIngredient(String name) {
    final text = _ingredientsCtrl.text;
    final i = text.lastIndexOf(',');
    final head = i < 0 ? '' : text.substring(0, i + 1);
    final completed = head.isEmpty ? '$name, ' : '$head $name, ';
    _ingredientsCtrl.text = completed;
    _ingredientsCtrl.selection =
        TextSelection.collapsed(offset: completed.length);
    setState(() => _ingredientQuery = '');
  }

  void _setQty(int i, double q) {
    setState(() =>
        _components[i] = _components[i].copyWith(quantity: q < 0.5 ? 0.5 : q));
  }

  Future<void> _addScanned() async {
    final product = await Navigator.push<ScannedProduct>(
      context,
      MaterialPageRoute(builder: (_) => const ScanFoodScreen(asComponent: true)),
    );
    if (product == null || !mounted) return;
    // El selector de porción calcula cuánto se usa realmente (gramos o
    // raciones) antes de añadirlo: los productos vienen por 100 g o por ración.
    final component = await PortionPickerDialog.show(context, product);
    if (component != null && mounted) {
      setState(() => _components.add(component));
    }
  }

  /// Añade un ingrediente desde la tabla de medidas caseras (comida fresca sin
  /// código de barras: pollo, arroz, huevos…).
  Future<void> _addFromTable() async {
    final component = await Navigator.push<FoodComponent>(
      context,
      MaterialPageRoute(builder: (_) => const IngredientPickerScreen()),
    );
    if (component != null && mounted) {
      setState(() => _components.add(component));
    }
  }

  /// Estima las macros del plato completo con IA (texto y/o foto) y rellena los
  /// campos de calorías y proteína.
  Future<void> _estimateWithAi() async {
    final estimate = await Navigator.push<AiEstimate>(
      context,
      MaterialPageRoute(
        builder: (_) => AiEstimateScreen(initialText: _nameCtrl.text.trim()),
      ),
    );
    if (estimate == null || !mounted) return;
    setState(() {
      if (_nameCtrl.text.trim().isEmpty && estimate.name.isNotEmpty) {
        _nameCtrl.text = estimate.name;
      }
      _kcalCtrl.text = '${estimate.kcal}';
      _proteinCtrl.text = '${estimate.protein}';
    });
    _snack(context.t.aiMacrosFilled);
  }

  Future<void> _addManual() async {
    final res = await showDialog<_CompResult>(
      context: context,
      builder: (_) => const _ComponentDialog(),
    );
    if (res?.component != null) {
      setState(() => _components.add(res!.component!));
    }
  }

  Future<void> _editComponent(int i) async {
    final res = await showDialog<_CompResult>(
      context: context,
      builder: (_) => _ComponentDialog(initial: _components[i], isEdit: true),
    );
    if (res == null) return;
    setState(() {
      if (res.delete) {
        _components.removeAt(i);
      } else if (res.component != null) {
        _components[i] = res.component!;
      }
    });
  }

  void _save(List<MealSlot> activeSlots, bool showMacros) {
    final name = _nameCtrl.text.trim();
    final t = context.t;
    final gymEnabled = context.read<GymProvider>().enabled;

    final String ingredients;
    final int? kcal;
    final int? protein;
    if (_composed) {
      ingredients = _components.map((c) => c.name).join(', ');
      kcal = Food.sumKcal(_components);
      protein = Food.sumProtein(_components);
    } else {
      // En Modo Gym el campo de texto está oculto: conservamos lo que ya
      // hubiera (plato editado/prerrellenado) o usamos el nombre como respaldo
      // para la lista de la compra.
      final text = _ingredientsCtrl.text.trim();
      ingredients = (gymEnabled && text.isEmpty) ? name : text;
      kcal = showMacros ? int.tryParse(_kcalCtrl.text) : _base?.kcal;
      protein = showMacros ? int.tryParse(_proteinCtrl.text) : _base?.protein;
    }

    if (name.isEmpty || ingredients.isEmpty) {
      _snack(gymEnabled
          ? t.pleaseCompleteName
          : t.pleaseCompleteNameAndIngredients);
      return;
    }

    var slots = Set<MealSlot>.from(_slots);
    if (slots.isEmpty) slots = activeSlots.toSet();

    final food = Food(
      name: name,
      ingredients: ingredients,
      slots: slots,
      kcal: kcal,
      protein: protein,
      components: _components,
      tags: _tags,
      prepMinutes: int.tryParse(_prepCtrl.text),
      servingsMade: _servingsMade,
      rating: _rating,
      favorite: _favorite,
      notes: _notesCtrl.text.trim(),
      photoPath: _photoPath,
      costPerServing: double.tryParse(_costCtrl.text.replaceAll(',', '.')),
      snoozedUntil: _base?.snoozedUntil,
    );

    final provider = context.read<MealProvider>();
    // Al editar pasamos el nombre anterior: si lo cambiaste, esto renombra el
    // plato de verdad (borra el viejo y reescribe las semanas planificadas) en
    // vez de crear un duplicado.
    provider.addOrReplaceFood(food, previousName: widget.existing?.name);
    if (_isEditing) {
      final renamed = widget.existing!.name != name;
      _snack(renamed ? t.renamedTo(name) : t.mealUpdated);
      Navigator.pop(context);
    } else {
      _snack(t.mealAdded);
      _nameCtrl.clear();
      _ingredientsCtrl.clear();
      _kcalCtrl.clear();
      _proteinCtrl.clear();
      _notesCtrl.clear();
      _prepCtrl.clear();
      _costCtrl.clear();
      setState(() {
        _slots = {};
        _components = [];
        _tags = {};
        _servingsMade = 1;
        _rating = 0;
        _favorite = false;
        _photoPath = '';
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeSlots = gym.activeMealSlots;
    final showMacros = gym.enabled || (_base?.hasMacros ?? false) || _composed;
    final theme = Theme.of(context);
    final t = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? t.editMeal : t.addMeal)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          if (widget.prefillNote != null && !_isEditing) ...[
            _Banner(
              icon: Icons.qr_code_scanner,
              text: t.prefillNotice(widget.prefillNote!),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoBox(path: _photoPath, onTap: _pickPhoto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: t.mealNameLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_favorite
                              ? Icons.favorite
                              : Icons.favorite_border),
                          color: _favorite ? theme.colorScheme.error : null,
                          tooltip: t.favourite,
                          onPressed: () =>
                              setState(() => _favorite = !_favorite),
                        ),
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 30, minHeight: 30),
                            icon: Icon(
                              i <= _rating ? Icons.star : Icons.star_border,
                              size: 20,
                            ),
                            color: theme.colorScheme.primary,
                            onPressed: () => setState(
                                () => _rating = _rating == i ? 0 : i),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(t.ingredientsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _addScanned,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(t.scan),
              ),
              OutlinedButton.icon(
                onPressed: _addFromTable,
                icon: const Icon(Icons.search),
                label: Text(t.searchIngredient),
              ),
              OutlinedButton.icon(
                onPressed: _addManual,
                icon: const Icon(Icons.add),
                label: Text(t.byHand),
              ),
            ],
          ),
          if (_composed) ...[
            const SizedBox(height: 8),
            for (var i = 0; i < _components.length; i++)
              _ComponentTile(
                component: _components[i],
                qtyLabel: _qtyStr(_components[i].quantity),
                onTap: () => _editComponent(i),
                onDec: () => _setQty(i, _components[i].quantity - 0.5),
                onInc: () => _setQty(i, _components[i].quantity + 0.5),
              ),
            const SizedBox(height: 8),
            _TotalCard(
              kcal: Food.sumKcal(_components),
              protein: Food.sumProtein(_components),
            ),
          ] else ...[
            // El campo de ingredientes en texto es del modo normal; en Modo Gym
            // los platos se montan con ingredientes con macros (escanear/buscar).
            if (!gym.enabled) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _ingredientsCtrl,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => setState(() => _ingredientQuery = _lastToken(v)),
                decoration: InputDecoration(
                  labelText: t.ingredientsTextLabel,
                  helperText: t.ingredientsTextHelper,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_basket),
                ),
              ),
              _IngredientSuggestions(
                query: _ingredientQuery,
                onPick: _completeIngredient,
              ),
            ],
            if (showMacros) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(t.nutritionPerServing,
                        style: theme.textTheme.titleSmall),
                  ),
                  TextButton.icon(
                    onPressed: _estimateWithAi,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(t.estimateWithAi),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kcalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t.calories,
                        suffixText: t.kcal,
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            const Icon(Icons.local_fire_department_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _proteinCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t.protein,
                        suffixText: t.gramShort,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.egg_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 20),
          Text(t.whichSlots, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final slot in activeSlots)
            SwitchListTile(
              title: Text(t.mealSlot(slot)),
              secondary: Icon(slot.icon),
              value: _slots.contains(slot),
              onChanged: (v) => setState(() {
                if (v) {
                  _slots.add(slot);
                } else {
                  _slots.remove(slot);
                }
              }),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t.ifNoneAllApply,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          Text(t.tagsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(t.tagsHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in kFoodTags)
                FilterChip(
                  label: Text(t.foodTag(tag)),
                  selected: _tags.contains(tag),
                  onSelected: (v) => setState(() {
                    if (v) {
                      _tags.add(tag);
                    } else {
                      _tags.remove(tag);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(t.detailsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _prepCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: t.prepTime,
                    suffixText: t.minutesShort,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.timer_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _costCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: t.costPerServing,
                    suffixText: '€',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restaurant_outlined),
            title: Text(t.servingsMadeTitle),
            subtitle: Text(_servingsMade > 1
                ? t.servingsMadeMulti(_servingsMade)
                : t.servingsMadeOne),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _servingsMade > 1
                      ? () => setState(() => _servingsMade--)
                      : null,
                ),
                Text('$_servingsMade', style: theme.textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _servingsMade < 6
                      ? () => setState(() => _servingsMade++)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: t.recipeOrNotes,
              helperText: t.recipeOrNotesHelper,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _save(activeSlots, showMacros),
            icon: Icon(_isEditing ? Icons.save : Icons.add),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            label: Text(_isEditing ? t.saveChanges : t.addMeal),
          ),
        ],
      ),
    );
  }
}

/// Cuadro de la foto del plato. Si no hay foto, invita a ponerla.
class _PhotoBox extends StatelessWidget {
  final String path;
  final VoidCallback onTap;
  const _PhotoBox({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = path.isEmpty ? null : File(path);
    final exists = file != null && file.existsSync();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        height: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: exists
            ? Image.file(file, fit: BoxFit.cover, cacheWidth: 288)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: theme.colorScheme.outline),
                  const SizedBox(height: 4),
                  Text(context.t.photo, style: theme.textTheme.labelSmall),
                ],
              ),
      ),
    );
  }
}

/// Chips de autocompletado leyendo de la despensa mientras escribes.
class _IngredientSuggestions extends StatelessWidget {
  final String query;
  final ValueChanged<String> onPick;
  const _IngredientSuggestions({required this.query, required this.onPick});

  @override
  Widget build(BuildContext context) {
    if (query.length < 2) return const SizedBox.shrink();
    final matches = context.read<PantryProvider>().suggestions(query);
    if (matches.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final m in matches)
            ActionChip(
              label: Text(m.name),
              visualDensity: VisualDensity.compact,
              onPressed: () => onPick(m.name),
            ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Banner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  final FoodComponent component;
  final String qtyLabel;
  final VoidCallback onTap;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _ComponentTile({
    required this.component,
    required this.qtyLabel,
    required this.onTap,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(component.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      context.t.macrosShort(
                          component.totalKcal, component.totalProtein),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onDec,
              ),
              Text('×$qtyLabel', style: theme.textTheme.labelLarge),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onInc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int kcal;
  final int protein;
  const _TotalCard({required this.kcal, required this.protein});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.insights_outlined,
                color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.t.totalLine(kcal, protein),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentDialog extends StatefulWidget {
  final FoodComponent? initial;
  final bool isEdit; // true: editar uno existente (muestra "Eliminar")
  const _ComponentDialog({this.initial, this.isEdit = false});

  @override
  State<_ComponentDialog> createState() => _ComponentDialogState();
}

class _ComponentDialogState extends State<_ComponentDialog> {
  late final TextEditingController _name;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _qty;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name ?? '');
    _kcal = TextEditingController(text: c != null ? '${c.kcal}' : '');
    _protein = TextEditingController(text: c != null ? '${c.protein}' : '');
    _qty = TextEditingController(
        text: c != null ? _AddFoodScreenState._qtyStr(c.quantity) : '1');
  }

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final q = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1;
    Navigator.pop(
      context,
      _CompResult(
        component: FoodComponent(
          name: name,
          kcal: int.tryParse(_kcal.text) ?? 0,
          protein: int.tryParse(_protein.text) ?? 0,
          quantity: q <= 0 ? 1 : q,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.isEdit;
    final t = context.t;
    return AlertDialog(
      title: Text(editing ? t.editIngredientTitle : t.addIngredientTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _qty,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: t.quantity,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const _CompResult(delete: true)),
            child: Text(t.delete),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(editing ? t.save : t.add),
        ),
      ],
    );
  }
}
