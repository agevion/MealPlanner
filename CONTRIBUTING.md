# Contribuir

Gracias por pasarte. Este es un proyecto personal, pero las sugerencias y los
parches son bienvenidos.

## Antes de abrir un pull request

Estos tres comandos son exactamente lo que ejecuta la integración continua, así
que si pasan en local, pasan en GitHub:

```bash
dart format .
```

```bash
flutter analyze
```

```bash
flutter test
```

## Cómo está organizado el código

- `lib/models/` — modelos de datos, serializables a JSON.
- `lib/data/` — persistencia y servicios externos (OpenFoodFacts, Gemini).
- `lib/state/` — estado de la app con `ChangeNotifier`.
- `lib/screens/` y `lib/widgets/` — interfaz.
- `lib/l10n/` — textos de la app, un archivo por idioma.

[DESIGN.md](DESIGN.md) explica el modelo de datos y la lógica de negocio con más
detalle; merece un vistazo antes de tocar nada de fondo.

## Detalles a tener en cuenta

- **Textos**: no se escriben literales en la interfaz. Se añaden a
  `lib/l10n/app_strings.dart` (inglés, la base) y a los archivos de cada idioma.
- **Nada de claves en el repositorio**: la clave de Gemini la pone cada persona
  desde Ajustes y se queda en su dispositivo.
- **Tests**: si tocas lógica de cálculo, planificación o migraciones de datos,
  acompáñalo de un test.

## Informar de un fallo

Abre una issue contando qué esperabas, qué pasó, y en qué versión de Android o
iOS. Si es un fallo de cálculo, los números concretos ayudan mucho.
