import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/common_ingredients.dart';
import '../data/text_utils.dart';
import '../models/pantry_ingredient.dart';

/// Estado de la despensa: la lista de ingredientes del usuario (medidas caseras
/// + macros + repetibilidad). La primera vez se siembra con [kPresetIngredients];
/// después el usuario los edita, añade los suyos o los borra. Persiste como un
/// único documento JSON en SharedPreferences.
class PantryProvider extends ChangeNotifier {
  static const _kStorageKey = 'pantry_v1';
  static const _kDeletedKey = 'pantry_deleted_presets_v1';

  final List<PantryIngredient> _items = [];

  /// Presets que el usuario borró a propósito. Sin esto volvían a aparecer en
  /// cada arranque, porque la mezcla de presets nuevos los daba por "faltantes".
  final Set<String> _deletedPresets = {};

  SharedPreferences? _prefs;

  List<PantryIngredient> get items => List.unmodifiable(_items);
  List<PantryIngredient> get presets =>
      _items.where((i) => i.isPreset).toList();
  List<PantryIngredient> get mine => _items.where((i) => !i.isPreset).toList();

  /// Los que tienes en casa ahora mismo (stock > 0).
  List<PantryIngredient> get inStock =>
      _items.where((i) => i.stock > 0).toList();

  static String _norm(String s) => normalizeText(s);

  // ---------------------- CARGA / GUARDADO ----------------------

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _deletedPresets
      ..clear()
      ..addAll(_prefs!.getStringList(_kDeletedKey) ?? const []);
    final raw = _prefs!.getString(_kStorageKey);
    if (raw == null || raw.isEmpty) {
      _items.addAll(kPresetIngredients);
      _save();
    } else {
      try {
        final list = jsonDecode(raw) as List;
        _items.addAll(list
            .map((e) => PantryIngredient.fromJson(e as Map<String, dynamic>)));
        _mergeNewPresets();
      } catch (_) {
        _items
          ..clear()
          ..addAll(kPresetIngredients);
      }
    }
    notifyListeners();
  }

  /// Tras una actualización de la app pueden existir presets nuevos que el
  /// usuario aún no tiene guardados. Los añadimos sin tocar sus ediciones y
  /// sin resucitar los que borró él mismo.
  void _mergeNewPresets() {
    final existing = _items.map((i) => _norm(i.name)).toSet();
    var added = false;
    for (final p in kPresetIngredients) {
      final key = _norm(p.name);
      if (existing.contains(key) || _deletedPresets.contains(key)) continue;
      _items.add(p);
      added = true;
    }
    if (added) _save();
  }

  void _save() {
    _prefs?.setString(
      _kStorageKey,
      jsonEncode(_items.map((i) => i.toJson()).toList()),
    );
    _prefs?.setStringList(_kDeletedKey, _deletedPresets.toList());
  }

  /// Vuelve a traer todos los ingredientes de la app que se habían borrado.
  void restorePresets() {
    _deletedPresets.clear();
    _mergeNewPresets();
    _save();
    notifyListeners();
  }

  // ---------------------- OPERACIONES ----------------------

  /// Añade uno nuevo o reemplaza el existente con el mismo nombre.
  void addOrReplace(PantryIngredient item) {
    final i = _items.indexWhere((e) => _norm(e.name) == _norm(item.name));
    if (i >= 0) {
      _items[i] = item;
    } else {
      _items.add(item);
    }
    _save();
    notifyListeners();
  }

  void remove(PantryIngredient item) {
    _items.removeWhere((e) => _norm(e.name) == _norm(item.name));
    // Si era de la app, lo recordamos para no volver a añadirlo al arrancar.
    if (item.isPreset) _deletedPresets.add(_norm(item.name));
    _save();
    notifyListeners();
  }

  PantryIngredient? byBarcode(String barcode) {
    if (barcode.isEmpty) return null;
    for (final i in _items) {
      if (i.barcode == barcode) return i;
    }
    return null;
  }

  /// Busca el ingrediente de la despensa que corresponde a un texto libre
  /// ("pollo" → "Pechuga de pollo"), con cruce blando.
  PantryIngredient? match(String text) {
    if (text.trim().isEmpty) return null;
    // Primero intento exacto, luego blando (evita falsos positivos tontos).
    for (final i in _items) {
      if (_norm(i.name) == _norm(text)) return i;
    }
    for (final i in _items) {
      if (ingredientsMatch(i.name, text)) return i;
    }
    return null;
  }

  /// Sugerencias para autocompletar mientras se escriben los ingredientes.
  List<PantryIngredient> suggestions(String query, {int limit = 8}) {
    final q = _norm(query);
    if (q.isEmpty) return const [];
    final starts = <PantryIngredient>[];
    final contains = <PantryIngredient>[];
    for (final i in _items) {
      final n = _norm(i.name);
      if (n.startsWith(q)) {
        starts.add(i);
      } else if (n.contains(q)) {
        contains.add(i);
      }
    }
    return [...starts, ...contains].take(limit).toList();
  }

  /// Cambia el stock (cuántas unidades tienes en casa) de un ingrediente.
  void setStock(PantryIngredient item, double stock) {
    final i = _items.indexWhere((e) => _norm(e.name) == _norm(item.name));
    if (i < 0) return;
    _items[i] = _items[i].copyWith(stock: stock < 0 ? 0 : stock);
    _save();
    notifyListeners();
  }

  /// Mapa nombre-normalizado → repetibilidad, para que el planificador pueda
  /// saber qué ingredientes conviene no repetir tanto.
  Map<String, Repeatability> repeatabilityByName() {
    final map = <String, Repeatability>{};
    for (final i in _items) {
      // Si el mismo nombre aparece repetido, nos quedamos con el más restrictivo.
      final key = _norm(i.name);
      final current = map[key];
      if (current == null || i.repeat.index > current.index) {
        map[key] = i.repeat;
      }
    }
    return map;
  }
}
