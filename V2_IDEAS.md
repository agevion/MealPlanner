# Meal Planner — Revisión y propuesta de V2

Documento de trabajo (2026-08-09). Revisión del código + catálogo de ideas.

## Estado de la implementación

**Hecho y verificado** (`flutter analyze` limpio, 100 tests en verde,
`flutter build apk --debug` OK):

- **Los 12 fallos A1–A12**: renombrado real de platos, presets borrados que no
  resucitan, "cargar plan" sin duplicados, navegación de días en el registro,
  semanas atadas al calendario, rotación coherente, confirmación al borrar
  semana, checks huérfanos, clave de IA que no se escribe en cada tecla, UI
  obsoleta fuera, docs al día, cruce de ingredientes con acentos y parciales.
- **Estructura**: 1, 2, 3, 4, 9, 10.
- **Planificador**: 11, 12, 14, 16, 17, 18, 19, 20 (parcial), 21, 22, 23, 24,
  25, 28 (parcial).
- **Registro**: 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 41.
- **Catálogo**: 42, 43, 44, 45, 46 (raciones que salen), 47, 48, 49, 53, 54.
- **Despensa**: 55, 56, 57, 58, 59, 60, 62.
- **Compra**: 64, 65, 67, 69, 70, 71 (coste de semana), 73.
- **Gym**: 76, 79, 80, 81, 84, 85 (parcial).
- **IA**: 87, 88, 92 (parcial).
- **Gamificación**: 94, 97, 98 (háptico).
- **Datos**: 101, 103.
- **Tonterías**: 116.
- **Interno**: 123, 126 (tests de lógica), 127, 130.

**Añadido después** (2026-08-11):

- **39 (widgets de la pantalla de inicio)**: tres widgets de Android —"Hoy"
  (anillo de kcal, barra de proteína, agua y racha), "Lo siguiente" (la comida
  del plan que toca y la de después) y "Compra" (lo que falta esta semana)—.
  Los dibuja Flutter y llegan a Android como imagen, así que salen con el tema
  de color y el modo oscuro de la app; se refrescan al salir de ella y al
  tocarlos abren su pestaña. Se gestionan desde *Más › Widgets de inicio*, con
  vista previa real y botón para colocarlos. Sin probar en un móvil.
- **Interfaz limpia** (*Ajustes › Interfaz*): esconde los controles secundarios
  de todas las pantallas (filtros del catálogo, dado y marcador de cada comida
  del plan, tarjetas de agua y peso, etiquetas de los platos…) y los deja en
  los menús. No quita ninguna función.

**Pendiente a propósito** (necesita plugins nativos o decisiones tuyas):

- 6, 40 (atajos y notificaciones): hace falta `flutter_local_notifications` +
  configuración nativa, y no se pueden probar sin un móvil delante.
- 83 (Health Connect), 104/105 (sync y perfiles múltiples), 106 (SQLite):
  cambios de arquitectura que conviene decidir aparte.
- 108 (Material You con `dynamic_color`), 15, 26, 27, 68, 72, 86, 93, 95, 96,
  99, 100, 115, 117–122: quedaban por debajo del corte de esta tanda.

---

## 0. Dónde está la app hoy

Lo que ya funciona bien:

- Planificador semanal por tomas (`MealSlot`), hasta 30 semanas, días bloqueables,
  edición manual por celda, randomizador con pesos y penalización por
  repetibilidad de ingredientes.
- Catálogo de platos con buscador, filtros por toma/macros y orden (A-Z, Z-A, más usados).
- Platos compuestos (`FoodComponent`) con macros sumadas desde sus ingredientes.
- Despensa con medidas caseras, macros por unidad y repetibilidad.
- Escáner de código de barras + OpenFoodFacts + selector de porción con memoria por producto.
- Estimación de macros con IA (Gemini, clave por usuario).
- Modo Gym: perfil → TDEE (Mifflin-St Jeor) → objetivos de kcal y proteína.
- Registro diario ("Hoy") con barras de progreso.
- Lista de la compra con ítems manuales y checks persistidos por semana.
- Temas (9 colores), modo claro/oscuro, AMOLED, intensidad de color.
- 40+ tests de lógica, `flutter analyze` limpio.

El código está bien: providers separados por dominio, modelos con migración y
back-compat cuidada, comentarios en español y útiles.

---

## A. Fallos y deudas reales (arreglar antes de meter cosas nuevas)

**A1. Renombrar un plato lo duplica.**
`add_food_screen.dart:203` llama a `addOrReplaceFood`, que casa por nombre
(`meal_provider.dart:87`). Si cambias el nombre al editar, se crea un plato nuevo,
el viejo sigue en el catálogo y todas las semanas planificadas siguen apuntando al
nombre antiguo. Hace falta un `renameFood(viejo, nuevo)` que actualice también
`Week.plan` de todas las semanas.

**A2. Los ingredientes preset borrados resucitan.**
`PantryProvider._mergeNewPresets` (`pantry_provider.dart:1116`) re-añade cualquier
preset que no esté por nombre. Si borras "Chorizo", vuelve al siguiente arranque.
Solución: lista de nombres borrados, o versión de semilla de presets.

**A3. "Cargar plan de hoy" duplica entradas.**
`today_screen.dart:403` hace `addEntries` sin comprobar nada. Dos toques = comida
contada dos veces.

**A4. "Hoy" solo existe hoy.**
`TodayScreen` es `StatelessWidget` con `DateTime.now()` fijo. No puedes ver ni
corregir ayer, ni ver un histórico. El `DiaryProvider` ya guarda por fecha, así que
falta solo la UI.

**A5. Las semanas no tienen fecha.**
"Semana 1…30" no se relaciona con el calendario. `_loadTodayPlan` asume que la
semana activa es la semana real actual: si tienes 4 semanas y estás mirando la 3,
carga el plan equivocado.

**A6. `rotateMeal` es incoherente con el randomizador.**
`meal_provider.dart:279`: elige totalmente al azar, no aplica pesos, no evita
repetir el plato del mismo día y no respeta el bloqueo del día.

**A7. Borrar semana no confirma ni deshace.**
Un toque en la papelera del `_WeekSelector` y la semana desaparece.

**A8. Checks huérfanos en la lista de compra.**
`Week.checked` guarda nombres visibles; al re-randomizar quedan marcados
ingredientes que ya no están en la lista.

**A9. La clave de Gemini se guarda en claro.**
`AiProvider` usa SharedPreferences, y `settings_screen.dart` la escribe en cada
pulsación (`onChanged: ai.setApiKey`). Mejor `flutter_secure_storage` y guardar al
salir del campo.

**A10. UI obsoleta.**
La tarjeta "Lo que llega después" (`gym_mode_screen.dart:1198`) anuncia 4 cosas que
ya están hechas. Ajustes muestra "Versión 1.0.0" escrita a mano.

**A11. Documentación desfasada.**
`DESIGN.md` documenta `lunches`/`dinners` e `isLunch`/`isDinner`, y no menciona
Modo Gym, despensa, IA, escáner ni platos compuestos. `README.md` es la plantilla
de Flutter.

**A12. Cruce de ingredientes frágil.**
El planificador cruza despensa ↔ platos comparando texto en minúsculas
(`randomizeActiveWeek`). "Pechuga de pollo" en la despensa no casa con "pollo" en
el texto del plato, así que la repetibilidad casi nunca se aplica.

---

## B. Navegación y estructura (lo que más cambia el uso diario)

1. **Barra de navegación inferior fija**: Hoy · Semana · Comidas · Compra · Más.
   Hoy todo cuelga de la home con `Navigator.push` encadenados.
2. Abrir la app directamente en "Hoy" (o pantalla de inicio configurable).
3. **Semanas con fechas reales** (lun 11 – dom 17), etiquetas "Esta semana /
   Próxima" y avance automático al llegar el lunes.
4. **Deshacer universal**: SnackBar con "Deshacer" en borrar plato, borrar semana,
   vaciar día, quitar entrada del diario.
5. Búsqueda global (una lupa que busca platos, ingredientes y entradas del diario).
6. App Shortcuts de Android (mantener pulsado el icono): "Registrar comida",
   "Lista de compra", "Randomizar semana".
7. Deslizar para borrar en listas; acciones al deslizar (marcar comido, favorito).
8. Onboarding real la primera vez: 3 pantallas (crea platos → randomiza → compra).
9. Buscador dentro del bottom sheet de elegir plato (con 60 platos es una lista larga).
10. Pantalla "Más" que agrupe despensa, ajustes, backup, estadísticas.

## C. Planificador

11. Arrastrar y soltar comidas entre días y tomas.
12. Duplicar semana / usar una semana como plantilla.
13. Plantillas guardadas: "semana de definición", "semana barata", "semana rápida".
14. **Modo sobras**: marcar un plato como "hace 2 raciones" y que ocupe
    automáticamente la cena del día siguiente.
15. Vista de calendario mensual además de la lista de 7 días.
16. Bloqueo por celda, no solo por día entero.
17. "No me apetece esta semana": excluir platos temporalmente del randomizador.
18. Randomizar **solo los huecos vacíos** (hoy sobrescribe todo lo no bloqueado).
19. **Randomizador con objetivo de calorías**: que la suma del día caiga cerca de tu
    objetivo (era la Fase 6 del plan del Modo Gym, sigue pendiente).
20. Reglas suaves configurables: "pescado ≥2 veces por semana", "no repetir plato en
    3 días", "viernes = capricho".
21. Etiquetas/categorías de plato (pasta, carne, pescado, veggie, rápido) y
    equilibrado por categoría al randomizar.
22. Tiempo de preparación por plato + "días con prisa" (solo platos de <15 min).
23. Marcar un día como "fuera de casa": no cuenta en la compra ni en el registro.
24. Compartir la semana como imagen bonita, además del JSON.
25. Vista compacta tipo tabla 7×tomas para verlo todo de un vistazo.
26. Historial: guardar lo que realmente se comió y poder "repetir aquella semana".
27. Comparar semanas (kcal medias, variedad, coste).
28. Avisos al planificar: "llevas pollo 5 veces", "el jueves te falta proteína".

## D. Hoy / registro diario

29. Navegar entre días (flechas + calendario) y corregir días pasados.
30. Registrar **por toma** (desayuno/almuerzo/cena) y hora, no una lista plana.
31. Marcar las comidas planificadas con un toque desde "Hoy" (checkbox por toma en
    lugar del botón "Cargar plan de hoy").
32. Recientes y frecuentes en el sheet de añadir (top 10 por uso).
33. Duplicar entrada y ajustar cantidad (×0.5, ×1.5, ×2) sin borrar y volver a crear.
34. Anillo de calorías (progreso circular) y "te quedan X kcal".
35. Reparto sugerido: cuántas kcal te quedan para cada toma restante.
36. Contador de vasos de agua.
37. **Registro de peso corporal** con gráfica y media móvil de 7 días.
38. Notas del día ("entrené piernas", "cena fuera").
39. Widget de pantalla de inicio con el anillo del día y botón de añadir rápido.
40. Recordatorios configurables ("¿qué has comido?" a las 15:00 y 22:00).
41. Copiar el día de ayer entero de un toque.

## E. Catálogo de platos

42. Renombrar de verdad (ver A1) y fusionar platos duplicados.
43. **Foto del plato** (`image_picker` ya está en el proyecto) + miniatura en la lista.
44. Receta: pasos, tiempo, notas, enlace o vídeo.
45. Favoritos ⭐ y valoración 1-5 que sesgue el randomizador.
46. Raciones por receta ("da 4 raciones") con escalado de ingredientes y macros.
47. Coste aproximado por ración → presupuesto semanal.
48. Etiquetas dietéticas y alérgenos (sin gluten, veggie, sin lactosa).
49. Duplicar un plato como base para una variante.
50. Papelera: platos borrados recuperables 30 días.
51. Importar/exportar **solo el catálogo** (hoy solo se exporta la semana activa).
52. Más platos de ejemplo, organizados por categorías y filtrables.
53. Ficha por plato: veces comido, última vez, kcal medias.
54. Ordenar también por kcal, por proteína y por "hace más que no lo comes".

## F. Despensa e ingredientes

55. Stock real: "tengo 3 latas de atún", descontar al planificar y sumar al comprar.
56. Caducidades y aviso "úsalo pronto".
57. **"Cocinar con lo que tengo"**: sugerir platos cuyos ingredientes estén en stock.
58. Autocompletado de ingredientes desde la despensa al escribir el texto libre
    (arregla A12 de paso).
59. Sinónimos/alias ("pechuga" = "pollo") para que el cruce y la agrupación de la
    compra funcionen de verdad.
60. Categorías editables y con orden propio.
61. Guardar un producto escaneado directo en la despensa (existe, pero está escondido).
62. Copiar macros de un ingrediente a otro; plantillas de unidad.
63. Ingredientes compuestos ("sofrito" = tomate + cebolla + aceite).

## G. Lista de la compra

64. **Agrupar por categoría de la despensa** (pasillos del súper). Las categorías ya
    existen en `common_ingredients.dart`, solo falta usarlas aquí.
65. **Cantidades reales**: sumar unidades ("6 huevos", "2 latas") en vez de solo nombres.
66. Marcar lo que ya tienes en casa (cruce con el stock, idea 55).
67. Compartir/copiar como texto plano para WhatsApp o Notas.
68. Lista combinada de varias semanas a la vez.
69. Ítems recurrentes fijos (papel de cocina, café) que aparecen siempre.
70. Modo súper: pantalla siempre encendida, letra grande, zonas de toque amplias.
71. Precio estimado por ítem y total del carro.
72. Historial de compras y "lo de siempre" para añadir en bloque.
73. Separar en dos secciones: pendiente / ya comprado.

## H. Modo Gym y nutrición

74. Objetivos distintos según el día (entreno vs descanso).
75. Ciclado de calorías / día de refeed automático.
76. **Ajuste automático del objetivo** según la evolución del peso (si en 2 semanas
    no te mueves, +100 kcal).
77. Grasas y carbohidratos como interruptor opcional (hoy solo kcal + proteína, que
    fue una decisión consciente: dejarlo opt-in).
78. Historial de objetivos y de cambios de perfil.
79. **Estadísticas**: media semanal de kcal y proteína, % de días cumplidos, gráfica
    de 30 días. Es lo único de "completitud" que quedó sin hacer.
80. Informe semanal automático ("cumpliste proteína 5 de 7 días").
81. Exportar el diario a CSV.
82. Suplementos (creatina, batido) como registro rápido de un toque.
83. Integración opcional con Health Connect (peso, calorías, pasos).
84. Calculadora inversa: "me quedan 600 kcal, ¿cuánto arroz me cabe?".
85. Aviso de proteína baja a media tarde, cuando aún da tiempo a arreglarlo.

## I. IA (Gemini)

86. Estimar con foto y añadirlo **directo a "Hoy"**, no solo al crear un plato.
87. Generar platos: "dame 5 cenas de menos de 400 kcal con lo que tengo en la despensa".
88. Rellenar ingredientes y receta a partir del nombre del plato.
89. Revisar/afinar las macros de un plato que ya existe.
90. Validar la clave con una llamada de prueba al guardarla.
91. Caché de estimaciones para no repetir llamadas por el mismo texto.
92. Elegir modelo de una lista desplegable en vez de escribir el nombre a mano.
93. "Analiza mi semana": comentario en cristiano sobre el plan de la semana.

## J. Gamificación y mascota (Fase 5, pendiente del arte)

94. Racha de días cumpliendo proteína, con "congelar racha" una vez por semana.
95. Mascota huevo → pollito → gallina que evoluciona con la racha.
96. XP y niveles por acciones (planificar, registrar, comprar).
97. Logros: "30 días seguidos", "50 platos creados", "semana perfecta".
98. Confeti y háptico al cumplir el objetivo del día.
99. Resumen anual estilo Wrapped ("tu plato del año fue…").
100. Reto semanal aleatorio ("prueba un plato que no comes desde hace 2 meses").

## K. Datos, backup y sincronización

101. **Backup completo** (catálogo + semanas + despensa + diario + ajustes) a un
     archivo, con restauración. Hoy solo se exporta la semana activa.
102. Auto-backup semanal a la carpeta de Descargas.
103. Versionado de esquema con migraciones explícitas (hoy hay claves `_v1` sueltas).
104. Sincronización opcional vía Google Drive / archivo en la nube, sin backend propio.
105. Perfiles múltiples (tú y tu pareja).
106. Migrar de SharedPreferences a SQLite/Isar si el JSON crece (hoy se reescribe el
     documento entero en cada toque, incluso al marcar un ingrediente).
107. Exportar la semana en PDF o imagen para imprimir y colgar en la nevera.

## L. Aspecto y personalización

108. Material You: usar el color del fondo de pantalla (`dynamic_color`).
109. Tamaño de texto y densidad ajustables (compacto / cómodo).
110. Emoji o icono propio por plato.
111. Animaciones de transición entre pantallas.
112. Sonido y háptico opcionales al randomizar.
113. Más temas + "tema aleatorio del día".
114. Home configurable: qué tarjetas ver y en qué orden.

## M. Tonterías con encanto

115. Animación de dado 3D al randomizar.
116. **Ruleta de la cena** a pantalla completa para cuando no sabes qué cenar.
117. Frases del día ("hoy toca pollo, otra vez").
118. Contador anual: "llevas 47 pollos este año".
119. Easter egg al tocar 7 veces el icono de la home.
120. "Agita el móvil para decidir" entre 3 platos.
121. Sello de "plato estrella del mes".
122. Modo oscuro que se activa a la hora de cenar.

## N. Calidad interna

123. `renameFood` / `mergeFood` con tests (ver A1).
124. Debounce del guardado en SharedPreferences.
125. Partir `MealProvider` (584 líneas) en catálogo / plan / compra.
126. Tests de widget de las pantallas grandes (hoy solo hay tests de lógica).
127. Actualizar `DESIGN.md`, escribir `GYM_MODE.md` y un README de verdad.
128. `package_info_plus` para la versión en Ajustes.
129. `intl` para fechas y plurales correctos (aunque solo haya español).
130. Estados de error de red visibles en escáner e IA ("sin conexión").

---

## Propuesta de orden

**V2.0 — Arreglos y estructura** (lo que hace que el resto no moleste)
A1, A2, A3, A4, A5, A7, A10, A11 + ideas 1, 3, 4, 9.

**V2.1 — Comodidad diaria** (el uso real de cada día)
Ideas 29, 30, 31, 32, 34, 41, 39, 40.

**V2.2 — Compra y despensa** (lo que se nota el sábado en el súper)
Ideas 64, 65, 67, 69, 70 + 55, 57, 58, 59.

**V2.3 — Planificar mejor**
Ideas 11, 14, 18, 19, 21, 22, 23, 45.

**V2.4 — Números y progreso**
Ideas 37, 79, 80, 76, 81.

**V2.5 — Gamificación y encanto**
Ideas 94-100 + 115, 116, 117, 118.
