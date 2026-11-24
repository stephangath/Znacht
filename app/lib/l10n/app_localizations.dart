import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Znacht'**
  String get appTitle;

  /// No description provided for @tabWeek.
  ///
  /// In de, this message translates to:
  /// **'Woche'**
  String get tabWeek;

  /// No description provided for @tabShopping.
  ///
  /// In de, this message translates to:
  /// **'Einkauf'**
  String get tabShopping;

  /// No description provided for @tabKitchen.
  ///
  /// In de, this message translates to:
  /// **'Küche'**
  String get tabKitchen;

  /// No description provided for @tabProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @weekEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Wochenplan'**
  String get weekEmptyTitle;

  /// No description provided for @weekEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Hier erscheinen bald die Abendessen deiner Woche.'**
  String get weekEmptyBody;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Einkaufsliste'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Hier erscheint bald deine Einkaufsliste mit geschätzten Preisen.'**
  String get shoppingEmptyBody;

  /// No description provided for @kitchenEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorrat'**
  String get kitchenEmptyTitle;

  /// No description provided for @kitchenEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Hier verwaltest du bald, was du schon zu Hause hast.'**
  String get kitchenEmptyBody;

  /// No description provided for @profileEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profileEmptyTitle;

  /// No description provided for @profileEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Hier kannst du bald deine Haushaltsangaben bearbeiten.'**
  String get profileEmptyBody;

  /// No description provided for @devInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'Entwicklung'**
  String get devInfoTitle;

  /// No description provided for @devInfoEmulator.
  ///
  /// In de, this message translates to:
  /// **'Verbunden mit lokalen Firebase-Emulatoren'**
  String get devInfoEmulator;

  /// No description provided for @devInfoCatalog.
  ///
  /// In de, this message translates to:
  /// **'{recipes} Rezepte, aktive Händler: {retailers}'**
  String devInfoCatalog(int recipes, String retailers);

  /// No description provided for @devInfoNoData.
  ///
  /// In de, this message translates to:
  /// **'Keine Stammdaten gefunden. Import starten: npm run data:import'**
  String get devInfoNoData;

  /// No description provided for @devInfoError.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zum Emulator: {error}'**
  String devInfoError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
