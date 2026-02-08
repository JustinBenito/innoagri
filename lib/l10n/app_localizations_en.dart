// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Uzhavan - Smart Agriculture';

  @override
  String get chatbotTitle => 'AI Chatbot';

  @override
  String get forumTitle => 'Forum';

  @override
  String get soilTitle => 'Soil';

  @override
  String get chatbotPlaceholder => 'Chatbot conversation will appear here.';

  @override
  String get forumPlaceholder => 'Forum feature coming soon.';

  @override
  String get soilPlaceholder => 'Soil sensor integration coming soon.';

  @override
  String get typeMessage => 'Type your message here...';

  @override
  String get farConnect => 'FarConnect';

  @override
  String get weatherConditions => 'Weather Conditions';

  @override
  String get temperature => 'Temperature';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get humidity => 'Humidity';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get soilMoisture => 'Soil Moisture';

  @override
  String get pH => 'pH';

  @override
  String get dailyNudge => 'Daily Nudge';

  @override
  String get wannaTalk => 'Wanna Talk ?';

  @override
  String get wannaTalkDesc => 'Talk to our Uzhavan Chatbot for assistance on your crops and also in farming in general.';

  @override
  String get startChatting => 'Start Chatting';

  @override
  String get identifyPlantDisease => 'Identify Plant Disease';

  @override
  String get identifyPlantDiseaseDesc => 'Upload or take a photo of your plant to detect diseases and get treatment recommendations.';

  @override
  String get scanPlant => 'Scan Plant';

  @override
  String get generatingAdvice => 'Generating personalized advice...';

  @override
  String get typingResponse => 'Typing response...';

  @override
  String get defaultNudge => 'Monitor your crops regularly and adjust watering based on weather conditions.';
}
