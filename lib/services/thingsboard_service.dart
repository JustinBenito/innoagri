import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingsBoardService {
  // Use your deployed server as proxy to avoid CORS issues
  static const String proxyUrl = 'https://agri.justinbenito.com/api/thingsboard/telemetry';

  static Future<Map<String, dynamic>?> getLatestTelemetry() async {
    try {
      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('ThingsBoard error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching ThingsBoard data: $e');
      return null;
    }
  }

  // Convert sensor data to mineral estimates
  static Map<String, String> estimateMinerals({
    required double pH,
    required double soilMoisture,
  }) {
    // Simple estimation logic based on pH and moisture
    // You can adjust these calculations based on your needs

    // Potassium availability is optimal at pH 6-7
    double potassiumLevel = (pH >= 6.0 && pH <= 7.0) ? 0.8 : 0.5;

    // Sodium increases with salinity (inverse of moisture in some cases)
    double sodiumLevel = (soilMoisture < 30) ? 2.5 : 1.5;

    // Salt concentration
    double saltLevel = (pH > 7.5) ? 3.2 : 2.0;

    return {
      'Potassium': '${potassiumLevel.toStringAsFixed(1)}mg',
      'Sodium': '${sodiumLevel.toStringAsFixed(1)}mg',
      'Salts': '${saltLevel.toStringAsFixed(1)}mg',
    };
  }
}
