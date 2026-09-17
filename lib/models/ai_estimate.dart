import 'food.dart';
import 'meal_slot.dart';

/// Un plato propuesto por la IA, listo para añadir al catálogo tras revisarlo.
class AiSuggestion {
  final String name;
  final String ingredients;
  final int kcal;
  final int protein;
  final int? prepMinutes;
  final Set<String> tags;
  final String recipe;

  const AiSuggestion({
    required this.name,
    required this.ingredients,
    this.kcal = 0,
    this.protein = 0,
    this.prepMinutes,
    this.tags = const {},
    this.recipe = '',
  });

  /// Lo pasa a un [Food] del catálogo. Las tomas quedan abiertas (vale para
  /// todas) para que el usuario las ajuste si quiere.
  Food toFood({Set<MealSlot>? slots}) => Food(
    name: name,
    ingredients: ingredients,
    slots: slots ?? const {MealSlot.lunch, MealSlot.dinner},
    kcal: kcal > 0 ? kcal : null,
    protein: protein > 0 ? protein : null,
    tags: tags,
    prepMinutes: prepMinutes,
    notes: recipe,
  );

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    String str(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v is List && v.isNotEmpty) return v.join(', ');
      }
      return '';
    }

    int? num_(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is num) return v.round();
        if (v is String) {
          final parsed = num.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (parsed != null) return parsed.round();
        }
      }
      return null;
    }

    return AiSuggestion(
      name: str(['nombre', 'name']),
      ingredients: str(['ingredientes', 'ingredients']),
      kcal: num_(['kcal', 'calorias', 'calories']) ?? 0,
      protein: num_(['proteina_g', 'proteina', 'protein']) ?? 0,
      prepMinutes: num_(['minutos', 'minutes', 'prepMinutes']),
      tags:
          ((json['etiquetas'] ?? json['tags']) as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toSet() ??
          const <String>{},
      recipe: str(['receta', 'recipe', 'pasos']),
    );
  }
}

/// Resultado de una estimación de macros hecha por la IA (Gemini). Son cifras
/// aproximadas por ración pensadas para el conteo cómodo, no valores exactos.
class AiEstimate {
  final String name;
  final int kcal;
  final int protein;

  /// Comentario corto de la IA (p. ej. "ración media, estimación aproximada").
  final String note;

  const AiEstimate({
    required this.name,
    required this.kcal,
    required this.protein,
    this.note = '',
  });

  /// Parseo tolerante del JSON que devuelve el modelo. Acepta claves en español
  /// e inglés por si el modelo se desvía del formato pedido.
  factory AiEstimate.fromJson(Map<String, dynamic> json) {
    num? pickNum(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is num) return v;
        if (v is String) {
          final parsed = num.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    String pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    return AiEstimate(
      name: pickStr(['nombre', 'name', 'plato', 'comida']),
      kcal: (pickNum(['kcal', 'calorias', 'calorias_kcal', 'calories']) ?? 0)
          .round(),
      protein:
          (pickNum(['proteina_g', 'proteina', 'protein', 'protein_g']) ?? 0)
              .round(),
      note: pickStr(['nota', 'note', 'comentario']),
    );
  }
}
