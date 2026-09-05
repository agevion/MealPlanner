/// Un ingrediente de la lista de compra junto con los platos que lo usan.
/// [manual] indica que lo añadió el usuario a mano (no viene de ningún plato).
/// [category] es el pasillo del súper (viene de la despensa; "Otros" si no se
/// reconoce) y [quantityLabel] la cantidad estimada ("6 huevos", "×3").
class IngredientGroup {
  final String name;
  final List<String> dishes;
  final bool manual;
  final String category;
  final String quantityLabel;

  const IngredientGroup(
    this.name,
    this.dishes, {
    this.manual = false,
    this.category = 'Otros',
    this.quantityLabel = '',
  });

  /// Ítem recurrente fijo (café, papel de cocina…): son manuales y no vienen
  /// de ningún plato.
  bool get isRecurring => manual && dishes.isEmpty;
}
