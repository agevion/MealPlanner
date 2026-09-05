import '../models/gym_goal.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';

/// Todos los textos de la app, en inglés.
///
/// Cada idioma es una subclase que sobreescribe lo que traduce. Se hizo así en
/// vez de con mapas de `String` por dos motivos: el compilador avisa si te
/// inventas el nombre de un texto (con un mapa saldría la clave en pantalla y
/// no te enterarías), y lo que un idioma no traduzca cae solo en el inglés de
/// aquí, sin escribir ni una línea extra.
///
/// Reglas al añadir un texto nuevo: se declara aquí primero, y las plantillas
/// van como métodos con parámetros (`kcalLeft(120)`) en lugar de trocear frases
/// y pegarlas, porque el orden de las palabras cambia de un idioma a otro.
class AppStrings {
  const AppStrings();

  String get languageCode => 'en';

  /// Nombre del idioma en inglés. Se le pasa a la IA para que conteste en el
  /// idioma del usuario.
  String get aiLanguageName => 'English';

  // ======================= COMÚN =======================

  String get appName => 'Meal Planner';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get saveChanges => 'Save changes';
  String get add => 'Add';
  String get added => 'Added';
  String get delete => 'Delete';
  String get remove => 'Remove';
  String get close => 'Close';
  String get undo => 'Undo';
  String get all => 'All';
  String get options => 'Options';
  String get more => 'More';
  String get search => 'Search';
  String get show => 'Show';
  String get hide => 'Hide';
  String get name => 'Name';
  String get quantity => 'Quantity';
  String get noResults => 'No results.';

  // ---------------- Unidades y macros ----------------

  String get kcal => 'kcal';
  String get gramShort => 'g';
  String get minutesShort => 'min';
  String get protein => 'Protein';
  String get calories => 'Calories';
  String get kcalPerDay => 'kcal/day';
  String get gramsPerDay => 'g/day';

  String kcalValue(int n) => '$n kcal';
  String proteinValue(int n) => '$n g protein';

  /// La línea de macros que sale por toda la app.
  String macros(int kcal, int protein) => '$kcal kcal · $protein g protein';

  /// Igual pero corta (sin la palabra "protein"), para sitios estrechos.
  String macrosShort(int kcal, int protein) => '$kcal kcal · $protein g';

  // ---------------- Fechas ----------------

  /// Lunes primero, igual que el planificador.
  List<String> get weekdays => const [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday',
      ];

  List<String> get weekdaysShort =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<String> get months => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];

  List<String> get monthsShort => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

  /// "Monday, 12 August". Cada idioma lo ordena a su manera.
  String longDate(DateTime d) =>
      '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';

  /// Rango de una semana para la pestaña: "11–17 Aug".
  String weekRange(DateTime start, DateTime end) {
    final sameMonth = start.month == end.month;
    final startText = sameMonth
        ? '${start.day}'
        : '${start.day} ${monthsShort[start.month - 1]}';
    return '$startText–${end.day} ${monthsShort[end.month - 1]}';
  }

  // ---------------- Enumeraciones ----------------

  String mealSlot(MealSlot slot) => switch (slot) {
        MealSlot.breakfast => 'Breakfast',
        MealSlot.lunch => 'Lunch',
        MealSlot.snack => 'Snack',
        MealSlot.dinner => 'Dinner',
        MealSlot.preWorkout => 'Pre-workout',
        MealSlot.postWorkout => 'Post-workout',
      };

  String gymGoal(GymGoal goal) => switch (goal) {
        GymGoal.volume => 'Bulking',
        GymGoal.definition => 'Cutting',
        GymGoal.maintenance => 'Maintenance',
        GymGoal.custom => 'Custom',
      };

  String gymGoalDescription(GymGoal goal) => switch (goal) {
        GymGoal.volume => 'Build muscle · eat a bit more than you burn',
        GymGoal.definition => 'Lose fat without losing muscle',
        GymGoal.maintenance => 'Keep your weight and perform',
        GymGoal.custom => 'You set the numbers',
      };

  String sex(Sex value) => value == Sex.male ? 'Male' : 'Female';

  String activity(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Sedentary',
        ActivityLevel.light => 'Light',
        ActivityLevel.moderate => 'Moderate',
        ActivityLevel.active => 'High',
        ActivityLevel.veryActive => 'Very high',
      };

  String activityDescription(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Little or no exercise',
        ActivityLevel.light => 'Training 1-3 days a week',
        ActivityLevel.moderate => 'Training 3-5 days a week',
        ActivityLevel.active => 'Training 6-7 days a week',
        ActivityLevel.veryActive => 'Hard training daily or physical job',
      };

  String repeatability(Repeatability r) => switch (r) {
        Repeatability.free => 'No limit',
        Repeatability.moderate => 'In moderation',
        Repeatability.limited => 'Limit',
      };

  String repeatabilityHint(Repeatability r) => switch (r) {
        Repeatability.free => 'Repeat it as often as you like',
        Repeatability.moderate => 'Better not to overdo it during the week',
        Repeatability.limited => 'Only once in a while',
      };

  /// Las categorías de la despensa se guardan en español (son la clave con la
  /// que casan los datos ya grabados). Aquí solo se traduce lo que se enseña,
  /// y si aparece una categoría desconocida se muestra tal cual.
  Map<String, String> get ingredientCategories => const {
        'Proteínas': 'Protein',
        'Carbohidratos': 'Carbs',
        'Legumbres': 'Pulses',
        'Verduras': 'Vegetables',
        'Frutas': 'Fruit',
        'Lácteos y huevos': 'Dairy & eggs',
        'Grasas y frutos secos': 'Fats & nuts',
        'Otros': 'Other',
      };

  String ingredientCategory(String stored) =>
      ingredientCategories[stored] ?? stored;

  /// Igual que las categorías: la etiqueta guardada no cambia, solo su rótulo.
  Map<String, String> get foodTags => const {
        'Pasta': 'Pasta',
        'Arroz': 'Rice',
        'Carne': 'Meat',
        'Pescado': 'Fish',
        'Verduras': 'Veggies',
        'Legumbres': 'Pulses',
        'Huevos': 'Eggs',
        'Sopa': 'Soup',
        'Ensalada': 'Salad',
        'Rápido': 'Quick',
        'De aprovechar': 'Leftovers',
        'Capricho': 'Treat',
      };

  String foodTag(String stored) => foodTags[stored] ?? stored;

  Map<String, String> get themeNames => const {
        'teal': 'Teal',
        'sunset': 'Sunset',
        'grape': 'Grape',
        'ocean': 'Ocean',
        'forest': 'Forest',
        'ruby': 'Ruby',
        'amber': 'Amber',
        'midnight': 'Midnight',
        'crimson': 'Crimson',
      };

  String themeName(String id) => themeNames[id] ?? id;

  // ======================= NAVEGACIÓN =======================

  String get tabToday => 'Today';
  String get tabWeek => 'Week';
  String get tabMeals => 'Meals';
  String get tabShopping => 'Shopping';
  String get tabMore => 'More';

  List<String> get tabNames =>
      [tabToday, tabWeek, tabMeals, tabShopping, tabMore];

  // ======================= TUTORIAL =======================

  String get onbLanguageTitle => 'Choose your language';
  String get onbLanguageBody =>
      'You can change it later in Settings whenever you like.';
  String get onbLanguageContinue => 'Continue';

  String get onbWelcomeTitle => 'Welcome to Meal Planner';
  String get onbWelcomeBody =>
      'Decide what you are eating this week, get the shopping list done for '
      'you and log what you actually eat. This quick tour takes half a minute.';

  String get onbPlannerTitle => 'Plan your week';
  String get onbPlannerBody =>
      'A grid with your seven days. Tap a slot to choose a dish, or hit '
      '"Randomise" and let the app fill the week for you. Drag a dish to move '
      'it to another day, lock the days you already sorted out and mark the '
      'ones you are eating out.';

  String get onbMealsTitle => 'Your meals';
  String get onbMealsBody =>
      'This is your own catalogue of dishes. Add them by hand, scan a barcode '
      'or start from the example meals. Each dish keeps its ingredients, and '
      'that is what the shopping list is built from.';

  String get onbShoppingTitle => 'The shopping list writes itself';
  String get onbShoppingBody =>
      'It gathers the ingredients of everything you planned, groups them by '
      'aisle and adds up amounts. Tick things off as you drop them in the '
      'trolley, and turn on big-text mode for the supermarket.';

  String get onbTodayTitle => 'Log what you eat';
  String get onbTodayBody =>
      'On the Today tab you tick off your planned meals or add anything else. '
      'You can also jot down your weight, your water and a note for the day.';

  String get onbGymTitle => 'Gym Mode (optional)';
  String get onbGymBody =>
      'If you train, turn it on in More › Gym Mode. Tell it your goal and it '
      'works out your daily calories and protein, then tracks how you are '
      'doing against them. If you are not interested, just leave it off: '
      'nothing changes.';

  String get onbReadyTitle => 'That is the whole tour';
  String get onbReadyBody =>
      'Best way to start: add a handful of meals from the examples, then hit '
      '"Randomise" on the Week tab. You can replay this tutorial any time from '
      'Settings.';

  String get onbSkip => 'Skip';
  String get onbNext => 'Next';
  String get onbBack => 'Back';
  String get onbStart => "Let's go";

  // ======================= AJUSTES =======================

  String get settingsTitle => 'Settings';
  String get sectionLanguage => 'Language';
  String get sectionAppearance => 'Appearance';
  String get sectionColorTheme => 'Colour theme';
  String get sectionOnOpen => 'When the app opens';
  String get sectionAi => 'AI assistant (Gemini)';
  String get sectionBackup => 'Backup';
  String get sectionHelp => 'Help';
  String get sectionAbout => 'About';

  String get languageSubtitle => 'The whole app changes language';

  String get modeSystem => 'System';
  String get modeLight => 'Light';
  String get modeDark => 'Dark';

  String get amoledTitle => 'AMOLED black';
  String get amoledSubtitle => 'Pure black backgrounds in dark mode';

  String get colorIntensity => 'Colour intensity';
  List<String> get intensityLabels =>
      const ['Soft', 'Balanced', 'Vivid', 'Intense'];

  String get startTabAuto => 'Automatic';

  String get replayTutorialTitle => 'Show the tutorial again';
  String get replayTutorialSubtitle => 'The welcome tour, from the beginning';

  String get aboutSubtitle => 'Version 2.0 · Made with Flutter';

  String get backupIntro =>
      'Saves EVERYTHING (dishes, weeks, pantry and log) to a file. Your AI key '
      'is left out for safety.';
  String get exportBackup => 'Export backup';
  String get exportBackupSubtitle => 'Share or save the .json file';
  String get restoreBackup => 'Restore backup';
  String get restoreBackupSubtitle => 'Replaces your current data';
  String get backupShareSubject => 'Meal Planner backup';
  String get restoreConfirmBody =>
      'This will replace your dishes, weeks, pantry and log with the ones in '
      'the backup. You will need to restart the app afterwards.\n\n'
      'Are you sure you want to continue?';
  String get restore => 'Restore';
  String get backupRestored =>
      'Backup restored. Close and reopen the app to see it.';

  String get aiIntro =>
      'With your free Google Gemini key you can estimate a dish’s macros from '
      'text or a photo. Get one at aistudio.google.com/apikey';
  String get apiKeyLabel => 'API key';
  String get modelLabel => 'Model';
  String modelHelper(String model) => 'Default: $model';
  String get aiEnabled => 'AI on: you can estimate from a photo or text.';
  String get aiDisabled => 'No key: AI estimation is off.';

  // ======================= "MÁS" =======================

  String get moreTitle => 'More';
  String get statDishes => 'dishes';
  String get statWeeks => 'weeks';
  String get statStreak => 'day streak';

  String get sectionYourFood => 'Your food';
  String get addMealTitle => 'Add a meal';
  String get addMealSubtitle => 'Create a new dish for your catalogue';
  String get myIngredientsTitle => 'My ingredients';
  String get myIngredientsSubtitle => 'Pantry with home measures and stock';
  String get giveIdeasTitle => 'Give me ideas';
  String get giveIdeasSubtitle => 'Let the AI suggest new dishes';
  String get rouletteTitle => 'Dinner roulette';
  String get rouletteSubtitle => 'For when you cannot even decide';

  String get sectionProgress => 'Progress';
  String get statsTitle => 'Statistics';
  String get statsSubtitle => 'Averages, streak, weight and days on target';
  String get gymModeTitle => 'Gym Mode';
  String gymModeActive(String goal) => 'On · $goal';
  String get gymModeNoGoal => 'no goal';
  String get gymModeSubtitle => 'Calorie and protein targets';

  String get sectionApp => 'App';
  String get settingsSubtitle => 'Theme, language, AI, backup';

  // ======================= HOY / REGISTRO =======================

  String get todayScreenTitle => 'Log';
  String get today => 'Today';
  String get yesterday => 'Yesterday';
  String get chooseDay => 'Choose a day';
  String get previousDay => 'Previous day';
  String get nextDay => 'Next day';

  String get menuCopyYesterday => 'Copy yesterday';
  String get menuDayNote => 'Note for the day';
  String get menuWhatFits => 'What fits in what is left?';
  String get menuRoulette => 'Dinner roulette';
  String get menuClearDay => 'Clear this day';

  String get whatYouveHad => 'What you have had';
  String get nothingLoggedYet =>
      'Nothing logged yet. Tick off the planned meals above or tap "Add".';
  String get otherSlot => 'Other';

  String get adjustAmount => 'Adjust amount';
  String howMuchOf(String dish) => 'How much of $dish did you have?';
  String get oneServing => '1 serving';
  String servingsCount(String amount) => '$amount servings';
  String removedItem(String name) => 'Removed: $name';

  String get needTargetForFits =>
      'Set your target in Gym Mode to use this';
  String get alreadyOverToday => 'You have already gone over today’s target.';
  String kcalLeftFits(int left) =>
      'You have $left kcal left. Here is what fits, most protein first:';
  String get nothingFitsCatalog => 'Nothing in your catalogue fits.';

  String get yesterdayWasEmpty => 'Nothing logged yesterday';
  String copiedMeals(int n) => 'Copied $n meals from yesterday';
  String get dayAlreadyEmpty => 'This day is already empty';
  String get dayCleared => 'Day cleared';

  String get weightToday => 'Today’s weight';
  String get weight => 'Weight';
  String get logWeight => 'Log your weight';
  String get weightSubtitle => 'Used for your progress chart';

  String get noteHint => 'Trained legs, dinner out…';

  String get manualEntry => 'Manual entry';
  String get manualEntrySubtitle => 'Type a name, calories and protein';
  String get searchYourMeals => 'Search your meals';
  String get noResultsUseManual => 'No results. Use manual entry.';
  String get noMacrosLoggedAsZero => 'No macros (logged as 0)';
  String get youEatThisOften => 'You eat this often';
  String addedItem(String name) => 'Added: $name';

  String get plannedForThisDay => 'What you had planned';
  String get nothingPlannedThisDay => 'Nothing planned for this day.';

  String hadKcalAndProtein(int kcal, int protein) =>
      'You have had $kcal kcal and $protein g of protein.';
  String get setUpGymProfile =>
      'Set up your profile in Gym Mode to see your targets.';
  String kcalLeft(int n) => 'You have $n kcal left';
  String kcalOver(int n) => 'You are $n kcal over';
  String get proteinMet => 'Protein hit';
  String streakBadge(int days) =>
      days == 1 ? '1 day streak' : '$days day streak';
  String ofTarget(int target) => 'of $target';

  String get water => 'Water';
  String waterGlasses(int n) =>
      n == 1 ? '1 glass of water' : '$n glasses of water';

  // ======================= PLANIFICADOR =======================

  String get plannerTitle => 'Planner';
  String get viewNormal => 'Normal view';
  String get viewCompact => 'Compact view';

  String get menuGoToThisWeek => 'Go to this week';
  String get menuWeekDate => 'Date of this week';
  String get menuDuplicateWeek => 'Duplicate week';
  String get menuImportWeek => 'Import week';
  String get menuExportWeek => 'Export week';
  String get menuShareAsText => 'Share as text';

  String get randomize => 'Randomise';
  String get howToRandomize => 'How to randomise';
  String get onlyFillGaps => 'Only fill the gaps';
  String get onlyFillGapsSubtitle => 'Leaves what you already set alone';
  String get useLeftovers => 'Use leftovers';
  String get useLeftoversSubtitle =>
      'Dishes that make several servings repeat in the next slot';
  String get onlyDishesWithMacros => 'Only dishes with macros';
  String get aimForMyCalories => 'Aim for my calories';
  String get aimForMyCaloriesSubtitle =>
      'Tries to land each day close to your target';
  String busyDaysMarked(int n) =>
      n == 1 ? '1 day marked as "in a rush"' : '$n days marked as "in a rush"';
  String get busyDaysSubtitle => 'They only get quick dishes';
  String get randomizerOptions => 'Randomiser options';

  String get weekDuplicated => 'Week duplicated';
  String get weekDuplicateFailed => 'Could not duplicate (week limit reached)';
  String get noWeekIsToday =>
      'No week is set to today’s date. Use "Date of this week".';
  String get pickAnyDayOfWeek => 'Pick any day of that week';
  String get noMealsToExport => 'No meals to export';
  String get weekShareSubject => 'Weekly planner';
  String get weekMenuSubject => 'This week’s menu';
  String importedIntoWeek(int n) => 'Planner imported into week $n';

  String get addWeek => 'Add a week';
  String get deleteCurrentWeek => 'Delete current week';
  String get deleteWeekTitle => 'Delete week';
  String deleteWeekBody(String label) =>
      'The plan for "$label" will be deleted. Are you sure?';
  String maxWeeks(int n) => 'Maximum of $n weeks';
  String get cannotDeleteOnlyWeek => 'You cannot delete your only week';

  String get todayBadge => 'TODAY';
  String get dayOptions => 'Day options';
  String get unlockDay => 'Unlock day';
  String get lockDay => 'Lock day';
  String get clearBusyDay => 'Clear "in a rush"';
  String get markBusyDay => 'In a rush (quick dishes)';
  String get eatingInAgain => 'Eating at home again';
  String get eatingOutThisDay => 'Eating out this day';
  String get clearDay => 'Clear day';
  String get eatingOutNotice =>
      'Eating out: not planned and not in the shopping list.';
  String dayClearedNamed(String day) => '$day cleared';

  String get tapToChoose => 'Tap to choose';
  String get addToMyCatalog => 'Add to my catalogue';
  String addedToCatalog(String name) => 'Added to your catalogue: $name';
  String get shuffleThisOne => 'Shuffle this one';
  String get dayIsLocked => 'That day is locked. Unlock it first.';
  String get searchDishOrIngredient => 'Search a dish or ingredient';
  String get clearThisMeal => 'Clear this meal';
  String get awayShort => 'Out';

  String weekNumber(int n) => 'Week $n';
  String get thisWeek => 'This week';

  // ======================= MIS COMIDAS =======================

  String get myMealsTitle => 'My meals';
  String get scanProduct => 'Scan a product';
  String get scanProductSubtitle => 'Fills in the data from the barcode';
  String get addByHand => 'Add by hand';
  String get addByHandSubtitle => 'For fresh food or anything without a code';
  String get exampleMeals => 'Example meals';
  String get sort => 'Sort';
  String get sortNameAsc => 'Name (A-Z)';
  String get sortNameDesc => 'Name (Z-A)';
  String get sortMostUsed => 'Most used';
  String get searchByNameOrIngredient => 'Search by name or ingredient';
  String get canCookNow => 'Can cook it now';
  String get withMacros => 'With macros';
  String get withoutMacros => 'Without macros';
  String get noSearchResults => 'No results for your search.';

  String ingredientCount(int n) =>
      n == 1 ? '1 ingredient' : '$n ingredients';
  String servingsMadeCount(int n) => n == 1 ? '1 serving' : '$n servings';
  String get highInProtein => 'High in protein';

  String get unfavourite => 'Remove from favourites';
  String get markFavourite => 'Mark as favourite';
  String get proposeAgain => 'Propose it again';
  String get notInTheMood => 'Not in the mood (2 weeks)';
  String get duplicate => 'Duplicate';
  String get copySuffix => 'copy';
  String snoozedMessage(String name) =>
      '"$name" will not come up at random for 2 weeks';
  String get deleteMealTitle => 'Delete meal';
  String deleteMealBody(String name) =>
      'Are you sure you want to delete "$name"?';
  String deletedItem(String name) => 'Deleted: $name';

  String get noMealsYet => 'No meals yet';
  String get noMealsYetSubtitle =>
      'Start with our example meals or create your own.';
  String get seeExampleMeals => 'See example meals';

  // ======================= LISTA DE LA COMPRA =======================

  String get shoppingListTitle => 'Shopping list';
  String get superMarketMode => 'Supermarket mode (big text)';
  String get checkAll => 'Check everything';
  String get uncheckAll => 'Uncheck everything';
  String get showBought => 'Show what is bought';
  String get hideBought => 'Hide what is bought';
  String get shareList => 'Share list';
  String get copyToClipboard => 'Copy to clipboard';
  String get recurringItems => 'Usual items';
  String get listCopied => 'List copied';
  String get shoppingShareSubject => 'Shopping list';
  String get recurringItemsBody => 'Add them to this week’s list with one tap.';
  String get addToListTitle => 'Add to the list';
  String get ingredientOrProduct => 'Ingredient or product';
  String get listComplete => 'List complete!';
  String inCart(int done, int total) => '$done of $total in the trolley';
  String get addedByHand => 'Added by hand';
  String get emptyListTitle => 'The list is empty';
  String get emptyListSubtitle =>
      'Plan some meals for this week or add items with the "Add" button.';

  /// Lo que se acaba comprando siempre. Es contenido, no interfaz, así que cada
  /// idioma trae su propia lista.
  List<String> get recurringItemsList => const [
        'Kitchen roll', 'Toilet paper', 'Coffee', 'Milk', 'Bread',
        'Olive oil', 'Salt', 'Bin bags', 'Detergent', 'Eggs',
        'Water', 'Mixed fruit',
      ];

  // ======================= AÑADIR / EDITAR COMIDA =======================

  String get editMeal => 'Edit meal';
  String get addMeal => 'Add a meal';
  String prefillNotice(String origin) =>
      '$origin. Check it and adjust it before saving.';
  String get mealNameLabel => 'Meal name';
  String get favourite => 'Favourite';
  String get photo => 'Photo';
  String get takePhoto => 'Take a photo';
  String get chooseFromGallery => 'Choose from the gallery';
  String get removePhoto => 'Remove the photo';

  String get ingredientsTitle => 'Ingredients';
  String get scan => 'Scan';
  String get searchIngredient => 'Search an ingredient';
  String get byHand => 'By hand';
  String get ingredientsTextLabel => 'Ingredients (text)';
  String get ingredientsTextHelper =>
      'Separate them with commas: tomato, pasta, cheese';
  String get nutritionPerServing => 'Nutrition (per serving)';
  String get estimateWithAi => 'Estimate with AI';
  String totalLine(int kcal, int protein) =>
      'Total: $kcal kcal · $protein g protein';

  String get whichSlots => 'Which meals does it fit?';
  String get ifNoneAllApply => 'If you tick none, it works for all of them.';
  String get tagsTitle => 'Tags';
  String get tagsHelp => 'They keep your week from turning into all pasta.';

  String get detailsTitle => 'Details';
  String get prepTime => 'Time';
  String get costPerServing => 'Cost/serving';
  String get servingsMadeTitle => 'Servings it makes';
  String servingsMadeMulti(int n) => 'Cook once, eat $n times';
  String get servingsMadeOne => 'Cooked for one sitting';
  String get recipeOrNotes => 'Recipe or notes';
  String get recipeOrNotesHelper => 'Steps, tips, a link…';

  String get pleaseCompleteName => 'Please fill in the name';
  String get pleaseCompleteNameAndIngredients =>
      'Please fill in the name and the ingredients';
  String renamedTo(String name) => 'Renamed to "$name" (in your weeks too)';
  String get mealUpdated => 'Meal updated';
  String get mealAdded => 'Meal added';
  String get aiMacrosFilled =>
      'Macros estimated with AI. Check them before saving.';

  String get addIngredientTitle => 'Add an ingredient';
  String get editIngredientTitle => 'Edit ingredient';
  String get kcalPerUnit => 'kcal/unit';
  String get proteinPerUnit => 'prot/unit';

  // ======================= DESPENSA =======================

  String get pantryTitle => 'My ingredients';
  String get restoreDeleted => 'Restore the deleted ones';
  String get presetsRestored => 'The app’s ingredients are back';
  String get tabFromApp => 'From the app';
  String get tabMine => 'Mine';
  String get searchIngredientHint => 'Search an ingredient';
  String addedToMine(String name) => '“$name” added to “Mine”';
  String get pantryEmptyMine =>
      'You have not added any ingredients yet.\nScan a product or tap "Add".';

  String haveInStock(String amount) => 'have $amount';
  String useSoonExpires(int days) =>
      days == 1 ? 'Use it up! Expires tomorrow' : 'Use it up! Expires in $days days';
  String expiresInDays(int days) => 'Expires in $days days';

  String get newIngredient => 'New ingredient';
  String get unitLabel => 'Unit';
  String get unitHint => 'slice, fillet…';
  String get gramsPerUnitShort => 'g/unit';
  String get unitTip =>
      'Tip: the packaging usually tells you the grams (e.g. "10 slices · 200 g" '
      '→ 20 g per slice).';
  String get unitTipRecalc =>
      ' The macros are recalculated on their own when you change the grams.';
  String get categoryLabel => 'Category';
  String get repeatQuestion => 'Can it be repeated often?';
  String get haveAtHomeQuestion => 'Do you have it at home?';
  String stockHelper(String unit) => 'In $unit';
  String get unitsFallback => 'units';
  String get expiryDate => 'Expiry date';
  String get expiryShort => 'Expiry';
  String get removeExpiry => 'Remove expiry';

  /// Unidades caseras que se ofrecen como chips. La clave es lo que se guarda.
  Map<String, String> get homeUnits => const {
        'loncha': 'slice',
        'filete': 'fillet',
        'unidad': 'unit',
        'rodaja': 'round',
        'cucharada': 'spoonful',
        'puñado': 'handful',
        'vaso': 'glass',
        'ración': 'serving',
        'muslo': 'thigh',
        'lomo': 'fillet',
        'lata': 'tin',
        'plato': 'plate',
        'rebanada': 'slice',
        'bol': 'bowl',
        'racimo': 'bunch',
        'tajada': 'wedge',
        'porción': 'portion',
        'cazo': 'scoop',
        'cucharadita': 'teaspoon',
      };

  String homeUnit(String stored) => homeUnits[stored] ?? stored;

  /// Cómo se describe una porción de la despensa: "1 slice (≈20 g)". El peso
  /// solo aparece si el ingrediente lo tiene puesto.
  String portionLabel(String unit, double gramsPerUnit) => gramsPerUnit > 0
      ? '1 ${homeUnit(unit)} (≈${gramsPerUnit.round()} g)'
      : '1 ${homeUnit(unit)}';

  // ======================= SELECTOR DE PORCIÓN =======================

  String get units => 'Units';
  String get grams => 'Grams';
  String get productHasNoMacros =>
      'This product has no macros. Add them by hand.';
  String get saveToMyIngredients => 'Save to My ingredients';
  String get whichMeasure => 'Which measure?';
  String get howMany => 'How many?';
  String gramsPer(String unit) => 'g per $unit';
  String get howManyGrams => 'How many grams?';
  String get howManyServings => 'How many servings?';
  String oneServingIs(String size) => '1 serving = $size';
  String get proteinGramsShort => 'protein (g)';

  // ======================= MODO GYM =======================

  String get gymIntro =>
      'Turn on Gym Mode to plan your meals around your goal (bulking, cutting…) '
      'without drowning in jargon.';
  String get enableGymMode => 'Turn on Gym Mode';
  String get enableGymModeSubtitle =>
      'Shows the tracking options for the gym';
  String get yourGoal => 'Your goal';
  String get yourGoalSubtitle => 'Pick what you want to achieve. No jargon.';
  String get yourTargets => 'Your targets';
  String estimatedExpenditure(int kcal) => 'Estimated burn: $kcal kcal/day';
  String get setYourOwnFigures =>
      'Set your own calorie and protein figures.';
  String get completeProfileToCalculate =>
      'Complete your profile to work out your targets.';
  String get adjustFigures => 'Adjust figures';
  String get editProfile => 'Edit profile';
  String get completeProfile => 'Complete profile';
  String get yourFigures => 'Your figures';
  String get todaysLog => 'Today’s log';
  String get todaysLogSubtitle => 'Log what you eat and track your progress';
  String get mealsPerDay => 'Meals per day';
  String get mealsPerDaySubtitle => 'Choose how many meals you plan each day.';
  String daysInARow(int days) =>
      days == 1 ? '1 day in a row' : '$days days in a row';
  String get noStreakYet => 'No streak yet';
  String get setTargetToCount => 'Set your target to start counting.';
  String get logToStartStreak => 'Log what you eat and start the streak.';
  String last7Days(int met, int days) =>
      'Last 7 days: protein hit $met of $days.';

  // ======================= PERFIL GYM =======================

  String get yourProfile => 'Your profile';
  String get profileIntro =>
      'We work out your targets from these. They are saved and you can change '
      'them whenever you like.';
  String get height => 'Height';
  String get age => 'Age';
  String get years => 'years';
  String get sexTitle => 'Sex';
  String get sexNote => 'Only used to work out your calorie burn.';
  String get activityLevel => 'Activity level';
  String get fillToSeeTargets =>
      'Fill in weight, height and age to see your targets.';
  String targetsForGoal(String goal) => 'Your targets · $goal';
  String get customFiguresNote =>
      'In "Custom" you can set these figures by hand.';
  String get saveProfile => 'Save profile';
  String get profileSaved => 'Profile saved';
  String get checkProfileData =>
      'Check your data: weight, height and age must be valid';

  // ======================= ESTADÍSTICAS =======================

  String get statisticsTitle => 'Statistics';
  String get exportCsv => 'Export log (CSV)';
  String get csvSubject => 'My meal log';
  String daysRange(int n) => '$n days';
  String get avgPerDay => 'Daily average';
  String get avgProtein => 'Average protein';
  String get daysMeetingProtein => 'Days hitting protein';
  String get currentStreak => 'Current streak';
  String get daysUnit => 'days';

  String get yourWeight => 'Your weight';
  String get weightNeedsTwoDays =>
      'Log your weight on at least two days from the log screen to see the '
      'chart and the trend.';
  String get sevenDayAverage => '7-day average';

  String get achievementsTitle => 'Achievements';
  String achievementsUnlocked(int unlocked, int total) =>
      '$unlocked of $total unlocked';

  String get whatYouEatMost => 'What you eat most';
  String get nothingPlannedYet => 'You have not planned anything yet.';
  String timesInYourWeeks(int n) =>
      n == 1 ? '1 time in your weeks' : '$n times in your weeks';

  String get verdictNoTarget =>
      'Set your target in Gym Mode to know how you are doing.';
  String get verdictNoData => 'Not enough data yet.';
  String get verdictGreat => 'Great: you hit your protein almost every day.';
  String get verdictOk =>
      'Doing all right, but quite a few days slip through. Try adding a '
      'protein snack in the afternoon.';
  String get verdictLow =>
      'You fall short on protein most days. Add some "high in protein" dishes '
      'to your catalogue.';
  String adjustToKcal(int kcal) => 'Adjust to $kcal kcal';
  String targetAdjusted(int kcal) => 'Target adjusted to $kcal kcal';
  String get noLogsInPeriod =>
      'No entries in this period yet.\nLog what you eat on the "Today" tab and '
      'your averages will show up here.';

  // ---------------- Logros ----------------

  Map<String, (String, String)> get achievements => const {
        'cocinero': ('Cook', 'Create 10 dishes in your catalogue'),
        'chef': ('Chef', 'Reach 50 dishes'),
        'constante': ('Consistent', 'Log 7 days'),
        'veterano': ('Veteran', 'Log 100 days'),
        'racha7': ('A perfect week', '7 days in a row hitting protein'),
        'racha30': ('Unstoppable', '30 days of protein in a row'),
        'planificador': ('Planner', 'Plan 4 weeks'),
        'fotografo': ('Photographer', 'Add a photo to 5 dishes'),
        'proteico': ('Target met', 'Hit your protein on 30 days in total'),
        'semanaperfecta':
            ('Perfect week', 'A whole week planned from end to end'),
      };

  String achievementTitle(String id) => achievements[id]?.$1 ?? id;
  String achievementDescription(String id) => achievements[id]?.$2 ?? '';

  // ======================= IA: ESTIMAR =======================

  String get aiEstimateTitle => 'Estimate with AI';
  String get aiEstimateIntro =>
      'Describe what you ate and/or add a photo. The AI estimates the calories '
      'and the protein (roughly).';
  String get descriptionLabel => 'Description';
  String get descriptionHint => 'e.g. a plate of pasta with tuna, normal portion';
  String get gallery => 'Gallery';
  String get photoAdded => 'Photo added';
  String get estimating => 'Estimating…';
  String get estimateMacros => 'Estimate macros';
  String get resultAdjustIt => 'Result (adjust it if you like)';
  String get useThisData => 'Use this data';
  String get couldNotOpenImage => 'Could not open the image.';
  String get missingGeminiKey => 'Your Gemini key is missing';
  String get missingGeminiKeyBody =>
      'To use AI estimation, add your free Google Gemini API key in Settings.';
  String get goToSettings => 'Go to Settings';

  // ======================= IA: IDEAS =======================

  String get whatDoYouFancy => 'What do you fancy?';
  String get whatDoYouFancyHint => 'Quick dinners with protein, no fish…';
  String get usePantry => 'Use my pantry';
  String get usePantrySubtitle => 'Prefers ingredients you already have';
  String get thinking => 'Thinking…';
  String get proposeDishes => 'Suggest dishes';
  String get proposals => 'Suggestions';
  String get proposalsDisclaimer =>
      'They are estimates: check them before trusting the macros.';
  String get writeWhatYouWant => 'Write what kind of dishes you want.';
  String get aiSuggestNotConfigured =>
      'For the AI to suggest dishes you need to add your free Gemini key in '
      'Settings.';

  List<String> get ideaPresets => const [
        'Light dinners under 400 kcal',
        'High-protein meals for after the gym',
        'Cheap dishes that go a long way',
        'Quick breakfasts under 10 minutes',
        'Leftover recipes with what I have',
      ];

  // ======================= BUSCAR INGREDIENTE =======================

  String get searchIngredientTitle => 'Search an ingredient';
  String get searchIngredientPlaceholder => 'Search (chicken, rice, egg…)';
  String get noResultsTryAnother => 'No results. Try another word.';
  String get otherQuantity => 'Another amount';
  String howManyUnits(String unit) => 'How many $unit?';
  String oneUnitIs(String unit, int kcal, int protein) =>
      '1 $unit = $kcal kcal · $protein g';

  // ======================= RULETA =======================

  String rouletteFor(String slot) => 'Roulette · $slot';
  String get whatsForDinner => 'What’s for dinner?';
  String get onlyWithWhatIHave => 'Only with what I have at home';
  String get spin => 'Spin!';
  String get spinAgain => 'Again';
  String get putItInThePlan => 'Put it in the plan';
  String noDishesFor(String slot) => 'You have no dishes for $slot';
  String assignedTo(String dish, String day, String slot) =>
      '$dish → $day, $slot';

  // ======================= ESCÁNER =======================

  String get scanProductTitle => 'Scan a product';
  String get scanIngredientTitle => 'Scan an ingredient';
  String get switchCamera => 'Switch camera';
  String get flash => 'Flash';
  String get aimAtBarcode =>
      'Point at the product barcode (it reads QR codes too)';
  String get searchingProduct => 'Looking up the product…';
  String get productNotFoundTitle => 'Product not found';
  String productNotFoundBody(String code) =>
      'No data for code $code. You can add it by hand.';
  String get keepScanning => 'Keep scanning';
  String scannedProductNote(String basis) =>
      'Scanned product (OpenFoodFacts · $basis)';
  String get basisPerServing => 'per serving';
  String get basisPer100g => 'per 100 g';
  String get basisNoData => 'no data';

  /// Rótulo de la clave que guarda `ScannedProduct.basis`.
  String productBasis(String key) => switch (key) {
        'serving' => basisPerServing,
        'per100' => basisPer100g,
        _ => basisNoData,
      };
  String unknownProduct(String barcode) => 'Product $barcode';

  // ======================= COMIDAS DE EJEMPLO =======================

  String get exampleMealsTitle => 'Example meals';
  String get selectAll => 'All';
  String get unselectAll => 'Clear all';
  String get alreadyInCatalog => 'Already in your catalogue';
  String get selectMeals => 'Select some meals';
  String addNMeals(int n) => n == 1 ? 'Add 1 meal' : 'Add $n meals';
  String addedNMeals(int n) => n == 1
      ? 'Added 1 meal to your catalogue'
      : 'Added $n meals to your catalogue';
  String get presetNotice =>
      'They are a starting point and fully editable: add the one that suits '
      'you and tweak its ingredients or macros afterwards.';

  // ======================= MENSAJES DEL PROVIDER =======================

  String get noMealsToAssign => 'No meals to assign';
  String get noSlotsConfigured => 'No meal slots set up';
  String noMealsWithMacrosFor(String slot) =>
      'No meals with macros for $slot';
  String noMealsFor(String slot) => 'No meals for $slot';
  String maxWeeksReached(int n) => 'Maximum of $n weeks reached';
  String importError(Object e) => 'Import failed: $e';
  String get weekTextHeader => 'This week’s menu';
  String get outOfHome => 'eating out';
  String get shoppingTextHeader => 'Shopping list';
  String get shoppingListIsEmpty => 'The list is empty.';
  String get unitAbbrev => 'u';

  // ======================= COPIA DE SEGURIDAD =======================

  String get backupInvalidFile => 'That file is not a valid backup.';
  String get backupCorrupt => 'The backup is empty or damaged.';
  String get backupNothingRestored => 'Nothing could be restored from that backup.';

  // ======================= GEMINI =======================

  String get geminiMissingKey =>
      'Your Gemini API key is missing. Add it in Settings.';
  String get geminiNeedTextOrPhoto =>
      'Write a description or add a photo of the dish.';
  String get geminiBadKey =>
      'The API key is not valid or the request was rejected.';
  String get geminiForbidden =>
      'API key without permission. Check that you copied it correctly.';
  String get geminiModelNotFound =>
      'Model not found. Check the model name in Settings.';
  String get geminiRateLimit =>
      'You have gone over the request limit. Try again in a moment.';
  String geminiError(int code) => 'Gemini error (code $code).';
  String get geminiNoConnection =>
      'Could not reach Gemini. Check your connection.';
  String get geminiUnreadable => 'Gemini’s response could not be read.';
  String get geminiNothingUseful => 'Gemini returned nothing usable.';
  String get geminiNoEstimate =>
      'Gemini did not return an estimate. Try describing it better.';
  String get geminiParseFail => 'Could not understand Gemini’s estimate.';
  String get geminiCouldNotEstimate =>
      'The AI could not estimate the macros. Try adding more detail.';
  String get geminiSuggestionsParseFail =>
      'Could not understand the suggestions.';
  String get geminiNoSuggestions => 'The AI did not suggest any dish.';

  // ======================= AJUSTE DE CALORÍAS =======================

  String get gymNotGaining =>
      'You are not gaining weight: try eating 150 kcal more.';
  String get gymGainingTooFast => 'You are gaining too fast: drop 150 kcal.';
  String get gymNotLosing => 'You are not losing: try 150 kcal less.';
  String get gymLosingTooFast =>
      'You are losing too fast: add 150 kcal.';

  // ======================= INTERFAZ LIMPIA =======================

  String get sectionInterface => 'Interface';
  String get cleanModeTitle => 'Clean interface';
  String get cleanModeSubtitle =>
      'Hides secondary buttons, filters and extra cards. Nothing is lost: it '
      'all moves into the menus.';
  String get cleanModeHintTitle => 'Where did everything go?';
  String get cleanModeHintBody =>
      'The buttons that disappeared are in the ⋮ menu at the top. Long-press a '
      'meal for its options.';

  // ======================= WIDGETS DE INICIO =======================

  String get widgetsTitle => 'Home screen widgets';
  String get widgetsSubtitle => 'Your day at a glance, without opening the app';
  String get widgetsIntro =>
      'Add one from here, or long-press an empty spot on your home screen and '
      'look for Meal Planner in the widget list.';
  String get widgetsRefreshNote =>
      'They refresh every time you leave the app, and follow your colour theme.';
  String get widgetTodayTitle => 'Today';
  String get widgetTodayDescription =>
      'Calories and protein of the day, water, and what you have left.';
  String get widgetNextTitle => 'Up next';
  String get widgetNextDescription =>
      'The next meal on your plan, and the one after it.';
  String get widgetShoppingTitle => 'Shopping list';
  String get widgetShoppingDescription =>
      'What is still missing from the trolley this week.';
  String get addToHomeScreen => 'Add to home screen';
  String get widgetPinUnsupported =>
      'Your launcher will not let the app place it. Long-press your home '
      'screen and pick it from the widget list.';
  String get widgetNoPlan => 'Nothing planned';
  String get widgetAllBought => 'All bought';
  String widgetItemsLeft(int n) => n == 1 ? '1 item left' : '$n items left';
  String get widgetOnlyAndroid => 'Widgets are only available on Android.';
}
