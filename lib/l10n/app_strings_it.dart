import '../models/gym_goal.dart';
import '../models/meal_slot.dart';
import '../models/pantry_ingredient.dart';
import 'app_strings.dart';

/// Italiano.
class AppStringsIt extends AppStrings {
  const AppStringsIt();

  @override
  String get languageCode => 'it';
  @override
  String get aiLanguageName => 'Italian';

  // ======================= COMUNE =======================

  @override
  String get cancel => 'Annulla';
  @override
  String get save => 'Salva';
  @override
  String get saveChanges => 'Salva le modifiche';
  @override
  String get add => 'Aggiungi';
  @override
  String get added => 'Aggiunto';
  @override
  String get delete => 'Elimina';
  @override
  String get remove => 'Togli';
  @override
  String get close => 'Chiudi';
  @override
  String get undo => 'Annulla';
  @override
  String get all => 'Tutti';
  @override
  String get options => 'Opzioni';
  @override
  String get more => 'Altro';
  @override
  String get search => 'Cerca';
  @override
  String get show => 'Mostra';
  @override
  String get hide => 'Nascondi';
  @override
  String get name => 'Nome';
  @override
  String get quantity => 'Quantità';
  @override
  String get noResults => 'Nessun risultato.';

  @override
  String get protein => 'Proteine';
  @override
  String get calories => 'Calorie';
  @override
  String get kcalPerDay => 'kcal/giorno';
  @override
  String get gramsPerDay => 'g/giorno';

  @override
  String proteinValue(int n) => '$n g di proteine';
  @override
  String macros(int kcal, int protein) => '$kcal kcal · $protein g di proteine';

  @override
  List<String> get weekdays => const [
        'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
        'Venerdì', 'Sabato', 'Domenica',
      ];
  @override
  List<String> get weekdaysShort =>
      const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
  @override
  List<String> get months => const [
        'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
        'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
      ];
  @override
  List<String> get monthsShort => const [
        'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
        'lug', 'ago', 'set', 'ott', 'nov', 'dic',
      ];

  @override
  String longDate(DateTime d) =>
      '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';

  @override
  String mealSlot(MealSlot slot) => switch (slot) {
        MealSlot.breakfast => 'Colazione',
        MealSlot.lunch => 'Pranzo',
        MealSlot.snack => 'Merenda',
        MealSlot.dinner => 'Cena',
        MealSlot.preWorkout => 'Pre-allenamento',
        MealSlot.postWorkout => 'Post-allenamento',
      };

  @override
  String gymGoal(GymGoal goal) => switch (goal) {
        GymGoal.volume => 'Massa',
        GymGoal.definition => 'Definizione',
        GymGoal.maintenance => 'Mantenimento',
        GymGoal.custom => 'Personalizzato',
      };

  @override
  String gymGoalDescription(GymGoal goal) => switch (goal) {
        GymGoal.volume =>
          'Mettere muscolo · mangiare un po’ più di quanto consumi',
        GymGoal.definition => 'Perdere grasso senza perdere muscolo',
        GymGoal.maintenance => 'Mantenere il peso e rendere bene',
        GymGoal.custom => 'I numeri li scegli tu',
      };

  @override
  String sex(Sex value) => value == Sex.male ? 'Uomo' : 'Donna';

  @override
  String activity(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Sedentario',
        ActivityLevel.light => 'Leggero',
        ActivityLevel.moderate => 'Moderato',
        ActivityLevel.active => 'Alto',
        ActivityLevel.veryActive => 'Molto alto',
      };

  @override
  String activityDescription(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 'Poco o nessun esercizio',
        ActivityLevel.light => 'Allenamento 1-3 giorni a settimana',
        ActivityLevel.moderate => 'Allenamento 3-5 giorni a settimana',
        ActivityLevel.active => 'Allenamento 6-7 giorni a settimana',
        ActivityLevel.veryActive =>
          'Allenamento intenso tutti i giorni o lavoro fisico',
      };

  @override
  String repeatability(Repeatability r) => switch (r) {
        Repeatability.free => 'Senza limiti',
        Repeatability.moderate => 'Con moderazione',
        Repeatability.limited => 'Da limitare',
      };

  @override
  String repeatabilityHint(Repeatability r) => switch (r) {
        Repeatability.free => 'Puoi ripeterlo quanto vuoi',
        Repeatability.moderate => 'Meglio non esagerare durante la settimana',
        Repeatability.limited => 'Solo ogni tanto',
      };

  @override
  Map<String, String> get ingredientCategories => const {
        'Proteínas': 'Proteine',
        'Carbohidratos': 'Carboidrati',
        'Legumbres': 'Legumi',
        'Verduras': 'Verdure',
        'Frutas': 'Frutta',
        'Lácteos y huevos': 'Latticini e uova',
        'Grasas y frutos secos': 'Grassi e frutta secca',
        'Otros': 'Altro',
      };

  @override
  Map<String, String> get foodTags => const {
        'Pasta': 'Pasta',
        'Arroz': 'Riso',
        'Carne': 'Carne',
        'Pescado': 'Pesce',
        'Verduras': 'Verdure',
        'Legumbres': 'Legumi',
        'Huevos': 'Uova',
        'Sopa': 'Zuppa',
        'Ensalada': 'Insalata',
        'Rápido': 'Veloce',
        'De aprovechar': 'Avanzi',
        'Capricho': 'Sfizio',
      };

  @override
  Map<String, String> get themeNames => const {
        'teal': 'Verde acqua',
        'sunset': 'Tramonto',
        'grape': 'Uva',
        'ocean': 'Oceano',
        'forest': 'Bosco',
        'ruby': 'Rubino',
        'amber': 'Ambra',
        'midnight': 'Mezzanotte',
        'crimson': 'Cremisi',
      };

  @override
  Map<String, String> get homeUnits => const {
        'loncha': 'fetta',
        'filete': 'filetto',
        'unidad': 'unità',
        'rodaja': 'rondella',
        'cucharada': 'cucchiaio',
        'puñado': 'manciata',
        'vaso': 'bicchiere',
        'ración': 'porzione',
        'muslo': 'coscia',
        'lomo': 'trancio',
        'lata': 'lattina',
        'plato': 'piatto',
        'rebanada': 'fetta',
        'bol': 'ciotola',
        'racimo': 'grappolo',
        'tajada': 'fetta',
        'porción': 'porzione',
        'cazo': 'misurino',
        'cucharadita': 'cucchiaino',
      };

  // ======================= NAVIGAZIONE =======================

  @override
  String get tabToday => 'Oggi';
  @override
  String get tabWeek => 'Settimana';
  @override
  String get tabMeals => 'Piatti';
  @override
  String get tabShopping => 'Spesa';
  @override
  String get tabMore => 'Altro';

  // ======================= TUTORIAL =======================

  @override
  String get onbLanguageTitle => 'Scegli la tua lingua';
  @override
  String get onbLanguageBody =>
      'Puoi cambiarla quando vuoi dalle Impostazioni.';
  @override
  String get onbLanguageContinue => 'Continua';

  @override
  String get onbWelcomeTitle => 'Benvenuto in Meal Planner';
  @override
  String get onbWelcomeBody =>
      'Decidi cosa mangi questa settimana, lascia che la lista della spesa si '
      'scriva da sola e segna quello che mangi davvero. Questo giro dura mezzo '
      'minuto.';

  @override
  String get onbPlannerTitle => 'Pianifica la settimana';
  @override
  String get onbPlannerBody =>
      'Una griglia con i tuoi sette giorni. Tocca un pasto per scegliere il '
      'piatto, oppure premi «A caso» e lascia che l’app riempia la settimana. '
      'Trascina un piatto per spostarlo di giorno, blocca i giorni già decisi e '
      'segna quelli in cui mangi fuori.';

  @override
  String get onbMealsTitle => 'I tuoi piatti';
  @override
  String get onbMealsBody =>
      'Questo è il tuo catalogo di piatti. Aggiungili a mano, scansiona un '
      'codice a barre o parti dai piatti di esempio. Ogni piatto tiene i suoi '
      'ingredienti, ed è da lì che nasce la lista della spesa.';

  @override
  String get onbShoppingTitle => 'La spesa si scrive da sola';
  @override
  String get onbShoppingBody =>
      'Raccoglie gli ingredienti di tutto quello che hai pianificato, li '
      'raggruppa per reparto e somma le quantità. Spunta man mano che riempi il '
      'carrello e attiva la modalità caratteri grandi per il supermercato.';

  @override
  String get onbTodayTitle => 'Segna cosa mangi';
  @override
  String get onbTodayBody =>
      'Nella scheda Oggi spunti i pasti che avevi pianificato o aggiungi '
      'qualsiasi altra cosa. Puoi anche annotare il peso, l’acqua e una nota '
      'della giornata.';

  @override
  String get onbGymTitle => 'Modalità Gym (facoltativa)';
  @override
  String get onbGymBody =>
      'Se ti alleni, attivala in Altro › Modalità Gym. Le dici il tuo obiettivo '
      'e lei calcola calorie e proteine del giorno, poi ti mostra come stai '
      'andando. Se non ti interessa lasciala spenta: non cambia nulla.';

  @override
  String get onbReadyTitle => 'Ed è tutto';
  @override
  String get onbReadyBody =>
      'Il modo migliore per iniziare: aggiungi qualche piatto di esempio e poi '
      'premi «A caso» nella scheda Settimana. Puoi rivedere questo tutorial '
      'quando vuoi dalle Impostazioni.';

  @override
  String get onbSkip => 'Salta';
  @override
  String get onbNext => 'Avanti';
  @override
  String get onbBack => 'Indietro';
  @override
  String get onbStart => 'Iniziamo';

  // ======================= IMPOSTAZIONI =======================

  @override
  String get settingsTitle => 'Impostazioni';
  @override
  String get sectionLanguage => 'Lingua';
  @override
  String get sectionAppearance => 'Aspetto';
  @override
  String get sectionColorTheme => 'Tema di colore';
  @override
  String get sectionOnOpen => 'All’apertura dell’app';
  @override
  String get sectionAi => 'Assistente IA (Gemini)';
  @override
  String get sectionBackup => 'Backup';
  @override
  String get sectionHelp => 'Aiuto';
  @override
  String get sectionAbout => 'Informazioni';

  @override
  String get languageSubtitle => 'Cambia la lingua di tutta l’app';

  @override
  String get modeSystem => 'Sistema';
  @override
  String get modeLight => 'Chiaro';
  @override
  String get modeDark => 'Scuro';

  @override
  String get amoledTitle => 'Nero AMOLED';
  @override
  String get amoledSubtitle => 'Sfondi neri puri in modalità scura';

  @override
  String get colorIntensity => 'Intensità del colore';
  @override
  List<String> get intensityLabels =>
      const ['Tenue', 'Equilibrata', 'Viva', 'Intensa'];

  @override
  String get startTabAuto => 'Automatica';

  @override
  String get replayTutorialTitle => 'Rivedi il tutorial';
  @override
  String get replayTutorialSubtitle => 'Il giro di benvenuto, dall’inizio';

  @override
  String get aboutSubtitle => 'Versione 2.0 · Fatta con Flutter';

  @override
  String get backupIntro =>
      'Salva TUTTO (piatti, settimane, dispensa e diario) in un file. La chiave '
      'dell’IA non viene inclusa, per sicurezza.';
  @override
  String get exportBackup => 'Esporta backup';
  @override
  String get exportBackupSubtitle => 'Condividi o salva il file .json';
  @override
  String get restoreBackup => 'Ripristina backup';
  @override
  String get restoreBackupSubtitle => 'Sostituisce i dati attuali';
  @override
  String get backupShareSubject => 'Backup di Meal Planner';
  @override
  String get restoreConfirmBody =>
      'Questo sostituirà i tuoi piatti, le settimane, la dispensa e il diario '
      'con quelli del backup. Alla fine bisogna riavviare l’app.\n\n'
      'Sicuro di voler continuare?';
  @override
  String get restore => 'Ripristina';
  @override
  String get backupRestored =>
      'Backup ripristinato. Chiudi e riapri l’app per vederlo.';

  @override
  String get aiIntro =>
      'Con la tua chiave gratuita di Google Gemini puoi stimare i macro di un '
      'piatto da testo o da foto. Prendila su aistudio.google.com/apikey';
  @override
  String get apiKeyLabel => 'Chiave API';
  @override
  String get modelLabel => 'Modello';
  @override
  String modelHelper(String model) => 'Predefinito: $model';
  @override
  String get aiEnabled => 'IA attiva: puoi stimare da foto o da testo.';
  @override
  String get aiDisabled => 'Senza chiave: la stima con IA è disattivata.';

  // ======================= «ALTRO» =======================

  @override
  String get moreTitle => 'Altro';
  @override
  String get statDishes => 'piatti';
  @override
  String get statWeeks => 'settimane';
  @override
  String get statStreak => 'giorni di fila';

  @override
  String get sectionYourFood => 'La tua cucina';
  @override
  String get addMealTitle => 'Aggiungi un piatto';
  @override
  String get addMealSubtitle => 'Crea un piatto nuovo per il tuo catalogo';
  @override
  String get myIngredientsTitle => 'I miei ingredienti';
  @override
  String get myIngredientsSubtitle => 'Dispensa con misure casalinghe e scorte';
  @override
  String get giveIdeasTitle => 'Dammi idee';
  @override
  String get giveIdeasSubtitle => 'Che l’IA ti proponga piatti nuovi';
  @override
  String get rouletteTitle => 'Roulette della cena';
  @override
  String get rouletteSubtitle => 'Per quando non vuoi nemmeno decidere';

  @override
  String get sectionProgress => 'Progressi';
  @override
  String get statsTitle => 'Statistiche';
  @override
  String get statsSubtitle => 'Medie, serie, peso e giorni centrati';
  @override
  String get gymModeTitle => 'Modalità Gym';
  @override
  String gymModeActive(String goal) => 'Attiva · $goal';
  @override
  String get gymModeNoGoal => 'senza obiettivo';
  @override
  String get gymModeSubtitle => 'Obiettivi di calorie e proteine';

  @override
  String get sectionApp => 'Applicazione';
  @override
  String get settingsSubtitle => 'Tema, lingua, IA, backup';

  // ======================= OGGI / DIARIO =======================

  @override
  String get todayScreenTitle => 'Diario';
  @override
  String get today => 'Oggi';
  @override
  String get yesterday => 'Ieri';
  @override
  String get chooseDay => 'Scegli il giorno';
  @override
  String get previousDay => 'Giorno precedente';
  @override
  String get nextDay => 'Giorno successivo';

  @override
  String get menuCopyYesterday => 'Copia la giornata di ieri';
  @override
  String get menuDayNote => 'Nota del giorno';
  @override
  String get menuWhatFits => 'Cosa ci sta in quello che mi resta?';
  @override
  String get menuRoulette => 'Roulette della cena';
  @override
  String get menuClearDay => 'Svuota questa giornata';

  @override
  String get whatYouveHad => 'Quello che hai mangiato';
  @override
  String get nothingLoggedYet =>
      'Ancora niente. Spunta i pasti pianificati qui sopra o premi «Aggiungi».';
  @override
  String get otherSlot => 'Altro';

  @override
  String get adjustAmount => 'Regola la quantità';
  @override
  String howMuchOf(String dish) => 'Quanto hai mangiato di $dish?';
  @override
  String get oneServing => '1 porzione';
  @override
  String servingsCount(String amount) => '$amount porzioni';
  @override
  String removedItem(String name) => 'Tolto: $name';

  @override
  String get needTargetForFits =>
      'Imposta il tuo obiettivo nella Modalità Gym per usare questo';
  @override
  String get alreadyOverToday => 'Hai già superato l’obiettivo di oggi.';
  @override
  String kcalLeftFits(int left) =>
      'Ti restano $left kcal. Ecco cosa ci sta, dal più proteico al meno:';
  @override
  String get nothingFitsCatalog => 'Non c’è niente nel tuo catalogo che ci stia.';

  @override
  String get yesterdayWasEmpty => 'Ieri non c’è niente segnato';
  @override
  String copiedMeals(int n) => 'Copiati $n pasti da ieri';
  @override
  String get dayAlreadyEmpty => 'Questa giornata è già vuota';
  @override
  String get dayCleared => 'Giornata svuotata';

  @override
  String get weightToday => 'Peso di oggi';
  @override
  String get weight => 'Peso';
  @override
  String get logWeight => 'Segna il peso';
  @override
  String get weightSubtitle => 'Serve per il grafico dei progressi';

  @override
  String get noteHint => 'Allenato gambe, cena fuori…';

  @override
  String get manualEntry => 'Inserimento manuale';
  @override
  String get manualEntrySubtitle => 'Scrivi nome, calorie e proteine';
  @override
  String get searchYourMeals => 'Cerca tra i tuoi piatti';
  @override
  String get noResultsUseManual =>
      'Nessun risultato. Usa l’inserimento manuale.';
  @override
  String get noMacrosLoggedAsZero => 'Senza macro (conta come 0)';
  @override
  String get youEatThisOften => 'Lo mangi spesso';
  @override
  String addedItem(String name) => 'Aggiunto: $name';

  @override
  String get plannedForThisDay => 'Quello che avevi pianificato';
  @override
  String get nothingPlannedThisDay => 'Non c’è niente pianificato per oggi.';

  @override
  String hadKcalAndProtein(int kcal, int protein) =>
      'Sei a $kcal kcal e $protein g di proteine.';
  @override
  String get setUpGymProfile =>
      'Completa il profilo nella Modalità Gym per vedere i tuoi obiettivi.';
  @override
  String kcalLeft(int n) => 'Ti restano $n kcal';
  @override
  String kcalOver(int n) => 'Hai superato di $n kcal';
  @override
  String get proteinMet => 'Proteine centrate';
  @override
  String streakBadge(int days) =>
      days == 1 ? 'Serie di 1 giorno' : 'Serie di $days giorni';
  @override
  String ofTarget(int target) => 'su $target';

  @override
  String get water => 'Acqua';
  @override
  String waterGlasses(int n) =>
      n == 1 ? '1 bicchiere d’acqua' : '$n bicchieri d’acqua';

  // ======================= PIANIFICATORE =======================

  @override
  String get plannerTitle => 'Pianificatore';
  @override
  String get viewNormal => 'Vista normale';
  @override
  String get viewCompact => 'Vista compatta';

  @override
  String get menuGoToThisWeek => 'Vai alla settimana di oggi';
  @override
  String get menuWeekDate => 'Data di questa settimana';
  @override
  String get menuDuplicateWeek => 'Duplica settimana';
  @override
  String get menuImportWeek => 'Importa settimana';
  @override
  String get menuExportWeek => 'Esporta settimana';
  @override
  String get menuShareAsText => 'Condividi come testo';

  @override
  String get randomize => 'A caso';
  @override
  String get howToRandomize => 'Come estrarre a caso';
  @override
  String get onlyFillGaps => 'Riempi solo i buchi';
  @override
  String get onlyFillGapsSubtitle => 'Non tocca quello che hai già messo';
  @override
  String get useLeftovers => 'Sfrutta gli avanzi';
  @override
  String get useLeftoversSubtitle =>
      'I piatti che rendono più porzioni tornano al pasto successivo';
  @override
  String get onlyDishesWithMacros => 'Solo piatti con macro';
  @override
  String get aimForMyCalories => 'Puntare alle mie calorie';
  @override
  String get aimForMyCaloriesSubtitle =>
      'Prova a far cadere ogni giornata vicino al tuo obiettivo';
  @override
  String busyDaysMarked(int n) => n == 1
      ? '1 giorno segnato come «vado di fretta»'
      : '$n giorni segnati come «vado di fretta»';
  @override
  String get busyDaysSubtitle => 'Ricevono solo piatti veloci';
  @override
  String get randomizerOptions => 'Opzioni dell’estrazione';

  @override
  String get weekDuplicated => 'Settimana duplicata';
  @override
  String get weekDuplicateFailed =>
      'Non è stato possibile duplicare (numero massimo di settimane)';
  @override
  String get noWeekIsToday =>
      'Nessuna settimana è impostata sulla data di oggi. Usa «Data di questa '
      'settimana».';
  @override
  String get pickAnyDayOfWeek => 'Scegli un giorno qualsiasi di quella settimana';
  @override
  String get noMealsToExport => 'Non ci sono piatti da esportare';
  @override
  String get weekShareSubject => 'Pianificatore settimanale';
  @override
  String get weekMenuSubject => 'Menù della settimana';
  @override
  String importedIntoWeek(int n) => 'Pianificatore importato nella settimana $n';

  @override
  String get addWeek => 'Aggiungi settimana';
  @override
  String get deleteCurrentWeek => 'Elimina la settimana attuale';
  @override
  String get deleteWeekTitle => 'Elimina settimana';
  @override
  String deleteWeekBody(String label) =>
      'Il piano di «$label» verrà cancellato. Sicuro?';
  @override
  String maxWeeks(int n) => 'Massimo $n settimane';
  @override
  String get cannotDeleteOnlyWeek =>
      'Non puoi eliminare la tua unica settimana';

  @override
  String get todayBadge => 'OGGI';
  @override
  String get dayOptions => 'Opzioni del giorno';
  @override
  String get unlockDay => 'Sblocca il giorno';
  @override
  String get lockDay => 'Blocca il giorno';
  @override
  String get clearBusyDay => 'Togli «vado di fretta»';
  @override
  String get markBusyDay => 'Vado di fretta (piatti veloci)';
  @override
  String get eatingInAgain => 'Torno a mangiare a casa';
  @override
  String get eatingOutThisDay => 'Questo giorno mangio fuori';
  @override
  String get clearDay => 'Svuota il giorno';
  @override
  String get eatingOutNotice =>
      'Mangi fuori: non si pianifica e non entra nella spesa.';
  @override
  String dayClearedNamed(String day) => '$day svuotato';

  @override
  String get tapToChoose => 'Tocca per scegliere';
  @override
  String get addToMyCatalog => 'Aggiungi al mio catalogo';
  @override
  String addedToCatalog(String name) => 'Aggiunto al tuo catalogo: $name';
  @override
  String get shuffleThisOne => 'Cambia a caso';
  @override
  String get dayIsLocked => 'Quel giorno è bloccato. Sbloccalo prima.';
  @override
  String get searchDishOrIngredient => 'Cerca un piatto o un ingrediente';
  @override
  String get clearThisMeal => 'Svuota questo pasto';
  @override
  String get awayShort => 'Fuori';

  @override
  String weekNumber(int n) => 'Settimana $n';
  @override
  String get thisWeek => 'Questa settimana';

  // ======================= I MIEI PIATTI =======================

  @override
  String get myMealsTitle => 'I miei piatti';
  @override
  String get scanProduct => 'Scansiona un prodotto';
  @override
  String get scanProductSubtitle => 'Riempie i dati dal codice a barre';
  @override
  String get addByHand => 'Aggiungi a mano';
  @override
  String get addByHandSubtitle => 'Per il fresco o quello senza codice';
  @override
  String get exampleMeals => 'Piatti di esempio';
  @override
  String get sort => 'Ordina';
  @override
  String get sortNameAsc => 'Nome (A-Z)';
  @override
  String get sortNameDesc => 'Nome (Z-A)';
  @override
  String get sortMostUsed => 'Più usati';
  @override
  String get searchByNameOrIngredient => 'Cerca per nome o ingrediente';
  @override
  String get canCookNow => 'Posso cucinarlo subito';
  @override
  String get withMacros => 'Con macro';
  @override
  String get withoutMacros => 'Senza macro';
  @override
  String get noSearchResults => 'Nessun risultato per la tua ricerca.';

  @override
  String ingredientCount(int n) => n == 1 ? '1 ingrediente' : '$n ingredienti';
  @override
  String servingsMadeCount(int n) => n == 1 ? '1 porzione' : '$n porzioni';
  @override
  String get highInProtein => 'Ricco di proteine';

  @override
  String get unfavourite => 'Togli dai preferiti';
  @override
  String get markFavourite => 'Segna come preferito';
  @override
  String get proposeAgain => 'Riproponilo';
  @override
  String get notInTheMood => 'Non mi va (2 settimane)';
  @override
  String get duplicate => 'Duplica';
  @override
  String get copySuffix => 'copia';
  @override
  String snoozedMessage(String name) =>
      '«$name» non uscirà a caso per 2 settimane';
  @override
  String get deleteMealTitle => 'Elimina piatto';
  @override
  String deleteMealBody(String name) =>
      'Sicuro di voler eliminare «$name»?';
  @override
  String deletedItem(String name) => 'Eliminato: $name';

  @override
  String get noMealsYet => 'Non hai ancora piatti';
  @override
  String get noMealsYetSubtitle =>
      'Comincia dai nostri piatti di esempio o creane di tuoi.';
  @override
  String get seeExampleMeals => 'Vedi i piatti di esempio';

  // ======================= LISTA DELLA SPESA =======================

  @override
  String get shoppingListTitle => 'Lista della spesa';
  @override
  String get superMarketMode => 'Modalità supermercato (caratteri grandi)';
  @override
  String get checkAll => 'Spunta tutto';
  @override
  String get uncheckAll => 'Togli tutte le spunte';
  @override
  String get showBought => 'Mostra ciò che hai comprato';
  @override
  String get hideBought => 'Nascondi ciò che hai comprato';
  @override
  String get shareList => 'Condividi la lista';
  @override
  String get copyToClipboard => 'Copia negli appunti';
  @override
  String get recurringItems => 'I soliti articoli';
  @override
  String get listCopied => 'Lista copiata';
  @override
  String get shoppingShareSubject => 'Lista della spesa';
  @override
  String get recurringItemsBody =>
      'Aggiungili alla lista di questa settimana con un tocco.';
  @override
  String get addToListTitle => 'Aggiungi alla lista';
  @override
  String get ingredientOrProduct => 'Ingrediente o prodotto';
  @override
  String get listComplete => 'Lista completata!';
  @override
  String inCart(int done, int total) => '$done di $total nel carrello';
  @override
  String get addedByHand => 'Aggiunto a mano';
  @override
  String get emptyListTitle => 'La lista è vuota';
  @override
  String get emptyListSubtitle =>
      'Pianifica dei pasti per questa settimana o aggiungi articoli con il '
      'pulsante «Aggiungi».';

  @override
  List<String> get recurringItemsList => const [
        'Carta da cucina', 'Carta igienica', 'Caffè', 'Latte', 'Pane',
        'Olio d’oliva', 'Sale', 'Sacchi della spazzatura', 'Detersivo', 'Uova',
        'Acqua', 'Frutta mista',
      ];

  // ======================= AGGIUNGI / MODIFICA PIATTO =======================

  @override
  String get editMeal => 'Modifica piatto';
  @override
  String get addMeal => 'Aggiungi un piatto';
  @override
  String prefillNotice(String origin) =>
      '$origin. Controllalo e sistemalo prima di salvare.';
  @override
  String get mealNameLabel => 'Nome del piatto';
  @override
  String get favourite => 'Preferito';
  @override
  String get photo => 'Foto';
  @override
  String get takePhoto => 'Scatta una foto';
  @override
  String get chooseFromGallery => 'Scegli dalla galleria';
  @override
  String get removePhoto => 'Togli la foto';

  @override
  String get ingredientsTitle => 'Ingredienti';
  @override
  String get scan => 'Scansiona';
  @override
  String get searchIngredient => 'Cerca un ingrediente';
  @override
  String get byHand => 'A mano';
  @override
  String get ingredientsTextLabel => 'Ingredienti (testo)';
  @override
  String get ingredientsTextHelper =>
      'Separali con virgole: pomodoro, pasta, formaggio';
  @override
  String get nutritionPerServing => 'Valori nutrizionali (per porzione)';
  @override
  String get estimateWithAi => 'Stima con l’IA';
  @override
  String totalLine(int kcal, int protein) =>
      'Totale: $kcal kcal · $protein g di proteine';

  @override
  String get whichSlots => 'Per quali pasti va bene?';
  @override
  String get ifNoneAllApply => 'Se non ne segni nessuno, varrà per tutti.';
  @override
  String get tagsTitle => 'Etichette';
  @override
  String get tagsHelp =>
      'Servono a evitare che la settimana sia tutta di pasta.';

  @override
  String get detailsTitle => 'Dettagli';
  @override
  String get prepTime => 'Tempo';
  @override
  String get costPerServing => 'Costo/porzione';
  @override
  String get servingsMadeTitle => 'Porzioni che rende';
  @override
  String servingsMadeMulti(int n) => 'Cucini una volta e mangi $n volte';
  @override
  String get servingsMadeOne => 'Si cucina per un pasto solo';
  @override
  String get recipeOrNotes => 'Ricetta o note';
  @override
  String get recipeOrNotesHelper => 'Passaggi, trucchi, un link…';

  @override
  String get pleaseCompleteName => 'Per favore, scrivi il nome';
  @override
  String get pleaseCompleteNameAndIngredients =>
      'Per favore, scrivi il nome e gli ingredienti';
  @override
  String renamedTo(String name) =>
      'Rinominato in «$name» (anche nelle tue settimane)';
  @override
  String get mealUpdated => 'Piatto aggiornato';
  @override
  String get mealAdded => 'Piatto aggiunto';
  @override
  String get aiMacrosFilled =>
      'Macro stimate con l’IA. Controllale prima di salvare.';

  @override
  String get addIngredientTitle => 'Aggiungi un ingrediente';
  @override
  String get editIngredientTitle => 'Modifica ingrediente';
  @override
  String get kcalPerUnit => 'kcal/unità';
  @override
  String get proteinPerUnit => 'prot/unità';

  // ======================= DISPENSA =======================

  @override
  String get pantryTitle => 'I miei ingredienti';
  @override
  String get restoreDeleted => 'Recupera quelli cancellati';
  @override
  String get presetsRestored => 'Recuperati gli ingredienti dell’app';
  @override
  String get tabFromApp => 'Dell’app';
  @override
  String get tabMine => 'I miei';
  @override
  String get searchIngredientHint => 'Cerca un ingrediente';
  @override
  String addedToMine(String name) => '«$name» aggiunto a «I miei»';
  @override
  String get pantryEmptyMine =>
      'Non hai ancora aggiunto ingredienti.\nScansiona un prodotto o premi '
      '«Aggiungi».';

  @override
  String haveInStock(String amount) => 'ne ho $amount';
  @override
  String useSoonExpires(int days) => days == 1
      ? 'Consumalo! Scade domani'
      : 'Consumalo! Scade tra $days giorni';
  @override
  String expiresInDays(int days) => 'Scade tra $days giorni';

  @override
  String get newIngredient => 'Nuovo ingrediente';
  @override
  String get unitLabel => 'Unità';
  @override
  String get unitHint => 'fetta, filetto…';
  @override
  String get gramsPerUnitShort => 'g/unità';
  @override
  String get unitTip =>
      'Trucco: la confezione di solito dice i grammi (per es. «10 fette · 200 g» '
      '→ 20 g a fetta).';
  @override
  String get unitTipRecalc =>
      ' I macro si ricalcolano da soli quando cambi i grammi.';
  @override
  String get categoryLabel => 'Categoria';
  @override
  String get repeatQuestion => 'Si può ripetere spesso?';
  @override
  String get haveAtHomeQuestion => 'Ce l’hai in casa?';
  @override
  String stockHelper(String unit) => 'In $unit';
  @override
  String get unitsFallback => 'unità';
  @override
  String get expiryDate => 'Data di scadenza';
  @override
  String get expiryShort => 'Scadenza';
  @override
  String get removeExpiry => 'Togli la scadenza';

  // ======================= SCELTA DELLA PORZIONE =======================

  @override
  String get units => 'Unità';
  @override
  String get grams => 'Grammi';
  @override
  String get productHasNoMacros =>
      'Questo prodotto non ha i macro. Aggiungili a mano.';
  @override
  String get saveToMyIngredients => 'Salva in I miei ingredienti';
  @override
  String get whichMeasure => 'In che misura?';
  @override
  String get howMany => 'Quante?';
  @override
  String gramsPer(String unit) => 'g per $unit';
  @override
  String get howManyGrams => 'Quanti grammi?';
  @override
  String get howManyServings => 'Quante porzioni?';
  @override
  String oneServingIs(String size) => '1 porzione = $size';
  @override
  String get proteinGramsShort => 'proteine (g)';

  // ======================= MODALITÀ GYM =======================

  @override
  String get gymIntro =>
      'Attiva la Modalità Gym per pianificare i pasti in base al tuo obiettivo '
      '(massa, definizione…) senza perderti nei tecnicismi.';
  @override
  String get enableGymMode => 'Attiva la Modalità Gym';
  @override
  String get enableGymModeSubtitle =>
      'Mostra le opzioni di monitoraggio per la palestra';
  @override
  String get yourGoal => 'Il tuo obiettivo';
  @override
  String get yourGoalSubtitle =>
      'Scegli cosa vuoi ottenere. Senza tecnicismi.';
  @override
  String get yourTargets => 'I tuoi obiettivi';
  @override
  String estimatedExpenditure(int kcal) =>
      'Consumo stimato: $kcal kcal/giorno';
  @override
  String get setYourOwnFigures =>
      'Metti i tuoi numeri di calorie e proteine.';
  @override
  String get completeProfileToCalculate =>
      'Completa il profilo per calcolare i tuoi obiettivi.';
  @override
  String get adjustFigures => 'Regola i numeri';
  @override
  String get editProfile => 'Modifica il profilo';
  @override
  String get completeProfile => 'Completa il profilo';
  @override
  String get yourFigures => 'I tuoi numeri';
  @override
  String get todaysLog => 'Diario di oggi';
  @override
  String get todaysLogSubtitle => 'Segna cosa mangi e segui i tuoi progressi';
  @override
  String get mealsPerDay => 'Pasti della giornata';
  @override
  String get mealsPerDaySubtitle =>
      'Scegli quanti pasti pianifichi ogni giorno.';
  @override
  String daysInARow(int days) =>
      days == 1 ? '1 giorno di fila' : '$days giorni di fila';
  @override
  String get noStreakYet => 'Ancora nessuna serie';
  @override
  String get setTargetToCount =>
      'Imposta il tuo obiettivo per iniziare a contare.';
  @override
  String get logToStartStreak => 'Segna cosa mangi e comincia la serie.';
  @override
  String last7Days(int met, int days) =>
      'Ultimi 7 giorni: proteine centrate $met su $days.';

  // ======================= PROFILO GYM =======================

  @override
  String get yourProfile => 'Il tuo profilo';
  @override
  String get profileIntro =>
      'Con questi dati calcoliamo i tuoi obiettivi. Restano salvati e puoi '
      'cambiarli quando vuoi.';
  @override
  String get height => 'Altezza';
  @override
  String get age => 'Età';
  @override
  String get years => 'anni';
  @override
  String get sexTitle => 'Sesso';
  @override
  String get sexNote => 'Serve solo per calcolare il consumo calorico.';
  @override
  String get activityLevel => 'Livello di attività';
  @override
  String get fillToSeeTargets =>
      'Inserisci peso, altezza ed età per vedere i tuoi obiettivi.';
  @override
  String targetsForGoal(String goal) => 'I tuoi obiettivi · $goal';
  @override
  String get customFiguresNote =>
      'In «Personalizzato» potrai regolare questi numeri a mano.';
  @override
  String get saveProfile => 'Salva il profilo';
  @override
  String get profileSaved => 'Profilo salvato';
  @override
  String get checkProfileData =>
      'Controlla i dati: peso, altezza ed età validi';

  // ======================= STATISTICHE =======================

  @override
  String get statisticsTitle => 'Statistiche';
  @override
  String get exportCsv => 'Esporta il diario (CSV)';
  @override
  String get csvSubject => 'Il mio diario alimentare';
  @override
  String daysRange(int n) => '$n giorni';
  @override
  String get avgPerDay => 'Media al giorno';
  @override
  String get avgProtein => 'Proteine medie';
  @override
  String get daysMeetingProtein => 'Giorni con proteine centrate';
  @override
  String get currentStreak => 'Serie attuale';
  @override
  String get daysUnit => 'giorni';

  @override
  String get yourWeight => 'Il tuo peso';
  @override
  String get weightNeedsTwoDays =>
      'Segna il peso in almeno due giorni dalla schermata del diario per vedere '
      'il grafico e la tendenza.';
  @override
  String get sevenDayAverage => 'Media di 7 giorni';

  @override
  String get achievementsTitle => 'Obiettivi';
  @override
  String achievementsUnlocked(int unlocked, int total) =>
      '$unlocked su $total sbloccati';

  @override
  String get whatYouEatMost => 'Quello che mangi di più';
  @override
  String get nothingPlannedYet => 'Non hai ancora pianificato niente.';
  @override
  String timesInYourWeeks(int n) => n == 1
      ? '1 volta nelle tue settimane'
      : '$n volte nelle tue settimane';

  @override
  String get verdictNoTarget =>
      'Imposta il tuo obiettivo nella Modalità Gym per sapere come stai andando.';
  @override
  String get verdictNoData => 'Non ci sono ancora abbastanza dati.';
  @override
  String get verdictGreat =>
      'Molto bene: centri le proteine quasi tutti i giorni.';
  @override
  String get verdictOk =>
      'Vai bene, ma parecchi giorni ti sfuggono. Prova a mettere uno spuntino '
      'proteico a metà pomeriggio.';
  @override
  String get verdictLow =>
      'Resti corto di proteine quasi tutti i giorni. Aggiungi piatti «ricchi di '
      'proteine» al tuo catalogo.';
  @override
  String adjustToKcal(int kcal) => 'Regola a $kcal kcal';
  @override
  String targetAdjusted(int kcal) => 'Obiettivo regolato a $kcal kcal';
  @override
  String get noLogsInPeriod =>
      'Ancora nessuna voce in questo periodo.\nSegna cosa mangi nella scheda '
      '«Oggi» e qui vedrai le tue medie.';

  @override
  Map<String, (String, String)> get achievements => const {
        'cocinero': ('Cuoco', 'Crea 10 piatti nel tuo catalogo'),
        'chef': ('Chef', 'Arriva a 50 piatti'),
        'constante': ('Costante', 'Registra 7 giorni'),
        'veterano': ('Veterano', 'Registra 100 giorni'),
        'racha7':
            ('Una settimana perfetta', '7 giorni di fila centrando le proteine'),
        'racha30': ('Inarrestabile', '30 giorni di proteine di fila'),
        'planificador': ('Pianificatore', 'Pianifica 4 settimane'),
        'fotografo': ('Fotografo', 'Metti una foto a 5 piatti'),
        'proteico':
            ('Obiettivo centrato', 'Centra le proteine 30 giorni in totale'),
        'semanaperfecta': ('Settimana perfetta',
            'Una settimana intera pianificata da cima a fondo'),
      };

  // ======================= IA: STIMARE =======================

  @override
  String get aiEstimateTitle => 'Stima con l’IA';
  @override
  String get aiEstimateIntro =>
      'Descrivi cosa hai mangiato e/o aggiungi una foto. L’IA stima le calorie '
      'e le proteine (all’incirca).';
  @override
  String get descriptionLabel => 'Descrizione';
  @override
  String get descriptionHint =>
      'Es.: un piatto di pasta col tonno, porzione normale';
  @override
  String get gallery => 'Galleria';
  @override
  String get photoAdded => 'Foto aggiunta';
  @override
  String get estimating => 'Sto stimando…';
  @override
  String get estimateMacros => 'Stima i macro';
  @override
  String get resultAdjustIt => 'Risultato (sistemalo se vuoi)';
  @override
  String get useThisData => 'Usa questi dati';
  @override
  String get couldNotOpenImage => 'Non è stato possibile aprire l’immagine.';
  @override
  String get missingGeminiKey => 'Manca la tua chiave di Gemini';
  @override
  String get missingGeminiKeyBody =>
      'Per usare la stima con l’IA, aggiungi la tua chiave API gratuita di '
      'Google Gemini nelle Impostazioni.';
  @override
  String get goToSettings => 'Vai alle Impostazioni';

  // ======================= IA: IDEE =======================

  @override
  String get whatDoYouFancy => 'Cosa ti va?';
  @override
  String get whatDoYouFancyHint => 'Cene veloci e proteiche, senza pesce…';
  @override
  String get usePantry => 'Usa la mia dispensa';
  @override
  String get usePantrySubtitle => 'Preferisce gli ingredienti che hai già';
  @override
  String get thinking => 'Sto pensando…';
  @override
  String get proposeDishes => 'Proponi piatti';
  @override
  String get proposals => 'Proposte';
  @override
  String get proposalsDisclaimer =>
      'Sono stime: controllale prima di fidarti dei macro.';
  @override
  String get writeWhatYouWant => 'Scrivi che tipo di piatti vuoi.';
  @override
  String get aiSuggestNotConfigured =>
      'Perché l’IA ti proponga dei piatti devi mettere la tua chiave gratuita '
      'di Gemini nelle Impostazioni.';

  @override
  List<String> get ideaPresets => const [
        'Cene leggere sotto le 400 kcal',
        'Piatti ricchi di proteine per dopo la palestra',
        'Piatti economici che rendono tanto',
        'Colazioni veloci sotto i 10 minuti',
        'Ricette di recupero con quello che ho',
      ];

  // ======================= CERCA INGREDIENTE =======================

  @override
  String get searchIngredientTitle => 'Cerca un ingrediente';
  @override
  String get searchIngredientPlaceholder => 'Cerca (pollo, riso, uovo…)';
  @override
  String get noResultsTryAnother =>
      'Nessun risultato. Prova con un’altra parola.';
  @override
  String get otherQuantity => 'Altra quantità';
  @override
  String howManyUnits(String unit) => 'Quante $unit?';
  @override
  String oneUnitIs(String unit, int kcal, int protein) =>
      '1 $unit = $kcal kcal · $protein g';

  // ======================= ROULETTE =======================

  @override
  String rouletteFor(String slot) => 'Roulette · $slot';
  @override
  String get whatsForDinner => 'Cosa ceno?';
  @override
  String get onlyWithWhatIHave => 'Solo con quello che ho in casa';
  @override
  String get spin => 'Gira!';
  @override
  String get spinAgain => 'Ancora';
  @override
  String get putItInThePlan => 'Mettilo nel piano';
  @override
  String noDishesFor(String slot) => 'Non hai piatti per $slot';
  @override
  String assignedTo(String dish, String day, String slot) =>
      '$dish → $day, $slot';

  // ======================= SCANNER =======================

  @override
  String get scanProductTitle => 'Scansiona un prodotto';
  @override
  String get scanIngredientTitle => 'Scansiona un ingrediente';
  @override
  String get switchCamera => 'Cambia fotocamera';
  @override
  String get flash => 'Flash';
  @override
  String get aimAtBarcode =>
      'Inquadra il codice a barre del prodotto (legge anche i QR)';
  @override
  String get searchingProduct => 'Sto cercando il prodotto…';
  @override
  String get productNotFoundTitle => 'Prodotto non trovato';
  @override
  String productNotFoundBody(String code) =>
      'Nessun dato per il codice $code. Puoi aggiungerlo a mano.';
  @override
  String get keepScanning => 'Continua a scansionare';
  @override
  String scannedProductNote(String basis) =>
      'Prodotto scansionato (OpenFoodFacts · $basis)';
  @override
  String get basisPerServing => 'per porzione';
  @override
  String get basisPer100g => 'per 100 g';
  @override
  String get basisNoData => 'senza dati';
  @override
  String unknownProduct(String barcode) => 'Prodotto $barcode';

  // ======================= PIATTI DI ESEMPIO =======================

  @override
  String get exampleMealsTitle => 'Piatti di esempio';
  @override
  String get selectAll => 'Tutti';
  @override
  String get unselectAll => 'Togli tutti';
  @override
  String get alreadyInCatalog => 'Già nel tuo catalogo';
  @override
  String get selectMeals => 'Scegli dei piatti';
  @override
  String addNMeals(int n) => n == 1 ? 'Aggiungi 1 piatto' : 'Aggiungi $n piatti';
  @override
  String addedNMeals(int n) => n == 1
      ? 'Aggiunto 1 piatto al tuo catalogo'
      : 'Aggiunti $n piatti al tuo catalogo';
  @override
  String get presetNotice =>
      'Sono un punto di partenza e si possono modificare: aggiungi quello che '
      'ti serve e poi sistema ingredienti o macro a piacere.';

  // ======================= MESSAGGI DEL PROVIDER =======================

  @override
  String get noMealsToAssign => 'Non ci sono piatti da assegnare';
  @override
  String get noSlotsConfigured => 'Non ci sono pasti configurati';
  @override
  String noMealsWithMacrosFor(String slot) =>
      'Non ci sono piatti con macro per $slot';
  @override
  String noMealsFor(String slot) => 'Non ci sono piatti per $slot';
  @override
  String maxWeeksReached(int n) => 'Raggiunto il massimo di $n settimane';
  @override
  String importError(Object e) => 'Errore nell’importazione: $e';
  @override
  String get weekTextHeader => 'Menù della settimana';
  @override
  String get outOfHome => 'fuori casa';
  @override
  String get shoppingTextHeader => 'Lista della spesa';
  @override
  String get shoppingListIsEmpty => 'La lista è vuota.';
  @override
  String get unitAbbrev => 'pz';

  // ======================= BACKUP =======================

  @override
  String get backupInvalidFile => 'Il file non è un backup valido.';
  @override
  String get backupCorrupt => 'Il backup è vuoto o danneggiato.';
  @override
  String get backupNothingRestored =>
      'Non è stato possibile ripristinare nulla da quel backup.';

  // ======================= GEMINI =======================

  @override
  String get geminiMissingKey =>
      'Manca la chiave API di Gemini. Aggiungila nelle Impostazioni.';
  @override
  String get geminiNeedTextOrPhoto =>
      'Scrivi una descrizione o aggiungi una foto del piatto.';
  @override
  String get geminiBadKey =>
      'La chiave API non è valida o la richiesta è stata rifiutata.';
  @override
  String get geminiForbidden =>
      'Chiave API senza permessi. Controlla di averla copiata bene.';
  @override
  String get geminiModelNotFound =>
      'Modello non trovato. Controlla il nome del modello nelle Impostazioni.';
  @override
  String get geminiRateLimit =>
      'Hai superato il limite di richieste. Riprova tra un momento.';
  @override
  String geminiError(int code) => 'Errore di Gemini (codice $code).';
  @override
  String get geminiNoConnection =>
      'Non è stato possibile contattare Gemini. Controlla la connessione.';
  @override
  String get geminiUnreadable => 'Risposta di Gemini illeggibile.';
  @override
  String get geminiNothingUseful => 'Gemini non ha restituito nulla di utile.';
  @override
  String get geminiNoEstimate =>
      'Gemini non ha restituito nessuna stima. Prova a descriverlo meglio.';
  @override
  String get geminiParseFail => 'Non si è capita la stima di Gemini.';
  @override
  String get geminiCouldNotEstimate =>
      'L’IA non è riuscita a stimare i macro. Prova con più dettagli.';
  @override
  String get geminiSuggestionsParseFail => 'Non si sono capite le proposte.';
  @override
  String get geminiNoSuggestions => 'L’IA non ha proposto nessun piatto.';

  // ======================= REGOLAZIONE DELLE CALORIE =======================

  @override
  String get gymNotGaining =>
      'Non stai prendendo peso: prova a mangiare 150 kcal in più.';
  @override
  String get gymGainingTooFast =>
      'Stai salendo troppo in fretta: togli 150 kcal.';
  @override
  String get gymNotLosing => 'Non stai calando: prova con 150 kcal in meno.';
  @override
  String get gymLosingTooFast =>
      'Stai calando troppo in fretta: aggiungi 150 kcal.';

  // ======================= INTERFAZ LIMPIA =======================

  @override
  String get sectionInterface => 'Interfaccia';
  @override
  String get cleanModeTitle => 'Interfaccia pulita';
  @override
  String get cleanModeSubtitle =>
      'Nasconde i pulsanti secondari, i filtri e le schede extra. Non si perde '
      'niente: finisce tutto nei menù.';
  @override
  String get cleanModeHintTitle => 'Dov’è finito tutto?';
  @override
  String get cleanModeHintBody =>
      'I pulsanti spariti sono nel menù ⋮ in alto. Tieni premuto un pasto per '
      'le sue opzioni.';

  // ======================= WIDGETS DE INICIO =======================

  @override
  String get widgetsTitle => 'Widget della home';
  @override
  String get widgetsSubtitle =>
      'La tua giornata a colpo d’occhio, senza aprire l’app';
  @override
  String get widgetsIntro =>
      'Aggiungine uno da qui, oppure tieni premuto uno spazio vuoto della home '
      'e cerca Meal Planner nell’elenco dei widget.';
  @override
  String get widgetsRefreshNote =>
      'Si aggiornano ogni volta che esci dall’app e seguono il tuo tema di '
      'colore.';
  @override
  String get widgetTodayTitle => 'Oggi';
  @override
  String get widgetTodayDescription =>
      'Calorie e proteine del giorno, l’acqua e quello che ti resta.';
  @override
  String get widgetNextTitle => 'Il prossimo';
  @override
  String get widgetNextDescription =>
      'Il prossimo pasto del piano, e quello dopo.';
  @override
  String get widgetShoppingTitle => 'Lista della spesa';
  @override
  String get widgetShoppingDescription =>
      'Quello che manca ancora nel carrello questa settimana.';
  @override
  String get addToHomeScreen => 'Aggiungi alla home';
  @override
  String get widgetPinUnsupported =>
      'Il tuo launcher non lascia che sia l’app a metterlo. Tieni premuta la '
      'home e scegli il widget dall’elenco.';
  @override
  String get widgetNoPlan => 'Niente in programma';
  @override
  String get widgetAllBought => 'Tutto comprato';
  @override
  String widgetItemsLeft(int n) =>
      n == 1 ? 'Manca 1 cosa' : 'Mancano $n cose';
  @override
  String get widgetOnlyAndroid => 'I widget ci sono solo su Android.';
}
