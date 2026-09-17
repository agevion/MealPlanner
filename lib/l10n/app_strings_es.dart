import '../models/gym_goal.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';
import 'app_strings.dart';

/// Español. Es el idioma en el que nació la app, así que los textos son los
/// originales tal cual estaban en las pantallas.
class AppStringsEs extends AppStrings {
  const AppStringsEs();

  @override
  String get languageCode => 'es';
  @override
  String get aiLanguageName => 'Spanish';

  // ======================= COMÚN =======================

  @override
  String get cancel => 'Cancelar';
  @override
  String get save => 'Guardar';
  @override
  String get saveChanges => 'Guardar cambios';
  @override
  String get add => 'Añadir';
  @override
  String get added => 'Añadido';
  @override
  String get delete => 'Eliminar';
  @override
  String get remove => 'Quitar';
  @override
  String get close => 'Cerrar';
  @override
  String get undo => 'Deshacer';
  @override
  String get all => 'Todas';
  @override
  String get options => 'Opciones';
  @override
  String get more => 'Más';
  @override
  String get search => 'Buscar';
  @override
  String get show => 'Mostrar';
  @override
  String get hide => 'Ocultar';
  @override
  String get name => 'Nombre';
  @override
  String get quantity => 'Cantidad';
  @override
  String get noResults => 'Sin resultados.';

  @override
  String get protein => 'Proteína';
  @override
  String get calories => 'Calorías';
  @override
  String get kcalPerDay => 'kcal/día';
  @override
  String get gramsPerDay => 'g/día';

  @override
  String proteinValue(int n) => '$n g proteína';
  @override
  String macros(int kcal, int protein) => '$kcal kcal · $protein g proteína';

  @override
  List<String> get weekdays => const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  @override
  List<String> get weekdaysShort => const [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];
  @override
  List<String> get months => const [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  @override
  List<String> get monthsShort => const [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  @override
  String longDate(DateTime d) =>
      '${weekdays[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]}';

  @override
  String mealSlot(MealSlot slot) => switch (slot) {
    MealSlot.breakfast => 'Desayuno',
    MealSlot.lunch => 'Almuerzo',
    MealSlot.snack => 'Merienda',
    MealSlot.dinner => 'Cena',
    MealSlot.preWorkout => 'Pre-entreno',
    MealSlot.postWorkout => 'Post-entreno',
  };

  @override
  String gymGoal(GymGoal goal) => switch (goal) {
    GymGoal.volume => 'Volumen',
    GymGoal.definition => 'Definición',
    GymGoal.maintenance => 'Mantenimiento',
    GymGoal.custom => 'Personalizado',
  };

  @override
  String gymGoalDescription(GymGoal goal) => switch (goal) {
    GymGoal.volume => 'Ganar músculo · comer algo más de lo que gastas',
    GymGoal.definition => 'Perder grasa sin perder músculo',
    GymGoal.maintenance => 'Mantener tu peso y rendir',
    GymGoal.custom => 'Tú pones las cifras',
  };

  @override
  String sex(Sex value) => value == Sex.male ? 'Hombre' : 'Mujer';

  @override
  String activity(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Sedentario',
    ActivityLevel.light => 'Ligero',
    ActivityLevel.moderate => 'Moderado',
    ActivityLevel.active => 'Alto',
    ActivityLevel.veryActive => 'Muy alto',
  };

  @override
  String activityDescription(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Poco o nada de ejercicio',
    ActivityLevel.light => 'Entreno 1-3 días por semana',
    ActivityLevel.moderate => 'Entreno 3-5 días por semana',
    ActivityLevel.active => 'Entreno 6-7 días por semana',
    ActivityLevel.veryActive => 'Entreno duro a diario o trabajo físico',
  };

  @override
  String repeatability(Repeatability r) => switch (r) {
    Repeatability.free => 'Sin límite',
    Repeatability.moderate => 'Con moderación',
    Repeatability.limited => 'Limitar',
  };

  @override
  String repeatabilityHint(Repeatability r) => switch (r) {
    Repeatability.free => 'Puedes repetirlo tanto como quieras',
    Repeatability.moderate => 'Mejor no abusar durante la semana',
    Repeatability.limited => 'Solo de vez en cuando',
  };

  @override
  Map<String, String> get ingredientCategories => const {
    'Proteínas': 'Proteínas',
    'Carbohidratos': 'Carbohidratos',
    'Legumbres': 'Legumbres',
    'Verduras': 'Verduras',
    'Frutas': 'Frutas',
    'Lácteos y huevos': 'Lácteos y huevos',
    'Grasas y frutos secos': 'Grasas y frutos secos',
    'Otros': 'Otros',
  };

  @override
  Map<String, String> get foodTags => const {
    'Pasta': 'Pasta',
    'Arroz': 'Arroz',
    'Carne': 'Carne',
    'Pescado': 'Pescado',
    'Verduras': 'Verduras',
    'Legumbres': 'Legumbres',
    'Huevos': 'Huevos',
    'Sopa': 'Sopa',
    'Ensalada': 'Ensalada',
    'Rápido': 'Rápido',
    'De aprovechar': 'De aprovechar',
    'Capricho': 'Capricho',
  };

  @override
  Map<String, String> get themeNames => const {
    'teal': 'Verde azulado',
    'sunset': 'Atardecer',
    'grape': 'Uva',
    'ocean': 'Océano',
    'forest': 'Bosque',
    'ruby': 'Rubí',
    'amber': 'Ámbar',
    'midnight': 'Medianoche',
    'crimson': 'Carmesí',
  };

  @override
  Map<String, String> get homeUnits => const {
    'loncha': 'loncha',
    'filete': 'filete',
    'unidad': 'unidad',
    'rodaja': 'rodaja',
    'cucharada': 'cucharada',
    'puñado': 'puñado',
    'vaso': 'vaso',
    'ración': 'ración',
    'muslo': 'muslo',
    'lomo': 'lomo',
    'lata': 'lata',
    'plato': 'plato',
    'rebanada': 'rebanada',
    'bol': 'bol',
    'racimo': 'racimo',
    'tajada': 'tajada',
    'porción': 'porción',
    'cazo': 'cazo',
    'cucharadita': 'cucharadita',
  };

  // ======================= NAVEGACIÓN =======================

  @override
  String get tabToday => 'Hoy';
  @override
  String get tabWeek => 'Semana';
  @override
  String get tabMeals => 'Comidas';
  @override
  String get tabShopping => 'Compra';
  @override
  String get tabMore => 'Más';

  // ======================= TUTORIAL =======================

  @override
  String get onbLanguageTitle => 'Elige tu idioma';
  @override
  String get onbLanguageBody =>
      'Puedes cambiarlo cuando quieras desde Ajustes.';
  @override
  String get onbLanguageContinue => 'Continuar';

  @override
  String get onbWelcomeTitle => 'Bienvenido a Meal Planner';
  @override
  String get onbWelcomeBody =>
      'Decide qué comes esta semana, deja que la lista de la compra se escriba '
      'sola y apunta lo que comes de verdad. Este repaso dura medio minuto.';

  @override
  String get onbPlannerTitle => 'Planifica tu semana';
  @override
  String get onbPlannerBody =>
      'Una rejilla con tus siete días. Toca una toma para elegir plato, o pulsa '
      '"Randomizar" y deja que la app te llene la semana. Arrastra un plato '
      'para moverlo de día, bloquea los días que ya tengas resueltos y marca '
      'los que comes fuera.';

  @override
  String get onbMealsTitle => 'Tus comidas';
  @override
  String get onbMealsBody =>
      'Este es tu catálogo de platos. Los añades a mano, escaneando un código '
      'de barras o partiendo de las comidas de ejemplo. Cada plato guarda sus '
      'ingredientes, y de ahí sale la lista de la compra.';

  @override
  String get onbShoppingTitle => 'La compra se escribe sola';
  @override
  String get onbShoppingBody =>
      'Junta los ingredientes de todo lo que has planificado, los agrupa por '
      'pasillo del súper y suma cantidades. Ve marcando lo que echas al carro, '
      'y activa el modo de letra grande para el supermercado.';

  @override
  String get onbTodayTitle => 'Apunta lo que comes';
  @override
  String get onbTodayBody =>
      'En la pestaña Hoy marcas las comidas que tenías planificadas o añades '
      'cualquier otra cosa. También puedes apuntar tu peso, el agua y una nota '
      'del día.';

  @override
  String get onbGymTitle => 'Modo Gym (opcional)';
  @override
  String get onbGymBody =>
      'Si entrenas, actívalo en Más › Modo Gym. Le dices tu objetivo y él '
      'calcula tus calorías y tu proteína del día, y luego te enseña cómo vas. '
      'Si no te interesa, déjalo apagado: no cambia nada.';

  @override
  String get onbReadyTitle => 'Y ya está';
  @override
  String get onbReadyBody =>
      'Lo mejor para empezar: añade unas cuantas comidas de las de ejemplo y '
      'pulsa "Randomizar" en la pestaña Semana. Puedes volver a ver este '
      'tutorial cuando quieras desde Ajustes.';

  @override
  String get onbSkip => 'Saltar';
  @override
  String get onbNext => 'Siguiente';
  @override
  String get onbBack => 'Atrás';
  @override
  String get onbStart => 'Empezar';

  // ======================= AJUSTES =======================

  @override
  String get settingsTitle => 'Ajustes';
  @override
  String get sectionLanguage => 'Idioma';
  @override
  String get sectionAppearance => 'Apariencia';
  @override
  String get sectionColorTheme => 'Tema de color';
  @override
  String get sectionOnOpen => 'Al abrir la app';
  @override
  String get sectionAi => 'Asistente de IA (Gemini)';
  @override
  String get sectionBackup => 'Copia de seguridad';
  @override
  String get sectionHelp => 'Ayuda';
  @override
  String get sectionAbout => 'Acerca de';

  @override
  String get languageSubtitle => 'Cambia el idioma de toda la app';

  @override
  String get modeSystem => 'Sistema';
  @override
  String get modeLight => 'Claro';
  @override
  String get modeDark => 'Oscuro';

  @override
  String get amoledTitle => 'Negro AMOLED';
  @override
  String get amoledSubtitle => 'Fondos negros puros en modo oscuro';

  @override
  String get colorIntensity => 'Intensidad del color';
  @override
  List<String> get intensityLabels => const [
    'Suave',
    'Equilibrado',
    'Vivo',
    'Intenso',
  ];

  @override
  String get startTabAuto => 'Automática';

  @override
  String get replayTutorialTitle => 'Ver el tutorial otra vez';
  @override
  String get replayTutorialSubtitle =>
      'El repaso de bienvenida, desde el principio';

  @override
  String get aboutSubtitle => 'Versión 2.0 · Hecho con Flutter';

  @override
  String get backupIntro =>
      'Guarda TODO (platos, semanas, despensa y registro) en un archivo. '
      'La clave de la IA no se incluye por seguridad.';
  @override
  String get exportBackup => 'Exportar copia de seguridad';
  @override
  String get exportBackupSubtitle => 'Comparte o guarda el archivo .json';
  @override
  String get restoreBackup => 'Restaurar copia';
  @override
  String get restoreBackupSubtitle => 'Sustituye los datos actuales';
  @override
  String get backupShareSubject => 'Copia de seguridad de Meal Planner';
  @override
  String get restoreConfirmBody =>
      'Esto sustituirá tus platos, semanas, despensa y registro por los '
      'de la copia. Al terminar hay que reiniciar la app.\n\n'
      '¿Seguro que quieres continuar?';
  @override
  String get restore => 'Restaurar';
  @override
  String get backupRestored =>
      'Copia restaurada. Cierra y vuelve a abrir la app para verla.';

  @override
  String get aiIntro =>
      'Con tu clave gratuita de Google Gemini puedes estimar las macros '
      'de un plato por texto o por foto. Consíguela en '
      'aistudio.google.com/apikey';
  @override
  String get apiKeyLabel => 'Clave de API';
  @override
  String get modelLabel => 'Modelo';
  @override
  String modelHelper(String model) => 'Por defecto: $model';
  @override
  String get aiEnabled => 'IA activada: ya puedes estimar con foto o texto.';
  @override
  String get aiDisabled => 'Sin clave: la estimación con IA está desactivada.';

  // ======================= "MÁS" =======================

  @override
  String get moreTitle => 'Más';
  @override
  String get statDishes => 'platos';
  @override
  String get statWeeks => 'semanas';
  @override
  String get statStreak => 'de racha';

  @override
  String get sectionYourFood => 'Tu comida';
  @override
  String get addMealTitle => 'Añadir comida';
  @override
  String get addMealSubtitle => 'Crea un plato nuevo para tu catálogo';
  @override
  String get myIngredientsTitle => 'Mis ingredientes';
  @override
  String get myIngredientsSubtitle => 'Despensa con medidas caseras y stock';
  @override
  String get giveIdeasTitle => 'Dame ideas';
  @override
  String get giveIdeasSubtitle => 'Que la IA te proponga platos nuevos';
  @override
  String get rouletteTitle => 'Ruleta de la cena';
  @override
  String get rouletteSubtitle => 'Para cuando no quieres ni decidir';

  @override
  String get sectionProgress => 'Progreso';
  @override
  String get statsTitle => 'Estadísticas';
  @override
  String get statsSubtitle => 'Medias, racha, peso y días cumplidos';
  @override
  String get gymModeTitle => 'Modo Gym';
  @override
  String gymModeActive(String goal) => 'Activo · $goal';
  @override
  String get gymModeNoGoal => 'sin objetivo';
  @override
  String get gymModeSubtitle => 'Objetivos de calorías y proteína';

  @override
  String get sectionApp => 'Aplicación';
  @override
  String get settingsSubtitle => 'Tema, idioma, IA, copia de seguridad';

  // ======================= HOY / REGISTRO =======================

  @override
  String get todayScreenTitle => 'Registro';
  @override
  String get today => 'Hoy';
  @override
  String get yesterday => 'Ayer';
  @override
  String get chooseDay => 'Elige el día';
  @override
  String get previousDay => 'Día anterior';
  @override
  String get nextDay => 'Día siguiente';

  @override
  String get menuCopyYesterday => 'Copiar el día de ayer';
  @override
  String get menuDayNote => 'Nota del día';
  @override
  String get menuWhatFits => '¿Qué me cabe con lo que queda?';
  @override
  String get menuRoulette => 'Ruleta de la cena';
  @override
  String get menuClearDay => 'Vaciar este día';

  @override
  String get whatYouveHad => 'Lo que llevas';
  @override
  String get nothingLoggedYet =>
      'Nada registrado todavía. Marca las comidas del plan de arriba '
      'o pulsa "Añadir".';
  @override
  String get otherSlot => 'Otros';

  @override
  String get adjustAmount => 'Ajustar cantidad';
  @override
  String howMuchOf(String dish) => '¿Cuánto has comido de $dish?';
  @override
  String get oneServing => '1 ración';
  @override
  String servingsCount(String amount) => '$amount raciones';
  @override
  String removedItem(String name) => 'Quitado: $name';

  @override
  String get needTargetForFits =>
      'Configura tu objetivo en el Modo Gym para usar esto';
  @override
  String get alreadyOverToday => 'Ya te has pasado del objetivo de hoy.';
  @override
  String kcalLeftFits(int left) =>
      'Te quedan $left kcal. Esto es lo que te cabe, de más a menos proteína:';
  @override
  String get nothingFitsCatalog => 'No hay nada de tu catálogo que entre.';

  @override
  String get yesterdayWasEmpty => 'Ayer no hay nada registrado';
  @override
  String copiedMeals(int n) => 'Copiadas $n comidas de ayer';
  @override
  String get dayAlreadyEmpty => 'Este día ya está vacío';
  @override
  String get dayCleared => 'Día vaciado';

  @override
  String get weightToday => 'Peso de hoy';
  @override
  String get weight => 'Peso';
  @override
  String get logWeight => 'Apuntar peso';
  @override
  String get weightSubtitle => 'Se usa para tu gráfica de progreso';

  @override
  String get noteHint => 'Entrené piernas, cena fuera…';

  @override
  String get manualEntry => 'Entrada manual';
  @override
  String get manualEntrySubtitle => 'Escribe nombre, calorías y proteína';
  @override
  String get searchYourMeals => 'Buscar en tus comidas';
  @override
  String get noResultsUseManual => 'Sin resultados. Usa la entrada manual.';
  @override
  String get noMacrosLoggedAsZero => 'Sin macros (se registra como 0)';
  @override
  String get youEatThisOften => 'Lo comes a menudo';
  @override
  String addedItem(String name) => 'Añadido: $name';

  @override
  String get plannedForThisDay => 'Lo que tenías planificado';
  @override
  String get nothingPlannedThisDay => 'No hay nada planificado para este día.';

  @override
  String hadKcalAndProtein(int kcal, int protein) =>
      'Llevas $kcal kcal y $protein g de proteína.';
  @override
  String get setUpGymProfile =>
      'Configura tu perfil en el Modo Gym para ver tus objetivos.';
  @override
  String kcalLeft(int n) => 'Te quedan $n kcal';
  @override
  String kcalOver(int n) => 'Te has pasado $n kcal';
  @override
  String get proteinMet => 'Proteína cumplida';
  @override
  String streakBadge(int days) =>
      days == 1 ? 'Racha de 1 día' : 'Racha de $days días';
  @override
  String ofTarget(int target) => 'de $target';

  @override
  String get water => 'Agua';
  @override
  String waterGlasses(int n) => n == 1 ? '1 vaso de agua' : '$n vasos de agua';

  // ======================= PLANIFICADOR =======================

  @override
  String get plannerTitle => 'Planificador';
  @override
  String get viewNormal => 'Vista normal';
  @override
  String get viewCompact => 'Vista compacta';

  @override
  String get menuGoToThisWeek => 'Ir a la semana de hoy';
  @override
  String get menuWeekDate => 'Fecha de esta semana';
  @override
  String get menuDuplicateWeek => 'Duplicar semana';
  @override
  String get menuImportWeek => 'Importar semana';
  @override
  String get menuExportWeek => 'Exportar semana';
  @override
  String get menuShareAsText => 'Compartir como texto';

  @override
  String get randomize => 'Randomizar';
  @override
  String get howToRandomize => 'Cómo randomizar';
  @override
  String get onlyFillGaps => 'Solo rellenar huecos';
  @override
  String get onlyFillGapsSubtitle => 'No toca lo que ya has puesto';
  @override
  String get useLeftovers => 'Aprovechar sobras';
  @override
  String get useLeftoversSubtitle =>
      'Los platos que dan varias raciones repiten en la toma siguiente';
  @override
  String get onlyDishesWithMacros => 'Solo platos con macros';
  @override
  String get aimForMyCalories => 'Ajustar a mis calorías';
  @override
  String get aimForMyCaloriesSubtitle =>
      'Intenta que cada día caiga cerca de tu objetivo';
  @override
  String busyDaysMarked(int n) => n == 1
      ? '1 día marcado como "voy con prisa"'
      : '$n días marcados como "voy con prisa"';
  @override
  String get busyDaysSubtitle => 'Solo se les asignan platos rápidos';
  @override
  String get randomizerOptions => 'Opciones del randomizador';

  @override
  String get weekDuplicated => 'Semana duplicada';
  @override
  String get weekDuplicateFailed => 'No se pudo duplicar (máximo de semanas)';
  @override
  String get noWeekIsToday =>
      'Ninguna semana está puesta en la fecha de hoy. Usa "Fecha de esta semana".';
  @override
  String get pickAnyDayOfWeek => 'Elige cualquier día de esa semana';
  @override
  String get noMealsToExport => 'No hay comidas para exportar';
  @override
  String get weekShareSubject => 'Planificador semanal';
  @override
  String get weekMenuSubject => 'Menú de la semana';
  @override
  String importedIntoWeek(int n) => 'Planificador importado en semana $n';

  @override
  String get addWeek => 'Añadir semana';
  @override
  String get deleteCurrentWeek => 'Eliminar semana actual';
  @override
  String get deleteWeekTitle => 'Eliminar semana';
  @override
  String deleteWeekBody(String label) =>
      'Se borrará el plan de "$label". ¿Seguro?';
  @override
  String maxWeeks(int n) => 'Máximo de $n semanas';
  @override
  String get cannotDeleteOnlyWeek => 'No puedes eliminar la única semana';

  @override
  String get todayBadge => 'HOY';
  @override
  String get dayOptions => 'Opciones del día';
  @override
  String get unlockDay => 'Desbloquear día';
  @override
  String get lockDay => 'Bloquear día';
  @override
  String get clearBusyDay => 'Quitar "voy con prisa"';
  @override
  String get markBusyDay => 'Voy con prisa (platos rápidos)';
  @override
  String get eatingInAgain => 'Vuelvo a comer en casa';
  @override
  String get eatingOutThisDay => 'Este día como fuera';
  @override
  String get clearDay => 'Vaciar día';
  @override
  String get eatingOutNotice =>
      'Comes fuera: no se planifica ni entra en la compra.';
  @override
  String dayClearedNamed(String day) => '$day vaciado';

  @override
  String get tapToChoose => 'Toca para elegir';
  @override
  String get addToMyCatalog => 'Añadir a mi catálogo';
  @override
  String addedToCatalog(String name) => 'Añadido a tu catálogo: $name';
  @override
  String get shuffleThisOne => 'Cambiar al azar';
  @override
  String get dayIsLocked => 'Ese día está bloqueado. Desbloquéalo primero.';
  @override
  String get searchDishOrIngredient => 'Buscar plato o ingrediente';
  @override
  String get clearThisMeal => 'Vaciar esta comida';
  @override
  String get awayShort => 'Fuera';

  @override
  String weekNumber(int n) => 'Semana $n';
  @override
  String get thisWeek => 'Esta semana';

  // ======================= MIS COMIDAS =======================

  @override
  String get myMealsTitle => 'Mis comidas';
  @override
  String get scanProduct => 'Escanear producto';
  @override
  String get scanProductSubtitle =>
      'Rellena los datos desde el código de barras';
  @override
  String get addByHand => 'Añadir a mano';
  @override
  String get addByHandSubtitle => 'Para comida fresca o sin código';
  @override
  String get exampleMeals => 'Comidas de ejemplo';
  @override
  String get sort => 'Ordenar';
  @override
  String get sortNameAsc => 'Nombre (A-Z)';
  @override
  String get sortNameDesc => 'Nombre (Z-A)';
  @override
  String get sortMostUsed => 'Más usados';
  @override
  String get searchByNameOrIngredient => 'Buscar por nombre o ingrediente';
  @override
  String get canCookNow => 'Puedo cocinarlo ya';
  @override
  String get withMacros => 'Con macros';
  @override
  String get withoutMacros => 'Sin macros';
  @override
  String get noSearchResults => 'Sin resultados para tu búsqueda.';

  @override
  String ingredientCount(int n) => n == 1 ? '1 ingrediente' : '$n ingredientes';
  @override
  String servingsMadeCount(int n) => n == 1 ? '1 ración' : '$n raciones';
  @override
  String get highInProtein => 'Alto en proteína';

  @override
  String get unfavourite => 'Quitar de favoritos';
  @override
  String get markFavourite => 'Marcar favorito';
  @override
  String get proposeAgain => 'Volver a proponerlo';
  @override
  String get notInTheMood => 'No me apetece (2 semanas)';
  @override
  String get duplicate => 'Duplicar';
  @override
  String get copySuffix => 'copia';
  @override
  String snoozedMessage(String name) =>
      '"$name" no saldrá al azar en 2 semanas';
  @override
  String get deleteMealTitle => 'Eliminar comida';
  @override
  String deleteMealBody(String name) => '¿Seguro que quieres eliminar "$name"?';
  @override
  String deletedItem(String name) => 'Eliminado: $name';

  @override
  String get noMealsYet => 'Aún no tienes comidas';
  @override
  String get noMealsYetSubtitle =>
      'Empieza con nuestras comidas de ejemplo o crea las tuyas.';
  @override
  String get seeExampleMeals => 'Ver comidas de ejemplo';

  // ======================= LISTA DE LA COMPRA =======================

  @override
  String get shoppingListTitle => 'Lista de compra';
  @override
  String get superMarketMode => 'Modo súper (letra grande)';
  @override
  String get checkAll => 'Marcar todo';
  @override
  String get uncheckAll => 'Desmarcar todo';
  @override
  String get showBought => 'Mostrar lo comprado';
  @override
  String get hideBought => 'Ocultar lo comprado';
  @override
  String get shareList => 'Compartir lista';
  @override
  String get copyToClipboard => 'Copiar al portapapeles';
  @override
  String get recurringItems => 'Ítems de siempre';
  @override
  String get listCopied => 'Lista copiada';
  @override
  String get shoppingShareSubject => 'Lista de la compra';
  @override
  String get recurringItemsBody =>
      'Añádelos a la lista de esta semana con un toque.';
  @override
  String get addToListTitle => 'Añadir a la lista';
  @override
  String get ingredientOrProduct => 'Ingrediente o producto';
  @override
  String get listComplete => '¡Lista completa!';
  @override
  String inCart(int done, int total) => '$done de $total en el carro';
  @override
  String get addedByHand => 'Añadido a mano';
  @override
  String get emptyListTitle => 'La lista está vacía';
  @override
  String get emptyListSubtitle =>
      'Planifica comidas en esta semana o añade ítems con el botón "Añadir".';

  @override
  List<String> get recurringItemsList => const [
    'Papel de cocina',
    'Papel higiénico',
    'Café',
    'Leche',
    'Pan',
    'Aceite de oliva',
    'Sal',
    'Bolsas de basura',
    'Detergente',
    'Huevos',
    'Agua',
    'Fruta variada',
  ];

  // ======================= AÑADIR / EDITAR COMIDA =======================

  @override
  String get editMeal => 'Editar comida';
  @override
  String get addMeal => 'Añadir comida';
  @override
  String prefillNotice(String origin) =>
      '$origin. Revísalo y ajústalo antes de guardar.';
  @override
  String get mealNameLabel => 'Nombre de la comida';
  @override
  String get favourite => 'Favorito';
  @override
  String get photo => 'Foto';
  @override
  String get takePhoto => 'Hacer una foto';
  @override
  String get chooseFromGallery => 'Elegir de la galería';
  @override
  String get removePhoto => 'Quitar la foto';

  @override
  String get ingredientsTitle => 'Ingredientes';
  @override
  String get scan => 'Escanear';
  @override
  String get searchIngredient => 'Buscar ingrediente';
  @override
  String get byHand => 'A mano';
  @override
  String get ingredientsTextLabel => 'Ingredientes (texto)';
  @override
  String get ingredientsTextHelper =>
      'Sepáralos con comas: tomate, pasta, queso';
  @override
  String get nutritionPerServing => 'Datos nutricionales (por ración)';
  @override
  String get estimateWithAi => 'Estimar con IA';
  @override
  String totalLine(int kcal, int protein) =>
      'Total: $kcal kcal · $protein g proteína';

  @override
  String get whichSlots => '¿En qué tomas encaja?';
  @override
  String get ifNoneAllApply => 'Si no marcas ninguna, valdrá para todas.';
  @override
  String get tagsTitle => 'Etiquetas';
  @override
  String get tagsHelp => 'Sirven para que la semana no salga toda de pasta.';

  @override
  String get detailsTitle => 'Detalles';
  @override
  String get prepTime => 'Tiempo';
  @override
  String get costPerServing => 'Coste/ración';
  @override
  String get servingsMadeTitle => 'Raciones que salen';
  @override
  String servingsMadeMulti(int n) => 'Cocinas una vez y comes $n veces';
  @override
  String get servingsMadeOne => 'Se cocina para una toma';
  @override
  String get recipeOrNotes => 'Receta o notas';
  @override
  String get recipeOrNotesHelper => 'Pasos, trucos, un enlace…';

  @override
  String get pleaseCompleteName => 'Por favor, completa el nombre';
  @override
  String get pleaseCompleteNameAndIngredients =>
      'Por favor, completa el nombre y los ingredientes';
  @override
  String renamedTo(String name) =>
      'Renombrado a "$name" (también en tus semanas)';
  @override
  String get mealUpdated => 'Comida actualizada';
  @override
  String get mealAdded => 'Comida añadida';
  @override
  String get aiMacrosFilled =>
      'Macros estimadas con IA. Revísalas antes de guardar.';

  @override
  String get addIngredientTitle => 'Añadir ingrediente';
  @override
  String get editIngredientTitle => 'Editar ingrediente';
  @override
  String get kcalPerUnit => 'kcal/ud';
  @override
  String get proteinPerUnit => 'prot/ud';

  // ======================= DESPENSA =======================

  @override
  String get pantryTitle => 'Mis ingredientes';
  @override
  String get restoreDeleted => 'Recuperar los borrados';
  @override
  String get presetsRestored => 'Recuperados los ingredientes de la app';
  @override
  String get tabFromApp => 'De la app';
  @override
  String get tabMine => 'Míos';
  @override
  String get searchIngredientHint => 'Buscar ingrediente';
  @override
  String addedToMine(String name) => '“$name” añadido a “Míos”';
  @override
  String get pantryEmptyMine =>
      'Aún no has añadido ingredientes.\nEscanea un producto o pulsa "Añadir".';

  @override
  String haveInStock(String amount) => 'tengo $amount';
  @override
  String useSoonExpires(int days) =>
      days == 1 ? '¡Gástalo! Caduca mañana' : '¡Gástalo! Caduca en $days días';
  @override
  String expiresInDays(int days) => 'Caduca en $days días';

  @override
  String get newIngredient => 'Nuevo ingrediente';
  @override
  String get unitLabel => 'Unidad';
  @override
  String get unitHint => 'loncha, filete…';
  @override
  String get gramsPerUnitShort => 'g/ud';
  @override
  String get unitTip =>
      'Truco: el paquete suele decir los gramos '
      '(p. ej. "10 lonchas · 200 g" → 20 g por loncha).';
  @override
  String get unitTipRecalc =>
      ' Las macros se recalculan solas al cambiar los gramos.';
  @override
  String get categoryLabel => 'Categoría';
  @override
  String get repeatQuestion => '¿Se puede repetir a menudo?';
  @override
  String get haveAtHomeQuestion => '¿Tienes en casa?';
  @override
  String stockHelper(String unit) => 'En $unit';
  @override
  String get unitsFallback => 'unidades';
  @override
  String get expiryDate => 'Fecha de caducidad';
  @override
  String get expiryShort => 'Caducidad';
  @override
  String get removeExpiry => 'Quitar caducidad';

  // ======================= SELECTOR DE PORCIÓN =======================

  @override
  String get units => 'Unidades';
  @override
  String get grams => 'Gramos';
  @override
  String get productHasNoMacros =>
      'Este producto no trae macros. Añádelas a mano.';
  @override
  String get saveToMyIngredients => 'Guardar en Mis ingredientes';
  @override
  String get whichMeasure => '¿En qué medida?';
  @override
  String get howMany => '¿Cuántas?';
  @override
  String gramsPer(String unit) => 'g por $unit';
  @override
  String get howManyGrams => '¿Cuántos gramos?';
  @override
  String get howManyServings => '¿Cuántas raciones?';
  @override
  String oneServingIs(String size) => '1 ración = $size';
  @override
  String get proteinGramsShort => 'proteína (g)';

  // ======================= MODO GYM =======================

  @override
  String get gymIntro =>
      'Activa el Modo Gym para planificar tus comidas según tu '
      'objetivo (volumen, definición…) sin liarte con tecnicismos.';
  @override
  String get enableGymMode => 'Activar Modo Gym';
  @override
  String get enableGymModeSubtitle =>
      'Muestra las opciones de seguimiento para el gimnasio';
  @override
  String get yourGoal => 'Tu objetivo';
  @override
  String get yourGoalSubtitle =>
      'Elige qué quieres conseguir. Sin tecnicismos.';
  @override
  String get yourTargets => 'Tus objetivos';
  @override
  String estimatedExpenditure(int kcal) => 'Gasto estimado: $kcal kcal/día';
  @override
  String get setYourOwnFigures =>
      'Pon tus propias cifras de calorías y proteína.';
  @override
  String get completeProfileToCalculate =>
      'Completa tu perfil para calcular tus objetivos.';
  @override
  String get adjustFigures => 'Ajustar cifras';
  @override
  String get editProfile => 'Editar perfil';
  @override
  String get completeProfile => 'Completar perfil';
  @override
  String get yourFigures => 'Tus cifras';
  @override
  String get todaysLog => 'Registro de hoy';
  @override
  String get todaysLogSubtitle => 'Apunta lo que comes y sigue tu progreso';
  @override
  String get mealsPerDay => 'Comidas del día';
  @override
  String get mealsPerDaySubtitle => 'Elige cuántas tomas planificas cada día.';
  @override
  String daysInARow(int days) =>
      days == 1 ? '1 día seguido' : '$days días seguidos';
  @override
  String get noStreakYet => 'Sin racha todavía';
  @override
  String get setTargetToCount => 'Pon tu objetivo para empezar a contar.';
  @override
  String get logToStartStreak => 'Registra lo que comes y empieza la racha.';
  @override
  String last7Days(int met, int days) =>
      'Últimos 7 días: proteína cumplida $met de $days.';

  // ======================= PERFIL GYM =======================

  @override
  String get yourProfile => 'Tu perfil';
  @override
  String get profileIntro =>
      'Con estos datos calculamos tus objetivos. Quedan guardados y los '
      'puedes cambiar cuando quieras.';
  @override
  String get height => 'Altura';
  @override
  String get age => 'Edad';
  @override
  String get years => 'años';
  @override
  String get sexTitle => 'Sexo';
  @override
  String get sexNote => 'Solo se usa para el cálculo del gasto calórico.';
  @override
  String get activityLevel => 'Nivel de actividad';
  @override
  String get fillToSeeTargets =>
      'Rellena peso, altura y edad para ver tus objetivos.';
  @override
  String targetsForGoal(String goal) => 'Tus objetivos · $goal';
  @override
  String get customFiguresNote =>
      'En "Personalizado" podrás ajustar estas cifras a mano.';
  @override
  String get saveProfile => 'Guardar perfil';
  @override
  String get profileSaved => 'Perfil guardado';
  @override
  String get checkProfileData =>
      'Revisa los datos: peso, altura y edad válidos';

  // ======================= ESTADÍSTICAS =======================

  @override
  String get statisticsTitle => 'Estadísticas';
  @override
  String get exportCsv => 'Exportar registro (CSV)';
  @override
  String get csvSubject => 'Mi registro de comidas';
  @override
  String daysRange(int n) => '$n días';
  @override
  String get avgPerDay => 'Media al día';
  @override
  String get avgProtein => 'Proteína media';
  @override
  String get daysMeetingProtein => 'Días cumpliendo proteína';
  @override
  String get currentStreak => 'Racha actual';
  @override
  String get daysUnit => 'días';

  @override
  String get yourWeight => 'Tu peso';
  @override
  String get weightNeedsTwoDays =>
      'Apunta tu peso al menos dos días en la pantalla de registro '
      'para ver la gráfica y la tendencia.';
  @override
  String get sevenDayAverage => 'Media de 7 días';

  @override
  String get achievementsTitle => 'Logros';
  @override
  String achievementsUnlocked(int unlocked, int total) =>
      '$unlocked de $total conseguidos';

  @override
  String get whatYouEatMost => 'Lo que más comes';
  @override
  String get nothingPlannedYet => 'Todavía no has planificado nada.';
  @override
  String timesInYourWeeks(int n) =>
      n == 1 ? '1 vez en tus semanas' : '$n veces en tus semanas';

  @override
  String get verdictNoTarget =>
      'Configura tu objetivo en el Modo Gym para saber si vas bien.';
  @override
  String get verdictNoData => 'Aún no hay datos suficientes.';
  @override
  String get verdictGreat =>
      'Muy bien: cumples la proteína casi todos los días.';
  @override
  String get verdictOk =>
      'Vas bien, pero se te escapan bastantes días. '
      'Prueba a meter una toma de proteína a media tarde.';
  @override
  String get verdictLow =>
      'Te quedas corto de proteína la mayoría de días. '
      'Añade platos "alto en proteína" a tu catálogo.';
  @override
  String adjustToKcal(int kcal) => 'Ajustar a $kcal kcal';
  @override
  String targetAdjusted(int kcal) => 'Objetivo ajustado a $kcal kcal';
  @override
  String get noLogsInPeriod =>
      'Todavía no hay registros en este periodo.\n'
      'Apunta lo que comes en la pestaña "Hoy" y aquí verás tus medias.';

  @override
  Map<String, (String, String)> get achievements => const {
    'cocinero': ('Cocinero', 'Crea 10 platos en tu catálogo'),
    'chef': ('Chef', 'Llega a 50 platos'),
    'constante': ('Constante', 'Registra 7 días'),
    'veterano': ('Veterano', 'Registra 100 días'),
    'racha7': ('Una semana clavada', '7 días seguidos cumpliendo proteína'),
    'racha30': ('Imparable', '30 días seguidos de proteína'),
    'planificador': ('Planificador', 'Planifica 4 semanas'),
    'fotografo': ('Fotógrafo', 'Ponle foto a 5 platos'),
    'proteico': ('Objetivo cumplido', 'Cumple la proteína 30 días en total'),
    'semanaperfecta': (
      'Semana perfecta',
      'Una semana entera planificada al completo',
    ),
  };

  // ======================= IA: ESTIMAR =======================

  @override
  String get aiEstimateTitle => 'Estimar con IA';
  @override
  String get aiEstimateIntro =>
      'Describe lo que has comido y/o añade una foto. La IA estima '
      'las calorías y la proteína (aproximado).';
  @override
  String get descriptionLabel => 'Descripción';
  @override
  String get descriptionHint =>
      'Ej: plato de macarrones con atún, ración normal';
  @override
  String get gallery => 'Galería';
  @override
  String get photoAdded => 'Foto añadida';
  @override
  String get estimating => 'Estimando…';
  @override
  String get estimateMacros => 'Estimar macros';
  @override
  String get resultAdjustIt => 'Resultado (ajústalo si quieres)';
  @override
  String get useThisData => 'Usar estos datos';
  @override
  String get couldNotOpenImage => 'No se pudo abrir la imagen.';
  @override
  String get missingGeminiKey => 'Falta tu clave de Gemini';
  @override
  String get missingGeminiKeyBody =>
      'Para usar la estimación con IA, añade tu clave de API gratuita '
      'de Google Gemini en Ajustes.';
  @override
  String get goToSettings => 'Ir a Ajustes';

  // ======================= IA: IDEAS =======================

  @override
  String get whatDoYouFancy => '¿Qué te apetece?';
  @override
  String get whatDoYouFancyHint => 'Cenas rápidas y con proteína, sin pescado…';
  @override
  String get usePantry => 'Usar mi despensa';
  @override
  String get usePantrySubtitle => 'Prioriza ingredientes que ya tienes en casa';
  @override
  String get thinking => 'Pensando…';
  @override
  String get proposeDishes => 'Proponer platos';
  @override
  String get proposals => 'Propuestas';
  @override
  String get proposalsDisclaimer =>
      'Son estimaciones: revísalas antes de fiarte de las macros.';
  @override
  String get writeWhatYouWant => 'Escribe qué tipo de platos quieres.';
  @override
  String get aiSuggestNotConfigured =>
      'Para que la IA te proponga platos necesitas poner tu clave '
      'gratuita de Gemini en Ajustes.';

  @override
  List<String> get ideaPresets => const [
    'Cenas ligeras de menos de 400 kcal',
    'Comidas altas en proteína para después del gym',
    'Platos baratos y que rindan mucho',
    'Desayunos rápidos de menos de 10 minutos',
    'Recetas de aprovechamiento con lo que tengo',
  ];

  // ======================= BUSCAR INGREDIENTE =======================

  @override
  String get searchIngredientTitle => 'Buscar ingrediente';
  @override
  String get searchIngredientPlaceholder => 'Buscar (pollo, arroz, huevo…)';
  @override
  String get noResultsTryAnother => 'Sin resultados. Prueba con otra palabra.';
  @override
  String get otherQuantity => 'Otra cantidad';
  @override
  String howManyUnits(String unit) => '¿Cuántas $unit?';
  @override
  String oneUnitIs(String unit, int kcal, int protein) =>
      '1 $unit = $kcal kcal · $protein g';

  // ======================= RULETA =======================

  @override
  String rouletteFor(String slot) => 'Ruleta · $slot';
  @override
  String get whatsForDinner => '¿Qué ceno?';
  @override
  String get onlyWithWhatIHave => 'Solo con lo que tengo en casa';
  @override
  String get spin => '¡Girar!';
  @override
  String get spinAgain => 'Otra vez';
  @override
  String get putItInThePlan => 'Ponerlo en el plan';
  @override
  String noDishesFor(String slot) => 'No tienes platos para $slot';
  @override
  String assignedTo(String dish, String day, String slot) =>
      '$dish → $day, $slot';

  // ======================= ESCÁNER =======================

  @override
  String get scanProductTitle => 'Escanear producto';
  @override
  String get scanIngredientTitle => 'Escanear ingrediente';
  @override
  String get switchCamera => 'Cambiar cámara';
  @override
  String get flash => 'Flash';
  @override
  String get aimAtBarcode =>
      'Apunta al código de barras del producto (también lee QR)';
  @override
  String get searchingProduct => 'Buscando producto…';
  @override
  String get productNotFoundTitle => 'Producto no encontrado';
  @override
  String productNotFoundBody(String code) =>
      'No hay datos para el código $code. Puedes añadirlo a mano.';
  @override
  String get keepScanning => 'Seguir escaneando';
  @override
  String scannedProductNote(String basis) =>
      'Producto escaneado (OpenFoodFacts · $basis)';
  @override
  String get basisPerServing => 'por ración';
  @override
  String get basisPer100g => 'por 100 g';
  @override
  String get basisNoData => 'sin datos';
  @override
  String unknownProduct(String barcode) => 'Producto $barcode';

  // ======================= COMIDAS DE EJEMPLO =======================

  @override
  String get exampleMealsTitle => 'Comidas de ejemplo';
  @override
  String get selectAll => 'Todo';
  @override
  String get unselectAll => 'Quitar todo';
  @override
  String get alreadyInCatalog => 'Ya en tu catálogo';
  @override
  String get selectMeals => 'Selecciona comidas';
  @override
  String addNMeals(int n) => n == 1 ? 'Añadir 1 comida' : 'Añadir $n comidas';
  @override
  String addedNMeals(int n) => n == 1
      ? 'Añadida 1 comida a tu catálogo'
      : 'Añadidas $n comidas a tu catálogo';
  @override
  String get presetNotice =>
      'Son orientativas y editables: añade la que te sirva de base y '
      'ajusta luego ingredientes o macros a tu gusto.';

  // ======================= MENSAJES DEL PROVIDER =======================

  @override
  String get noMealsToAssign => 'No hay comidas para asignar';
  @override
  String get noSlotsConfigured => 'No hay tomas configuradas';
  @override
  String noMealsWithMacrosFor(String slot) =>
      'No hay comidas con macros para $slot';
  @override
  String noMealsFor(String slot) => 'No hay comidas para $slot';
  @override
  String maxWeeksReached(int n) => 'Máximo de $n semanas alcanzado';
  @override
  String importError(Object e) => 'Error al importar: $e';
  @override
  String get weekTextHeader => 'Menú de la semana';
  @override
  String get outOfHome => 'fuera de casa';
  @override
  String get shoppingTextHeader => 'Lista de la compra';
  @override
  String get shoppingListIsEmpty => 'La lista está vacía.';
  @override
  String get unitAbbrev => 'ud';

  // ======================= COPIA DE SEGURIDAD =======================

  @override
  String get backupInvalidFile => 'El archivo no es una copia válida.';
  @override
  String get backupCorrupt => 'La copia está vacía o dañada.';
  @override
  String get backupNothingRestored => 'No se pudo restaurar nada de esa copia.';

  // ======================= GEMINI =======================

  @override
  String get geminiMissingKey =>
      'Falta la clave de API de Gemini. Añádela en Ajustes.';
  @override
  String get geminiNeedTextOrPhoto =>
      'Escribe una descripción o añade una foto del plato.';
  @override
  String get geminiBadKey =>
      'La clave de API no es válida o la petición fue rechazada.';
  @override
  String get geminiForbidden =>
      'Clave de API sin permiso. Revisa que la copiaste bien.';
  @override
  String get geminiModelNotFound =>
      'Modelo no encontrado. Revisa el nombre del modelo en Ajustes.';
  @override
  String get geminiRateLimit =>
      'Has superado el límite de peticiones. Prueba en un momento.';
  @override
  String geminiError(int code) => 'Error de Gemini (código $code).';
  @override
  String get geminiNoConnection =>
      'No se pudo conectar con Gemini. Revisa tu conexión.';
  @override
  String get geminiUnreadable => 'Respuesta de Gemini ilegible.';
  @override
  String get geminiNothingUseful => 'Gemini no devolvió datos utilizables.';
  @override
  String get geminiNoEstimate =>
      'Gemini no devolvió ninguna estimación. Prueba a describirlo mejor.';
  @override
  String get geminiParseFail => 'No se entendió la estimación de Gemini.';
  @override
  String get geminiCouldNotEstimate =>
      'La IA no pudo estimar las macros. Prueba con más detalle.';
  @override
  String get geminiSuggestionsParseFail => 'No se entendieron las propuestas.';
  @override
  String get geminiNoSuggestions => 'La IA no propuso ningún plato.';

  // ======================= AJUSTE DE CALORÍAS =======================

  @override
  String get gymNotGaining =>
      'No estás subiendo de peso: prueba a comer 150 kcal más.';
  @override
  String get gymGainingTooFast => 'Estás subiendo muy rápido: baja 150 kcal.';
  @override
  String get gymNotLosing => 'No estás bajando: prueba con 150 kcal menos.';
  @override
  String get gymLosingTooFast =>
      'Estás bajando demasiado rápido: sube 150 kcal.';

  // ======================= INTERFAZ LIMPIA =======================

  @override
  String get sectionInterface => 'Interfaz';
  @override
  String get cleanModeTitle => 'Interfaz limpia';
  @override
  String get cleanModeSubtitle =>
      'Esconde los botones secundarios, los filtros y las tarjetas de extras. '
      'No se pierde nada: todo pasa a los menús.';
  @override
  String get cleanModeHintTitle => '¿Dónde está todo?';
  @override
  String get cleanModeHintBody =>
      'Los botones que han desaparecido están en el menú ⋮ de arriba. Deja '
      'pulsada una comida para ver sus opciones.';

  // ======================= WIDGETS DE INICIO =======================

  @override
  String get widgetsTitle => 'Widgets de inicio';
  @override
  String get widgetsSubtitle => 'Tu día de un vistazo, sin abrir la app';
  @override
  String get widgetsIntro =>
      'Añade uno desde aquí, o deja pulsado un hueco de la pantalla de inicio '
      'y busca Meal Planner en la lista de widgets.';
  @override
  String get widgetsRefreshNote =>
      'Se actualizan cada vez que sales de la app y siguen tu tema de color.';
  @override
  String get widgetTodayTitle => 'Hoy';
  @override
  String get widgetTodayDescription =>
      'Calorías y proteína del día, el agua y lo que te queda.';
  @override
  String get widgetNextTitle => 'Lo siguiente';
  @override
  String get widgetNextDescription =>
      'La próxima comida del plan, y la de después.';
  @override
  String get widgetShoppingTitle => 'Lista de la compra';
  @override
  String get widgetShoppingDescription =>
      'Lo que aún falta por meter en el carro esta semana.';
  @override
  String get addToHomeScreen => 'Añadir a la pantalla de inicio';
  @override
  String get widgetPinUnsupported =>
      'Tu launcher no deja que lo coloque la app. Deja pulsada la pantalla de '
      'inicio y elígelo de la lista de widgets.';
  @override
  String get widgetNoPlan => 'Nada planificado';
  @override
  String get widgetAllBought => 'Todo comprado';
  @override
  String widgetItemsLeft(int n) => n == 1 ? 'Falta 1 cosa' : 'Faltan $n cosas';
  @override
  String get widgetOnlyAndroid => 'Los widgets solo están en Android.';
}
