import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeApiService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY'; // Replace with your actual API key
  
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
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 200,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? 'No nudge generated';
      } else {
        print('Claude API error: ${response.statusCode} - ${response.body}');
        return _getDefaultNudge();
      }
    } catch (e) {
      print('Error calling Claude API: $e');
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
''';
  }

  static String _getDefaultNudge() {
    return 'Monitor your crops regularly and adjust watering based on weather conditions. Check soil moisture levels before watering.';
  }
}