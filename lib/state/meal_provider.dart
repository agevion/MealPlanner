import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../data/text_utils.dart';
import '../models/food.dart';
import '../models/ingredient_group.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';
import '../models/week.dart';

/// Los siete días como CLAVE de almacenamiento, no como texto para enseñar.
///
/// El JSON de exportación de la app Android original usa estos nombres como
/// claves ("LunesCena"), así que traducirlos rompería la compatibilidad con los
/// archivos que la gente ya tiene. Lo que se ve en pantalla sale de
/// `AppStrings.weekdays`.
const List<String> kDays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const int kMaxWeeks = 30;
const String _kStorageKey = 'mealplanner_data_v1';

/// Resultado de intentar cambiar al azar una comida concreta.
enum RotateResult { ok, noFoods, locked }

/// Estado central de la aplicación. Sustituye al `FoodViewModel` de Android y
/// concentra además toda la lógica del planificador (semanas, randomización,
/// import/export y lista de compra). Persiste todo como un único documento
/// JSON en SharedPreferences.
class MealProvider extends ChangeNotifier {
  final List<Food> _foods = [];
  final List<Week> _weeks = [Week()];
  int _activeWeek = 0;
  final Random _rng = Random();
  SharedPreferences? _prefs;

  List<Food> get foods => List.unmodifiable(_foods);
  List<Week> get weeks => List.unmodifiable(_weeks);
  int get activeWeekIndex => _activeWeek;
  Week get activeWeek => _weeks[_activeWeek];

  // ---------------------- CARGA / GUARDADO ----------------------

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kStorageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _foods
          ..clear()
          ..addAll(
            (data['foods'] as List? ?? []).map(
              (e) => Food.fromJson(e as Map<String, dynamic>),
            ),
          );
        _weeks
          ..clear()
          ..addAll(
            (data['weeks'] as List? ?? []).map(
              (e) => Week.fromJson(e as Map<String, dynamic>),
            ),
          );
        if (_weeks.isEmpty) _weeks.add(Week());
        _activeWeek = (data['activeWeek'] as int? ?? 0).clamp(
          0,
          _weeks.length - 1,
        );
      } catch (_) {
        // Datos corruptos: empezamos de cero sin romper la app.
      }
    }
    // Ata la semana activa al calendario real si el usuario todavía no tiene
    // ninguna semana con fecha (instalaciones que vienen de la versión vieja).
    ensureCalendarAnchor();
    notifyListeners();
  }

  Timer? _saveTimer;

  /// Guarda, pero sin machacar el disco.
  ///
  /// Cada cambio (marcar un ingrediente, mover una comida) serializaba el
  /// documento entero —catálogo + las 30 semanas— y lo escribía. Al ir
  /// marcando la lista de la compra eso se notaba en los fotogramas. Ahora se
  /// agrupan los cambios seguidos en una sola escritura.
  void _save() {
    if (_prefs == null) return; // en tests no hay disco: nada que agrupar
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _writeNow);
  }

  void _writeNow() {
    _saveTimer?.cancel();
    _saveTimer = null;
    final data = {
      'foods': _foods.map((f) => f.toJson()).toList(),
      'weeks': _weeks.map((w) => w.toJson()).toList(),
      'activeWeek': _activeWeek,
    };
    _prefs?.setString(_kStorageKey, jsonEncode(data));
  }

  /// Fuerza la escritura pendiente. Se llama al cerrar o dejar la app en
  /// segundo plano, para no perder los últimos segundos de cambios.
  void flushPendingSave() {
    if (_saveTimer?.isActive ?? false) _writeNow();
  }

  @override
  void dispose() {
    flushPendingSave();
    _saveTimer?.cancel();
    super.dispose();
  }

  // ---------------------- CATÁLOGO DE COMIDAS ----------------------

  void addFood(Food food) {
    _foods.add(food);
    _save();
    notifyListeners();
  }

  /// Guarda un plato. Si [previousName] viene informado y es distinto del
  /// nombre nuevo, es un RENOMBRADO: se borra el plato viejo y se reescriben
  /// todas las referencias en los planes de todas las semanas, para que la
  /// semana planificada no se quede apuntando a un plato que ya no existe.
  void addOrReplaceFood(Food food, {String? previousName}) {
    final renaming =
        previousName != null &&
        previousName.isNotEmpty &&
        previousName != food.name;

    if (renaming) {
      _foods.removeWhere((f) => f.name == previousName);
      _renamePlanReferences(previousName, food.name);
    }

    final i = _foods.indexWhere((f) => f.name == food.name);
    if (i >= 0) {
      _foods[i] = food;
    } else {
      _foods.add(food);
    }
    _save();
    notifyListeners();
  }

  /// Reescribe el nombre de un plato en los planes y en los platos embebidos de
  /// todas las semanas.
  void _renamePlanReferences(String oldName, String newName) {
    for (final week in _weeks) {
      for (final list in week.plan.values) {
        for (var i = 0; i < list.length; i++) {
          if (list[i] == oldName) list[i] = newName;
        }
      }
      for (var i = 0; i < week.embeddedFoods.length; i++) {
        if (week.embeddedFoods[i].name == oldName) {
          week.embeddedFoods[i] = week.embeddedFoods[i].copyWith(name: newName);
        }
      }
    }
  }

  /// Fusiona dos platos: todo lo planificado con [fromName] pasa a [intoName] y
  /// el primero desaparece del catálogo. Devuelve false si alguno no existe.
  bool mergeFoods(String fromName, String intoName) {
    if (fromName == intoName) return false;
    if (!catalogContains(fromName) || !catalogContains(intoName)) return false;
    _foods.removeWhere((f) => f.name == fromName);
    _renamePlanReferences(fromName, intoName);
    _save();
    notifyListeners();
    return true;
  }

  /// Añade varias comidas de una vez (reemplazando las que ya existan por
  /// nombre). Guarda y notifica una sola vez. Útil para el muestrario inicial.
  void addFoods(Iterable<Food> newFoods) {
    var changed = false;
    for (final food in newFoods) {
      final i = _foods.indexWhere((f) => f.name == food.name);
      if (i >= 0) {
        _foods[i] = food;
      } else {
        _foods.add(food);
      }
      changed = true;
    }
    if (changed) {
      _save();
      notifyListeners();
    }
  }

  void removeFood(Food food) {
    _foods.removeWhere(
      (f) => f.name == food.name && f.ingredients == food.ingredients,
    );
    _save();
    notifyListeners();
  }

  bool catalogContains(String name) => _foods.any((f) => f.name == name);

  /// Aparca un plato: durante [weeks] semanas el randomizador no lo propondrá.
  /// Es el "no me apetece ahora mismo" sin tener que borrarlo.
  void snoozeFood(Food food, {int weeks = 2}) {
    final i = _foods.indexWhere((f) => f.name == food.name);
    if (i < 0) return;
    _foods[i] = _foods[i].copyWith(
      snoozedUntil: DateTime.now().add(Duration(days: weeks * 7)),
    );
    _save();
    notifyListeners();
  }

  /// Coste estimado de la semana activa, sumando el coste por ración de cada
  /// comida planificada. Devuelve null si ningún plato tiene precio.
  double? weekCost() {
    var total = 0.0;
    var any = false;
    final week = activeWeek;
    for (final entry in week.plan.entries) {
      for (var day = 0; day < entry.value.length; day++) {
        if (week.isAway(day)) continue;
        final name = entry.value[day];
        if (name == null) continue;
        final cost = resolveFood(name)?.costPerServing;
        if (cost != null) {
          total += cost;
          any = true;
        }
      }
    }
    return any ? total : null;
  }

  // ---------------------- SEMANAS ----------------------

  void setActiveWeek(int index) {
    if (index < 0 || index >= _weeks.length) return;
    _activeWeek = index;
    _save();
    notifyListeners();
  }

  /// Devuelve false si ya se alcanzó el máximo de semanas.
  ///
  /// La semana nueva se ata al calendario: continúa a la última semana que
  /// tenga fecha, o al lunes de la semana real actual si ninguna la tiene.
  bool addWeek() {
    if (_weeks.length >= kMaxWeeks) return false;
    _weeks.add(Week(startDate: _nextWeekStart()));
    _activeWeek = _weeks.length - 1;
    _save();
    notifyListeners();
    return true;
  }

  /// El lunes que le tocaría a una semana nueva.
  DateTime _nextWeekStart() {
    DateTime? latest;
    for (final w in _weeks) {
      final s = w.startDate;
      if (s != null && (latest == null || s.isAfter(latest))) latest = s;
    }
    if (latest == null) return Week.mondayOf(DateTime.now());
    final next = latest.add(const Duration(days: 7));
    // Nunca proponemos una semana ya pasada.
    final thisMonday = Week.mondayOf(DateTime.now());
    return next.isBefore(thisMonday) ? thisMonday : next;
  }

  // ---------------------- SEMANAS Y CALENDARIO ----------------------

  /// Índice de la semana que cubre [date] en el calendario, o null si ninguna
  /// tiene esa fecha asignada.
  int? indexOfWeekContaining(DateTime date) {
    for (var i = 0; i < _weeks.length; i++) {
      if (_weeks[i].containsDate(date)) return i;
    }
    return null;
  }

  /// La semana que cubre [date], o la activa si ninguna está atada a esa fecha.
  /// Así "Hoy" nunca se queda sin plan que mirar.
  Week weekForDate(DateTime date) {
    final i = indexOfWeekContaining(date);
    return i != null ? _weeks[i] : activeWeek;
  }

  /// Ata (o desata, con null) una semana a un lunes concreto del calendario.
  void setWeekStart(int index, DateTime? monday) {
    if (index < 0 || index >= _weeks.length) return;
    _weeks[index].startDate = monday == null ? null : Week.mondayOf(monday);
    _save();
    notifyListeners();
  }

  /// Etiqueta de una semana para las pestañas: "11–17 ago" si tiene fecha, o
  /// "Semana N" si es una semana suelta. Marca la semana real actual.
  String weekLabel(int index, {AppStrings t = const AppStrings()}) {
    if (index < 0 || index >= _weeks.length) return '';
    final week = _weeks[index];
    final start = week.startDate;
    if (start == null) return t.weekNumber(index + 1);
    if (week.containsDate(DateTime.now())) return t.thisWeek;
    return t.weekRange(start, start.add(const Duration(days: 6)));
  }

  /// Se llama al arrancar: si ninguna semana está atada al calendario, ata la
  /// activa a la semana real actual para que "Hoy" y el planificador hablen de
  /// lo mismo. No toca nada si el usuario ya tiene fechas puestas.
  void ensureCalendarAnchor() {
    if (_weeks.any((w) => w.startDate != null)) return;
    _weeks[_activeWeek].startDate = Week.mondayOf(DateTime.now());
    _save();
  }

  /// Salta a la semana del calendario que corresponde a hoy, si existe.
  bool goToCurrentWeek() {
    final i = indexOfWeekContaining(DateTime.now());
    if (i == null) return false;
    setActiveWeek(i);
    return true;
  }

  /// Duplica una semana (plan y días bloqueados) en una nueva. Útil para
  /// reutilizar una semana que te funcionó como plantilla.
  bool duplicateWeek(int index) {
    if (index < 0 || index >= _weeks.length) return false;
    if (_weeks.length >= kMaxWeeks) return false;
    final src = _weeks[index];
    final copy = Week(
      plan: {
        for (final e in src.plan.entries) e.key: List<String?>.of(e.value),
      },
      locked: Set<int>.of(src.locked),
      away: Set<int>.of(src.away),
      manualItems: List<String>.of(src.manualItems),
      embeddedFoods: List<Food>.of(src.embeddedFoods),
      imported: src.imported,
      startDate: _nextWeekStart(),
    );
    _weeks.add(copy);
    _activeWeek = _weeks.length - 1;
    _save();
    notifyListeners();
    return true;
  }

  /// Devuelve false si solo queda una semana (no se puede borrar la última).
  bool removeActiveWeek() {
    if (_weeks.length <= 1) return false;
    _weeks.removeAt(_activeWeek);
    if (_activeWeek >= _weeks.length) _activeWeek = _weeks.length - 1;
    _save();
    notifyListeners();
    return true;
  }

  // ---------------------- RANDOMIZACIÓN ----------------------

  /// Selección aleatoria con peso: cuanto más se ha usado un plato esta semana,
  /// menos probable es volver a elegirlo. [exclude] son platos ya usados ese
  /// mismo día, para no repetir un plato en dos tomas seguidas. [penalty] añade
  /// un factor extra por plato (p. ej. para no amontonar ingredientes poco
  /// repetibles); 1.0 = sin penalización.
  Food _weightedPick(
    List<Food> pool,
    Map<String, int> used,
    Set<String> exclude, {
    double Function(Food)? penalty,
  }) {
    var candidates = pool.where((f) => !exclude.contains(f.name)).toList();
    if (candidates.isEmpty) candidates = pool;
    if (candidates.length == 1) return candidates.first;

    final weights = candidates.map((f) {
      final base = 1.0 / (1 + (used[f.name] ?? 0) * 2);
      return base * (penalty?.call(f) ?? 1.0);
    }).toList();
    final total = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return candidates[_rng.nextInt(candidates.length)];
    var acc = 0.0;
    final r = _rng.nextDouble() * total;
    for (var i = 0; i < candidates.length; i++) {
      acc += weights[i];
      if (r <= acc) return candidates[i];
    }
    return candidates.last;
  }

  /// Rellena la semana activa al azar para las [slots] indicadas.
  /// [repeatByIngredient] (opcional) sesga la elección para no repetir tanto los
  /// ingredientes marcados como "con moderación" o "limitar" en la despensa.
  /// Devuelve un mensaje de error o null si todo fue bien.
  /// [onlyEmpty] rellena únicamente las celdas vacías, respetando lo que ya
  /// habías puesto a mano. [targetKcal], si viene, hace que el randomizador
  /// prefiera platos que acerquen el día a esas calorías.
  String? randomizeActiveWeek(
    List<MealSlot> slots, {
    Map<String, Repeatability> repeatByIngredient = const {},
    bool onlyWithMacros = false,
    bool onlyEmpty = false,
    int? targetKcal,
    bool useLeftovers = false,
    Set<int> busyDays = const {},
    AppStrings t = const AppStrings(),
  }) {
    if (_foods.isEmpty) return t.noMealsToAssign;
    if (slots.isEmpty) return t.noSlotsConfigured;

    final pools = <MealSlot, List<Food>>{};
    for (final slot in slots) {
      var pool = _foods.where((f) => f.fitsSlot(slot)).toList();
      if (onlyWithMacros) pool = pool.where((f) => f.hasMacros).toList();
      // Los platos "en pausa" no salen, salvo que no quedara ningún otro.
      final awake = pool.where((f) => !f.isSnoozed).toList();
      if (awake.isNotEmpty) pool = awake;
      if (pool.isEmpty) {
        return onlyWithMacros
            ? t.noMealsWithMacrosFor(t.mealSlot(slot))
            : t.noMealsFor(t.mealSlot(slot));
      }
      pools[slot] = pool;
    }

    // Cuántas veces ha salido cada etiqueta: sirve para no montar una semana
    // entera de pasta.
    final tagUse = <String, int>{};
    void countTags(Food food) {
      for (final t in food.tags) {
        tagUse[t] = (tagUse[t] ?? 0) + 1;
      }
    }

    /// Peso extra por gusto: los favoritos y los bien valorados salen más.
    double preference(Food food) {
      var factor = 1.0;
      if (food.favorite) factor *= 1.8;
      if (food.rating > 0) factor *= 1 + (food.rating - 3) * 0.15;
      // Variedad por etiqueta: a partir de 3 usos en la semana, penaliza.
      for (final t in food.tags) {
        final u = tagUse[t] ?? 0;
        if (u >= 3) factor *= 0.35;
      }
      return factor.clamp(0.1, 3.0);
    }

    final week = activeWeek;
    final used = <String, int>{};
    // Cuántas veces se ha usado esta semana cada ingrediente controlado.
    final ingredientUse = <String, int>{};

    // Cruce blando: "Pechuga de pollo" (despensa) casa con "pollo" (plato).
    // Antes se comparaba el texto exacto en minúsculas y casi nunca coincidía.
    final controlled = repeatByIngredient.entries
        .where((e) => e.value != Repeatability.free)
        .toList();

    List<String> controlledKeysOf(Food food) {
      if (controlled.isEmpty) return const [];
      final keys = <String>[];
      for (final ing in splitIngredients(food.ingredients)) {
        for (final entry in controlled) {
          if (ingredientsMatch(entry.key, ing)) keys.add(entry.key);
        }
      }
      return keys;
    }

    void countIngredients(Food food) {
      for (final key in controlledKeysOf(food)) {
        ingredientUse[key] = (ingredientUse[key] ?? 0) + 1;
      }
    }

    // Lo que ya hay en días bloqueados cuenta para la variedad (no se toca).
    for (final day in week.locked) {
      for (final slot in slots) {
        final name = week.mealAt(slot, day);
        if (name != null) {
          used[name] = (used[name] ?? 0) + 1;
          final food = resolveFood(name);
          if (food != null) {
            countIngredients(food);
            countTags(food);
          }
        }
      }
    }

    // Celdas que ya ha ocupado una sobra: el bucle no debe pisarlas.
    final reserved = <String>{};

    /// La toma siguiente en el recorrido (día, toma) → para las sobras.
    ({int day, MealSlot slot})? nextCell(int day, int slotIndex) {
      if (slotIndex + 1 < slots.length) {
        return (day: day, slot: slots[slotIndex + 1]);
      }
      if (day + 1 < 7) return (day: day + 1, slot: slots.first);
      return null;
    }

    // Penaliza platos cuyos ingredientes controlados ya se han usado mucho.
    double penalty(Food food) {
      var factor = 1.0;
      for (final key in controlledKeysOf(food)) {
        final r = repeatByIngredient[key];
        if (r == null) continue;
        final cap = r.weeklySoftCap ?? 99;
        final u = ingredientUse[key] ?? 0;
        if (u >= cap) {
          factor *= 0.12;
        } else if (u >= cap - 1) {
          factor *= 0.5;
        }
      }
      return factor;
    }

    for (var day = 0; day < 7; day++) {
      if (week.locked.contains(day)) continue; // respetamos días bloqueados
      if (week.isAway(day)) continue; // ese día no comes en casa
      final usedToday = <String>{};
      // Lo que ya hay puesto ese día cuenta para no repetirlo en otra toma.
      for (final slot in slots) {
        final existing = week.mealAt(slot, day);
        if (existing != null) usedToday.add(existing);
      }
      // Presupuesto de calorías que le queda al día, si hay objetivo.
      var kcalLeft = targetKcal;
      if (kcalLeft != null) {
        for (final slot in slots) {
          final existing = week.mealAt(slot, day);
          final food = existing == null ? null : resolveFood(existing);
          if (food?.kcal != null) kcalLeft = kcalLeft! - food!.kcal!;
        }
      }

      for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
        final slot = slots[slotIndex];
        if (reserved.contains('$day-${slot.id}')) continue; // ya hay sobras
        if (onlyEmpty && week.mealAt(slot, day) != null) continue;
        final remainingSlots = kcalLeft == null
            ? 1
            : slots.where((s) => week.mealAt(s, day) == null).length;
        final budget = kcalLeft;
        final perSlot = (budget != null && remainingSlots > 0)
            ? budget / remainingSlots
            : null;

        // "Días con prisa": solo platos rápidos, si es que hay alguno.
        var pool = pools[slot]!;
        if (busyDays.contains(day)) {
          final quick = pool.where((f) => f.isQuick).toList();
          if (quick.isNotEmpty) pool = quick;
        }

        final pick = _weightedPick(
          pool,
          used,
          usedToday,
          penalty: (f) => penalty(f) * preference(f) * _kcalFit(f, perSlot),
        );
        week.setMeal(slot, day, pick.name);
        used[pick.name] = (used[pick.name] ?? 0) + 1;
        usedToday.add(pick.name);
        countIngredients(pick);
        countTags(pick);
        final spent = pick.kcal;
        if (budget != null && spent != null) kcalLeft = budget - spent;

        // Sobras: si el plato da para más de una ración, la toma siguiente la
        // ocupan las sobras en vez de cocinar otra cosa.
        if (useLeftovers && pick.hasLeftovers) {
          final next = nextCell(day, slotIndex);
          // La celda siguiente aún no la ha tocado este recorrido, así que
          // solo hay que respetar bloqueos, días fuera y, en modo "solo
          // huecos", lo que el usuario ya hubiera puesto a mano.
          if (next != null &&
              !week.isLocked(next.day) &&
              !week.isAway(next.day) &&
              (!onlyEmpty || week.mealAt(next.slot, next.day) == null)) {
            week.setMeal(next.slot, next.day, pick.name);
            reserved.add('${next.day}-${next.slot.id}');
            used[pick.name] = (used[pick.name] ?? 0) + 1;
            if (next.day == day) usedToday.add(pick.name);
          }
        }
      }
    }

    // Al randomizar dejamos de considerarla una semana importada.
    week.imported = false;
    week.embeddedFoods = [];

    _pruneChecks();
    _save();
    notifyListeners();
    return null;
  }

  /// Cuánto encaja un plato en las calorías que quedan para esa toma. Devuelve
  /// un factor de peso: 1.0 si encaja bien, menos cuanto más se pasa o se
  /// queda corto. Sin objetivo o sin macros, no influye.
  static double _kcalFit(Food food, double? targetPerSlot) {
    if (targetPerSlot == null || targetPerSlot <= 0 || food.kcal == null) {
      return 1.0;
    }
    final ratio = food.kcal! / targetPerSlot;
    final distance = (ratio - 1).abs();
    return (1.0 / (1 + distance * 2)).clamp(0.15, 1.0);
  }

  /// Re-randomiza una sola celda (una toma de un día concreto).
  ///
  /// A diferencia de antes, usa los mismos pesos que el randomizador de la
  /// semana (favorece platos poco usados) y no repite lo que ya hay ese día.
  /// Un día bloqueado no se toca: devuelve [RotateResult.locked].
  RotateResult rotateMeal(int dayIndex, MealSlot slot) {
    final week = activeWeek;
    if (week.isLocked(dayIndex)) return RotateResult.locked;

    final pool = _foods.where((f) => f.fitsSlot(slot)).toList();
    if (pool.isEmpty) return RotateResult.noFoods;

    // Uso de cada plato en la semana, para no repetir siempre los mismos.
    final used = <String, int>{};
    for (final list in week.plan.values) {
      for (final name in list) {
        if (name != null) used[name] = (used[name] ?? 0) + 1;
      }
    }

    // No repetimos lo que ya hay ese día, ni el plato que estamos cambiando.
    final exclude = <String>{};
    for (final s in week.plan.keys) {
      final n = week.mealAt(s, dayIndex);
      if (n != null) exclude.add(n);
    }

    final pick = _weightedPick(pool, used, exclude);
    week.setMeal(slot, dayIndex, pick.name);
    _save();
    notifyListeners();
    return RotateResult.ok;
  }

  /// Marca/desmarca un día como "fuera de casa": no se planifica ni entra en la
  /// lista de la compra.
  void toggleDayAway(int dayIndex) {
    final week = activeWeek;
    if (week.away.contains(dayIndex)) {
      week.away.remove(dayIndex);
    } else {
      week.away.add(dayIndex);
      for (final slot in week.plan.keys) {
        week.setMeal(slot, dayIndex, null);
      }
    }
    _save();
    notifyListeners();
  }

  // ---------------------- EDICIÓN MANUAL DEL PLAN ----------------------

  /// Asigna (o quita, con [name] null/vacío) un plato concreto a una celda.
  void setMeal(int dayIndex, MealSlot slot, String? name) {
    final value = (name == null || name.isEmpty) ? null : name;
    activeWeek.setMeal(slot, dayIndex, value);
    _pruneChecks();
    _save();
    notifyListeners();
  }

  /// Mueve una comida de una celda a otra (arrastrar y soltar). Si la celda de
  /// destino tenía algo, las dos comidas se intercambian.
  void moveMeal(int fromDay, MealSlot fromSlot, int toDay, MealSlot toSlot) {
    if (fromDay == toDay && fromSlot == toSlot) return;
    final week = activeWeek;
    final origin = week.mealAt(fromSlot, fromDay);
    final target = week.mealAt(toSlot, toDay);
    week.setMeal(toSlot, toDay, origin);
    week.setMeal(fromSlot, fromDay, target);
    _save();
    notifyListeners();
  }

  /// Vacía todas las tomas de un día.
  void clearDay(int dayIndex) {
    final week = activeWeek;
    for (final slot in week.plan.keys) {
      week.setMeal(slot, dayIndex, null);
    }
    _pruneChecks();
    _save();
    notifyListeners();
  }

  bool isDayLocked(int dayIndex) => activeWeek.isLocked(dayIndex);

  /// Bloquea/desbloquea un día (los bloqueados no los toca el randomizador).
  void toggleDayLock(int dayIndex) {
    final week = activeWeek;
    if (week.locked.contains(dayIndex)) {
      week.locked.remove(dayIndex);
    } else {
      week.locked.add(dayIndex);
    }
    _save();
    notifyListeners();
  }

  /// Qué porcentaje de los ingredientes de un plato tienes en casa ahora mismo
  /// (0.0 a 1.0). Alimenta el filtro "puedo cocinarlo ahora".
  double stockCoverage(Food food, List<PantryIngredient> pantry) {
    final ingredients = splitIngredients(food.ingredients);
    if (ingredients.isEmpty) return 0;
    final available = pantry.where((p) => p.stock > 0).toList();
    if (available.isEmpty) return 0;
    var have = 0;
    for (final ing in ingredients) {
      if (available.any((p) => ingredientsMatch(p.name, ing))) have++;
    }
    return have / ingredients.length;
  }

  /// Platos que puedes cocinar ya, ordenados de más a menos cubiertos.
  /// [minCoverage] es cuánto hace falta tener para que cuente (0.6 = 60 %).
  List<Food> cookableNow(
    List<PantryIngredient> pantry, {
    double minCoverage = 0.6,
  }) {
    final scored = <(Food, double)>[];
    for (final f in _foods) {
      final c = stockCoverage(f, pantry);
      if (c >= minCoverage) scored.add((f, c));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  /// Cuántas semanas están completas: todas las tomas de todos los días
  /// (menos los días que comes fuera) tienen plato. Alimenta el logro
  /// "semana perfecta".
  int completeWeeks(List<MealSlot> slots) {
    if (slots.isEmpty) return 0;
    var count = 0;
    for (final week in _weeks) {
      var complete = true;
      var anyDay = false;
      for (var day = 0; day < 7 && complete; day++) {
        if (week.isAway(day)) continue;
        anyDay = true;
        for (final slot in slots) {
          if (week.mealAt(slot, day) == null) {
            complete = false;
            break;
          }
        }
      }
      if (complete && anyDay) count++;
    }
    return count;
  }

  /// Cuántas veces aparece cada plato en todos los planes (todas las semanas).
  Map<String, int> foodUsageCounts() {
    final counts = <String, int>{};
    for (final week in _weeks) {
      for (final list in week.plan.values) {
        for (final name in list) {
          if (name != null) counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  // ---------------------- IMPORTAR PLATO AL CATÁLOGO ----------------------

  /// Busca un plato embebido (de una semana importada) por nombre.
  Food? findEmbedded(String name) {
    for (final f in activeWeek.embeddedFoods) {
      if (f.name == name) return f;
    }
    return null;
  }

  /// Para una celda cuyo plato no está en el catálogo: ¿podemos añadirlo?
  bool canAddToCatalog(String name) =>
      !catalogContains(name) && findEmbedded(name) != null;

  bool addMealToCatalog(String name) {
    final food = findEmbedded(name);
    if (food == null) return false;
    addOrReplaceFood(food);
    return true;
  }

  // ---------------------- MACROS (MODO GYM) ----------------------

  /// Resuelve un nombre de plato a su Food: primero en el catálogo, si no, en
  /// los platos embebidos de la semana importada.
  Food? resolveFood(String name) {
    final c = _foods.where((f) => f.name == name);
    if (c.isNotEmpty) return c.first;
    final e = activeWeek.embeddedFoods.where((f) => f.name == name);
    return e.isNotEmpty ? e.first : null;
  }

  /// Suma de kcal y proteína de las tomas asignadas un día. `complete` es true
  /// si hay al menos un plato asignado y todos tienen macros.
  ({int kcal, int protein, bool complete}) dayMacros(
    int day,
    List<MealSlot> slots,
  ) {
    var kcal = 0;
    var protein = 0;
    var any = false;
    var allHaveMacros = true;
    for (final slot in slots) {
      final name = activeWeek.mealAt(slot, day);
      if (name == null) continue;
      any = true;
      final food = resolveFood(name);
      if (food == null || !food.hasMacros) {
        allHaveMacros = false;
        continue;
      }
      kcal += food.kcal!;
      protein += food.protein!;
    }
    return (kcal: kcal, protein: protein, complete: any && allHaveMacros);
  }

  // ---------------------- LISTA DE COMPRA ----------------------

  /// Construye la lista de la compra de la semana activa.
  ///
  /// [pantry] (opcional) sirve para dos cosas: poner cada ingrediente en su
  /// pasillo del súper y estimar cantidades ("6 huevos") a partir de los
  /// platos compuestos. Los días marcados como "fuera de casa" no cuentan.
  List<IngredientGroup> shoppingListForActiveWeek({
    List<PantryIngredient> pantry = const [],
    AppStrings t = const AppStrings(),
  }) {
    final week = activeWeek;

    // Contamos cuántas veces se cocina cada plato (sin contar días fuera de
    // casa): dos veces pasta = doble de tomate.
    final timesCooked = <String, int>{};
    for (final list in week.plan.entries) {
      for (var day = 0; day < list.value.length; day++) {
        if (week.isAway(day)) continue;
        final name = list.value[day];
        if (name != null) timesCooked[name] = (timesCooked[name] ?? 0) + 1;
      }
    }

    final resolved = <Food>[];
    for (final name in timesCooked.keys) {
      final food = resolveFood(name);
      if (food != null) resolved.add(food);
    }

    PantryIngredient? pantryFor(String ingredient) {
      for (final p in pantry) {
        if (ingredientsMatch(p.name, ingredient)) return p;
      }
      return null;
    }

    final dishesByKey = <String, List<String>>{};
    final displayName = <String, String>{};
    final categoryByKey = <String, String>{};
    final unitsByKey = <String, double>{}; // nº de unidades acumuladas
    final unitLabelByKey = <String, String>{};

    for (final food in resolved) {
      final times = timesCooked[food.name] ?? 1;
      for (final ing in splitIngredients(food.ingredients)) {
        final key = normalizeText(ing);
        if (key.isEmpty) continue;
        displayName.putIfAbsent(key, () => capitalize(ing));
        dishesByKey.putIfAbsent(key, () => []);
        for (var i = 0; i < times; i++) {
          dishesByKey[key]!.add(food.name);
        }

        final p = pantryFor(ing);
        if (p != null) {
          categoryByKey[key] = p.category;
          unitLabelByKey[key] = p.unit;
        }

        // Si el plato es compuesto y este ingrediente es uno de sus
        // componentes, sabemos cuántas unidades hacen falta de verdad.
        for (final comp in food.components) {
          if (ingredientsMatch(comp.name, ing)) {
            unitsByKey[key] = (unitsByKey[key] ?? 0) + comp.quantity * times;
            if (p == null) unitLabelByKey.putIfAbsent(key, () => t.unitAbbrev);
          }
        }
      }
    }

    String quantityFor(String key) {
      final units = unitsByKey[key];
      if (units != null && units > 0) {
        final unit = unitLabelByKey[key] ?? t.unitAbbrev;
        final n = units == units.roundToDouble()
            ? '${units.toInt()}'
            : units.toStringAsFixed(1);
        return '$n $unit${units > 1 && !unit.endsWith('s') ? 's' : ''}';
      }
      final count = dishesByKey[key]?.length ?? 0;
      return count > 1 ? '×$count' : '';
    }

    final groups = <IngredientGroup>[];
    for (final entry in dishesByKey.entries) {
      groups.add(
        IngredientGroup(
          displayName[entry.key] ?? entry.key,
          // Un plato que se repite no se lista dos veces como "quién lo usa".
          entry.value.toSet().toList(),
          category: categoryByKey[entry.key] ?? 'Otros',
          quantityLabel: quantityFor(entry.key),
        ),
      );
    }

    // Ítems añadidos a mano que no provienen de ningún plato.
    for (final item in week.manualItems) {
      if (dishesByKey.containsKey(normalizeText(item))) continue;
      final p = pantryFor(item);
      groups.add(
        IngredientGroup(
          item,
          const [],
          manual: true,
          category: p?.category ?? 'Otros',
        ),
      );
    }
    return groups;
  }

  /// Borra los checks de ingredientes que ya no están en la lista (pasa al
  /// re-randomizar la semana: quedaban marcados ingredientes fantasma).
  void _pruneChecks() {
    final valid = shoppingListForActiveWeek().map((g) => g.name).toSet();
    activeWeek.checked.removeWhere((c) => !valid.contains(c));
  }

  /// Texto plano de la lista, para copiar o mandar por WhatsApp.
  String shoppingListAsText({
    List<PantryIngredient> pantry = const [],
    AppStrings t = const AppStrings(),
  }) {
    final groups = shoppingListForActiveWeek(pantry: pantry, t: t)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (groups.isEmpty) return t.shoppingListIsEmpty;

    final byCategory = <String, List<IngredientGroup>>{};
    for (final g in groups) {
      byCategory.putIfAbsent(g.category, () => []).add(g);
    }

    final buffer = StringBuffer('${t.shoppingTextHeader}\n');
    for (final entry in byCategory.entries) {
      buffer.writeln('\n${t.ingredientCategory(entry.key)}');
      for (final g in entry.value) {
        final done = activeWeek.checked.contains(g.name) ? 'x' : ' ';
        final qty = g.quantityLabel.isEmpty ? '' : ' (${g.quantityLabel})';
        buffer.writeln('[$done] ${g.name}$qty');
      }
    }
    return buffer.toString();
  }

  void addManualShoppingItem(String item) {
    final trimmed = item.trim();
    if (trimmed.isEmpty) return;
    final exists = activeWeek.manualItems.any(
      (e) => e.toLowerCase() == trimmed.toLowerCase(),
    );
    if (!exists) {
      activeWeek.manualItems.add(trimmed);
      _save();
      notifyListeners();
    }
  }

  void removeManualShoppingItem(String item) {
    activeWeek.manualItems.removeWhere(
      (e) => e.toLowerCase() == item.toLowerCase(),
    );
    activeWeek.checked.remove(item);
    _save();
    notifyListeners();
  }

  void clearChecks() {
    activeWeek.checked.clear();
    _save();
    notifyListeners();
  }

  void setAllChecked(Iterable<String> items) {
    activeWeek.checked
      ..clear()
      ..addAll(items);
    _save();
    notifyListeners();
  }

  bool isChecked(String ingredient) => activeWeek.checked.contains(ingredient);

  void toggleChecked(String ingredient, bool value) {
    if (value) {
      activeWeek.checked.add(ingredient);
    } else {
      activeWeek.checked.remove(ingredient);
    }
    _save();
    notifyListeners();
  }

  // ---------------------- EXPORTAR / IMPORTAR ----------------------

  String exportActiveWeekJson() {
    final week = activeWeek;
    final names = week.assignedNames();

    // Formato nuevo multi-toma: { slotId: { "Lunes": plato, ... } }.
    final plan = <String, dynamic>{};
    for (final entry in week.plan.entries) {
      final dayMap = <String, String>{};
      for (var i = 0; i < 7 && i < entry.value.length; i++) {
        final v = entry.value[i];
        if (v != null) dayMap[kDays[i]] = v;
      }
      if (dayMap.isNotEmpty) plan[entry.key.id] = dayMap;
    }

    // 'planificador' legacy (solo almuerzo/cena) para que la app Android
    // original siga pudiendo importar al menos esas dos tomas.
    final planificador = <String, String>{};
    final lunches = week.plan[MealSlot.lunch];
    final dinners = week.plan[MealSlot.dinner];
    for (var i = 0; i < 7; i++) {
      final l = (lunches != null && i < lunches.length) ? lunches[i] : null;
      final d = (dinners != null && i < dinners.length) ? dinners[i] : null;
      if (l != null) planificador[kDays[i]] = l;
      if (d != null) planificador['${kDays[i]}Cena'] = d;
    }

    final foodsExport = <Food>[];
    for (final name in names) {
      final c = _foods.where((f) => f.name == name);
      if (c.isNotEmpty) {
        foodsExport.add(c.first);
        continue;
      }
      final e = week.embeddedFoods.where((f) => f.name == name);
      if (e.isNotEmpty) foodsExport.add(e.first);
    }

    final root = {
      'version': 2,
      'comidas': foodsExport.map((f) => f.toJson()).toList(),
      'plan': plan,
      'planificador': planificador,
    };
    return const JsonEncoder.withIndent('  ').convert(root);
  }

  /// El menú de la semana en texto plano, para mandarlo por WhatsApp o pegarlo
  /// donde sea.
  String weekAsText(List<MealSlot> slots, {AppStrings t = const AppStrings()}) {
    final week = activeWeek;
    final buffer = StringBuffer('${t.weekTextHeader}\n');
    for (var day = 0; day < kDays.length; day++) {
      final dayName = t.weekdays[day];
      if (week.isAway(day)) {
        buffer.writeln('\n$dayName: ${t.outOfHome}');
        continue;
      }
      final lines = <String>[];
      for (final slot in slots) {
        final name = week.mealAt(slot, day);
        if (name != null) lines.add('  ${t.mealSlot(slot)}: $name');
      }
      if (lines.isEmpty) continue;
      buffer.writeln('\n$dayName');
      lines.forEach(buffer.writeln);
    }
    return buffer.toString();
  }

  /// Importa una semana desde un JSON. Devuelve un mensaje de error o null.
  String? importWeekFromJson(
    String jsonString, {
    AppStrings t = const AppStrings(),
  }) {
    if (_weeks.length >= kMaxWeeks) {
      return t.maxWeeksReached(kMaxWeeks);
    }
    try {
      final root = jsonDecode(jsonString) as Map<String, dynamic>;
      final comidas = (root['comidas'] as List? ?? const [])
          .map((e) => Food.fromJson(e as Map<String, dynamic>))
          .toList();

      final week = Week(imported: true, embeddedFoods: comidas);

      final planJson = root['plan'] as Map<String, dynamic>?;
      if (planJson != null) {
        // Formato nuevo multi-toma.
        for (final entry in planJson.entries) {
          final slot = mealSlotFromId(entry.key);
          if (slot == null) continue;
          final dayMap = entry.value as Map<String, dynamic>?;
          if (dayMap == null) continue;
          for (var i = 0; i < 7; i++) {
            final v = dayMap[kDays[i]];
            if (v is String) week.setMeal(slot, i, v);
          }
        }
      } else {
        // Formato antiguo: 'planificador' con almuerzo y cena.
        final planificador =
            root['planificador'] as Map<String, dynamic>? ?? const {};
        for (var i = 0; i < 7; i++) {
          final day = kDays[i];
          final lunch = planificador[day];
          final dinner = planificador['${day}Cena'];
          if (lunch is String) week.setMeal(MealSlot.lunch, i, lunch);
          if (dinner is String) week.setMeal(MealSlot.dinner, i, dinner);
        }
      }

      _weeks.add(week);
      _activeWeek = _weeks.length - 1;
      _save();
      notifyListeners();
      return null;
    } catch (e) {
      return t.importError(e);
    }
  }
}
