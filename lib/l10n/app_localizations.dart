import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @allGallery.
  ///
  /// In fr, this message translates to:
  /// **'Toute la galerie'**
  String get allGallery;

  /// No description provided for @folder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier'**
  String get folder;

  /// No description provided for @trash.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get trash;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @darkmode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkmode;

  /// No description provided for @emptyTrash.
  ///
  /// In fr, this message translates to:
  /// **'La corbeille est vide'**
  String get emptyTrash;

  /// No description provided for @deviceFolders.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers de l\'appareil'**
  String get deviceFolders;

  /// No description provided for @photos.
  ///
  /// In fr, this message translates to:
  /// **'photos'**
  String get photos;

  /// No description provided for @january.
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get january;

  /// No description provided for @february.
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get february;

  /// No description provided for @march.
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get march;

  /// No description provided for @april.
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get april;

  /// No description provided for @may.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get may;

  /// No description provided for @june.
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get june;

  /// No description provided for @july.
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get july;

  /// No description provided for @august.
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get august;

  /// No description provided for @september.
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get september;

  /// No description provided for @october.
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get october;

  /// No description provided for @november.
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get november;

  /// No description provided for @december.
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get december;

  /// No description provided for @toEmptyTrash.
  ///
  /// In fr, this message translates to:
  /// **'Vider la corbeille ?'**
  String get toEmptyTrash;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get confirm;

  /// No description provided for @deleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get deleteAll;

  /// No description provided for @previousImage.
  ///
  /// In fr, this message translates to:
  /// **'Image postérieure'**
  String get previousImage;

  /// No description provided for @nextImage.
  ///
  /// In fr, this message translates to:
  /// **'Image antérieure'**
  String get nextImage;

  /// No description provided for @random.
  ///
  /// In fr, this message translates to:
  /// **'Aléatoire'**
  String get random;

  /// No description provided for @chrono.
  ///
  /// In fr, this message translates to:
  /// **'Chrono'**
  String get chrono;

  /// No description provided for @sortMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de tri'**
  String get sortMode;

  /// No description provided for @deleteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Ces photos seront définitivement supprimées de votre appareil. Cette action est irréversible.'**
  String get deleteWarning;

  /// No description provided for @removeFromTrash.
  ///
  /// In fr, this message translates to:
  /// **'Enlever de la corbeille'**
  String get removeFromTrash;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @restartSortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer le tri ?'**
  String get restartSortTitle;

  /// No description provided for @restartSortWarning.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les photos de ce dossier que vous aviez validées réapparaîtront.'**
  String get restartSortWarning;

  /// No description provided for @restart.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get restart;

  /// No description provided for @noPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo trouvée ou permission refusée'**
  String get noPhotos;

  /// No description provided for @vibrationSetting.
  ///
  /// In fr, this message translates to:
  /// **'Vibration au glissement'**
  String get vibrationSetting;

  /// No description provided for @spaceSaved.
  ///
  /// In fr, this message translates to:
  /// **'Espace libéré'**
  String get spaceSaved;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
