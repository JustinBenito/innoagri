import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Uzhavan - Smart Agriculture'**
  String get appTitle;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chatbot'**
  String get chatbotTitle;

  /// No description provided for @forumTitle.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forumTitle;

  /// No description provided for @soilTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get soilTitle;

  /// No description provided for @chatbotPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chatbot conversation will appear here.'**
  String get chatbotPlaceholder;

  /// No description provided for @forumPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Forum feature coming soon.'**
  String get forumPlaceholder;

  /// No description provided for @soilPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Soil sensor integration coming soon.'**
  String get soilPlaceholder;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message here...'**
  String get typeMessage;

  /// No description provided for @farConnect.
  ///
  /// In en, this message translates to:
  /// **'FarConnect'**
  String get farConnect;

  /// No description provided for @weatherConditions.
  ///
  /// In en, this message translates to:
  /// **'Weather Conditions'**
  String get weatherConditions;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get uvIndex;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @pH.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get pH;

  /// No description provided for @dailyNudge.
  ///
  /// In en, this message translates to:
  /// **'Daily Nudge'**
  String get dailyNudge;

  /// No description provided for @wannaTalk.
  ///
  /// In en, this message translates to:
  /// **'Wanna Talk ?'**
  String get wannaTalk;

  /// No description provided for @wannaTalkDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk to our Uzhavan Chatbot for assistance on your crops and also in farming in general.'**
  String get wannaTalkDesc;

  /// No description provided for @startChatting.
  ///
  /// In en, this message translates to:
  /// **'Start Chatting'**
  String get startChatting;

  /// No description provided for @identifyPlantDisease.
  ///
  /// In en, this message translates to:
  /// **'Identify Plant Disease'**
  String get identifyPlantDisease;

  /// No description provided for @identifyPlantDiseaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload or take a photo of your plant to detect diseases and get treatment recommendations.'**
  String get identifyPlantDiseaseDesc;

  /// No description provided for @scanPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlant;

  /// No description provided for @generatingAdvice.
  ///
  /// In en, this message translates to:
  /// **'Generating personalized advice...'**
  String get generatingAdvice;

  /// No description provided for @typingResponse.
  ///
  /// In en, this message translates to:
  /// **'Typing response...'**
  String get typingResponse;

  /// No description provided for @defaultNudge.
  ///
  /// In en, this message translates to:
  /// **'Monitor your crops regularly and adjust watering based on weather conditions.'**
  String get defaultNudge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'hi',
    'kn',
    'ml',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
