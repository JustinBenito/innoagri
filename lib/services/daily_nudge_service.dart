import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'claude_api_service.dart';

class DailyNudgeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'daily_nudges';

  static Future<String> getDailyNudge({
    required double temperature,
    required double windSpeed,
    required double humidity,
    required double uvIndex,
    required String weatherCondition,
    required Map<String, String> mineralValues,
  }) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Check if nudge already exists for today
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(today)
          .get();

      if (docSnapshot.exists) {
        // Return existing nudge
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['nudge'] ?? _getDefaultNudge();
      } else {
        // Generate new nudge using Claude API
        final nudge = await ClaudeApiService.generateDailyNudge(
          temperature: temperature,
          windSpeed: windSpeed,
          humidity: humidity,
          uvIndex: uvIndex,
          weatherCondition: weatherCondition,
          mineralValues: mineralValues,
        );

        // Store the nudge in Firebase
        await _firestore.collection(_collection).doc(today).set({
          'nudge': nudge,
          'date': today,
          'timestamp': FieldValue.serverTimestamp(),
          'weather_data': {
            'temperature': temperature,
            'wind_speed': windSpeed,
            'humidity': humidity,
            'uv_index': uvIndex,
            'condition': weatherCondition,
          },
          'mineral_data': mineralValues,
        });

        return nudge;
      }
    } catch (e) {
      print('Error in DailyNudgeService: $e');
      return _getDefaultNudge();
    }
  }

  static Future<Map<String, dynamic>?> getTodaysNudgeData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(today)
          .get();
      
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting today\'s nudge data: $e');
      return null;
    }
  }

  static Future<void> deleteOldNudges() async {
    try {
      // Delete nudges older than 30 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffString = DateFormat('yyyy-MM-dd').format(cutoffDate);
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isLessThan: cutoffString)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Deleted ${querySnapshot.docs.length} old nudges');
    } catch (e) {
      print('Error deleting old nudges: $e');
    }
  }

  static String _getDefaultNudge() {
    return 'Monitor your crops regularly and adjust watering based on weather conditions. Check soil moisture levels before watering.';
  }
}