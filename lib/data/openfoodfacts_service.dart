import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_strings.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';

/// Resultado de escanear un producto: el plato listo para prerrellenar el
/// formulario, una nota de en qué base vienen las macros y los valores crudos
/// (por 100 g y por ración) para que el selector de porción pueda calcular
/// cuánto se va a usar realmente.
class ScannedProduct {
  final Food food;

  /// Sobre qué están calculadas las macros: 'serving', 'per100' o 'none'.
  /// Es una clave estable; el rótulo traducido sale de `AppStrings.productBasis`.
  final String basis;
  final String barcode;

  /// Macros por 100 g (si el producto las trae). Permiten elegir gramos.
  final double? kcalPer100;
  final double? proteinPer100;

  /// Macros por ración/porción declarada por el fabricante (si las trae).
  final double? kcalServing;
  final double? proteinServing;

  /// Tamaño de ración declarado, p. ej. "30 g" (texto tal cual de la API).
  final String servingSize;

  const ScannedProduct({
    required this.food,
    required this.basis,
    this.barcode = '',
    this.kcalPer100,
    this.proteinPer100,
    this.kcalServing,
    this.proteinServing,
    this.servingSize = '',
  });

  /// True si podemos calcular las macros de una cantidad en gramos.
  bool get hasPer100 => kcalPer100 != null || proteinPer100 != null;
}

/// Cliente mínimo de OpenFoodFacts: a partir de un código de barras devuelve un
/// [ScannedProduct] con nombre y macros (kcal + proteína). Útil para productos
/// envasados: preentrenos, bebidas energéticas, comidas preparadas…
class OpenFoodFactsService {
  /// Llama a la API de OpenFoodFacts y devuelve el producto, o null si no se
  /// encuentra o hay un error.
  static Future<ScannedProduct?> fetchByBarcode(
    String barcode, {
    http.Client? client,
    AppStrings t = const AppStrings(),
  }) async {
    final http.Client c = client ?? http.Client();
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
        // OpenFoodFacts guarda el nombre traducido en product_name_<idioma>:
        // pedimos el del usuario y dejamos el genérico como respaldo.
        '?fields=product_name,product_name_${t.languageCode},brands,'
        'nutriments,serving_size',
      );
      final res = await c.get(
        uri,
        headers: const {'User-Agent': 'MealPlannerFlutter/1.0 (proyecto TFG)'},
      );
      if (res.statusCode != 200) return null;
      final root = jsonDecode(res.body) as Map<String, dynamic>;
      return parseProduct(root, barcode, t: t);
    } catch (_) {
      return null;
    } finally {
      if (client == null) c.close();
    }
  }

  /// Parseo puro de la respuesta de la API (sin red), para poder testearlo.
  static ScannedProduct? parseProduct(
    Map<String, dynamic> root,
    String barcode, {
    AppStrings t = const AppStrings(),
  }) {
    if ((root['status'] as num?)?.toInt() != 1) return null;
    final productRaw = root['product'];
    if (productRaw is! Map) return null;
    final product = productRaw;

    String pick(String key) => (product[key] as String?)?.trim() ?? '';
    final name = [
      pick('product_name_${t.languageCode}'),
      pick('product_name'),
      pick('brands'),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => 'Producto $barcode');

    final nutrRaw = product['nutriments'];
    final Map<dynamic, dynamic> nutr = nutrRaw is Map ? nutrRaw : const {};
    num? n(String key) => nutr[key] as num?;

    final kcalServing = n('energy-kcal_serving');
    final proteinServing = n('proteins_serving');
    final kcal100 = n('energy-kcal_100g');
    final protein100 = n('proteins_100g');
    final servingSize = pick('serving_size');

    int? kcal;
    int? protein;
    String basis;

    if (kcalServing != null || proteinServing != null) {
      kcal = kcalServing?.round();
      protein = proteinServing?.round();
      basis = 'serving';
    } else if (kcal100 != null || protein100 != null) {
      kcal = kcal100?.round();
      protein = protein100?.round();
      basis = 'per100';
    } else {
      basis = 'none';
    }

    final food = Food(
      name: name,
      ingredients: name, // editable; sirve para la lista de la compra
      slots: const {MealSlot.snack},
      kcal: kcal,
      protein: protein,
    );
    return ScannedProduct(
      food: food,
      basis: basis,
      barcode: barcode,
      kcalPer100: kcal100?.toDouble(),
      proteinPer100: protein100?.toDouble(),
      kcalServing: kcalServing?.toDouble(),
      proteinServing: proteinServing?.toDouble(),
      servingSize: servingSize,
    );
  }
}
