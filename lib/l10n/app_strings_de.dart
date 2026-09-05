import '../models/gym_goal.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';
import 'app_strings.dart';

/// Deutsch.
class AppStringsDe extends AppStrings {
  const AppStringsDe();

  @override
  String get languageCode => 'de';
  @override
  String get aiLanguageName => 'German';

  // ======================= ALLGEMEIN =======================

  @override
  String get cancel => 'Abbrechen';
  @override
  String get save => 'Speichern';
  @override
  String get saveChanges => 'Änderungen speichern';
  @override
  String get add => 'Hinzufügen';
  @override
  String get added => 'Hinzugefügt';
  @override
  String get delete => 'Löschen';
  @override
  String get remove => 'Entfernen';
  @override
  String get close => 'Schließen';
  @override
  String get undo => 'Rückgängig';
  @override
  String get all => 'Alle';
  @override
  String get options => 'Optionen';
  @override
  String get more => 'Mehr';
  @override
  String get search => 'Suchen';
  @override
  String get show => 'Anzeigen';
  @override
  String get hide => 'Verbergen';
  @override
  String get name => 'Name';
  @override
  String get quantity => 'Menge';
  @override
  String get noResults => 'Keine Treffer.';

  @override
  String get protein => 'Eiweiß';
  @override
  String get calories => 'Kalorien';
  @override
  String get kcalPerDay => 'kcal/Tag';
  @override
  String get gramsPerDay => 'g/Tag';

  @override
  String proteinValue(int n) => '$n g Eiweiß';
  @override
  String macros(int kcal, int protein) => '$kcal kcal · $protein g Eiweiß';

  @override
  List<String> get weekdays => const [
        'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
        'Freitag', 'Samstag', 'Sonntag',
      ];
  @override
  List<String> get weekdaysShort =>
      const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  @override
  List<String> get months => const [
        'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
        'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
      ];
  @override
  List<String> get monthsShort => const [
        'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
        'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
      ];

  @override
  String longDate(DateTime d) =>
      '${weekdays[d.weekday - 1]}, ${d.day}. ${months[d.month - 1]}';

  @override
  String mealSlot(MealSlot slot) => switch (slot) {
        MealSlot.breakfast => 'Frühstück',
        MealSlot.lunch => 'Mittagessen',
        MealSlot.snack => 'Snack',
        MealSlot.dinner => 'Abendessen',
        MealSlot.preWorkout => 'Vor dem Training',
        MealSlot.postWorkout => 'Nach dem Training',
      };

  @override
  String gymGoal(GymGoal goal) => switch (goal) {
        GymGoal.volume => 'Masseaufbau',
        GymGoal.definition => 'Definition',
        GymGoal.maintenance => 'Halten',
        GymGoal.custom => 'Eigene Werte',
      };

  @override
  String gymGoalDescription(GymGoal goal) => switch (goal) {
        GymGoal.volume =>
          'Muskeln aufbauen · etwas mehr essen, als du verbrauchst',
        GymGoal.definition => 'Fett verlieren, ohne Muskeln zu verlieren',
        GymGoal.maintenance => 'Gewicht halten und leistungsfähig bleiben',
        GymGoal.custom => 'Du legst die Zahlen fest',
      };

  @override
  String sex(Sex value) => value == Sex.male ? 'Mann' : 'Frau';

  @override
  String activity(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Sitzend',
        ActivityLevel.light => 'Leicht',
        ActivityLevel.moderate => 'Mittel',
        ActivityLevel.active => 'Hoch',
        ActivityLevel.veryActive => 'Sehr hoch',
      };

  @override
  String activityDescription(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Wenig oder gar kein Sport',
        ActivityLevel.light => 'Training an 1-3 Tagen pro Woche',
        ActivityLevel.moderate => 'Training an 3-5 Tagen pro Woche',
        ActivityLevel.active => 'Training an 6-7 Tagen pro Woche',
        ActivityLevel.veryActive =>
          'Täglich hartes Training oder körperliche Arbeit',
      };

  @override
  String repeatability(Repeatability r) => switch (r) {
        Repeatability.free => 'Ohne Grenze',
        Repeatability.moderate => 'In Maßen',
        Repeatability.limited => 'Begrenzen',
      };

  @override
  String repeatabilityHint(Repeatability r) => switch (r) {
        Repeatability.free => 'Du kannst es so oft wiederholen, wie du willst',
        Repeatability.moderate => 'Lieber nicht übertreiben in der Woche',
        Repeatability.limited => 'Nur ab und zu',
      };

  @override
  Map<String, String> get ingredientCategories => const {
        'Proteínas': 'Eiweiß',
        'Carbohidratos': 'Kohlenhydrate',
        'Legumbres': 'Hülsenfrüchte',
        'Verduras': 'Gemüse',
        'Frutas': 'Obst',
        'Lácteos y huevos': 'Milchprodukte und Eier',
        'Grasas y frutos secos': 'Fette und Nüsse',
        'Otros': 'Sonstiges',
      };

  @override
  Map<String, String> get foodTags => const {
        'Pasta': 'Nudeln',
        'Arroz': 'Reis',
        'Carne': 'Fleisch',
        'Pescado': 'Fisch',
        'Verduras': 'Gemüse',
        'Legumbres': 'Hülsenfrüchte',
        'Huevos': 'Eier',
        'Sopa': 'Suppe',
        'Ensalada': 'Salat',
        'Rápido': 'Schnell',
        'De aprovechar': 'Reste',
        'Capricho': 'Genuss',
      };

  @override
  Map<String, String> get themeNames => const {
        'teal': 'Blaugrün',
        'sunset': 'Sonnenuntergang',
        'grape': 'Traube',
        'ocean': 'Ozean',
        'forest': 'Wald',
        'ruby': 'Rubin',
        'amber': 'Bernstein',
        'midnight': 'Mitternacht',
        'crimson': 'Karmesin',
      };

  @override
  Map<String, String> get homeUnits => const {
        'loncha': 'Scheibe',
        'filete': 'Filet',
        'unidad': 'Stück',
        'rodaja': 'Ring',
        'cucharada': 'Löffel',
        'puñado': 'Handvoll',
        'vaso': 'Glas',
        'ración': 'Portion',
        'muslo': 'Keule',
        'lomo': 'Stück',
        'lata': 'Dose',
        'plato': 'Teller',
        'rebanada': 'Scheibe',
        'bol': 'Schale',
        'racimo': 'Traube',
        'tajada': 'Stück',
        'porción': 'Portion',
        'cazo': 'Messlöffel',
        'cucharadita': 'Teelöffel',
      };

  // ======================= NAVIGATION =======================

  @override
  String get tabToday => 'Heute';
  @override
  String get tabWeek => 'Woche';
  @override
  String get tabMeals => 'Gerichte';
  @override
  String get tabShopping => 'Einkauf';
  @override
  String get tabMore => 'Mehr';

  // ======================= TUTORIAL =======================

  @override
  String get onbLanguageTitle => 'Wähle deine Sprache';
  @override
  String get onbLanguageBody =>
      'Du kannst sie jederzeit in den Einstellungen ändern.';
  @override
  String get onbLanguageContinue => 'Weiter';

  @override
  String get onbWelcomeTitle => 'Willkommen bei Meal Planner';
  @override
  String get onbWelcomeBody =>
      'Entscheide, was du diese Woche isst, lass die Einkaufsliste sich selbst '
      'schreiben und notiere, was du wirklich isst. Diese Runde dauert eine '
      'halbe Minute.';

  @override
  String get onbPlannerTitle => 'Plane deine Woche';
  @override
  String get onbPlannerBody =>
      'Ein Raster mit deinen sieben Tagen. Tippe auf eine Mahlzeit, um ein '
      'Gericht zu wählen, oder drücke „Zufall“ und lass die App die Woche '
      'füllen. Zieh ein Gericht auf einen anderen Tag, sperre die Tage, die '
      'schon stehen, und markiere die, an denen du auswärts isst.';

  @override
  String get onbMealsTitle => 'Deine Gerichte';
  @override
  String get onbMealsBody =>
      'Das ist dein eigener Gerichte-Katalog. Trag sie von Hand ein, scanne '
      'einen Barcode oder starte mit den Beispielgerichten. Jedes Gericht merkt '
      'sich seine Zutaten – daraus entsteht die Einkaufsliste.';

  @override
  String get onbShoppingTitle => 'Die Einkaufsliste schreibt sich selbst';
  @override
  String get onbShoppingBody =>
      'Sie sammelt die Zutaten von allem, was du geplant hast, gruppiert sie '
      'nach Regal und rechnet die Mengen zusammen. Hak ab, was im Wagen landet, '
      'und schalte für den Supermarkt die große Schrift ein.';

  @override
  String get onbTodayTitle => 'Notiere, was du isst';
  @override
  String get onbTodayBody =>
      'Im Tab „Heute“ hakst du die geplanten Mahlzeiten ab oder trägst etwas '
      'anderes ein. Du kannst auch dein Gewicht, dein Wasser und eine Notiz zum '
      'Tag festhalten.';

  @override
  String get onbGymTitle => 'Gym-Modus (optional)';
  @override
  String get onbGymBody =>
      'Wenn du trainierst, schalte ihn unter Mehr › Gym-Modus ein. Du nennst '
      'ihm dein Ziel, er rechnet deine Kalorien und dein Eiweiß für den Tag aus '
      'und zeigt dir, wie du liegst. Kein Interesse? Lass ihn einfach aus, dann '
      'ändert sich nichts.';

  @override
  String get onbReadyTitle => 'Das war schon alles';
  @override
  String get onbReadyBody =>
      'Der beste Start: füge ein paar Beispielgerichte hinzu und drücke im Tab '
      '„Woche“ auf „Zufall“. Dieses Tutorial kannst du jederzeit in den '
      'Einstellungen noch einmal ansehen.';

  @override
  String get onbSkip => 'Überspringen';
  @override
  String get onbNext => 'Weiter';
  @override
  String get onbBack => 'Zurück';
  @override
  String get onbStart => 'Los geht’s';

  // ======================= EINSTELLUNGEN =======================

  @override
  String get settingsTitle => 'Einstellungen';
  @override
  String get sectionLanguage => 'Sprache';
  @override
  String get sectionAppearance => 'Darstellung';
  @override
  String get sectionColorTheme => 'Farbthema';
  @override
  String get sectionOnOpen => 'Beim Öffnen der App';
  @override
  String get sectionAi => 'KI-Assistent (Gemini)';
  @override
  String get sectionBackup => 'Sicherung';
  @override
  String get sectionHelp => 'Hilfe';
  @override
  String get sectionAbout => 'Über';

  @override
  String get languageSubtitle => 'Ändert die Sprache der ganzen App';

  @override
  String get modeSystem => 'System';
  @override
  String get modeLight => 'Hell';
  @override
  String get modeDark => 'Dunkel';

  @override
  String get amoledTitle => 'AMOLED-Schwarz';
  @override
  String get amoledSubtitle => 'Reines Schwarz im dunklen Modus';

  @override
  String get colorIntensity => 'Farbintensität';
  @override
  List<String> get intensityLabels =>
      const ['Sanft', 'Ausgewogen', 'Kräftig', 'Intensiv'];

  @override
  String get startTabAuto => 'Automatisch';

  @override
  String get replayTutorialTitle => 'Tutorial noch einmal ansehen';
  @override
  String get replayTutorialSubtitle => 'Die Willkommensrunde, von vorne';

  @override
  String get aboutSubtitle => 'Version 2.0 · Gemacht mit Flutter';

  @override
  String get backupIntro =>
      'Speichert ALLES (Gerichte, Wochen, Vorrat und Tagebuch) in einer Datei. '
      'Dein KI-Schlüssel bleibt aus Sicherheitsgründen draußen.';
  @override
  String get exportBackup => 'Sicherung exportieren';
  @override
  String get exportBackupSubtitle => 'Teile oder speichere die .json-Datei';
  @override
  String get restoreBackup => 'Sicherung wiederherstellen';
  @override
  String get restoreBackupSubtitle => 'Ersetzt deine aktuellen Daten';
  @override
  String get backupShareSubject => 'Meal-Planner-Sicherung';
  @override
  String get restoreConfirmBody =>
      'Das ersetzt deine Gerichte, Wochen, deinen Vorrat und dein Tagebuch '
      'durch die aus der Sicherung. Danach muss die App neu gestartet '
      'werden.\n\nWirklich fortfahren?';
  @override
  String get restore => 'Wiederherstellen';
  @override
  String get backupRestored =>
      'Sicherung wiederhergestellt. Schließe die App und öffne sie neu.';

  @override
  String get aiIntro =>
      'Mit deinem kostenlosen Google-Gemini-Schlüssel kannst du die Makros '
      'eines Gerichts aus Text oder Foto schätzen lassen. Hol ihn dir auf '
      'aistudio.google.com/apikey';
  @override
  String get apiKeyLabel => 'API-Schlüssel';
  @override
  String get modelLabel => 'Modell';
  @override
  String modelHelper(String model) => 'Standard: $model';
  @override
  String get aiEnabled => 'KI an: du kannst per Foto oder Text schätzen.';
  @override
  String get aiDisabled => 'Ohne Schlüssel: die KI-Schätzung ist aus.';

  // ======================= „MEHR“ =======================

  @override
  String get moreTitle => 'Mehr';
  @override
  String get statDishes => 'Gerichte';
  @override
  String get statWeeks => 'Wochen';
  @override
  String get statStreak => 'Tage in Folge';

  @override
  String get sectionYourFood => 'Dein Essen';
  @override
  String get addMealTitle => 'Gericht hinzufügen';
  @override
  String get addMealSubtitle => 'Leg ein neues Gericht für deinen Katalog an';
  @override
  String get myIngredientsTitle => 'Meine Zutaten';
  @override
  String get myIngredientsSubtitle => 'Vorrat mit Hausmaßen und Bestand';
  @override
  String get giveIdeasTitle => 'Gib mir Ideen';
  @override
  String get giveIdeasSubtitle => 'Lass die KI neue Gerichte vorschlagen';
  @override
  String get rouletteTitle => 'Abendessen-Roulette';
  @override
  String get rouletteSubtitle => 'Für wenn du nicht mal entscheiden willst';

  @override
  String get sectionProgress => 'Fortschritt';
  @override
  String get statsTitle => 'Statistiken';
  @override
  String get statsSubtitle => 'Durchschnitte, Serie, Gewicht und Zieltage';
  @override
  String get gymModeTitle => 'Gym-Modus';
  @override
  String gymModeActive(String goal) => 'Aktiv · $goal';
  @override
  String get gymModeNoGoal => 'ohne Ziel';
  @override
  String get gymModeSubtitle => 'Kalorien- und Eiweißziele';

  @override
  String get sectionApp => 'App';
  @override
  String get settingsSubtitle => 'Thema, Sprache, KI, Sicherung';

  // ======================= HEUTE / TAGEBUCH =======================

  @override
  String get todayScreenTitle => 'Tagebuch';
  @override
  String get today => 'Heute';
  @override
  String get yesterday => 'Gestern';
  @override
  String get chooseDay => 'Tag wählen';
  @override
  String get previousDay => 'Vorheriger Tag';
  @override
  String get nextDay => 'Nächster Tag';

  @override
  String get menuCopyYesterday => 'Gestrigen Tag kopieren';
  @override
  String get menuDayNote => 'Notiz zum Tag';
  @override
  String get menuWhatFits => 'Was passt noch in den Rest?';
  @override
  String get menuRoulette => 'Abendessen-Roulette';
  @override
  String get menuClearDay => 'Diesen Tag leeren';

  @override
  String get whatYouveHad => 'Was du bisher hattest';
  @override
  String get nothingLoggedYet =>
      'Noch nichts eingetragen. Hak oben die geplanten Mahlzeiten ab oder tippe '
      'auf „Hinzufügen“.';
  @override
  String get otherSlot => 'Sonstiges';

  @override
  String get adjustAmount => 'Menge anpassen';
  @override
  String howMuchOf(String dish) => 'Wie viel hast du von $dish gegessen?';
  @override
  String get oneServing => '1 Portion';
  @override
  String servingsCount(String amount) => '$amount Portionen';
  @override
  String removedItem(String name) => 'Entfernt: $name';

  @override
  String get needTargetForFits =>
      'Stell dein Ziel im Gym-Modus ein, um das zu nutzen';
  @override
  String get alreadyOverToday => 'Du bist heute schon über deinem Ziel.';
  @override
  String kcalLeftFits(int left) =>
      'Dir bleiben $left kcal. Das passt noch, von viel zu wenig Eiweiß:';
  @override
  String get nothingFitsCatalog => 'Aus deinem Katalog passt nichts mehr.';

  @override
  String get yesterdayWasEmpty => 'Gestern ist nichts eingetragen';
  @override
  String copiedMeals(int n) => '$n Mahlzeiten von gestern kopiert';
  @override
  String get dayAlreadyEmpty => 'Dieser Tag ist schon leer';
  @override
  String get dayCleared => 'Tag geleert';

  @override
  String get weightToday => 'Gewicht heute';
  @override
  String get weight => 'Gewicht';
  @override
  String get logWeight => 'Gewicht eintragen';
  @override
  String get weightSubtitle => 'Wird für deine Fortschrittskurve genutzt';

  @override
  String get noteHint => 'Beine trainiert, Abendessen auswärts…';

  @override
  String get manualEntry => 'Manueller Eintrag';
  @override
  String get manualEntrySubtitle => 'Name, Kalorien und Eiweiß eintippen';
  @override
  String get searchYourMeals => 'In deinen Gerichten suchen';
  @override
  String get noResultsUseManual =>
      'Keine Treffer. Nutze den manuellen Eintrag.';
  @override
  String get noMacrosLoggedAsZero => 'Ohne Makros (zählt als 0)';
  @override
  String get youEatThisOften => 'Das isst du oft';
  @override
  String addedItem(String name) => 'Hinzugefügt: $name';

  @override
  String get plannedForThisDay => 'Was du geplant hattest';
  @override
  String get nothingPlannedThisDay => 'Für diesen Tag ist nichts geplant.';

  @override
  String hadKcalAndProtein(int kcal, int protein) =>
      'Du bist bei $kcal kcal und $protein g Eiweiß.';
  @override
  String get setUpGymProfile =>
      'Richte dein Profil im Gym-Modus ein, um deine Ziele zu sehen.';
  @override
  String kcalLeft(int n) => 'Dir bleiben $n kcal';
  @override
  String kcalOver(int n) => 'Du bist $n kcal drüber';
  @override
  String get proteinMet => 'Eiweiß erreicht';
  @override
  String streakBadge(int days) =>
      days == 1 ? 'Serie von 1 Tag' : 'Serie von $days Tagen';
  @override
  String ofTarget(int target) => 'von $target';

  @override
  String get water => 'Wasser';
  @override
  String waterGlasses(int n) =>
      n == 1 ? '1 Glas Wasser' : '$n Gläser Wasser';

  // ======================= PLANER =======================

  @override
  String get plannerTitle => 'Planer';
  @override
  String get viewNormal => 'Normale Ansicht';
  @override
  String get viewCompact => 'Kompakte Ansicht';

  @override
  String get menuGoToThisWeek => 'Zur Woche von heute';
  @override
  String get menuWeekDate => 'Datum dieser Woche';
  @override
  String get menuDuplicateWeek => 'Woche duplizieren';
  @override
  String get menuImportWeek => 'Woche importieren';
  @override
  String get menuExportWeek => 'Woche exportieren';
  @override
  String get menuShareAsText => 'Als Text teilen';

  @override
  String get randomize => 'Zufall';
  @override
  String get howToRandomize => 'Wie ausgelost wird';
  @override
  String get onlyFillGaps => 'Nur Lücken füllen';
  @override
  String get onlyFillGapsSubtitle => 'Rührt nicht an, was du schon gesetzt hast';
  @override
  String get useLeftovers => 'Reste nutzen';
  @override
  String get useLeftoversSubtitle =>
      'Gerichte mit mehreren Portionen kommen bei der nächsten Mahlzeit wieder';
  @override
  String get onlyDishesWithMacros => 'Nur Gerichte mit Makros';
  @override
  String get aimForMyCalories => 'An meine Kalorien anpassen';
  @override
  String get aimForMyCaloriesSubtitle =>
      'Versucht, jeden Tag nah an dein Ziel zu bringen';
  @override
  String busyDaysMarked(int n) => n == 1
      ? '1 Tag als „wenig Zeit“ markiert'
      : '$n Tage als „wenig Zeit“ markiert';
  @override
  String get busyDaysSubtitle => 'Sie bekommen nur schnelle Gerichte';
  @override
  String get randomizerOptions => 'Optionen der Auslosung';

  @override
  String get weekDuplicated => 'Woche dupliziert';
  @override
  String get weekDuplicateFailed =>
      'Duplizieren nicht möglich (maximale Wochenzahl)';
  @override
  String get noWeekIsToday =>
      'Keine Woche steht auf dem heutigen Datum. Nutze „Datum dieser Woche“.';
  @override
  String get pickAnyDayOfWeek => 'Wähle irgendeinen Tag dieser Woche';
  @override
  String get noMealsToExport => 'Keine Gerichte zum Exportieren';
  @override
  String get weekShareSubject => 'Wochenplaner';
  @override
  String get weekMenuSubject => 'Speiseplan der Woche';
  @override
  String importedIntoWeek(int n) => 'Planer in Woche $n importiert';

  @override
  String get addWeek => 'Woche hinzufügen';
  @override
  String get deleteCurrentWeek => 'Aktuelle Woche löschen';
  @override
  String get deleteWeekTitle => 'Woche löschen';
  @override
  String deleteWeekBody(String label) =>
      'Der Plan von „$label“ wird gelöscht. Sicher?';
  @override
  String maxWeeks(int n) => 'Maximal $n Wochen';
  @override
  String get cannotDeleteOnlyWeek =>
      'Du kannst deine einzige Woche nicht löschen';

  @override
  String get todayBadge => 'HEUTE';
  @override
  String get dayOptions => 'Optionen für den Tag';
  @override
  String get unlockDay => 'Tag entsperren';
  @override
  String get lockDay => 'Tag sperren';
  @override
  String get clearBusyDay => '„Wenig Zeit“ entfernen';
  @override
  String get markBusyDay => 'Wenig Zeit (schnelle Gerichte)';
  @override
  String get eatingInAgain => 'Ich esse wieder zu Hause';
  @override
  String get eatingOutThisDay => 'An diesem Tag esse ich auswärts';
  @override
  String get clearDay => 'Tag leeren';
  @override
  String get eatingOutNotice =>
      'Auswärts essen: wird nicht geplant und nicht eingekauft.';
  @override
  String dayClearedNamed(String day) => '$day geleert';

  @override
  String get tapToChoose => 'Zum Wählen tippen';
  @override
  String get addToMyCatalog => 'Zu meinem Katalog hinzufügen';
  @override
  String addedToCatalog(String name) => 'Zu deinem Katalog hinzugefügt: $name';
  @override
  String get shuffleThisOne => 'Zufällig tauschen';
  @override
  String get dayIsLocked => 'Dieser Tag ist gesperrt. Entsperre ihn zuerst.';
  @override
  String get searchDishOrIngredient => 'Gericht oder Zutat suchen';
  @override
  String get clearThisMeal => 'Diese Mahlzeit leeren';
  @override
  String get awayShort => 'Auswärts';

  @override
  String weekNumber(int n) => 'Woche $n';
  @override
  String get thisWeek => 'Diese Woche';

  // ======================= MEINE GERICHTE =======================

  @override
  String get myMealsTitle => 'Meine Gerichte';
  @override
  String get scanProduct => 'Produkt scannen';
  @override
  String get scanProductSubtitle => 'Füllt die Daten aus dem Barcode';
  @override
  String get addByHand => 'Von Hand hinzufügen';
  @override
  String get addByHandSubtitle => 'Für Frisches oder ohne Code';
  @override
  String get exampleMeals => 'Beispielgerichte';
  @override
  String get sort => 'Sortieren';
  @override
  String get sortNameAsc => 'Name (A-Z)';
  @override
  String get sortNameDesc => 'Name (Z-A)';
  @override
  String get sortMostUsed => 'Am häufigsten genutzt';
  @override
  String get searchByNameOrIngredient => 'Nach Name oder Zutat suchen';
  @override
  String get canCookNow => 'Kann ich sofort kochen';
  @override
  String get withMacros => 'Mit Makros';
  @override
  String get withoutMacros => 'Ohne Makros';
  @override
  String get noSearchResults => 'Keine Treffer für deine Suche.';

  @override
  String ingredientCount(int n) => n == 1 ? '1 Zutat' : '$n Zutaten';
  @override
  String servingsMadeCount(int n) => n == 1 ? '1 Portion' : '$n Portionen';
  @override
  String get highInProtein => 'Eiweißreich';

  @override
  String get unfavourite => 'Aus Favoriten entfernen';
  @override
  String get markFavourite => 'Als Favorit markieren';
  @override
  String get proposeAgain => 'Wieder vorschlagen';
  @override
  String get notInTheMood => 'Keine Lust (2 Wochen)';
  @override
  String get duplicate => 'Duplizieren';
  @override
  String get copySuffix => 'Kopie';
  @override
  String snoozedMessage(String name) =>
      '„$name“ kommt 2 Wochen lang nicht per Zufall dran';
  @override
  String get deleteMealTitle => 'Gericht löschen';
  @override
  String deleteMealBody(String name) =>
      'Willst du „$name“ wirklich löschen?';
  @override
  String deletedItem(String name) => 'Gelöscht: $name';

  @override
  String get noMealsYet => 'Du hast noch keine Gerichte';
  @override
  String get noMealsYetSubtitle =>
      'Fang mit unseren Beispielgerichten an oder leg eigene an.';
  @override
  String get seeExampleMeals => 'Beispielgerichte ansehen';

  // ======================= EINKAUFSLISTE =======================

  @override
  String get shoppingListTitle => 'Einkaufsliste';
  @override
  String get superMarketMode => 'Supermarkt-Modus (große Schrift)';
  @override
  String get checkAll => 'Alles abhaken';
  @override
  String get uncheckAll => 'Alle Haken entfernen';
  @override
  String get showBought => 'Gekauftes anzeigen';
  @override
  String get hideBought => 'Gekauftes ausblenden';
  @override
  String get shareList => 'Liste teilen';
  @override
  String get copyToClipboard => 'In die Zwischenablage kopieren';
  @override
  String get recurringItems => 'Die üblichen Sachen';
  @override
  String get listCopied => 'Liste kopiert';
  @override
  String get shoppingShareSubject => 'Einkaufsliste';
  @override
  String get recurringItemsBody =>
      'Füge sie mit einem Tipp zur Liste dieser Woche hinzu.';
  @override
  String get addToListTitle => 'Zur Liste hinzufügen';
  @override
  String get ingredientOrProduct => 'Zutat oder Produkt';
  @override
  String get listComplete => 'Liste komplett!';
  @override
  String inCart(int done, int total) => '$done von $total im Wagen';
  @override
  String get addedByHand => 'Von Hand hinzugefügt';
  @override
  String get emptyListTitle => 'Die Liste ist leer';
  @override
  String get emptyListSubtitle =>
      'Plane Mahlzeiten für diese Woche oder füge Einträge mit „Hinzufügen“ '
      'hinzu.';

  @override
  List<String> get recurringItemsList => const [
        'Küchenrolle', 'Toilettenpapier', 'Kaffee', 'Milch', 'Brot',
        'Olivenöl', 'Salz', 'Müllbeutel', 'Waschmittel', 'Eier',
        'Wasser', 'Gemischtes Obst',
      ];

  // ======================= GERICHT ANLEGEN / BEARBEITEN =======================

  @override
  String get editMeal => 'Gericht bearbeiten';
  @override
  String get addMeal => 'Gericht hinzufügen';
  @override
  String prefillNotice(String origin) =>
      '$origin. Prüfe und passe es an, bevor du speicherst.';
  @override
  String get mealNameLabel => 'Name des Gerichts';
  @override
  String get favourite => 'Favorit';
  @override
  String get photo => 'Foto';
  @override
  String get takePhoto => 'Foto aufnehmen';
  @override
  String get chooseFromGallery => 'Aus der Galerie wählen';
  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get ingredientsTitle => 'Zutaten';
  @override
  String get scan => 'Scannen';
  @override
  String get searchIngredient => 'Zutat suchen';
  @override
  String get byHand => 'Von Hand';
  @override
  String get ingredientsTextLabel => 'Zutaten (Text)';
  @override
  String get ingredientsTextHelper =>
      'Mit Kommas trennen: Tomate, Nudeln, Käse';
  @override
  String get nutritionPerServing => 'Nährwerte (pro Portion)';
  @override
  String get estimateWithAi => 'Mit KI schätzen';
  @override
  String totalLine(int kcal, int protein) =>
      'Gesamt: $kcal kcal · $protein g Eiweiß';

  @override
  String get whichSlots => 'Zu welchen Mahlzeiten passt es?';
  @override
  String get ifNoneAllApply =>
      'Wenn du keine ankreuzt, gilt es für alle.';
  @override
  String get tagsTitle => 'Etiketten';
  @override
  String get tagsHelp =>
      'Damit die Woche nicht komplett aus Nudeln besteht.';

  @override
  String get detailsTitle => 'Details';
  @override
  String get prepTime => 'Zeit';
  @override
  String get costPerServing => 'Kosten/Portion';
  @override
  String get servingsMadeTitle => 'Portionen, die rauskommen';
  @override
  String servingsMadeMulti(int n) => 'Einmal kochen, $n Mal essen';
  @override
  String get servingsMadeOne => 'Wird für eine Mahlzeit gekocht';
  @override
  String get recipeOrNotes => 'Rezept oder Notizen';
  @override
  String get recipeOrNotesHelper => 'Schritte, Tricks, ein Link…';

  @override
  String get pleaseCompleteName => 'Bitte trag den Namen ein';
  @override
  String get pleaseCompleteNameAndIngredients =>
      'Bitte trag den Namen und die Zutaten ein';
  @override
  String renamedTo(String name) =>
      'Umbenannt in „$name“ (auch in deinen Wochen)';
  @override
  String get mealUpdated => 'Gericht aktualisiert';
  @override
  String get mealAdded => 'Gericht hinzugefügt';
  @override
  String get aiMacrosFilled =>
      'Makros mit KI geschätzt. Prüfe sie vor dem Speichern.';

  @override
  String get addIngredientTitle => 'Zutat hinzufügen';
  @override
  String get editIngredientTitle => 'Zutat bearbeiten';
  @override
  String get kcalPerUnit => 'kcal/Stk.';
  @override
  String get proteinPerUnit => 'Eiw./Stk.';

  // ======================= VORRAT =======================

  @override
  String get pantryTitle => 'Meine Zutaten';
  @override
  String get restoreDeleted => 'Gelöschte zurückholen';
  @override
  String get presetsRestored => 'Die Zutaten der App sind wieder da';
  @override
  String get tabFromApp => 'Von der App';
  @override
  String get tabMine => 'Meine';
  @override
  String get searchIngredientHint => 'Zutat suchen';
  @override
  String addedToMine(String name) => '„$name“ zu „Meine“ hinzugefügt';
  @override
  String get pantryEmptyMine =>
      'Du hast noch keine Zutaten hinzugefügt.\nScanne ein Produkt oder tippe '
      'auf „Hinzufügen“.';

  @override
  String haveInStock(String amount) => 'habe $amount';
  @override
  String useSoonExpires(int days) => days == 1
      ? 'Aufbrauchen! Läuft morgen ab'
      : 'Aufbrauchen! Läuft in $days Tagen ab';
  @override
  String expiresInDays(int days) => 'Läuft in $days Tagen ab';

  @override
  String get newIngredient => 'Neue Zutat';
  @override
  String get unitLabel => 'Einheit';
  @override
  String get unitHint => 'Scheibe, Filet…';
  @override
  String get gramsPerUnitShort => 'g/Stk.';
  @override
  String get unitTip =>
      'Tipp: auf der Packung stehen meist die Gramm (z. B. „10 Scheiben · 200 g“ '
      '→ 20 g pro Scheibe).';
  @override
  String get unitTipRecalc =>
      ' Die Makros rechnen sich von selbst neu, wenn du die Gramm änderst.';
  @override
  String get categoryLabel => 'Kategorie';
  @override
  String get repeatQuestion => 'Darf es oft wiederkommen?';
  @override
  String get haveAtHomeQuestion => 'Hast du es zu Hause?';
  @override
  String stockHelper(String unit) => 'In $unit';
  @override
  String get unitsFallback => 'Stück';
  @override
  String get expiryDate => 'Mindesthaltbarkeitsdatum';
  @override
  String get expiryShort => 'Haltbar bis';
  @override
  String get removeExpiry => 'Haltbarkeit entfernen';

  // ======================= PORTIONSWAHL =======================

  @override
  String get units => 'Einheiten';
  @override
  String get grams => 'Gramm';
  @override
  String get productHasNoMacros =>
      'Dieses Produkt hat keine Makros. Trag sie von Hand ein.';
  @override
  String get saveToMyIngredients => 'In Meine Zutaten speichern';
  @override
  String get whichMeasure => 'In welchem Maß?';
  @override
  String get howMany => 'Wie viele?';
  @override
  String gramsPer(String unit) => 'g pro $unit';
  @override
  String get howManyGrams => 'Wie viele Gramm?';
  @override
  String get howManyServings => 'Wie viele Portionen?';
  @override
  String oneServingIs(String size) => '1 Portion = $size';
  @override
  String get proteinGramsShort => 'Eiweiß (g)';

  // ======================= GYM-MODUS =======================

  @override
  String get gymIntro =>
      'Schalte den Gym-Modus ein, um deine Mahlzeiten nach deinem Ziel zu '
      'planen (Masseaufbau, Definition…) – ohne Fachchinesisch.';
  @override
  String get enableGymMode => 'Gym-Modus einschalten';
  @override
  String get enableGymModeSubtitle =>
      'Zeigt die Tracking-Optionen fürs Fitnessstudio';
  @override
  String get yourGoal => 'Dein Ziel';
  @override
  String get yourGoalSubtitle =>
      'Wähle, was du erreichen willst. Ohne Fachchinesisch.';
  @override
  String get yourTargets => 'Deine Ziele';
  @override
  String estimatedExpenditure(int kcal) =>
      'Geschätzter Verbrauch: $kcal kcal/Tag';
  @override
  String get setYourOwnFigures =>
      'Leg deine eigenen Kalorien- und Eiweißwerte fest.';
  @override
  String get completeProfileToCalculate =>
      'Fülle dein Profil aus, um deine Ziele zu berechnen.';
  @override
  String get adjustFigures => 'Werte anpassen';
  @override
  String get editProfile => 'Profil bearbeiten';
  @override
  String get completeProfile => 'Profil ausfüllen';
  @override
  String get yourFigures => 'Deine Werte';
  @override
  String get todaysLog => 'Tagebuch von heute';
  @override
  String get todaysLogSubtitle =>
      'Notiere, was du isst, und verfolge deinen Fortschritt';
  @override
  String get mealsPerDay => 'Mahlzeiten am Tag';
  @override
  String get mealsPerDaySubtitle =>
      'Wähle, wie viele Mahlzeiten du pro Tag planst.';
  @override
  String daysInARow(int days) =>
      days == 1 ? '1 Tag in Folge' : '$days Tage in Folge';
  @override
  String get noStreakYet => 'Noch keine Serie';
  @override
  String get setTargetToCount => 'Setz dein Ziel, damit gezählt werden kann.';
  @override
  String get logToStartStreak =>
      'Notiere, was du isst, und starte die Serie.';
  @override
  String last7Days(int met, int days) =>
      'Letzte 7 Tage: Eiweiß an $met von $days Tagen erreicht.';

  // ======================= GYM-PROFIL =======================

  @override
  String get yourProfile => 'Dein Profil';
  @override
  String get profileIntro =>
      'Damit berechnen wir deine Ziele. Sie bleiben gespeichert und du kannst '
      'sie jederzeit ändern.';
  @override
  String get height => 'Größe';
  @override
  String get age => 'Alter';
  @override
  String get years => 'Jahre';
  @override
  String get sexTitle => 'Geschlecht';
  @override
  String get sexNote =>
      'Wird nur für die Berechnung des Kalorienverbrauchs genutzt.';
  @override
  String get activityLevel => 'Aktivitätsniveau';
  @override
  String get fillToSeeTargets =>
      'Trag Gewicht, Größe und Alter ein, um deine Ziele zu sehen.';
  @override
  String targetsForGoal(String goal) => 'Deine Ziele · $goal';
  @override
  String get customFiguresNote =>
      'Unter „Eigene Werte“ kannst du diese Zahlen von Hand anpassen.';
  @override
  String get saveProfile => 'Profil speichern';
  @override
  String get profileSaved => 'Profil gespeichert';
  @override
  String get checkProfileData =>
      'Prüfe die Daten: Gewicht, Größe und Alter müssen gültig sein';

  // ======================= STATISTIKEN =======================

  @override
  String get statisticsTitle => 'Statistiken';
  @override
  String get exportCsv => 'Tagebuch exportieren (CSV)';
  @override
  String get csvSubject => 'Mein Ess-Tagebuch';
  @override
  String daysRange(int n) => '$n Tage';
  @override
  String get avgPerDay => 'Schnitt pro Tag';
  @override
  String get avgProtein => 'Eiweiß im Schnitt';
  @override
  String get daysMeetingProtein => 'Tage mit erreichtem Eiweiß';
  @override
  String get currentStreak => 'Aktuelle Serie';
  @override
  String get daysUnit => 'Tage';

  @override
  String get yourWeight => 'Dein Gewicht';
  @override
  String get weightNeedsTwoDays =>
      'Trag dein Gewicht an mindestens zwei Tagen im Tagebuch ein, um Kurve und '
      'Trend zu sehen.';
  @override
  String get sevenDayAverage => '7-Tage-Schnitt';

  @override
  String get achievementsTitle => 'Erfolge';
  @override
  String achievementsUnlocked(int unlocked, int total) =>
      '$unlocked von $total freigeschaltet';

  @override
  String get whatYouEatMost => 'Was du am meisten isst';
  @override
  String get nothingPlannedYet => 'Du hast noch nichts geplant.';
  @override
  String timesInYourWeeks(int n) =>
      n == 1 ? '1 Mal in deinen Wochen' : '$n Mal in deinen Wochen';

  @override
  String get verdictNoTarget =>
      'Stell dein Ziel im Gym-Modus ein, um zu sehen, wie du liegst.';
  @override
  String get verdictNoData => 'Noch nicht genug Daten.';
  @override
  String get verdictGreat =>
      'Sehr gut: du erreichst dein Eiweiß fast jeden Tag.';
  @override
  String get verdictOk =>
      'Läuft ganz gut, aber einige Tage rutschen durch. Probier einen '
      'Eiweiß-Snack am Nachmittag.';
  @override
  String get verdictLow =>
      'An den meisten Tagen fehlt dir Eiweiß. Nimm „eiweißreiche“ Gerichte in '
      'deinen Katalog auf.';
  @override
  String adjustToKcal(int kcal) => 'Auf $kcal kcal anpassen';
  @override
  String targetAdjusted(int kcal) => 'Ziel auf $kcal kcal angepasst';
  @override
  String get noLogsInPeriod =>
      'In diesem Zeitraum gibt es noch keine Einträge.\nNotiere im Tab „Heute“, '
      'was du isst, dann erscheinen hier deine Durchschnitte.';

  @override
  Map<String, (String, String)> get achievements => const {
        'cocinero': ('Koch', 'Leg 10 Gerichte in deinem Katalog an'),
        'chef': ('Chefkoch', 'Erreiche 50 Gerichte'),
        'constante': ('Beständig', 'Trag 7 Tage ein'),
        'veterano': ('Veteran', 'Trag 100 Tage ein'),
        'racha7':
            ('Eine perfekte Woche', '7 Tage in Folge das Eiweiß erreicht'),
        'racha30': ('Unaufhaltsam', '30 Tage Eiweiß in Folge'),
        'planificador': ('Planer', 'Plane 4 Wochen'),
        'fotografo': ('Fotograf', 'Gib 5 Gerichten ein Foto'),
        'proteico':
            ('Ziel erreicht', 'Erreiche dein Eiweiß an insgesamt 30 Tagen'),
        'semanaperfecta':
            ('Perfekte Woche', 'Eine ganze Woche komplett durchgeplant'),
      };

  // ======================= KI: SCHÄTZEN =======================

  @override
  String get aiEstimateTitle => 'Mit KI schätzen';
  @override
  String get aiEstimateIntro =>
      'Beschreibe, was du gegessen hast, und/oder füge ein Foto hinzu. Die KI '
      'schätzt Kalorien und Eiweiß (ungefähr).';
  @override
  String get descriptionLabel => 'Beschreibung';
  @override
  String get descriptionHint =>
      'z. B.: ein Teller Nudeln mit Thunfisch, normale Portion';
  @override
  String get gallery => 'Galerie';
  @override
  String get photoAdded => 'Foto hinzugefügt';
  @override
  String get estimating => 'Schätze…';
  @override
  String get estimateMacros => 'Makros schätzen';
  @override
  String get resultAdjustIt => 'Ergebnis (bei Bedarf anpassen)';
  @override
  String get useThisData => 'Diese Daten übernehmen';
  @override
  String get couldNotOpenImage => 'Das Bild konnte nicht geöffnet werden.';
  @override
  String get missingGeminiKey => 'Dein Gemini-Schlüssel fehlt';
  @override
  String get missingGeminiKeyBody =>
      'Für die KI-Schätzung trag deinen kostenlosen Google-Gemini-API-Schlüssel '
      'in den Einstellungen ein.';
  @override
  String get goToSettings => 'Zu den Einstellungen';

  // ======================= KI: IDEEN =======================

  @override
  String get whatDoYouFancy => 'Worauf hast du Lust?';
  @override
  String get whatDoYouFancyHint =>
      'Schnelle Abendessen mit Eiweiß, ohne Fisch…';
  @override
  String get usePantry => 'Meinen Vorrat nutzen';
  @override
  String get usePantrySubtitle => 'Bevorzugt Zutaten, die du schon hast';
  @override
  String get thinking => 'Denke nach…';
  @override
  String get proposeDishes => 'Gerichte vorschlagen';
  @override
  String get proposals => 'Vorschläge';
  @override
  String get proposalsDisclaimer =>
      'Das sind Schätzungen: prüfe sie, bevor du den Makros traust.';
  @override
  String get writeWhatYouWant => 'Schreib, was für Gerichte du willst.';
  @override
  String get aiSuggestNotConfigured =>
      'Damit die KI dir Gerichte vorschlägt, brauchst du deinen kostenlosen '
      'Gemini-Schlüssel in den Einstellungen.';

  @override
  List<String> get ideaPresets => const [
        'Leichte Abendessen unter 400 kcal',
        'Eiweißreiche Mahlzeiten für nach dem Training',
        'Günstige Gerichte, die viel hergeben',
        'Schnelle Frühstücke unter 10 Minuten',
        'Resteverwertung mit dem, was ich habe',
      ];

  // ======================= ZUTAT SUCHEN =======================

  @override
  String get searchIngredientTitle => 'Zutat suchen';
  @override
  String get searchIngredientPlaceholder => 'Suchen (Hähnchen, Reis, Ei…)';
  @override
  String get noResultsTryAnother =>
      'Keine Treffer. Probier ein anderes Wort.';
  @override
  String get otherQuantity => 'Andere Menge';
  @override
  String howManyUnits(String unit) => 'Wie viele $unit?';
  @override
  String oneUnitIs(String unit, int kcal, int protein) =>
      '1 $unit = $kcal kcal · $protein g';

  // ======================= ROULETTE =======================

  @override
  String rouletteFor(String slot) => 'Roulette · $slot';
  @override
  String get whatsForDinner => 'Was esse ich heute Abend?';
  @override
  String get onlyWithWhatIHave => 'Nur mit dem, was ich zu Hause habe';
  @override
  String get spin => 'Drehen!';
  @override
  String get spinAgain => 'Nochmal';
  @override
  String get putItInThePlan => 'In den Plan setzen';
  @override
  String noDishesFor(String slot) => 'Du hast keine Gerichte für $slot';
  @override
  String assignedTo(String dish, String day, String slot) =>
      '$dish → $day, $slot';

  // ======================= SCANNER =======================

  @override
  String get scanProductTitle => 'Produkt scannen';
  @override
  String get scanIngredientTitle => 'Zutat scannen';
  @override
  String get switchCamera => 'Kamera wechseln';
  @override
  String get flash => 'Blitz';
  @override
  String get aimAtBarcode =>
      'Ziel auf den Barcode des Produkts (liest auch QR-Codes)';
  @override
  String get searchingProduct => 'Suche das Produkt…';
  @override
  String get productNotFoundTitle => 'Produkt nicht gefunden';
  @override
  String productNotFoundBody(String code) =>
      'Keine Daten für den Code $code. Du kannst es von Hand eintragen.';
  @override
  String get keepScanning => 'Weiter scannen';
  @override
  String scannedProductNote(String basis) =>
      'Gescanntes Produkt (OpenFoodFacts · $basis)';
  @override
  String get basisPerServing => 'pro Portion';
  @override
  String get basisPer100g => 'pro 100 g';
  @override
  String get basisNoData => 'keine Daten';
  @override
  String unknownProduct(String barcode) => 'Produkt $barcode';

  // ======================= BEISPIELGERICHTE =======================

  @override
  String get exampleMealsTitle => 'Beispielgerichte';
  @override
  String get selectAll => 'Alle';
  @override
  String get unselectAll => 'Alle abwählen';
  @override
  String get alreadyInCatalog => 'Schon in deinem Katalog';
  @override
  String get selectMeals => 'Wähle Gerichte aus';
  @override
  String addNMeals(int n) =>
      n == 1 ? '1 Gericht hinzufügen' : '$n Gerichte hinzufügen';
  @override
  String addedNMeals(int n) => n == 1
      ? '1 Gericht zu deinem Katalog hinzugefügt'
      : '$n Gerichte zu deinem Katalog hinzugefügt';
  @override
  String get presetNotice =>
      'Sie sind ein Startpunkt und frei änderbar: nimm das, was dir passt, und '
      'pass danach Zutaten oder Makros an.';

  // ======================= MELDUNGEN DES PROVIDERS =======================

  @override
  String get noMealsToAssign => 'Keine Gerichte zum Zuordnen';
  @override
  String get noSlotsConfigured => 'Keine Mahlzeiten eingerichtet';
  @override
  String noMealsWithMacrosFor(String slot) =>
      'Keine Gerichte mit Makros für $slot';
  @override
  String noMealsFor(String slot) => 'Keine Gerichte für $slot';
  @override
  String maxWeeksReached(int n) => 'Maximum von $n Wochen erreicht';
  @override
  String importError(Object e) => 'Import fehlgeschlagen: $e';
  @override
  String get weekTextHeader => 'Speiseplan der Woche';
  @override
  String get outOfHome => 'auswärts essen';
  @override
  String get shoppingTextHeader => 'Einkaufsliste';
  @override
  String get shoppingListIsEmpty => 'Die Liste ist leer.';
  @override
  String get unitAbbrev => 'Stk.';

  // ======================= SICHERUNG =======================

  @override
  String get backupInvalidFile => 'Die Datei ist keine gültige Sicherung.';
  @override
  String get backupCorrupt => 'Die Sicherung ist leer oder beschädigt.';
  @override
  String get backupNothingRestored =>
      'Aus dieser Sicherung konnte nichts wiederhergestellt werden.';

  // ======================= GEMINI =======================

  @override
  String get geminiMissingKey =>
      'Der Gemini-API-Schlüssel fehlt. Trag ihn in den Einstellungen ein.';
  @override
  String get geminiNeedTextOrPhoto =>
      'Schreib eine Beschreibung oder füge ein Foto des Gerichts hinzu.';
  @override
  String get geminiBadKey =>
      'Der API-Schlüssel ist ungültig oder die Anfrage wurde abgelehnt.';
  @override
  String get geminiForbidden =>
      'API-Schlüssel ohne Berechtigung. Prüfe, ob du ihn richtig kopiert hast.';
  @override
  String get geminiModelNotFound =>
      'Modell nicht gefunden. Prüfe den Modellnamen in den Einstellungen.';
  @override
  String get geminiRateLimit =>
      'Du hast das Anfragelimit überschritten. Versuch es gleich noch einmal.';
  @override
  String geminiError(int code) => 'Gemini-Fehler (Code $code).';
  @override
  String get geminiNoConnection =>
      'Gemini war nicht erreichbar. Prüfe deine Verbindung.';
  @override
  String get geminiUnreadable => 'Die Antwort von Gemini ist unlesbar.';
  @override
  String get geminiNothingUseful =>
      'Gemini hat nichts Brauchbares zurückgegeben.';
  @override
  String get geminiNoEstimate =>
      'Gemini hat keine Schätzung geliefert. Beschreib es genauer.';
  @override
  String get geminiParseFail =>
      'Die Schätzung von Gemini war nicht verständlich.';
  @override
  String get geminiCouldNotEstimate =>
      'Die KI konnte die Makros nicht schätzen. Gib mehr Details an.';
  @override
  String get geminiSuggestionsParseFail =>
      'Die Vorschläge waren nicht verständlich.';
  @override
  String get geminiNoSuggestions => 'Die KI hat kein Gericht vorgeschlagen.';

  // ======================= KALORIEN ANPASSEN =======================

  @override
  String get gymNotGaining =>
      'Du nimmst nicht zu: probier 150 kcal mehr.';
  @override
  String get gymGainingTooFast =>
      'Du nimmst zu schnell zu: geh 150 kcal runter.';
  @override
  String get gymNotLosing => 'Du nimmst nicht ab: probier 150 kcal weniger.';
  @override
  String get gymLosingTooFast =>
      'Du nimmst zu schnell ab: geh 150 kcal rauf.';

  // ======================= INTERFAZ LIMPIA =======================

  @override
  String get sectionInterface => 'Oberfläche';
  @override
  String get cleanModeTitle => 'Aufgeräumte Oberfläche';
  @override
  String get cleanModeSubtitle =>
      'Blendet Nebenschaltflächen, Filter und Extra-Karten aus. Nichts geht '
      'verloren: alles wandert in die Menüs.';
  @override
  String get cleanModeHintTitle => 'Wo ist alles hin?';
  @override
  String get cleanModeHintBody =>
      'Die verschwundenen Schaltflächen stecken im ⋮-Menü oben. Lange auf eine '
      'Mahlzeit tippen zeigt ihre Optionen.';

  // ======================= WIDGETS DE INICIO =======================

  @override
  String get widgetsTitle => 'Startbildschirm-Widgets';
  @override
  String get widgetsSubtitle => 'Dein Tag auf einen Blick, ohne die App zu öffnen';
  @override
  String get widgetsIntro =>
      'Füg eins von hier aus hinzu, oder halte eine freie Stelle auf dem '
      'Startbildschirm gedrückt und such Meal Planner in der Widget-Liste.';
  @override
  String get widgetsRefreshNote =>
      'Sie aktualisieren sich jedes Mal, wenn du die App verlässt, und folgen '
      'deinem Farbthema.';
  @override
  String get widgetTodayTitle => 'Heute';
  @override
  String get widgetTodayDescription =>
      'Kalorien und Eiweiß des Tages, Wasser und was dir bleibt.';
  @override
  String get widgetNextTitle => 'Als Nächstes';
  @override
  String get widgetNextDescription =>
      'Die nächste Mahlzeit im Plan und die danach.';
  @override
  String get widgetShoppingTitle => 'Einkaufsliste';
  @override
  String get widgetShoppingDescription =>
      'Was diese Woche noch im Wagen fehlt.';
  @override
  String get addToHomeScreen => 'Zum Startbildschirm hinzufügen';
  @override
  String get widgetPinUnsupported =>
      'Dein Launcher lässt die App es nicht platzieren. Halte den '
      'Startbildschirm gedrückt und wähl es aus der Widget-Liste.';
  @override
  String get widgetNoPlan => 'Nichts geplant';
  @override
  String get widgetAllBought => 'Alles gekauft';
  @override
  String widgetItemsLeft(int n) => n == 1 ? '1 Sache fehlt' : '$n Sachen fehlen';
  @override
  String get widgetOnlyAndroid => 'Widgets gibt es nur auf Android.';
}
