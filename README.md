# Meal Planner

App de planificación de comidas semanales con seguimiento opcional de calorías y
proteína. Flutter · Android / iOS · todo local, sin cuenta ni servidor.

## Qué hace

- **Planifica la semana**: 7 días × las tomas que quieras, con randomización que
  evita repetir platos e ingredientes y puede ajustarse a tus calorías.
- **Lista de la compra automática**: agrupada por pasillos del súper, con
  cantidades estimadas y modo "letra grande" para usarla comprando.
- **Registro diario**: apunta lo que comes por tomas, con anillo de calorías,
  barra de proteína, agua, peso y racha.
- **Despensa**: tus ingredientes con medidas caseras (1 filete, 1 loncha…),
  macros por unidad, stock y caducidad. De ahí sale "puedo cocinarlo ya".
- **Escáner de código de barras** (OpenFoodFacts) y **estimación con IA**
  (Gemini, con tu propia clave) para no pelearte con las macros.
- **Estadísticas**: medias, días cumplidos, evolución del peso, export a CSV.
- **Copia de seguridad completa** en un archivo JSON.

## Poner en marcha

```bash
flutter pub get
```

```bash
flutter run
```

## Comprobar que todo sigue bien

```bash
flutter analyze
```

```bash
flutter test
```

## Documentación

- [DESIGN.md](DESIGN.md) — modelo de datos, arquitectura y lógica de negocio.
- [V2_IDEAS.md](V2_IDEAS.md) — catálogo de ideas y hoja de ruta.

## Notas

- La clave de la API de Gemini se guarda solo en el dispositivo y **no** se
  incluye en las copias de seguridad.
- El escáner necesita permiso de cámara (ya declarado en Android e iOS).
