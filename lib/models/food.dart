import 'meal_slot.dart';

/// Un ingrediente con macros propias dentro de un plato compuesto (p. ej. el pan
/// y la carne de una hamburguesa). [kcal]/[protein] son por unidad; [quantity]
/// es cuántas unidades se usan (admite decimales: 1.5, 0.5…).
class FoodComponent {
  final String name;
  final int kcal;
  final int protein;
  final double quantity;

  const FoodComponent({
    required this.name,
    this.kcal = 0,
    this.protein = 0,
    this.quantity = 1,
  });

  int get totalKcal => (kcal * quantity).round();
  int get totalProtein => (protein * quantity).round();

  FoodComponent copyWith({
    String? name,
    int? kcal,
    int? protein,
    double? quantity,
  }) {
    return FoodComponent(
      name: name ?? this.name,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'kcal': kcal,
        'protein': protein,
        'quantity': quantity,
      };

  factory FoodComponent.fromJson(Map<String, dynamic> json) => FoodComponent(
        name: json['name'] as String? ?? '',
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      );
}

/// Un plato del catálogo del usuario.
///
/// `ingredients` se guarda como texto separado por comas, igual que en la
/// versión Android original. `slots` indica en qué tomas encaja. `kcal` y
/// `protein` son opcionales (Modo Gym). `components`, si no está vacío, es la
/// lista de ingredientes con macros con la que se han calculado `kcal`/`protein`
/// (plato compuesto, p. ej. hamburguesa = pan + carne).
class Food {
  final String name;
  final String ingredients;
  final Set<MealSlot> slots;
  final int? kcal; // por ración
  final int? protein; // gramos por ración
  final List<FoodComponent> components;

  /// Etiquetas libres para clasificar y equilibrar la semana: "pasta", "carne",
  /// "pescado", "veggie"… Ver [kFoodTags].
  final Set<String> tags;

  /// Minutos que lleva prepararlo. Sirve para los "días con prisa".
  final int? prepMinutes;

  /// Cuántas raciones salen al cocinarlo una vez. Si es >1, el planificador
  /// puede aprovechar las sobras para la toma siguiente.
  final int servingsMade;

  /// Valoración de 0 a 5. Los platos mejor valorados salen más al randomizar.
  final int rating;

  final bool favorite;

  /// Receta, pasos, enlace… texto libre.
  final String notes;

  /// Ruta local de una foto del plato (la que eligió el usuario).
  final String photoPath;

  /// Coste aproximado por ración, para el presupuesto de la semana.
  final double? costPerServing;

  /// Si está puesto, el randomizador no lo elige hasta esa fecha
  /// ("no me apetece esta semana").
  final DateTime? snoozedUntil;

  const Food({
    required this.name,
    required this.ingredients,
    this.slots = const {MealSlot.lunch, MealSlot.dinner},
    this.kcal,
    this.protein,
    this.components = const [],
    this.tags = const {},
    this.prepMinutes,
    this.servingsMade = 1,
    this.rating = 0,
    this.favorite = false,
    this.notes = '',
    this.photoPath = '',
    this.costPerServing,
    this.snoozedUntil,
  });

  /// True si ahora mismo está "descansando" y no debe salir al azar.
  bool get isSnoozed {
    final until = snoozedUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  /// Se cocina una vez y da para más de una toma.
  bool get hasLeftovers => servingsMade > 1;

  /// Se hace en 15 minutos o menos.
  bool get isQuick => prepMinutes != null && prepMinutes! <= 15;

  bool fitsSlot(MealSlot slot) => slots.contains(slot);

  bool get hasMacros => kcal != null && protein != null;

  bool get isComposed => components.isNotEmpty;

  static int sumKcal(List<FoodComponent> c) =>
      c.fold(0, (a, b) => a + b.totalKcal);
  static int sumProtein(List<FoodComponent> c) =>
      c.fold(0, (a, b) => a + b.totalProtein);

  /// Proporción de calorías que provienen de la proteína (4 kcal por gramo).
  double? get proteinShareOfKcal {
    if (kcal == null || protein == null || kcal! <= 0) return null;
    return (protein! * 4) / kcal!;
  }

  /// "Alto en proteína": al menos un 30 % de las calorías vienen de la proteína.
  bool get isHighProtein {
    final share = proteinShareOfKcal;
    return share != null && share >= 0.30;
  }

  Food copyWith({
    String? name,
    String? ingredients,
    Set<MealSlot>? slots,
    int? kcal,
    int? protein,
    List<FoodComponent>? components,
    Set<String>? tags,
    int? prepMinutes,
    int? servingsMade,
    int? rating,
    bool? favorite,
    String? notes,
    String? photoPath,
    double? costPerServing,
    DateTime? snoozedUntil,
    bool clearSnooze = false,
  }) {
    return Food(
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      slots: slots ?? this.slots,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      components: components ?? this.components,
      tags: tags ?? this.tags,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      servingsMade: servingsMade ?? this.servingsMade,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      costPerServing: costPerServing ?? this.costPerServing,
      snoozedUntil: clearSnooze ? null : (snoozedUntil ?? this.snoozedUntil),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'ingredients': ingredients,
      'slots': slots.map((s) => s.id).toList(),
      // Compatibilidad con la app Android original (almuerzo/cena).
      'isLunch': slots.contains(MealSlot.lunch),
      'isDinner': slots.contains(MealSlot.dinner),
    };
    if (kcal != null) map['kcal'] = kcal;
    if (protein != null) map['protein'] = protein;
    if (components.isNotEmpty) {
      map['components'] = components.map((c) => c.toJson()).toList();
    }
    // Los campos nuevos solo se escriben si tienen valor: así el JSON de quien
    // no los usa sigue siendo idéntico al de antes.
    if (tags.isNotEmpty) map['tags'] = tags.toList();
    if (prepMinutes != null) map['prepMinutes'] = prepMinutes;
    if (servingsMade != 1) map['servingsMade'] = servingsMade;
    if (rating > 0) map['rating'] = rating;
    if (favorite) map['favorite'] = true;
    if (notes.isNotEmpty) map['notes'] = notes;
    if (photoPath.isNotEmpty) map['photoPath'] = photoPath;
    if (costPerServing != null) map['costPerServing'] = costPerServing;
    if (snoozedUntil != null) {
      map['snoozedUntil'] = snoozedUntil!.toIso8601String().substring(0, 10);
    }
    return map;
  }

  /// Acepta el formato nuevo (`slots`), el intermedio Flutter
  /// (`isLunch`/`isDinner`) y el de la app Android original
  /// (`esAlmuerzo`/`esCena`). Macros y componentes son opcionales.
  factory Food.fromJson(Map<String, dynamic> json) {
    Set<MealSlot> slots;

    final rawSlots = json['slots'] as List?;
    if (rawSlots != null) {
      slots = rawSlots
          .map((e) => mealSlotFromId(e as String))
          .whereType<MealSlot>()
          .toSet();
    } else {
      final isLunch =
          json['isLunch'] as bool? ?? json['esAlmuerzo'] as bool? ?? true;
      final isDinner =
          json['isDinner'] as bool? ?? json['esCena'] as bool? ?? true;
      slots = {
        if (isLunch) MealSlot.lunch,
        if (isDinner) MealSlot.dinner,
      };
    }
    if (slots.isEmpty) slots = {MealSlot.lunch, MealSlot.dinner};

    final rawComponents = json['components'] as List?;
    final components = rawComponents
            ?.map((e) => FoodComponent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <FoodComponent>[];

    return Food(
      name: json['name'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      slots: slots,
      kcal: (json['kcal'] as num?)?.toInt(),
      protein: (json['protein'] as num?)?.toInt(),
      components: components,
      tags: ((json['tags'] as List?)?.map((e) => e.toString()).toSet()) ??
          const <String>{},
      prepMinutes: (json['prepMinutes'] as num?)?.toInt(),
      servingsMade: (json['servingsMade'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      photoPath: json['photoPath'] as String? ?? '',
      costPerServing: (json['costPerServing'] as num?)?.toDouble(),
      snoozedUntil: DateTime.tryParse((json['snoozedUntil'] as String?) ?? ''),
    );
  }
}

/// Etiquetas sugeridas al clasificar un plato. El usuario puede escribir otras;
/// estas son solo las que se ofrecen de un toque.
const List<String> kFoodTags = [
  'Pasta',
  'Arroz',
  'Carne',
  'Pescado',
  'Verduras',
  'Legumbres',
  'Huevos',
  'Sopa',
  'Ensalada',
  'Rápido',
  'De aprovechar',
  'Capricho',
];
