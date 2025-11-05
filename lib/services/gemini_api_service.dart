import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static const String _apiKey = 'YOUR_KEY'; // Replace with your actual API key

  static Future<String> generateDailyNudge({
    required double temperature,
    required double windSpeed,
    required double humidity,
    required double uvIndex,
    required String weatherCondition,
    required Map<String, String> mineralValues,
  }) async {
    try {
      final prompt = _buildPrompt(
        temperature: temperature,
        windSpeed: windSpeed,
        humidity: humidity,
        uvIndex: uvIndex,
        weatherCondition: weatherCondition,
        mineralValues: mineralValues,
      );

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'No nudge generated';
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return _getDefaultNudge();
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return _getDefaultNudge();
    }
  }

  static String _buildPrompt({
    required double temperature,
    required double windSpeed,
    required double humidity,
    required double uvIndex,
    required String weatherCondition,
    required Map<String, String> mineralValues,
  }) {
    return '''
You are an expert agricultural advisor. Based on the following data, provide a concise daily farming nudge (2-3 sentences max) for farmers:

Weather Data:
- Temperature: ${temperature}°C
- Wind Speed: ${windSpeed} km/h
- Humidity: ${humidity}%
- UV Index: ${uvIndex}
- Condition: $weatherCondition

Soil Mineral Data:
${mineralValues.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Provide practical, actionable advice for today's farming activities based on these conditions. Focus on plant care, watering, soil management, or protection measures. Keep it simple and farmer-friendly.

ALL IN SHORT SUCCINCT TAMIL TEXT ONLY. NO ENGLISH
''';
  }

  static String _getDefaultNudge() {
    return 'Monitor your crops regularly and adjust watering based on weather conditions. Check soil moisture levels before watering.';
  }
}
