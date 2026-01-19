import 'package:flutter_tts/flutter_tts.dart';
import '../utils/language_detector.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;
  static List<dynamic> _availableLanguages = [];

  static Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Get available languages
      _availableLanguages = await _flutterTts.getLanguages ?? [];
      print('Available TTS languages: $_availableLanguages');

      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);

      // Platform-specific settings
      if (!kIsWeb) {
        if (Platform.isIOS) {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            ],
            IosTextToSpeechAudioMode.voicePrompt,
          );
        }
      }

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      print('TTS Initialization error: $e');
      _isInitialized = true; // Mark as initialized even on error
    }
  }

  /// Speaks text with auto-detected language
  static Future<void> speakAuto(String text) async {
    final detectedLanguage = LanguageDetector.detectLanguage(text);
    print('Detected language: $detectedLanguage for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    await speak(text, languageCode: detectedLanguage);
  }

  /// Speaks text with specified language
  static Future<void> speak(String text, {String languageCode = 'ta'}) async {
    await _initialize();

    if (_isSpeaking) {
      await stop();
    }

    try {
      // Set language based on code with fallback options
      String langCode;
      if (languageCode == 'ta') {
        // Try different Tamil language codes
        if (_availableLanguages.contains('ta-IN')) {
          langCode = 'ta-IN';
        } else if (_availableLanguages.contains('ta')) {
          langCode = 'ta';
        } else if (_availableLanguages.contains('ta_IN')) {
          langCode = 'ta_IN';
        } else {
          print('Tamil language not available. Available languages: $_availableLanguages');
          // Fallback to English if Tamil not available
          langCode = 'en-US';
        }
      } else {
        langCode = 'en-US';
      }

      print('Setting TTS language to: $langCode');
      final result = await _flutterTts.setLanguage(langCode);
      print('setLanguage result: $result');

      _isSpeaking = true;
      final speakResult = await _flutterTts.speak(text);
      print('speak result: $speakResult');
    } catch (e) {
      print('TTS speak error: $e');
      _isSpeaking = false;
    }
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  static bool get isSpeaking => _isSpeaking;

  static Future<void> dispose() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }
}
