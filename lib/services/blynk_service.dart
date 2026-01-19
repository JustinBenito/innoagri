import 'dart:convert';
import 'package:http/http.dart' as http;

class BlynkService {
  static const String baseUrl = 'https://blynk.cloud/external/api/get';
  static const String token = 'ZEibHEuI_54d8IsJh4nMC4TpZSQHQQ9n';

  /// Fetches sensor data from Blynk API
  /// V0 -> temperature
  /// V1 -> humidity
  /// V2 -> soil moisture
  /// V3 -> pH
  static Future<BlynkSensorData?> getSensorData() async {
    try {
      final uri = Uri.parse('$baseUrl?token=$token&V0&V1&V2&V3');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BlynkSensorData.fromJson(data);
      } else {
        print('Blynk API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Blynk data: $e');
      return null;
    }
  }

  // Convert sensor data to mineral estimates
  static Map<String, String> estimateMinerals({
    required double pH,
    required double soilMoisture,
  }) {
    // Simple estimation logic based on pH and moisture

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

class BlynkSensorData {
  final double? temperature;
  final double? humidity;
  final double? soilMoisture;
  final double? pH;

  BlynkSensorData({
    this.temperature,
    this.humidity,
    this.soilMoisture,
    this.pH,
  });

  factory BlynkSensorData.fromJson(Map<String, dynamic> json) {
    return BlynkSensorData(
      temperature: _parseDouble(json['V0']),
      humidity: _parseDouble(json['V1']),
      soilMoisture: _parseDouble(json['V2']),
      pH: _parseDouble(json['V3']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
