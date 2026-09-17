import '../models/gym_goal.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';
import 'app_strings.dart';

/// Français.
class AppStringsFr extends AppStrings {
  const AppStringsFr();

  @override
  String get languageCode => 'fr';
  @override
  String get aiLanguageName => 'French';

  // ======================= COMMUN =======================

  @override
  String get cancel => 'Annuler';
  @override
  String get save => 'Enregistrer';
  @override
  String get saveChanges => 'Enregistrer les modifications';
  @override
  String get add => 'Ajouter';
  @override
  String get added => 'Ajouté';
  @override
  String get delete => 'Supprimer';
  @override
  String get remove => 'Retirer';
  @override
  String get close => 'Fermer';
  @override
  String get undo => 'Annuler';
  @override
  String get all => 'Tous';
  @override
  String get options => 'Options';
  @override
  String get more => 'Plus';
  @override
  String get search => 'Rechercher';
  @override
  String get show => 'Afficher';
  @override
  String get hide => 'Masquer';
  @override
  String get name => 'Nom';
  @override
  String get quantity => 'Quantité';
  @override
  String get noResults => 'Aucun résultat.';

  @override
  String get protein => 'Protéines';
  @override
  String get calories => 'Calories';
  @override
  String get kcalPerDay => 'kcal/jour';
  @override
  String get gramsPerDay => 'g/jour';

  @override
  String proteinValue(int n) => '$n g de protéines';
  @override
  String macros(int kcal, int protein) =>
      '$kcal kcal · $protein g de protéines';

  @override
  List<String> get weekdays => const [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  @override
  List<String> get weekdaysShort => const [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];
  @override
  List<String> get months => const [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  @override
  List<String> get monthsShort => const [
    'janv',
    'févr',
    'mars',
    'avr',
    'mai',
    'juin',
    'juil',
    'août',
    'sept',
    'oct',
    'nov',
    'déc',
  ];

  @override
  String longDate(DateTime d) =>
      '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';

  @override
  String mealSlot(MealSlot slot) => switch (slot) {
    MealSlot.breakfast => 'Petit-déjeuner',
    MealSlot.lunch => 'Déjeuner',
    MealSlot.snack => 'Goûter',
    MealSlot.dinner => 'Dîner',
    MealSlot.preWorkout => 'Avant l’entraînement',
    MealSlot.postWorkout => 'Après l’entraînement',
  };

  @override
  String gymGoal(GymGoal goal) => switch (goal) {
    GymGoal.volume => 'Prise de masse',
    GymGoal.definition => 'Sèche',
    GymGoal.maintenance => 'Maintien',
    GymGoal.custom => 'Personnalisé',
  };

  @override
  String gymGoalDescription(GymGoal goal) => switch (goal) {
    GymGoal.volume =>
      'Prendre du muscle · manger un peu plus que ce que tu dépenses',
    GymGoal.definition => 'Perdre du gras sans perdre de muscle',
    GymGoal.maintenance => 'Garder ton poids et rester performant',
    GymGoal.custom => 'C’est toi qui fixes les chiffres',
  };

  @override
  String sex(Sex value) => value == Sex.male ? 'Homme' : 'Femme';

  @override
  String activity(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Sédentaire',
    ActivityLevel.light => 'Léger',
    ActivityLevel.moderate => 'Modéré',
    ActivityLevel.active => 'Élevé',
    ActivityLevel.veryActive => 'Très élevé',
  };

  @override
  String activityDescription(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Peu ou pas d’exercice',
    ActivityLevel.light => 'Entraînement 1 à 3 jours par semaine',
    ActivityLevel.moderate => 'Entraînement 3 à 5 jours par semaine',
    ActivityLevel.active => 'Entraînement 6 à 7 jours par semaine',
    ActivityLevel.veryActive =>
      'Entraînement intense tous les jours ou travail physique',
  };

  @override
  String repeatability(Repeatability r) => switch (r) {
    Repeatability.free => 'Sans limite',
    Repeatability.moderate => 'Avec modération',
    Repeatability.limited => 'À limiter',
  };

  @override
  String repeatabilityHint(Repeatability r) => switch (r) {
    Repeatability.free => 'Tu peux en reprendre autant que tu veux',
    Repeatability.moderate => 'Mieux vaut ne pas en abuser dans la semaine',
    Repeatability.limited => 'Seulement de temps en temps',
  };

  @override
  Map<String, String> get ingredientCategories => const {
    'Proteínas': 'Protéines',
    'Carbohidratos': 'Féculents',
    'Legumbres': 'Légumineuses',
    'Verduras': 'Légumes',
    'Frutas': 'Fruits',
    'Lácteos y huevos': 'Produits laitiers et œufs',
    'Grasas y frutos secos': 'Matières grasses et fruits secs',
    'Otros': 'Autres',
  };

  @override
  Map<String, String> get foodTags => const {
    'Pasta': 'Pâtes',
    'Arroz': 'Riz',
    'Carne': 'Viande',
    'Pescado': 'Poisson',
    'Verduras': 'Légumes',
    'Legumbres': 'Légumineuses',
    'Huevos': 'Œufs',
    'Sopa': 'Soupe',
    'Ensalada': 'Salade',
    'Rápido': 'Rapide',
    'De aprovechar': 'Restes',
    'Capricho': 'Plaisir',
  };

  @override
  Map<String, String> get themeNames => const {
    'teal': 'Bleu-vert',
    'sunset': 'Coucher de soleil',
    'grape': 'Raisin',
    'ocean': 'Océan',
    'forest': 'Forêt',
    'ruby': 'Rubis',
    'amber': 'Ambre',
    'midnight': 'Minuit',
    'crimson': 'Cramoisi',
  };

  @override
  Map<String, String> get homeUnits => const {
    'loncha': 'tranche',
    'filete': 'escalope',
    'unidad': 'unité',
    'rodaja': 'rondelle',
    'cucharada': 'cuillère',
    'puñado': 'poignée',
    'vaso': 'verre',
    'ración': 'portion',
    'muslo': 'cuisse',
    'lomo': 'pavé',
    'lata': 'boîte',
    'plato': 'assiette',
    'rebanada': 'tranche',
    'bol': 'bol',
    'racimo': 'grappe',
    'tajada': 'part',
    'porción': 'portion',
    'cazo': 'dosette',
    'cucharadita': 'cuillère à café',
  };

  // ======================= NAVIGATION =======================

  @override
  String get tabToday => 'Aujourd’hui';
  @override
  String get tabWeek => 'Semaine';
  @override
  String get tabMeals => 'Repas';
  @override
  String get tabShopping => 'Courses';
  @override
  String get tabMore => 'Plus';

  // ======================= TUTORIEL =======================

  @override
  String get onbLanguageTitle => 'Choisis ta langue';
  @override
  String get onbLanguageBody =>
      'Tu pourras la changer quand tu veux dans les Réglages.';
  @override
  String get onbLanguageContinue => 'Continuer';

  @override
  String get onbWelcomeTitle => 'Bienvenue dans Meal Planner';
  @override
  String get onbWelcomeBody =>
      'Décide ce que tu manges cette semaine, laisse la liste de courses '
      's’écrire toute seule et note ce que tu manges vraiment. Ce tour '
      'd’horizon prend trente secondes.';

  @override
  String get onbPlannerTitle => 'Planifie ta semaine';
  @override
  String get onbPlannerBody =>
      'Une grille avec tes sept jours. Touche un repas pour choisir un plat, ou '
      'appuie sur « Au hasard » et laisse l’appli remplir la semaine. Fais '
      'glisser un plat pour le changer de jour, verrouille les jours déjà '
      'réglés et marque ceux où tu manges dehors.';

  @override
  String get onbMealsTitle => 'Tes repas';
  @override
  String get onbMealsBody =>
      'C’est ton catalogue de plats. Ajoute-les à la main, scanne un code-barres '
      'ou pars des repas d’exemple. Chaque plat garde ses ingrédients, et c’est '
      'de là que sort la liste de courses.';

  @override
  String get onbShoppingTitle => 'La liste s’écrit toute seule';
  @override
  String get onbShoppingBody =>
      'Elle rassemble les ingrédients de tout ce que tu as planifié, les '
      'regroupe par rayon et additionne les quantités. Coche au fur et à mesure '
      'et active le mode gros caractères pour le supermarché.';

  @override
  String get onbTodayTitle => 'Note ce que tu manges';
  @override
  String get onbTodayBody =>
      'Dans l’onglet Aujourd’hui, tu coches les repas prévus ou tu ajoutes '
      'autre chose. Tu peux aussi noter ton poids, ton eau et un mot sur la '
      'journée.';

  @override
  String get onbGymTitle => 'Mode Gym (facultatif)';
  @override
  String get onbGymBody =>
      'Si tu t’entraînes, active-le dans Plus › Mode Gym. Tu lui donnes ton '
      'objectif et il calcule tes calories et tes protéines du jour, puis te '
      'montre où tu en es. Si ça ne t’intéresse pas, laisse-le éteint : rien ne '
      'change.';

  @override
  String get onbReadyTitle => 'Et voilà, c’est tout';
  @override
  String get onbReadyBody =>
      'Pour bien démarrer : ajoute quelques repas d’exemple, puis appuie sur '
      '« Au hasard » dans l’onglet Semaine. Tu peux revoir ce tutoriel quand tu '
      'veux depuis les Réglages.';

  @override
  String get onbSkip => 'Passer';
  @override
  String get onbNext => 'Suivant';
  @override
  String get onbBack => 'Retour';
  @override
  String get onbStart => 'C’est parti';

  // ======================= RÉGLAGES =======================

  @override
  String get settingsTitle => 'Réglages';
  @override
  String get sectionLanguage => 'Langue';
  @override
  String get sectionAppearance => 'Apparence';
  @override
  String get sectionColorTheme => 'Thème de couleur';
  @override
  String get sectionOnOpen => 'À l’ouverture de l’appli';
  @override
  String get sectionAi => 'Assistant IA (Gemini)';
  @override
  String get sectionBackup => 'Sauvegarde';
  @override
  String get sectionHelp => 'Aide';
  @override
  String get sectionAbout => 'À propos';

  @override
  String get languageSubtitle => 'Change la langue de toute l’appli';

  @override
  String get modeSystem => 'Système';
  @override
  String get modeLight => 'Clair';
  @override
  String get modeDark => 'Sombre';

  @override
  String get amoledTitle => 'Noir AMOLED';
  @override
  String get amoledSubtitle => 'Fonds noirs purs en mode sombre';

  @override
  String get colorIntensity => 'Intensité de la couleur';
  @override
  List<String> get intensityLabels => const [
    'Douce',
    'Équilibrée',
    'Vive',
    'Intense',
  ];

  @override
  String get startTabAuto => 'Automatique';

  @override
  String get replayTutorialTitle => 'Revoir le tutoriel';
  @override
  String get replayTutorialSubtitle => 'Le tour de bienvenue, depuis le début';

  @override
  String get aboutSubtitle => 'Version 2.0 · Fait avec Flutter';

  @override
  String get backupIntro =>
      'Enregistre TOUT (plats, semaines, garde-manger et journal) dans un '
      'fichier. Ta clé IA n’est pas incluse, par sécurité.';
  @override
  String get exportBackup => 'Exporter la sauvegarde';
  @override
  String get exportBackupSubtitle => 'Partage ou enregistre le fichier .json';
  @override
  String get restoreBackup => 'Restaurer une sauvegarde';
  @override
  String get restoreBackupSubtitle => 'Remplace tes données actuelles';
  @override
  String get backupShareSubject => 'Sauvegarde Meal Planner';
  @override
  String get restoreConfirmBody =>
      'Cela remplacera tes plats, tes semaines, ton garde-manger et ton journal '
      'par ceux de la sauvegarde. Il faudra redémarrer l’appli ensuite.\n\n'
      'Tu es sûr de vouloir continuer ?';
  @override
  String get restore => 'Restaurer';
  @override
  String get backupRestored =>
      'Sauvegarde restaurée. Ferme et rouvre l’appli pour la voir.';

  @override
  String get aiIntro =>
      'Avec ta clé Google Gemini gratuite, tu peux estimer les macros d’un plat '
      'à partir d’un texte ou d’une photo. Récupère-la sur '
      'aistudio.google.com/apikey';
  @override
  String get apiKeyLabel => 'Clé d’API';
  @override
  String get modelLabel => 'Modèle';
  @override
  String modelHelper(String model) => 'Par défaut : $model';
  @override
  String get aiEnabled =>
      'IA activée : tu peux estimer avec une photo ou du texte.';
  @override
  String get aiDisabled => 'Sans clé : l’estimation par IA est désactivée.';

  // ======================= « PLUS » =======================

  @override
  String get moreTitle => 'Plus';
  @override
  String get statDishes => 'plats';
  @override
  String get statWeeks => 'semaines';
  @override
  String get statStreak => 'jours de suite';

  @override
  String get sectionYourFood => 'Ta cuisine';
  @override
  String get addMealTitle => 'Ajouter un repas';
  @override
  String get addMealSubtitle => 'Crée un nouveau plat pour ton catalogue';
  @override
  String get myIngredientsTitle => 'Mes ingrédients';
  @override
  String get myIngredientsSubtitle =>
      'Garde-manger avec mesures maison et stock';
  @override
  String get giveIdeasTitle => 'Donne-moi des idées';
  @override
  String get giveIdeasSubtitle => 'Que l’IA te propose de nouveaux plats';
  @override
  String get rouletteTitle => 'Roulette du dîner';
  @override
  String get rouletteSubtitle => 'Pour quand tu ne veux même pas décider';

  @override
  String get sectionProgress => 'Progression';
  @override
  String get statsTitle => 'Statistiques';
  @override
  String get statsSubtitle => 'Moyennes, série, poids et jours réussis';
  @override
  String get gymModeTitle => 'Mode Gym';
  @override
  String gymModeActive(String goal) => 'Actif · $goal';
  @override
  String get gymModeNoGoal => 'sans objectif';
  @override
  String get gymModeSubtitle => 'Objectifs de calories et de protéines';

  @override
  String get sectionApp => 'Application';
  @override
  String get settingsSubtitle => 'Thème, langue, IA, sauvegarde';

  // ======================= AUJOURD’HUI / JOURNAL =======================

  @override
  String get todayScreenTitle => 'Journal';
  @override
  String get today => 'Aujourd’hui';
  @override
  String get yesterday => 'Hier';
  @override
  String get chooseDay => 'Choisis le jour';
  @override
  String get previousDay => 'Jour précédent';
  @override
  String get nextDay => 'Jour suivant';

  @override
  String get menuCopyYesterday => 'Copier la journée d’hier';
  @override
  String get menuDayNote => 'Note du jour';
  @override
  String get menuWhatFits => 'Qu’est-ce qui rentre dans ce qu’il me reste ?';
  @override
  String get menuRoulette => 'Roulette du dîner';
  @override
  String get menuClearDay => 'Vider cette journée';

  @override
  String get whatYouveHad => 'Ce que tu as mangé';
  @override
  String get nothingLoggedYet =>
      'Rien de noté pour l’instant. Coche les repas prévus ci-dessus ou appuie '
      'sur « Ajouter ».';
  @override
  String get otherSlot => 'Autres';

  @override
  String get adjustAmount => 'Ajuster la quantité';
  @override
  String howMuchOf(String dish) => 'Tu as mangé combien de $dish ?';
  @override
  String get oneServing => '1 portion';
  @override
  String servingsCount(String amount) => '$amount portions';
  @override
  String removedItem(String name) => 'Retiré : $name';

  @override
  String get needTargetForFits =>
      'Règle ton objectif dans le Mode Gym pour utiliser ça';
  @override
  String get alreadyOverToday => 'Tu as déjà dépassé ton objectif du jour.';
  @override
  String kcalLeftFits(int left) =>
      'Il te reste $left kcal. Voici ce qui rentre, du plus protéiné au moins :';
  @override
  String get nothingFitsCatalog => 'Rien dans ton catalogue ne rentre.';

  @override
  String get yesterdayWasEmpty => 'Rien de noté hier';
  @override
  String copiedMeals(int n) => '$n repas copiés depuis hier';
  @override
  String get dayAlreadyEmpty => 'Cette journée est déjà vide';
  @override
  String get dayCleared => 'Journée vidée';

  @override
  String get weightToday => 'Poids du jour';
  @override
  String get weight => 'Poids';
  @override
  String get logWeight => 'Noter le poids';
  @override
  String get weightSubtitle => 'Sert à ton graphique de progression';

  @override
  String get noteHint => 'Séance jambes, dîner dehors…';

  @override
  String get manualEntry => 'Saisie manuelle';
  @override
  String get manualEntrySubtitle =>
      'Écris un nom, des calories et des protéines';
  @override
  String get searchYourMeals => 'Chercher dans tes repas';
  @override
  String get noResultsUseManual =>
      'Aucun résultat. Utilise la saisie manuelle.';
  @override
  String get noMacrosLoggedAsZero => 'Sans macros (compté comme 0)';
  @override
  String get youEatThisOften => 'Tu en manges souvent';
  @override
  String addedItem(String name) => 'Ajouté : $name';

  @override
  String get plannedForThisDay => 'Ce que tu avais prévu';
  @override
  String get nothingPlannedThisDay => 'Rien de prévu pour cette journée.';

  @override
  String hadKcalAndProtein(int kcal, int protein) =>
      'Tu en es à $kcal kcal et $protein g de protéines.';
  @override
  String get setUpGymProfile =>
      'Complète ton profil dans le Mode Gym pour voir tes objectifs.';
  @override
  String kcalLeft(int n) => 'Il te reste $n kcal';
  @override
  String kcalOver(int n) => 'Tu as dépassé de $n kcal';
  @override
  String get proteinMet => 'Protéines atteintes';
  @override
  String streakBadge(int days) =>
      days == 1 ? 'Série de 1 jour' : 'Série de $days jours';
  @override
  String ofTarget(int target) => 'sur $target';

  @override
  String get water => 'Eau';
  @override
  String waterGlasses(int n) => n == 1 ? '1 verre d’eau' : '$n verres d’eau';

  // ======================= PLANIFICATEUR =======================

  @override
  String get plannerTitle => 'Planificateur';
  @override
  String get viewNormal => 'Vue normale';
  @override
  String get viewCompact => 'Vue compacte';

  @override
  String get menuGoToThisWeek => 'Aller à la semaine en cours';
  @override
  String get menuWeekDate => 'Date de cette semaine';
  @override
  String get menuDuplicateWeek => 'Dupliquer la semaine';
  @override
  String get menuImportWeek => 'Importer une semaine';
  @override
  String get menuExportWeek => 'Exporter la semaine';
  @override
  String get menuShareAsText => 'Partager en texte';

  @override
  String get randomize => 'Au hasard';
  @override
  String get howToRandomize => 'Comment tirer au sort';
  @override
  String get onlyFillGaps => 'Remplir seulement les trous';
  @override
  String get onlyFillGapsSubtitle => 'Ne touche pas à ce que tu as déjà mis';
  @override
  String get useLeftovers => 'Profiter des restes';
  @override
  String get useLeftoversSubtitle =>
      'Les plats qui font plusieurs portions reviennent au repas suivant';
  @override
  String get onlyDishesWithMacros => 'Seulement les plats avec macros';
  @override
  String get aimForMyCalories => 'Viser mes calories';
  @override
  String get aimForMyCaloriesSubtitle =>
      'Essaie de rapprocher chaque journée de ton objectif';
  @override
  String busyDaysMarked(int n) => n == 1
      ? '1 jour marqué « je suis pressé »'
      : '$n jours marqués « je suis pressé »';
  @override
  String get busyDaysSubtitle => 'Ils ne reçoivent que des plats rapides';
  @override
  String get randomizerOptions => 'Options du tirage';

  @override
  String get weekDuplicated => 'Semaine dupliquée';
  @override
  String get weekDuplicateFailed =>
      'Impossible de dupliquer (nombre maximum de semaines)';
  @override
  String get noWeekIsToday =>
      'Aucune semaine n’est calée sur la date d’aujourd’hui. Utilise « Date de '
      'cette semaine ».';
  @override
  String get pickAnyDayOfWeek => 'Choisis n’importe quel jour de cette semaine';
  @override
  String get noMealsToExport => 'Aucun repas à exporter';
  @override
  String get weekShareSubject => 'Planificateur hebdomadaire';
  @override
  String get weekMenuSubject => 'Menu de la semaine';
  @override
  String importedIntoWeek(int n) => 'Planificateur importé dans la semaine $n';

  @override
  String get addWeek => 'Ajouter une semaine';
  @override
  String get deleteCurrentWeek => 'Supprimer la semaine actuelle';
  @override
  String get deleteWeekTitle => 'Supprimer la semaine';
  @override
  String deleteWeekBody(String label) =>
      'Le planning de « $label » sera effacé. Tu confirmes ?';
  @override
  String maxWeeks(int n) => 'Maximum de $n semaines';
  @override
  String get cannotDeleteOnlyWeek =>
      'Tu ne peux pas supprimer ta seule semaine';

  @override
  String get todayBadge => 'AUJ.';
  @override
  String get dayOptions => 'Options du jour';
  @override
  String get unlockDay => 'Déverrouiller le jour';
  @override
  String get lockDay => 'Verrouiller le jour';
  @override
  String get clearBusyDay => 'Retirer « je suis pressé »';
  @override
  String get markBusyDay => 'Je suis pressé (plats rapides)';
  @override
  String get eatingInAgain => 'Je remange à la maison';
  @override
  String get eatingOutThisDay => 'Ce jour-là je mange dehors';
  @override
  String get clearDay => 'Vider la journée';
  @override
  String get eatingOutNotice =>
      'Repas dehors : pas de planning ni de courses pour ce jour.';
  @override
  String dayClearedNamed(String day) => '$day vidé';

  @override
  String get tapToChoose => 'Touche pour choisir';
  @override
  String get addToMyCatalog => 'Ajouter à mon catalogue';
  @override
  String addedToCatalog(String name) => 'Ajouté à ton catalogue : $name';
  @override
  String get shuffleThisOne => 'Changer au hasard';
  @override
  String get dayIsLocked => 'Ce jour est verrouillé. Déverrouille-le d’abord.';
  @override
  String get searchDishOrIngredient => 'Chercher un plat ou un ingrédient';
  @override
  String get clearThisMeal => 'Vider ce repas';
  @override
  String get awayShort => 'Dehors';

  @override
  String weekNumber(int n) => 'Semaine $n';
  @override
  String get thisWeek => 'Cette semaine';

  // ======================= MES REPAS =======================

  @override
  String get myMealsTitle => 'Mes repas';
  @override
  String get scanProduct => 'Scanner un produit';
  @override
  String get scanProductSubtitle => 'Remplit les données depuis le code-barres';
  @override
  String get addByHand => 'Ajouter à la main';
  @override
  String get addByHandSubtitle => 'Pour le frais ou ce qui n’a pas de code';
  @override
  String get exampleMeals => 'Repas d’exemple';
  @override
  String get sort => 'Trier';
  @override
  String get sortNameAsc => 'Nom (A-Z)';
  @override
  String get sortNameDesc => 'Nom (Z-A)';
  @override
  String get sortMostUsed => 'Les plus utilisés';
  @override
  String get searchByNameOrIngredient => 'Chercher par nom ou ingrédient';
  @override
  String get canCookNow => 'Je peux le cuisiner maintenant';
  @override
  String get withMacros => 'Avec macros';
  @override
  String get withoutMacros => 'Sans macros';
  @override
  String get noSearchResults => 'Aucun résultat pour ta recherche.';

  @override
  String ingredientCount(int n) => n == 1 ? '1 ingrédient' : '$n ingrédients';
  @override
  String servingsMadeCount(int n) => n == 1 ? '1 portion' : '$n portions';
  @override
  String get highInProtein => 'Riche en protéines';

  @override
  String get unfavourite => 'Retirer des favoris';
  @override
  String get markFavourite => 'Mettre en favori';
  @override
  String get proposeAgain => 'Le reproposer';
  @override
  String get notInTheMood => 'Pas envie (2 semaines)';
  @override
  String get duplicate => 'Dupliquer';
  @override
  String get copySuffix => 'copie';
  @override
  String snoozedMessage(String name) =>
      '« $name » ne sortira pas au hasard pendant 2 semaines';
  @override
  String get deleteMealTitle => 'Supprimer le repas';
  @override
  String deleteMealBody(String name) =>
      'Tu es sûr de vouloir supprimer « $name » ?';
  @override
  String deletedItem(String name) => 'Supprimé : $name';

  @override
  String get noMealsYet => 'Tu n’as pas encore de repas';
  @override
  String get noMealsYetSubtitle =>
      'Commence avec nos repas d’exemple ou crée les tiens.';
  @override
  String get seeExampleMeals => 'Voir les repas d’exemple';

  // ======================= LISTE DE COURSES =======================

  @override
  String get shoppingListTitle => 'Liste de courses';
  @override
  String get superMarketMode => 'Mode supermarché (gros caractères)';
  @override
  String get checkAll => 'Tout cocher';
  @override
  String get uncheckAll => 'Tout décocher';
  @override
  String get showBought => 'Afficher ce qui est acheté';
  @override
  String get hideBought => 'Masquer ce qui est acheté';
  @override
  String get shareList => 'Partager la liste';
  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';
  @override
  String get recurringItems => 'Les incontournables';
  @override
  String get listCopied => 'Liste copiée';
  @override
  String get shoppingShareSubject => 'Liste de courses';
  @override
  String get recurringItemsBody =>
      'Ajoute-les à la liste de cette semaine d’un seul geste.';
  @override
  String get addToListTitle => 'Ajouter à la liste';
  @override
  String get ingredientOrProduct => 'Ingrédient ou produit';
  @override
  String get listComplete => 'Liste terminée !';
  @override
  String inCart(int done, int total) => '$done sur $total dans le caddie';
  @override
  String get addedByHand => 'Ajouté à la main';
  @override
  String get emptyListTitle => 'La liste est vide';
  @override
  String get emptyListSubtitle =>
      'Planifie des repas pour cette semaine ou ajoute des articles avec le '
      'bouton « Ajouter ».';

  @override
  List<String> get recurringItemsList => const [
    'Essuie-tout',
    'Papier toilette',
    'Café',
    'Lait',
    'Pain',
    'Huile d’olive',
    'Sel',
    'Sacs poubelle',
    'Lessive',
    'Œufs',
    'Eau',
    'Fruits variés',
  ];

  // ======================= AJOUTER / MODIFIER UN REPAS =======================

  @override
  String get editMeal => 'Modifier le repas';
  @override
  String get addMeal => 'Ajouter un repas';
  @override
  String prefillNotice(String origin) =>
      '$origin. Vérifie et ajuste avant d’enregistrer.';
  @override
  String get mealNameLabel => 'Nom du repas';
  @override
  String get favourite => 'Favori';
  @override
  String get photo => 'Photo';
  @override
  String get takePhoto => 'Prendre une photo';
  @override
  String get chooseFromGallery => 'Choisir dans la galerie';
  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get ingredientsTitle => 'Ingrédients';
  @override
  String get scan => 'Scanner';
  @override
  String get searchIngredient => 'Chercher un ingrédient';
  @override
  String get byHand => 'À la main';
  @override
  String get ingredientsTextLabel => 'Ingrédients (texte)';
  @override
  String get ingredientsTextHelper =>
      'Sépare-les par des virgules : tomate, pâtes, fromage';
  @override
  String get nutritionPerServing => 'Valeurs nutritionnelles (par portion)';
  @override
  String get estimateWithAi => 'Estimer avec l’IA';
  @override
  String totalLine(int kcal, int protein) =>
      'Total : $kcal kcal · $protein g de protéines';

  @override
  String get whichSlots => 'À quels repas ça convient ?';
  @override
  String get ifNoneAllApply => 'Si tu n’en coches aucun, ça vaudra pour tous.';
  @override
  String get tagsTitle => 'Étiquettes';
  @override
  String get tagsHelp =>
      'Elles évitent que ta semaine ne soit faite que de pâtes.';

  @override
  String get detailsTitle => 'Détails';
  @override
  String get prepTime => 'Temps';
  @override
  String get costPerServing => 'Coût/portion';
  @override
  String get servingsMadeTitle => 'Portions obtenues';
  @override
  String servingsMadeMulti(int n) =>
      'Tu cuisines une fois et tu manges $n fois';
  @override
  String get servingsMadeOne => 'Cuisiné pour un seul repas';
  @override
  String get recipeOrNotes => 'Recette ou notes';
  @override
  String get recipeOrNotesHelper => 'Étapes, astuces, un lien…';

  @override
  String get pleaseCompleteName => 'Merci de renseigner le nom';
  @override
  String get pleaseCompleteNameAndIngredients =>
      'Merci de renseigner le nom et les ingrédients';
  @override
  String renamedTo(String name) =>
      'Renommé en « $name » (dans tes semaines aussi)';
  @override
  String get mealUpdated => 'Repas mis à jour';
  @override
  String get mealAdded => 'Repas ajouté';
  @override
  String get aiMacrosFilled =>
      'Macros estimées par l’IA. Vérifie-les avant d’enregistrer.';

  @override
  String get addIngredientTitle => 'Ajouter un ingrédient';
  @override
  String get editIngredientTitle => 'Modifier l’ingrédient';
  @override
  String get kcalPerUnit => 'kcal/unité';
  @override
  String get proteinPerUnit => 'prot/unité';

  // ======================= GARDE-MANGER =======================

  @override
  String get pantryTitle => 'Mes ingrédients';
  @override
  String get restoreDeleted => 'Récupérer les supprimés';
  @override
  String get presetsRestored => 'Les ingrédients de l’appli sont revenus';
  @override
  String get tabFromApp => 'De l’appli';
  @override
  String get tabMine => 'Les miens';
  @override
  String get searchIngredientHint => 'Chercher un ingrédient';
  @override
  String addedToMine(String name) => '« $name » ajouté à « Les miens »';
  @override
  String get pantryEmptyMine =>
      'Tu n’as pas encore ajouté d’ingrédients.\nScanne un produit ou appuie '
      'sur « Ajouter ».';

  @override
  String haveInStock(String amount) => 'j’en ai $amount';
  @override
  String useSoonExpires(int days) => days == 1
      ? 'À finir ! Périme demain'
      : 'À finir ! Périme dans $days jours';
  @override
  String expiresInDays(int days) => 'Périme dans $days jours';

  @override
  String get newIngredient => 'Nouvel ingrédient';
  @override
  String get unitLabel => 'Unité';
  @override
  String get unitHint => 'tranche, escalope…';
  @override
  String get gramsPerUnitShort => 'g/unité';
  @override
  String get unitTip =>
      'Astuce : l’emballage indique souvent les grammes (par ex. « 10 tranches '
      '· 200 g » → 20 g par tranche).';
  @override
  String get unitTipRecalc =>
      ' Les macros se recalculent toutes seules quand tu changes les grammes.';
  @override
  String get categoryLabel => 'Catégorie';
  @override
  String get repeatQuestion => 'Ça peut revenir souvent ?';
  @override
  String get haveAtHomeQuestion => 'Tu en as à la maison ?';
  @override
  String stockHelper(String unit) => 'En $unit';
  @override
  String get unitsFallback => 'unités';
  @override
  String get expiryDate => 'Date de péremption';
  @override
  String get expiryShort => 'Péremption';
  @override
  String get removeExpiry => 'Retirer la péremption';

  // ======================= CHOIX DE LA PORTION =======================

  @override
  String get units => 'Unités';
  @override
  String get grams => 'Grammes';
  @override
  String get productHasNoMacros =>
      'Ce produit n’a pas de macros. Ajoute-les à la main.';
  @override
  String get saveToMyIngredients => 'Enregistrer dans Mes ingrédients';
  @override
  String get whichMeasure => 'En quelle mesure ?';
  @override
  String get howMany => 'Combien ?';
  @override
  String gramsPer(String unit) => 'g par $unit';
  @override
  String get howManyGrams => 'Combien de grammes ?';
  @override
  String get howManyServings => 'Combien de portions ?';
  @override
  String oneServingIs(String size) => '1 portion = $size';
  @override
  String get proteinGramsShort => 'protéines (g)';

  // ======================= MODE GYM =======================

  @override
  String get gymIntro =>
      'Active le Mode Gym pour planifier tes repas selon ton objectif (prise de '
      'masse, sèche…) sans te noyer dans le jargon.';
  @override
  String get enableGymMode => 'Activer le Mode Gym';
  @override
  String get enableGymModeSubtitle =>
      'Affiche les options de suivi pour la salle';
  @override
  String get yourGoal => 'Ton objectif';
  @override
  String get yourGoalSubtitle => 'Choisis ce que tu veux obtenir. Sans jargon.';
  @override
  String get yourTargets => 'Tes objectifs';
  @override
  String estimatedExpenditure(int kcal) => 'Dépense estimée : $kcal kcal/jour';
  @override
  String get setYourOwnFigures =>
      'Fixe tes propres chiffres de calories et de protéines.';
  @override
  String get completeProfileToCalculate =>
      'Complète ton profil pour calculer tes objectifs.';
  @override
  String get adjustFigures => 'Ajuster les chiffres';
  @override
  String get editProfile => 'Modifier le profil';
  @override
  String get completeProfile => 'Compléter le profil';
  @override
  String get yourFigures => 'Tes chiffres';
  @override
  String get todaysLog => 'Journal du jour';
  @override
  String get todaysLogSubtitle =>
      'Note ce que tu manges et suis ta progression';
  @override
  String get mealsPerDay => 'Repas de la journée';
  @override
  String get mealsPerDaySubtitle =>
      'Choisis combien de repas tu planifies chaque jour.';
  @override
  String daysInARow(int days) =>
      days == 1 ? '1 jour d’affilée' : '$days jours d’affilée';
  @override
  String get noStreakYet => 'Pas encore de série';
  @override
  String get setTargetToCount => 'Fixe ton objectif pour commencer à compter.';
  @override
  String get logToStartStreak => 'Note ce que tu manges et lance la série.';
  @override
  String last7Days(int met, int days) =>
      '7 derniers jours : protéines atteintes $met fois sur $days.';

  // ======================= PROFIL GYM =======================

  @override
  String get yourProfile => 'Ton profil';
  @override
  String get profileIntro =>
      'C’est avec ça qu’on calcule tes objectifs. Ils sont enregistrés et tu '
      'peux les changer quand tu veux.';
  @override
  String get height => 'Taille';
  @override
  String get age => 'Âge';
  @override
  String get years => 'ans';
  @override
  String get sexTitle => 'Sexe';
  @override
  String get sexNote => 'Sert uniquement au calcul de la dépense calorique.';
  @override
  String get activityLevel => 'Niveau d’activité';
  @override
  String get fillToSeeTargets =>
      'Renseigne poids, taille et âge pour voir tes objectifs.';
  @override
  String targetsForGoal(String goal) => 'Tes objectifs · $goal';
  @override
  String get customFiguresNote =>
      'Dans « Personnalisé », tu pourras ajuster ces chiffres à la main.';
  @override
  String get saveProfile => 'Enregistrer le profil';
  @override
  String get profileSaved => 'Profil enregistré';
  @override
  String get checkProfileData =>
      'Vérifie tes données : poids, taille et âge valides';

  // ======================= STATISTIQUES =======================

  @override
  String get statisticsTitle => 'Statistiques';
  @override
  String get exportCsv => 'Exporter le journal (CSV)';
  @override
  String get csvSubject => 'Mon journal de repas';
  @override
  String daysRange(int n) => '$n jours';
  @override
  String get avgPerDay => 'Moyenne par jour';
  @override
  String get avgProtein => 'Protéines moyennes';
  @override
  String get daysMeetingProtein => 'Jours avec protéines atteintes';
  @override
  String get currentStreak => 'Série en cours';
  @override
  String get daysUnit => 'jours';

  @override
  String get yourWeight => 'Ton poids';
  @override
  String get weightNeedsTwoDays =>
      'Note ton poids au moins deux jours depuis l’écran du journal pour voir '
      'le graphique et la tendance.';
  @override
  String get sevenDayAverage => 'Moyenne sur 7 jours';

  @override
  String get achievementsTitle => 'Succès';
  @override
  String achievementsUnlocked(int unlocked, int total) =>
      '$unlocked sur $total débloqués';

  @override
  String get whatYouEatMost => 'Ce que tu manges le plus';
  @override
  String get nothingPlannedYet => 'Tu n’as encore rien planifié.';
  @override
  String timesInYourWeeks(int n) =>
      n == 1 ? '1 fois dans tes semaines' : '$n fois dans tes semaines';

  @override
  String get verdictNoTarget =>
      'Règle ton objectif dans le Mode Gym pour savoir où tu en es.';
  @override
  String get verdictNoData => 'Pas encore assez de données.';
  @override
  String get verdictGreat =>
      'Très bien : tu atteins tes protéines presque tous les jours.';
  @override
  String get verdictOk =>
      'Ça va, mais pas mal de jours passent à la trappe. Essaie d’ajouter une '
      'collation protéinée l’après-midi.';
  @override
  String get verdictLow =>
      'Tu manques de protéines la plupart des jours. Ajoute des plats « riches '
      'en protéines » à ton catalogue.';
  @override
  String adjustToKcal(int kcal) => 'Ajuster à $kcal kcal';
  @override
  String targetAdjusted(int kcal) => 'Objectif ajusté à $kcal kcal';
  @override
  String get noLogsInPeriod =>
      'Aucune entrée sur cette période pour l’instant.\nNote ce que tu manges '
      'dans l’onglet « Aujourd’hui » et tes moyennes s’afficheront ici.';

  @override
  Map<String, (String, String)> get achievements => const {
    'cocinero': ('Cuisinier', 'Crée 10 plats dans ton catalogue'),
    'chef': ('Chef', 'Atteins 50 plats'),
    'constante': ('Régulier', 'Note 7 journées'),
    'veterano': ('Vétéran', 'Note 100 journées'),
    'racha7': (
      'Une semaine parfaite',
      '7 jours d’affilée avec les protéines atteintes',
    ),
    'racha30': ('Inarrêtable', '30 jours de protéines d’affilée'),
    'planificador': ('Planificateur', 'Planifie 4 semaines'),
    'fotografo': ('Photographe', 'Mets une photo à 5 plats'),
    'proteico': ('Objectif atteint', 'Atteins tes protéines 30 jours au total'),
    'semanaperfecta': (
      'Semaine parfaite',
      'Une semaine entière planifiée de bout en bout',
    ),
  };

  // ======================= IA : ESTIMER =======================

  @override
  String get aiEstimateTitle => 'Estimer avec l’IA';
  @override
  String get aiEstimateIntro =>
      'Décris ce que tu as mangé et/ou ajoute une photo. L’IA estime les '
      'calories et les protéines (approximatif).';
  @override
  String get descriptionLabel => 'Description';
  @override
  String get descriptionHint =>
      'Ex. : une assiette de pâtes au thon, portion normale';
  @override
  String get gallery => 'Galerie';
  @override
  String get photoAdded => 'Photo ajoutée';
  @override
  String get estimating => 'Estimation…';
  @override
  String get estimateMacros => 'Estimer les macros';
  @override
  String get resultAdjustIt => 'Résultat (ajuste-le si tu veux)';
  @override
  String get useThisData => 'Utiliser ces données';
  @override
  String get couldNotOpenImage => 'Impossible d’ouvrir l’image.';
  @override
  String get missingGeminiKey => 'Ta clé Gemini est manquante';
  @override
  String get missingGeminiKeyBody =>
      'Pour utiliser l’estimation par IA, ajoute ta clé d’API Google Gemini '
      'gratuite dans les Réglages.';
  @override
  String get goToSettings => 'Aller aux Réglages';

  // ======================= IA : IDÉES =======================

  @override
  String get whatDoYouFancy => 'Tu as envie de quoi ?';
  @override
  String get whatDoYouFancyHint => 'Dîners rapides et protéinés, sans poisson…';
  @override
  String get usePantry => 'Utiliser mon garde-manger';
  @override
  String get usePantrySubtitle => 'Privilégie les ingrédients que tu as déjà';
  @override
  String get thinking => 'Réflexion…';
  @override
  String get proposeDishes => 'Proposer des plats';
  @override
  String get proposals => 'Propositions';
  @override
  String get proposalsDisclaimer =>
      'Ce sont des estimations : vérifie-les avant de te fier aux macros.';
  @override
  String get writeWhatYouWant => 'Écris quel genre de plats tu veux.';
  @override
  String get aiSuggestNotConfigured =>
      'Pour que l’IA te propose des plats, ajoute ta clé Gemini gratuite dans '
      'les Réglages.';

  @override
  List<String> get ideaPresets => const [
    'Dîners légers de moins de 400 kcal',
    'Repas riches en protéines pour après la salle',
    'Plats pas chers qui remplissent bien',
    'Petits-déjeuners rapides en moins de 10 minutes',
    'Recettes anti-gaspi avec ce que j’ai',
  ];

  // ======================= CHERCHER UN INGRÉDIENT =======================

  @override
  String get searchIngredientTitle => 'Chercher un ingrédient';
  @override
  String get searchIngredientPlaceholder => 'Chercher (poulet, riz, œuf…)';
  @override
  String get noResultsTryAnother => 'Aucun résultat. Essaie un autre mot.';
  @override
  String get otherQuantity => 'Autre quantité';
  @override
  String howManyUnits(String unit) => 'Combien de $unit ?';
  @override
  String oneUnitIs(String unit, int kcal, int protein) =>
      '1 $unit = $kcal kcal · $protein g';

  // ======================= ROULETTE =======================

  @override
  String rouletteFor(String slot) => 'Roulette · $slot';
  @override
  String get whatsForDinner => 'Je mange quoi ce soir ?';
  @override
  String get onlyWithWhatIHave => 'Seulement avec ce que j’ai à la maison';
  @override
  String get spin => 'Tourner !';
  @override
  String get spinAgain => 'Encore';
  @override
  String get putItInThePlan => 'L’ajouter au planning';
  @override
  String noDishesFor(String slot) => 'Tu n’as aucun plat pour $slot';
  @override
  String assignedTo(String dish, String day, String slot) =>
      '$dish → $day, $slot';

  // ======================= SCANNER =======================

  @override
  String get scanProductTitle => 'Scanner un produit';
  @override
  String get scanIngredientTitle => 'Scanner un ingrédient';
  @override
  String get switchCamera => 'Changer de caméra';
  @override
  String get flash => 'Flash';
  @override
  String get aimAtBarcode =>
      'Vise le code-barres du produit (il lit aussi les QR)';
  @override
  String get searchingProduct => 'Recherche du produit…';
  @override
  String get productNotFoundTitle => 'Produit introuvable';
  @override
  String productNotFoundBody(String code) =>
      'Aucune donnée pour le code $code. Tu peux l’ajouter à la main.';
  @override
  String get keepScanning => 'Continuer à scanner';
  @override
  String scannedProductNote(String basis) =>
      'Produit scanné (OpenFoodFacts · $basis)';
  @override
  String get basisPerServing => 'par portion';
  @override
  String get basisPer100g => 'pour 100 g';
  @override
  String get basisNoData => 'sans données';
  @override
  String unknownProduct(String barcode) => 'Produit $barcode';

  // ======================= REPAS D’EXEMPLE =======================

  @override
  String get exampleMealsTitle => 'Repas d’exemple';
  @override
  String get selectAll => 'Tout';
  @override
  String get unselectAll => 'Tout retirer';
  @override
  String get alreadyInCatalog => 'Déjà dans ton catalogue';
  @override
  String get selectMeals => 'Sélectionne des repas';
  @override
  String addNMeals(int n) => n == 1 ? 'Ajouter 1 repas' : 'Ajouter $n repas';
  @override
  String addedNMeals(int n) => n == 1
      ? '1 repas ajouté à ton catalogue'
      : '$n repas ajoutés à ton catalogue';
  @override
  String get presetNotice =>
      'Ce sont des points de départ, entièrement modifiables : ajoute celui qui '
      't’arrange puis ajuste ses ingrédients ou ses macros.';

  // ======================= MESSAGES DU PROVIDER =======================

  @override
  String get noMealsToAssign => 'Aucun repas à attribuer';
  @override
  String get noSlotsConfigured => 'Aucun repas configuré';
  @override
  String noMealsWithMacrosFor(String slot) =>
      'Aucun repas avec macros pour $slot';
  @override
  String noMealsFor(String slot) => 'Aucun repas pour $slot';
  @override
  String maxWeeksReached(int n) => 'Maximum de $n semaines atteint';
  @override
  String importError(Object e) => 'Échec de l’import : $e';
  @override
  String get weekTextHeader => 'Menu de la semaine';
  @override
  String get outOfHome => 'repas dehors';
  @override
  String get shoppingTextHeader => 'Liste de courses';
  @override
  String get shoppingListIsEmpty => 'La liste est vide.';
  @override
  String get unitAbbrev => 'u';

  // ======================= SAUVEGARDE =======================

  @override
  String get backupInvalidFile => 'Ce fichier n’est pas une sauvegarde valide.';
  @override
  String get backupCorrupt => 'La sauvegarde est vide ou abîmée.';
  @override
  String get backupNothingRestored =>
      'Rien n’a pu être restauré depuis cette sauvegarde.';

  // ======================= GEMINI =======================

  @override
  String get geminiMissingKey =>
      'Ta clé d’API Gemini est manquante. Ajoute-la dans les Réglages.';
  @override
  String get geminiNeedTextOrPhoto =>
      'Écris une description ou ajoute une photo du plat.';
  @override
  String get geminiBadKey =>
      'La clé d’API n’est pas valide ou la requête a été refusée.';
  @override
  String get geminiForbidden =>
      'Clé d’API sans autorisation. Vérifie que tu l’as bien copiée.';
  @override
  String get geminiModelNotFound =>
      'Modèle introuvable. Vérifie son nom dans les Réglages.';
  @override
  String get geminiRateLimit =>
      'Tu as dépassé la limite de requêtes. Réessaie dans un instant.';
  @override
  String geminiError(int code) => 'Erreur Gemini (code $code).';
  @override
  String get geminiNoConnection =>
      'Impossible de joindre Gemini. Vérifie ta connexion.';
  @override
  String get geminiUnreadable => 'Réponse de Gemini illisible.';
  @override
  String get geminiNothingUseful => 'Gemini n’a rien renvoyé d’exploitable.';
  @override
  String get geminiNoEstimate =>
      'Gemini n’a pas renvoyé d’estimation. Essaie de mieux décrire.';
  @override
  String get geminiParseFail => 'Estimation de Gemini incompréhensible.';
  @override
  String get geminiCouldNotEstimate =>
      'L’IA n’a pas pu estimer les macros. Donne plus de détails.';
  @override
  String get geminiSuggestionsParseFail =>
      'Les propositions n’ont pas pu être lues.';
  @override
  String get geminiNoSuggestions => 'L’IA n’a proposé aucun plat.';

  // ======================= AJUSTEMENT DES CALORIES =======================

  @override
  String get gymNotGaining =>
      'Tu ne prends pas de poids : essaie 150 kcal de plus.';
  @override
  String get gymGainingTooFast => 'Tu prends trop vite : enlève 150 kcal.';
  @override
  String get gymNotLosing => 'Tu ne perds pas : essaie 150 kcal de moins.';
  @override
  String get gymLosingTooFast => 'Tu perds trop vite : ajoute 150 kcal.';

  // ======================= INTERFAZ LIMPIA =======================

  @override
  String get sectionInterface => 'Interface';
  @override
  String get cleanModeTitle => 'Interface épurée';
  @override
  String get cleanModeSubtitle =>
      'Masque les boutons secondaires, les filtres et les cartes en extra. '
      'Rien n’est perdu : tout passe dans les menus.';
  @override
  String get cleanModeHintTitle => 'Où est passé le reste ?';
  @override
  String get cleanModeHintBody =>
      'Les boutons disparus sont dans le menu ⋮ en haut. Appui long sur un '
      'repas pour ses options.';

  // ======================= WIDGETS DE INICIO =======================

  @override
  String get widgetsTitle => 'Widgets d’accueil';
  @override
  String get widgetsSubtitle => 'Ta journée d’un coup d’œil, sans ouvrir l’app';
  @override
  String get widgetsIntro =>
      'Ajoute-en un d’ici, ou appuie longuement sur un espace vide de ton '
      'écran d’accueil et cherche Meal Planner dans la liste des widgets.';
  @override
  String get widgetsRefreshNote =>
      'Ils se mettent à jour chaque fois que tu quittes l’app et suivent ton '
      'thème de couleur.';
  @override
  String get widgetTodayTitle => 'Aujourd’hui';
  @override
  String get widgetTodayDescription =>
      'Calories et protéines du jour, l’eau et ce qu’il te reste.';
  @override
  String get widgetNextTitle => 'La suite';
  @override
  String get widgetNextDescription =>
      'Le prochain repas de ton plan, et celui d’après.';
  @override
  String get widgetShoppingTitle => 'Liste de courses';
  @override
  String get widgetShoppingDescription =>
      'Ce qu’il manque encore dans le caddie cette semaine.';
  @override
  String get addToHomeScreen => 'Ajouter à l’écran d’accueil';
  @override
  String get widgetPinUnsupported =>
      'Ton lanceur ne laisse pas l’app le placer. Appuie longuement sur '
      'l’écran d’accueil et choisis-le dans la liste des widgets.';
  @override
  String get widgetNoPlan => 'Rien de prévu';
  @override
  String get widgetAllBought => 'Tout est acheté';
  @override
  String widgetItemsLeft(int n) =>
      n == 1 ? 'Il reste 1 article' : 'Il reste $n articles';
  @override
  String get widgetOnlyAndroid =>
      'Les widgets ne sont disponibles que sur Android.';
}
