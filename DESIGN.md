# Meal Planner — Documento de Diseño y Funcionalidad (V2)

## 1. Qué es la app

Meal Planner es una aplicación móvil (Flutter / Android · iOS) para planificar
las comidas de la semana sin fricción y, opcionalmente, llevar la cuenta de las
calorías y la proteína.

Responde a dos preguntas cotidianas:

- **"¿Qué comemos esta semana?"** → planificador con randomización inteligente y
  lista de la compra automática.
- **"¿Voy bien con lo que como?"** → Modo Gym: objetivos calculados, registro
  diario y estadísticas.

Todo local: sin cuenta, sin backend, sin sincronización obligatoria.

---

## 2. Estructura de la app (V2)

La app se organiza en una **barra de navegación inferior** con cinco destinos
(`lib/screens/home_shell.dart`):

| Pestaña | Pantalla | Para qué |
|---|---|---|
| Hoy | `today_screen.dart` | Registrar lo que comes y ver el progreso del día |
| Semana | `planner_screen.dart` | Planificar los 7 días |
| Comidas | `food_list_screen.dart` | Tu catálogo de platos |
| Compra | `shopping_list_screen.dart` | La lista del súper |
| Más | `more_screen.dart` | Despensa, estadísticas, Modo Gym, ajustes |

La pestaña de arranque es configurable en Ajustes; por defecto es "Hoy" si el
Modo Gym está activo y "Semana" si no.

### Interfaz limpia

Un interruptor en *Ajustes › Interfaz* (`SettingsProvider.cleanMode`, leído con
`context.clean`) que quita de la vista los controles secundarios de todas las
pantallas y los deja en los menús: filtros del catálogo, dado y marcador de
cada comida del plan, tarjetas de agua y peso, etiquetas de los platos, botones
del selector de semanas, nombres de todas las pestañas… **No desaparece ninguna
función**: cada cosa que se esconde tiene su sitio en el menú ⋮ de su pantalla,
en la hoja que se abre al tocar una comida, o dejando pulsada una tarjeta.

### Widgets de la pantalla de inicio (solo Android)

Tres widgets, gestionados desde *Más › Widgets de inicio*:

| Widget | Qué enseña | Al tocarlo |
|---|---|---|
| Hoy | anillo de kcal, barra de proteína, agua y racha | pestaña Hoy |
| Lo siguiente | la comida del plan que toca y la de después | pestaña Hoy |
| Compra | cuántas cosas faltan y las primeras | pestaña Compra |

El contenido lo **dibuja Flutter** (`widgets/home_widget_faces.dart`) y viaja a
Android como PNG (`HomeWidget.renderFlutterWidget`); el layout nativo
(`res/layout/widget_card.xml`) es solo un `ImageView`, y los proveedores
(`WidgetProviders.kt`) solo cargan la imagen y ponen el enlace. Así el widget
sale con el tema de color y el modo oscuro elegidos en la app, sin duplicar la
paleta de Material 3 en XML. El precio es que los colores van cocidos en la
imagen: hay que repintarla al cambiar de tema.

`HomeWidgetService` decide qué y cuándo: se repinta al arrancar, al salir de la
app (`paused`/`hidden`) y al cambiar el brillo del sistema. Android no los
refresca por su cuenta (`updatePeriodMillis="0"`) para no gastar batería.

---

## 3. Modelo de datos

### Food (plato) — `models/food.dart`
```
name        : String                 nombre (clave del catálogo)
ingredients : String                 texto libre separado por comas
slots       : Set<MealSlot>          en qué tomas encaja
kcal        : int?                   por ración (opcional)
protein     : int?                   gramos por ración (opcional)
components  : List<FoodComponent>    plato compuesto (pan + carne…)
```
Si tiene `components`, sus `kcal`, `protein` e `ingredients` se calculan de ellos
al guardar. `isHighProtein` = ≥30 % de las calorías vienen de la proteína.

### FoodComponent
`name`, `kcal`/ud, `protein`/ud, `quantity` (admite 0.5). `totalKcal` y
`totalProtein` aplican la cantidad.

### MealSlot — `models/meal_slot.dart`
`breakfast · lunch · snack · dinner · preWorkout · postWorkout`.
`kStandardSlots` = almuerzo + cena (modo normal). El Modo Gym permite elegir.

### Week (semana) — `models/week.dart`
```
plan          : Map<MealSlot, List<String?>>   7 días por toma
checked       : Set<String>                    marcados en la compra
locked        : Set<int>                       días que el randomizador no toca
away          : Set<int>                       días que comes fuera
manualItems   : List<String>                   añadidos a mano a la compra
startDate     : DateTime?                      lunes real de esta semana
imported      : bool
embeddedFoods : List<Food>                     copia de los platos importados
```
`startDate` es la novedad grande de la V2: ata la semana al calendario real, de
modo que "Hoy" sabe qué día del plan mirar (`containsDate`, `dateOfDay`).

### PantryIngredient (despensa) — `models/pantry_ingredient.dart`
```
name, category, unit ("loncha", "filete"…), kcal/ud, protein/ud,
gramsPerUnit, isPreset, repeat (libre/moderado/limitar),
barcode, stock (cuánto tienes en casa), expiry (caducidad)
```

### LoggedItem (registro) — `models/logged_item.dart`
```
name, kcal, protein (por ración), slot?, minutesOfDay?, servings
```
`totalKcal`/`totalProtein` aplican las raciones. Guarda una *copia* de las
macros, no una referencia al plato: el histórico no cambia si editas el catálogo.

### IngredientGroup (compra) — `models/ingredient_group.dart`
`name`, `dishes`, `manual`, `category` (pasillo del súper), `quantityLabel`.

---

## 4. Arquitectura

- **Flutter** + **Material 3**, tema por color semilla (9 temas).
- Estado: **Provider** (`ChangeNotifier`), un provider por dominio:

| Provider | Responsabilidad | Clave de persistencia |
|---|---|---|
| `MealProvider` | catálogo, semanas, randomizador, compra, import/export | `mealplanner_data_v1` |
| `PantryProvider` | despensa, stock, repetibilidad | `pantry_v1`, `pantry_deleted_presets_v1` |
| `DiaryProvider` | registro diario, agua, peso, notas, racha | `diary_v1`, `diary_extras_v1` |
| `GymProvider` | perfil, objetivos, tomas activas | claves `gym_*` |
| `SettingsProvider` | tema, modo, AMOLED, intensidad, pestaña inicial | claves `settings_*` |
| `AiProvider` | clave y modelo de Gemini | `ai_gemini_api_key` |

- Persistencia: **SharedPreferences**. Sin base de datos.
- `BackupService` (`data/backup_service.dart`) vuelca y restaura todas esas
  claves en un único JSON. La clave de la IA queda fuera a propósito.

### Utilidades transversales
`data/text_utils.dart` normaliza texto (quita acentos, respeta la ñ) y cruza
ingredientes de forma blanda: `ingredientsMatch('Pechuga de pollo', 'pollo')` es
`true`. De ahí dependen la repetibilidad del randomizador, los pasillos de la
lista de la compra y "cocinar con lo que tengo".

---

## 5. Lógica de negocio clave

### Randomización
`MealProvider.randomizeActiveWeek(slots, ...)`:

- **Peso inverso por uso**: `1 / (1 + vecesUsado × 2)`.
- **Penalización por repetibilidad**: los ingredientes marcados "con moderación"
  (tope blando 4/semana) o "limitar" (2/semana) reducen el peso de los platos
  que los usan (×0.5 al acercarse al tope, ×0.12 al pasarlo).
- **Objetivo de calorías** (`targetKcal`): reparte las kcal que quedan entre las
  tomas pendientes del día y favorece los platos que encajan (`_kcalFit`).
- **Respeta** días bloqueados y días "fuera de casa".
- **`onlyEmpty`**: rellena solo los huecos, sin tocar lo que pusiste a mano.
- **`onlyWithMacros`**: solo platos con kcal y proteína.

`rotateMeal(day, slot)` usa los mismos pesos, evita repetir lo que ya hay ese día
y devuelve `RotateResult.locked` si el día está bloqueado.

### Renombrar platos
`addOrReplaceFood(food, previousName: ...)` detecta el renombrado: borra el plato
viejo y **reescribe todas las referencias** en los planes de todas las semanas.
`mergeFoods(from, into)` fusiona dos platos moviendo el plan.

### Lista de la compra
`shoppingListForActiveWeek(pantry: ...)`:
- Cuenta cuántas veces se cocina cada plato (los días "fuera" no cuentan).
- Agrupa ingredientes con texto normalizado.
- Asigna el pasillo desde la despensa.
- Estima cantidades: unidades reales si el plato es compuesto ("6 huevos"), o
  el número de repeticiones ("×3").
- `_pruneChecks()` borra los checks de ingredientes que ya no están.

### Objetivos del Modo Gym
Mifflin-St Jeor → BMR → TDEE (× factor de actividad) → objetivo:

| Objetivo | Calorías | Proteína |
|---|---|---|
| Volumen | TDEE × 1.12 | 2.0 g/kg |
| Definición | TDEE × 0.80 | 2.2 g/kg |
| Mantenimiento | TDEE | 1.8 g/kg |
| Personalizado | tus cifras | tus cifras |

### Racha
`DiaryProvider.proteinStreak(objetivo)`: días consecutivos cumpliendo proteína.
Si hoy todavía no lo has cumplido, se cuenta desde ayer (el día no ha acabado).

---

## 6. Formato de import/export

### Semana (compatible con la app Android original)
```json
{
  "version": 2,
  "comidas": [ { "name": "...", "ingredients": "...", "slots": ["lunch"], "isLunch": true } ],
  "plan": { "lunch": { "Lunes": "Puchero" } },
  "planificador": { "Lunes": "Puchero", "LunesCena": "Tortilla" }
}
```
`plan` es el formato nuevo multi-toma; `planificador` se mantiene para que la app
Android antigua siga pudiendo leer almuerzo y cena.

### Copia de seguridad completa
```json
{ "app": "mealplanner_flutter", "backupVersion": 1, "createdAt": "...",
  "data": { "<clave>": { "type": "bool|int|double|string|stringList", "value": ... } } }
```

---

## 7. Compatibilidad hacia atrás

Todo lo viejo sigue leyéndose:

- `Food`: `slots` → o `isLunch`/`isDinner` → o `esAlmuerzo`/`esCena` (Android).
- `Week`: `plan` → o `lunches`/`dinners`.
- Semanas sin `startDate`: al arrancar, `ensureCalendarAnchor()` ata la semana
  activa a la semana real actual si ninguna tiene fecha.
- Ingredientes de la despensa sin `stock`/`expiry`: valen 0 y null.
- Entradas del diario sin `slot`/`servings`: van al grupo "Otros" con 1 ración.

---

## 8. Tests

`flutter test` — 121 tests. Cobertura de la lógica, no de la UI:

| Archivo | Qué cubre |
|---|---|
| `migration_test.dart` | migraciones de `Food` y `Week` |
| `macros_test.dart` | kcal/proteína, `isHighProtein` |
| `components_test.dart` | platos compuestos |
| `pantry_test.dart` | despensa y repetibilidad |
| `planner_features_test.dart` | edición manual, bloqueo, ítems manuales |
| `preset_foods_test.dart` | muestrario de platos |
| `openfoodfacts_test.dart` | parseo del escáner |
| `diary_test.dart` | registro diario |
| `v2_test.dart` | renombrado, fechas de semana, compra con pasillos y cantidades, stock, racha, backup |
| `widget_test.dart` | smoke test de arranque |
| `widgets_and_clean_test.dart` | qué enseñan los widgets de inicio, sus enlaces, y que la interfaz limpia esconde sin perder nada |

---

## 9. Decisiones de diseño

- **Un JSON en SharedPreferences** en lugar de SQLite: el volumen es de decenas
  de platos y unas pocas semanas. Si algún día crece, tocará migrar (el guardado
  reescribe el documento entero en cada cambio).
- **Provider en vez de Riverpod/Bloc**: el estado es pequeño y con pocas
  relaciones; un `ChangeNotifier` por dominio se lee bien.
- **Ingredientes como texto libre**: menos fricción al escribir. El cruce con la
  despensa es blando (`text_utils.dart`) precisamente porque el texto es libre.
- **Solo kcal y proteína**: decisión explícita para que contar sea llevadero. No
  hay carbohidratos ni grasas.
- **La IA es Gemini con clave del usuario**: cada uno pone su clave gratuita de
  Google AI Studio; no hay cuota compartida ni servidor intermedio.
- **Nada de jerga**: los objetivos se llaman "Volumen"/"Definición" y se explican
  en una línea; el usuario nunca escribe términos técnicos.
