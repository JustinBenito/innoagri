import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GeminiVisionService {
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
  static const String _apiKey = 'AIzaSyCbHOuLskezYas1foWQM6til2fc1Dj1ruo';

  static Future<Map<String, dynamic>> detectPlantDiseaseFromXFile(XFile imageFile) async {
    try {
      // Read image file and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      return await _analyzeImage(base64Image);
    } catch (e) {
      print('Error calling Gemini Vision API: $e');
      return {
        'diseaseDetected': false,
        'error': 'An error occurred while analyzing the image: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> detectPlantDisease(File imageFile) async {
    try {
      // Read image file and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      return await _analyzeImage(base64Image);
    } catch (e) {
      print('Error calling Gemini Vision API: $e');
      return {
        'diseaseDetected': false,
        'error': 'An error occurred while analyzing the image: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> _analyzeImage(String base64Image) async {
    try {

      final prompt = '''
You are an expert plant pathologist. Analyze this image and determine if there is any plant disease present.

Instructions:
1. If you detect a plant disease, respond in this JSON format (ALL TEXT IN TAMIL):
{
  "diseaseDetected": true,
  "diseaseName": "Name of the disease in Tamil",
  "description": "Brief description of the disease in Tamil (2-3 sentences)",
  "severity": "குறைவு/நடுத்தர/அதிக (Low/Medium/High in Tamil)",
  "treatment": "Recommended treatment in Tamil (2-3 sentences)"
}

2. If NO disease is detected and the plant looks healthy, respond in this JSON format (IN TAMIL):
{
  "diseaseDetected": false,
  "message": "Message in Tamil saying the plant is healthy"
}

3. If the image does not contain a plant, respond (IN TAMIL):
{
  "diseaseDetected": false,
  "error": "Error message in Tamil asking to upload a clear plant image"
}

IMPORTANT:
- Provide all text fields (diseaseName, description, severity, treatment, message, error) in TAMIL language only.
- Use proper Tamil unicode characters.
- Provide ONLY the JSON response, no additional text.
''';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                },
                {'text': prompt},
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from response (handling markdown code blocks)
        String jsonText = text.trim();
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        jsonText = jsonText.trim();

        final result = jsonDecode(jsonText) as Map<String, dynamic>;
        return result;
      } else {
        print('Gemini Vision API error: ${response.statusCode} - ${response.body}');
        return {
          'diseaseDetected': false,
          'error': 'Failed to analyze image. Please try again.',
        };
      }
    } catch (e) {
      print('Error in _analyzeImage: $e');
      return {
        'diseaseDetected': false,
        'error': 'An error occurred while analyzing the image: ${e.toString()}',
      };
    }
  }
}
