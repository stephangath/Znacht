// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Znacht';

  @override
  String get tabWeek => 'Woche';

  @override
  String get tabShopping => 'Einkauf';

  @override
  String get tabKitchen => 'Küche';

  @override
  String get tabProfile => 'Profil';

  @override
  String get weekEmptyTitle => 'Dein Wochenplan';

  @override
  String get weekEmptyBody =>
      'Hier erscheinen bald die Abendessen deiner Woche.';

  @override
  String get shoppingEmptyTitle => 'Einkaufsliste';

  @override
  String get shoppingEmptyBody =>
      'Hier erscheint bald deine Einkaufsliste mit geschätzten Preisen.';

  @override
  String get kitchenEmptyTitle => 'Vorrat';

  @override
  String get kitchenEmptyBody =>
      'Hier verwaltest du bald, was du schon zu Hause hast.';

  @override
  String get profileEmptyTitle => 'Profil';

  @override
  String get profileEmptyBody =>
      'Hier kannst du bald deine Haushaltsangaben bearbeiten.';

  @override
  String get devInfoTitle => 'Entwicklung';

  @override
  String get devInfoEmulator => 'Verbunden mit lokalen Firebase-Emulatoren';

  @override
  String devInfoCatalog(int recipes, String retailers) {
    return '$recipes Rezepte, aktive Händler: $retailers';
  }

  @override
  String get devInfoNoData =>
      'Keine Stammdaten gefunden. Import starten: npm run data:import';

  @override
  String devInfoError(String error) {
    return 'Keine Verbindung zum Emulator: $error';
  }
}
