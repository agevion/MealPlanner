import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_strings.dart';
import '../models/ai_estimate.dart';

/// Excepción con mensaje ya listo para enseñar al usuario, en su idioma.
class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);
  @override
  String toString() => message;
}

/// Cliente mínimo de la API de Google Gemini (Generative Language API).
///
/// Cada usuario pone su propia clave (gratis en aistudio.google.com), así no se
/// gasta ninguna cuota compartida. A partir de una descripción escrita y/o una
/// foto del plato, devuelve una [AiEstimate] con kcal y proteína aproximadas.
class GeminiService {
  /// Estima las macros de una comida. [description] es texto libre del usuario
  /// ("plato de macarrones con atún, ración normal"). [imageBytes], si se pasa,
  /// es una foto del plato (JPEG/PNG) que la IA analiza junto al texto.
  static Future<AiEstimate> estimate({
    required String apiKey,
    required String model,
    String description = '',
    List<int>? imageBytes,
    String imageMimeType = 'image/jpeg',
    http.Client? client,
    AppStrings t = const AppStrings(),
  }) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiException(t.geminiMissingKey);
    }
    if (description.trim().isEmpty && imageBytes == null) {
      throw GeminiException(t.geminiNeedTextOrPhoto);
    }

    final http.Client c = client ?? http.Client();
    try {
      final parts = <Map<String, dynamic>>[
        {'text': _prompt(description, t)},
      ];
      if (imageBytes != null) {
        parts.add({
          'inline_data': {
            'mime_type': imageMimeType,
            'data': base64Encode(imageBytes),
          },
        });
      }

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${model.trim()}:generateContent',
      );
      final res = await c.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey.trim(),
        },
        body: jsonEncode({
          'contents': [
            {'parts': parts},
          ],
          'generationConfig': {
            'temperature': 0.2,
            'responseMimeType': 'application/json',
          },
        }),
      );

      _checkStatus(res.statusCode, t);
      return _parse(res.body, t);
    } on GeminiException {
      rethrow;
    } catch (_) {
      throw GeminiException(t.geminiNoConnection);
    } finally {
      if (client == null) c.close();
    }
  }

  /// Pide al modelo que invente platos nuevos con las condiciones que le dé el
  /// usuario ("cenas de menos de 400 kcal con lo que tengo en la despensa").
  /// Devuelve platos listos para añadir al catálogo, con macros aproximadas.
  static Future<List<AiSuggestion>> suggestMeals({
    required String apiKey,
    required String model,
    required String request,
    List<String> availableIngredients = const [],
    int count = 5,
    http.Client? client,
    AppStrings t = const AppStrings(),
  }) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiException(t.geminiMissingKey);
    }

    final http.Client c = client ?? http.Client();
    try {
      final res = await c.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          '${model.trim()}:generateContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey.trim(),
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': _suggestPrompt(
                    request,
                    availableIngredients,
                    count,
                    t,
                  ),
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.9, // aquí sí queremos variedad
            'responseMimeType': 'application/json',
          },
        }),
      );

      _checkStatus(res.statusCode, t);
      return _parseSuggestions(res.body, t);
    } on GeminiException {
      rethrow;
    } catch (_) {
      throw GeminiException(t.geminiNoConnection);
    } finally {
      if (client == null) c.close();
    }
  }

  /// La instrucción va en inglés (es lo que mejor sigue el modelo), pero se le
  /// pide explícitamente que escriba los platos en el idioma del usuario: si
  /// no, alguien con la app en alemán recibiría recetas en español.
  static String _suggestPrompt(
    String request,
    List<String> ingredients,
    int count,
    AppStrings t,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        'You are a home cook. Suggest $count simple, realistic '
        'everyday dishes.',
      )
      ..writeln('User request: "${request.trim()}"');
    if (ingredients.isNotEmpty) {
      buffer
        ..writeln('Available ingredients: ${ingredients.take(40).join(', ')}.')
        ..writeln('Prefer using those ingredients.');
    }
    buffer
      ..writeln('Write every piece of text in ${t.aiLanguageName}.')
      ..writeln('Reply ONLY with JSON in exactly this shape:')
      ..writeln(
        '{"platos": [{"nombre": string, "ingredientes": string, '
        '"kcal": number, "proteina_g": number, "minutos": number, '
        '"etiquetas": [string], "receta": string}]}',
      )
      ..writeln(
        'Keep those JSON keys exactly as written even though the '
        'values are in ${t.aiLanguageName}. "ingredientes" is a '
        'comma-separated list, "receta" is 2-3 sentences with the steps. '
        'Macros are per serving and approximate. No text outside the JSON.',
      );
    return buffer.toString();
  }

  static List<AiSuggestion> _parseSuggestions(String body, AppStrings t) {
    final text = _extractText(body, t);
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw GeminiException(t.geminiSuggestionsParseFail);
    }
    try {
      final map =
          jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
      final list = (map['platos'] ?? map['meals']) as List?;
      if (list == null || list.isEmpty) {
        throw GeminiException(t.geminiNoSuggestions);
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(AiSuggestion.fromJson)
          .where((s) => s.name.isNotEmpty)
          .toList();
    } on GeminiException {
      rethrow;
    } catch (_) {
      throw GeminiException(t.geminiSuggestionsParseFail);
    }
  }

  /// Convierte los códigos de error HTTP en mensajes que el usuario entienda.
  static void _checkStatus(int code, AppStrings t) {
    if (code == 200) return;
    throw GeminiException(switch (code) {
      400 => t.geminiBadKey,
      403 => t.geminiForbidden,
      404 => t.geminiModelNotFound,
      429 => t.geminiRateLimit,
      _ => t.geminiError(code),
    });
  }

  /// Saca el texto de la respuesta de Gemini.
  static String _extractText(String body, AppStrings t) {
    Map<String, dynamic> root;
    try {
      root = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiException(t.geminiUnreadable);
    }
    final candidates = root['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw GeminiException(t.geminiNothingUseful);
    }
    final content = (candidates.first as Map?)?['content'];
    final parts = (content as Map?)?['parts'];
    final text = (parts is List && parts.isNotEmpty)
        ? ((parts.first as Map?)?['text'] as String?)
        : null;
    if (text == null || text.trim().isEmpty) {
      throw GeminiException(t.geminiNothingUseful);
    }
    return text;
  }

  /// Instrucción que se le da al modelo. Le pedimos JSON limpio y estimación
  /// aproximada por ración (cómodo, no exacto).
  static String _prompt(String description, AppStrings t) {
    final buffer = StringBuffer()
      ..writeln(
        'You are a nutrition assistant. Estimate the calories (kcal) and the '
        'grams of protein of the described meal and/or of the photo.',
      )
      ..writeln(
        'Give a reasonable, approximate estimate for ONE normal serving. It '
        'does not have to be exact.',
      )
      ..writeln('Reply ONLY with a JSON object with these exact keys:')
      ..writeln(
        '{"nombre": string, "kcal": number, "proteina_g": number, "nota": string}',
      )
      ..writeln(
        '"nombre" is a short name for the dish and "nota" a brief comment '
        '(max 8 words); write both in ${t.aiLanguageName}, but keep the JSON '
        'keys exactly as written. No text outside the JSON.',
      );
    if (description.trim().isNotEmpty) {
      buffer.writeln('User description: "${description.trim()}"');
    } else {
      buffer.writeln('The user wrote no description: rely on the photo.');
    }
    return buffer.toString();
  }

  /// Extrae el JSON de la respuesta de Gemini y lo convierte en [AiEstimate].
  static AiEstimate _parse(String body, AppStrings t) {
    Map<String, dynamic> root;
    try {
      root = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiException(t.geminiUnreadable);
    }

    final candidates = root['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw GeminiException(t.geminiNoEstimate);
    }
    final content = (candidates.first as Map?)?['content'];
    final parts = (content as Map?)?['parts'];
    final text = (parts is List && parts.isNotEmpty)
        ? ((parts.first as Map?)?['text'] as String?)
        : null;
    if (text == null || text.trim().isEmpty) {
      throw GeminiException(t.geminiNothingUseful);
    }

    // El modelo debería devolver JSON puro, pero por si acaso recortamos a las
    // llaves exteriores.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw GeminiException(t.geminiParseFail);
    }
    try {
      final map =
          jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
      final estimate = AiEstimate.fromJson(map);
      if (estimate.kcal <= 0 && estimate.protein <= 0) {
        throw GeminiException(t.geminiCouldNotEstimate);
      }
      return estimate;
    } on GeminiException {
      rethrow;
    } catch (_) {
      throw GeminiException(t.geminiParseFail);
    }
  }
}
