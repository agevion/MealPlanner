import '../models/pantry_ingredient.dart';

/// Categorías en el orden en que se muestran.
const List<String> kIngredientCategories = [
  'Proteínas',
  'Carbohidratos',
  'Legumbres',
  'Verduras',
  'Frutas',
  'Lácteos y huevos',
  'Grasas y frutos secos',
  'Otros',
];

// Las cosas que se acaban comprando siempre (café, papel de cocina…) viven en
// `AppStrings.recurringItemsList`: son texto que se enseña, y cada idioma trae
// su propia lista.

/// Semilla de la despensa: ingredientes comunes de una cocina española normal,
/// con su medida casera (1 filete, 1 loncha, 1 cucharada…), macros por unidad y
/// una repetibilidad por defecto (carne/pescado sin límite; embutidos, fritos y
/// dulces limitados). Todo es aproximado y editable por el usuario.
const List<PantryIngredient> kPresetIngredients = [
  // ----------------------------- PROTEÍNAS -----------------------------
  PantryIngredient(name: 'Pechuga de pollo', category: 'Proteínas', unit: 'filete', gramsPerUnit: 125, kcal: 155, protein: 29, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Muslo de pollo', category: 'Proteínas', unit: 'muslo', gramsPerUnit: 100, kcal: 180, protein: 19, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pavo (pechuga)', category: 'Proteínas', unit: 'filete', gramsPerUnit: 120, kcal: 130, protein: 28, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Ternera (filete)', category: 'Proteínas', unit: 'filete', gramsPerUnit: 120, kcal: 220, protein: 26, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Carne picada mixta', category: 'Proteínas', unit: 'ración', gramsPerUnit: 100, kcal: 240, protein: 18, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Cerdo (lomo)', category: 'Proteínas', unit: 'filete', gramsPerUnit: 120, kcal: 210, protein: 27, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Salmón', category: 'Proteínas', unit: 'lomo', gramsPerUnit: 130, kcal: 270, protein: 26, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Merluza', category: 'Proteínas', unit: 'filete', gramsPerUnit: 130, kcal: 120, protein: 24, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Atún en lata (al natural)', category: 'Proteínas', unit: 'lata', gramsPerUnit: 52, kcal: 60, protein: 14, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Atún en lata (en aceite)', category: 'Proteínas', unit: 'lata', gramsPerUnit: 52, kcal: 100, protein: 13, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Gambas / langostinos', category: 'Proteínas', unit: 'ración', gramsPerUnit: 100, kcal: 85, protein: 18, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Jamón serrano', category: 'Proteínas', unit: 'loncha', gramsPerUnit: 15, kcal: 40, protein: 5, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Jamón / pavo cocido', category: 'Proteínas', unit: 'loncha', gramsPerUnit: 20, kcal: 22, protein: 4, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Chorizo', category: 'Proteínas', unit: 'ración', gramsPerUnit: 30, kcal: 135, protein: 7, isPreset: true, repeat: Repeatability.limited),
  PantryIngredient(name: 'Tofu', category: 'Proteínas', unit: 'ración', gramsPerUnit: 100, kcal: 120, protein: 12, isPreset: true, repeat: Repeatability.free),

  // --------------------------- CARBOHIDRATOS ---------------------------
  PantryIngredient(name: 'Arroz blanco (cocido)', category: 'Carbohidratos', unit: 'plato', gramsPerUnit: 200, kcal: 260, protein: 5, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Arroz (crudo)', category: 'Carbohidratos', unit: 'puñado', gramsPerUnit: 70, kcal: 250, protein: 5, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pasta (cocida)', category: 'Carbohidratos', unit: 'plato', gramsPerUnit: 200, kcal: 280, protein: 10, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pasta (cruda)', category: 'Carbohidratos', unit: 'ración', gramsPerUnit: 80, kcal: 285, protein: 10, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pan (barra)', category: 'Carbohidratos', unit: 'rebanada', gramsPerUnit: 30, kcal: 80, protein: 3, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pan de molde', category: 'Carbohidratos', unit: 'rebanada', gramsPerUnit: 28, kcal: 75, protein: 3, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Patata', category: 'Carbohidratos', unit: 'unidad', gramsPerUnit: 150, kcal: 115, protein: 3, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Boniato', category: 'Carbohidratos', unit: 'unidad', gramsPerUnit: 150, kcal: 130, protein: 2, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Avena (copos)', category: 'Carbohidratos', unit: 'ración', gramsPerUnit: 40, kcal: 150, protein: 5, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Tortilla / wrap', category: 'Carbohidratos', unit: 'unidad', gramsPerUnit: 40, kcal: 130, protein: 3, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Cereales de desayuno', category: 'Carbohidratos', unit: 'bol', gramsPerUnit: 40, kcal: 150, protein: 3, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Cuscús (cocido)', category: 'Carbohidratos', unit: 'plato', gramsPerUnit: 180, kcal: 200, protein: 7, isPreset: true, repeat: Repeatability.free),

  // ----------------------------- LEGUMBRES -----------------------------
  PantryIngredient(name: 'Lentejas (cocidas)', category: 'Legumbres', unit: 'plato', gramsPerUnit: 220, kcal: 260, protein: 18, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Garbanzos (cocidos)', category: 'Legumbres', unit: 'plato', gramsPerUnit: 220, kcal: 300, protein: 16, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Alubias (cocidas)', category: 'Legumbres', unit: 'plato', gramsPerUnit: 220, kcal: 280, protein: 18, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Guisantes', category: 'Legumbres', unit: 'ración', gramsPerUnit: 120, kcal: 100, protein: 7, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Hummus', category: 'Legumbres', unit: 'ración', gramsPerUnit: 50, kcal: 90, protein: 3, isPreset: true, repeat: Repeatability.free),

  // ----------------------------- VERDURAS ------------------------------
  PantryIngredient(name: 'Tomate', category: 'Verduras', unit: 'unidad', gramsPerUnit: 120, kcal: 22, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Tomate frito', category: 'Verduras', unit: 'ración', gramsPerUnit: 50, kcal: 45, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Lechuga / ensalada', category: 'Verduras', unit: 'bol', gramsPerUnit: 80, kcal: 15, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Cebolla', category: 'Verduras', unit: 'ración', gramsPerUnit: 60, kcal: 25, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pimiento', category: 'Verduras', unit: 'unidad', gramsPerUnit: 120, kcal: 30, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Calabacín', category: 'Verduras', unit: 'ración', gramsPerUnit: 150, kcal: 25, protein: 2, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Berenjena', category: 'Verduras', unit: 'ración', gramsPerUnit: 150, kcal: 35, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Zanahoria', category: 'Verduras', unit: 'unidad', gramsPerUnit: 70, kcal: 30, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Brócoli', category: 'Verduras', unit: 'ración', gramsPerUnit: 150, kcal: 50, protein: 4, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Espinacas', category: 'Verduras', unit: 'puñado', gramsPerUnit: 60, kcal: 15, protein: 2, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Champiñones', category: 'Verduras', unit: 'ración', gramsPerUnit: 100, kcal: 25, protein: 3, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Judías verdes', category: 'Verduras', unit: 'ración', gramsPerUnit: 150, kcal: 45, protein: 3, isPreset: true, repeat: Repeatability.free),

  // ------------------------------ FRUTAS -------------------------------
  PantryIngredient(name: 'Plátano', category: 'Frutas', unit: 'unidad', gramsPerUnit: 120, kcal: 105, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Manzana', category: 'Frutas', unit: 'unidad', gramsPerUnit: 180, kcal: 95, protein: 0, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Naranja', category: 'Frutas', unit: 'unidad', gramsPerUnit: 180, kcal: 85, protein: 2, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Fresas', category: 'Frutas', unit: 'bol', gramsPerUnit: 150, kcal: 50, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Uvas', category: 'Frutas', unit: 'racimo', gramsPerUnit: 100, kcal: 70, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Melón / sandía', category: 'Frutas', unit: 'tajada', gramsPerUnit: 200, kcal: 70, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Pera', category: 'Frutas', unit: 'unidad', gramsPerUnit: 180, kcal: 100, protein: 1, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Aguacate', category: 'Frutas', unit: 'ración', gramsPerUnit: 100, kcal: 160, protein: 2, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Arándanos', category: 'Frutas', unit: 'puñado', gramsPerUnit: 80, kcal: 45, protein: 1, isPreset: true, repeat: Repeatability.free),

  // ------------------------- LÁCTEOS Y HUEVOS --------------------------
  PantryIngredient(name: 'Huevo', category: 'Lácteos y huevos', unit: 'unidad', gramsPerUnit: 55, kcal: 75, protein: 6, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Clara de huevo', category: 'Lácteos y huevos', unit: 'unidad', gramsPerUnit: 33, kcal: 17, protein: 4, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Leche', category: 'Lácteos y huevos', unit: 'vaso', gramsPerUnit: 250, kcal: 125, protein: 8, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Leche desnatada', category: 'Lácteos y huevos', unit: 'vaso', gramsPerUnit: 250, kcal: 85, protein: 9, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Yogur natural', category: 'Lácteos y huevos', unit: 'unidad', gramsPerUnit: 125, kcal: 80, protein: 5, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Yogur griego', category: 'Lácteos y huevos', unit: 'unidad', gramsPerUnit: 150, kcal: 140, protein: 8, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Queso fresco / batido', category: 'Lácteos y huevos', unit: 'ración', gramsPerUnit: 100, kcal: 70, protein: 11, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Queso curado', category: 'Lácteos y huevos', unit: 'loncha', gramsPerUnit: 25, kcal: 100, protein: 6, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Queso fundido / lonchas', category: 'Lácteos y huevos', unit: 'loncha', gramsPerUnit: 20, kcal: 60, protein: 4, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Requesón', category: 'Lácteos y huevos', unit: 'ración', gramsPerUnit: 100, kcal: 95, protein: 11, isPreset: true, repeat: Repeatability.free),

  // ---------------------- GRASAS Y FRUTOS SECOS ------------------------
  PantryIngredient(name: 'Aceite de oliva', category: 'Grasas y frutos secos', unit: 'cucharada', gramsPerUnit: 10, kcal: 90, protein: 0, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Mantequilla', category: 'Grasas y frutos secos', unit: 'porción', gramsPerUnit: 10, kcal: 75, protein: 0, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Almendras', category: 'Grasas y frutos secos', unit: 'puñado', gramsPerUnit: 25, kcal: 145, protein: 5, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Nueces', category: 'Grasas y frutos secos', unit: 'puñado', gramsPerUnit: 25, kcal: 165, protein: 4, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Cacahuetes', category: 'Grasas y frutos secos', unit: 'puñado', gramsPerUnit: 25, kcal: 145, protein: 6, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Crema de cacahuete', category: 'Grasas y frutos secos', unit: 'cucharada', gramsPerUnit: 16, kcal: 95, protein: 4, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Semillas (chía/lino)', category: 'Grasas y frutos secos', unit: 'cucharada', gramsPerUnit: 12, kcal: 60, protein: 2, isPreset: true, repeat: Repeatability.free),

  // ------------------------------- OTROS -------------------------------
  PantryIngredient(name: 'Proteína en polvo (whey)', category: 'Otros', unit: 'cazo', gramsPerUnit: 30, kcal: 120, protein: 24, isPreset: true, repeat: Repeatability.free),
  PantryIngredient(name: 'Chocolate negro', category: 'Otros', unit: 'ración', gramsPerUnit: 20, kcal: 110, protein: 2, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Miel', category: 'Otros', unit: 'cucharada', gramsPerUnit: 20, kcal: 60, protein: 0, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Azúcar', category: 'Otros', unit: 'cucharadita', gramsPerUnit: 8, kcal: 32, protein: 0, isPreset: true, repeat: Repeatability.limited),
  PantryIngredient(name: 'Mermelada', category: 'Otros', unit: 'cucharada', gramsPerUnit: 20, kcal: 50, protein: 0, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Galletas tipo María', category: 'Otros', unit: 'ración', gramsPerUnit: 24, kcal: 105, protein: 2, isPreset: true, repeat: Repeatability.limited),
  PantryIngredient(name: 'Patatas fritas (bolsa)', category: 'Otros', unit: 'puñado', gramsPerUnit: 30, kcal: 160, protein: 2, isPreset: true, repeat: Repeatability.limited),
  PantryIngredient(name: 'Kétchup / salsa de tomate', category: 'Otros', unit: 'cucharada', gramsPerUnit: 17, kcal: 20, protein: 0, isPreset: true, repeat: Repeatability.moderate),
  PantryIngredient(name: 'Mayonesa', category: 'Otros', unit: 'cucharada', gramsPerUnit: 15, kcal: 100, protein: 0, isPreset: true, repeat: Repeatability.limited),
];
