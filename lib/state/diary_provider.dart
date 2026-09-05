import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../models/logged_item.dart';

/// Clave de día (yyyy-mm-dd) para indexar el registro.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Registro diario de lo que el usuario ha comido de verdad, más los extras del
/// día: vasos de agua, peso corporal y una nota. De aquí salen la racha, las
/// estadísticas y la gamificación. Persiste en SharedPreferences.
class DiaryProvider extends ChangeNotifier {
  static const _kKey = 'diary_v1';
  static const _kExtrasKey = 'diary_extras_v1';

  SharedPreferences? _prefs;
  final Map<String, List<LoggedItem>> _byDate = {};

  /// Extras por fecha: agua (vasos), peso (kg) y nota libre.
  final Map<String, int> _water = {};
  final Map<String, double> _weight = {};
  final Map<String, String> _notes = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _byDate.clear();
        data.forEach((key, value) {
          _byDate[key] = (value as List)
              .map((e) => LoggedItem.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {
        // Datos corruptos: empezamos vacío sin romper la app.
      }
    }

    final rawExtras = _prefs!.getString(_kExtrasKey);
    if (rawExtras != null && rawExtras.isNotEmpty) {
      try {
        final data = jsonDecode(rawExtras) as Map<String, dynamic>;
        data.forEach((key, value) {
          final m = value as Map<String, dynamic>;
          final w = (m['water'] as num?)?.toInt();
          final kg = (m['weight'] as num?)?.toDouble();
          final note = m['note'] as String?;
          if (w != null && w > 0) _water[key] = w;
          if (kg != null && kg > 0) _weight[key] = kg;
          if (note != null && note.isNotEmpty) _notes[key] = note;
        });
      } catch (_) {
        // Igual que arriba: los extras son accesorios, no rompen nada.
      }
    }
    notifyListeners();
  }

  void _save() {
    final data = {
      for (final e in _byDate.entries)
        e.key: e.value.map((i) => i.toJson()).toList(),
    };
    _prefs?.setString(_kKey, jsonEncode(data));
  }

  void _saveExtras() {
    final keys = {..._water.keys, ..._weight.keys, ..._notes.keys};
    final data = {
      for (final k in keys)
        k: {
          if (_water[k] != null) 'water': _water[k],
          if (_weight[k] != null) 'weight': _weight[k],
          if (_notes[k] != null) 'note': _notes[k],
        },
    };
    _prefs?.setString(_kExtrasKey, jsonEncode(data));
  }

  // ---------------------- CONSULTAS ----------------------

  List<LoggedItem> entriesFor(DateTime date) =>
      List.unmodifiable(_byDate[dateKey(date)] ?? const <LoggedItem>[]);

  int kcalFor(DateTime date) =>
      entriesFor(date).fold(0, (a, b) => a + b.totalKcal);

  int proteinFor(DateTime date) =>
      entriesFor(date).fold(0, (a, b) => a + b.totalProtein);

  bool hasEntries(DateTime date) => (_byDate[dateKey(date)] ?? const []).isNotEmpty;

  /// Todas las fechas con registro, de la más reciente a la más antigua.
  List<DateTime> get loggedDates {
    final dates = _byDate.keys
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return dates;
  }

  int waterFor(DateTime date) => _water[dateKey(date)] ?? 0;
  double? weightFor(DateTime date) => _weight[dateKey(date)];
  String noteFor(DateTime date) => _notes[dateKey(date)] ?? '';

  /// Historial de pesos ordenado de más antiguo a más reciente.
  List<({DateTime date, double kg})> get weightHistory {
    final list = <({DateTime date, double kg})>[];
    _weight.forEach((key, value) {
      final d = DateTime.tryParse(key);
      if (d != null) list.add((date: d, kg: value));
    });
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Media móvil de 7 días del peso: suaviza el ruido diario de la báscula.
  List<({DateTime date, double kg})> weightTrend() {
    final history = weightHistory;
    final result = <({DateTime date, double kg})>[];
    for (var i = 0; i < history.length; i++) {
      final window = history.sublist((i - 6).clamp(0, i), i + 1);
      final avg = window.fold<double>(0, (a, b) => a + b.kg) / window.length;
      result.add((date: history[i].date, kg: avg));
    }
    return result;
  }

  // ---------------------- ESCRITURA ----------------------

  void addEntry(DateTime date, LoggedItem item) {
    _byDate.putIfAbsent(dateKey(date), () => []).add(item);
    _save();
    notifyListeners();
  }

  void addEntries(DateTime date, Iterable<LoggedItem> items) {
    if (items.isEmpty) return;
    _byDate.putIfAbsent(dateKey(date), () => []).addAll(items);
    _save();
    notifyListeners();
  }

  void replaceEntryAt(DateTime date, int index, LoggedItem item) {
    final list = _byDate[dateKey(date)];
    if (list == null || index < 0 || index >= list.length) return;
    list[index] = item;
    _save();
    notifyListeners();
  }

  void removeEntryAt(DateTime date, int index) {
    final list = _byDate[dateKey(date)];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    if (list.isEmpty) _byDate.remove(dateKey(date));
    _save();
    notifyListeners();
  }

  /// Vuelve a insertar una entrada en su sitio. Es lo que usa "Deshacer".
  void insertEntryAt(DateTime date, int index, LoggedItem item) {
    final list = _byDate.putIfAbsent(dateKey(date), () => []);
    list.insert(index.clamp(0, list.length), item);
    _save();
    notifyListeners();
  }

  /// Copia todo lo registrado de [from] a [to]. Devuelve cuántas entradas copió.
  int copyDay(DateTime from, DateTime to) {
    final source = _byDate[dateKey(from)];
    if (source == null || source.isEmpty) return 0;
    _byDate.putIfAbsent(dateKey(to), () => []).addAll(source);
    _save();
    notifyListeners();
    return source.length;
  }

  void clearDay(DateTime date) {
    if (_byDate.remove(dateKey(date)) == null) return;
    _save();
    notifyListeners();
  }

  void setWater(DateTime date, int glasses) {
    final key = dateKey(date);
    if (glasses <= 0) {
      _water.remove(key);
    } else {
      _water[key] = glasses;
    }
    _saveExtras();
    notifyListeners();
  }

  void setWeight(DateTime date, double? kg) {
    final key = dateKey(date);
    if (kg == null || kg <= 0) {
      _weight.remove(key);
    } else {
      _weight[key] = kg;
    }
    _saveExtras();
    notifyListeners();
  }

  void setNote(DateTime date, String note) {
    final key = dateKey(date);
    if (note.trim().isEmpty) {
      _notes.remove(key);
    } else {
      _notes[key] = note.trim();
    }
    _saveExtras();
    notifyListeners();
  }

  // ---------------------- RACHA Y ESTADÍSTICAS ----------------------

  /// Días consecutivos (hasta hoy) cumpliendo el objetivo de proteína. Si hoy
  /// todavía no lo has cumplido no se rompe la racha: se cuenta desde ayer,
  /// porque el día no ha terminado.
  int proteinStreak(int? targetProtein) {
    if (targetProtein == null || targetProtein <= 0) return 0;
    var streak = 0;
    var day = DateTime.now();
    if (proteinFor(day) < targetProtein) {
      day = day.subtract(const Duration(days: 1));
    }
    while (proteinFor(day) >= targetProtein) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Resumen de los últimos [days] días con registro.
  ({int days, int avgKcal, int avgProtein, int metProtein}) summary(
    int days,
    int? targetProtein,
  ) {
    var counted = 0;
    var kcal = 0;
    var protein = 0;
    var met = 0;
    for (var i = 0; i < days; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      if (!hasEntries(d)) continue;
      counted++;
      kcal += kcalFor(d);
      final p = proteinFor(d);
      protein += p;
      if (targetProtein != null && targetProtein > 0 && p >= targetProtein) {
        met++;
      }
    }
    if (counted == 0) {
      return (days: 0, avgKcal: 0, avgProtein: 0, metProtein: 0);
    }
    return (
      days: counted,
      avgKcal: (kcal / counted).round(),
      avgProtein: (protein / counted).round(),
      metProtein: met,
    );
  }

  /// Cambio medio de peso por semana, calculado sobre la tendencia suavizada.
  /// Devuelve null si no hay al menos dos semanas de datos.
  double? weightChangePerWeek() {
    final trend = weightTrend();
    if (trend.length < 2) return null;
    final first = trend.first;
    final last = trend.last;
    final days = last.date.difference(first.date).inDays;
    if (days < 14) return null; // menos de dos semanas no dice nada
    return (last.kg - first.kg) / (days / 7);
  }

  /// Exporta el registro a CSV (fecha, toma, plato, raciones, kcal, proteína).
  ///
  /// Las cabeceras y el nombre de la toma van en el idioma de la app: el
  /// archivo lo abre el usuario, no lo lee la app.
  String toCsv({AppStrings t = const AppStrings()}) {
    final buffer = StringBuffer('date,meal,dish,servings,kcal,protein_g\n');
    final keys = _byDate.keys.toList()..sort();
    for (final key in keys) {
      for (final item in _byDate[key]!) {
        final name = item.name.replaceAll('"', "'");
        final slot = item.slot == null ? '' : t.mealSlot(item.slot!);
        buffer.writeln('$key,$slot,"$name",'
            '${item.servings},${item.totalKcal},${item.totalProtein}');
      }
    }
    return buffer.toString();
  }
}
