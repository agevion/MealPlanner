import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

/// Copia de seguridad completa de la app: catálogo, semanas, despensa,
/// registro diario y ajustes en un solo archivo JSON.
///
/// Antes solo se podía exportar la semana activa: si perdías el móvil, perdías
/// el catálogo entero. Esto vuelca todas las claves que usa la app.
class BackupService {
  /// Claves que forman el estado de la app. Si algún día se añade otra, hay que
  /// apuntarla aquí para que entre en la copia.
  static const List<String> keys = [
    'mealplanner_data_v1', // catálogo + semanas
    'pantry_v1', // despensa
    'pantry_deleted_presets_v1',
    'diary_v1', // registro diario
    'diary_extras_v1', // agua, peso, notas
    'gym_mode_enabled',
    'gym_goal',
    'gym_weight',
    'gym_height',
    'gym_age',
    'gym_sex',
    'gym_activity',
    'gym_custom_kcal',
    'gym_custom_protein',
    'gym_meal_slots',
    'settings_theme_id',
    'settings_theme_mode',
    'settings_amoled',
    'settings_color_intensity',
    'settings_start_tab',
  ];

  /// La clave de la IA NO se incluye a propósito: es un secreto personal y no
  /// tiene por qué viajar en un archivo que puedes mandar por WhatsApp.
  static const String excludedKey = 'ai_gemini_api_key';

  static const int formatVersion = 1;

  /// Genera el JSON de la copia. Guarda el tipo de cada valor para poder
  /// restaurarlo tal cual (bool, int, double, String o lista de String).
  static Future<String> export() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};

    for (final key in keys) {
      final value = prefs.get(key);
      if (value == null) continue;
      data[key] = {
        'type': switch (value) {
          bool _ => 'bool',
          int _ => 'int',
          double _ => 'double',
          List<String> _ => 'stringList',
          _ => 'string',
        },
        'value': value is List<String> ? value : value.toString(),
      };
    }

    return const JsonEncoder.withIndent('  ').convert({
      'app': 'mealplanner_flutter',
      'backupVersion': formatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  /// Restaura una copia. Devuelve un mensaje de error o null si fue bien.
  /// Machaca los datos actuales: quien llama debe confirmarlo antes.
  static Future<String?> import(
    String jsonString, {
    AppStrings t = const AppStrings(),
  }) async {
    Map<String, dynamic> root;
    try {
      root = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return t.backupInvalidFile;
    }

    if (root['app'] != 'mealplanner_flutter') {
      return t.backupInvalidFile;
    }
    final data = root['data'];
    if (data is! Map) return t.backupCorrupt;

    final prefs = await SharedPreferences.getInstance();
    var restored = 0;
    for (final entry in data.entries) {
      final key = entry.key as String;
      if (!keys.contains(key)) continue; // ignoramos claves desconocidas
      final item = entry.value;
      if (item is! Map) continue;
      final type = item['type'] as String?;
      final value = item['value'];
      try {
        switch (type) {
          case 'bool':
            await prefs.setBool(key, value.toString() == 'true');
          case 'int':
            final v = int.tryParse(value.toString());
            if (v != null) await prefs.setInt(key, v);
          case 'double':
            final v = double.tryParse(value.toString());
            if (v != null) await prefs.setDouble(key, v);
          case 'stringList':
            await prefs.setStringList(
              key,
              (value as List).map((e) => e.toString()).toList(),
            );
          default:
            await prefs.setString(key, value.toString());
        }
        restored++;
      } catch (_) {
        // Una clave rota no debe tumbar toda la restauración.
      }
    }

    if (restored == 0) return t.backupNothingRestored;
    return null;
  }
}
