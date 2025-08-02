import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/theme.dart';
import '../services/daily_nudge_service.dart';
import 'chatbot_screen.dart';

class SoilScreen extends StatefulWidget {
  const SoilScreen({super.key});

  @override
  State<SoilScreen> createState() => _SoilScreenState();
}

class _SoilScreenState extends State<SoilScreen> {
  double? temperature;
  double? windSpeed;
  double? humidity;
  double? feelsLike;
  double? uvIndex;
  String? condition;
  String? dailyNudge;
  bool isLoadingNudge = false;
  List<double> hourlyWindSpeeds = [];
  
  // Mineral values (these would typically come from soil sensors)
  final Map<String, String> mineralValues = {
    'Potassium': '0.8mg',
    'Sodium': '1.8mg',
    'Salts': '2.8mg',
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'http://api.weatherapi.com/v1/current.json?key=57b13983b93d4a3582e163244232106&q=Chennai&aqi=yes';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['current']['temp_c']?.toDouble();
        windSpeed = data['current']['wind_kph']?.toDouble();
        humidity = data['current']['humidity']?.toDouble();
        feelsLike = data['current']['feelslike_c']?.toDouble();
        uvIndex = data['current']['uv']?.toDouble();
        condition = data['current']['condition']['text'];
        hourlyWindSpeeds = [windSpeed ?? 0];
      });
      
      // Generate daily nudge after weather data is loaded
      await _generateDailyNudge();
    } else {
      print('Failed to load weather data');
    }
  }

  Future<void> _generateDailyNudge() async {
    if (temperature == null || windSpeed == null || humidity == null || 
        uvIndex == null || condition == null) {
      return;
    }

    setState(() {
      isLoadingNudge = true;
    });

    try {
      final nudge = await DailyNudgeService.getDailyNudge(
        temperature: temperature!,
        windSpeed: windSpeed!,
        humidity: humidity!,
        uvIndex: uvIndex!,
        weatherCondition: condition!,
        mineralValues: mineralValues,
      );

      setState(() {
        dailyNudge = nudge;
        isLoadingNudge = false;
      });
    } catch (e) {
      print('Error generating daily nudge: $e');
      setState(() {
        dailyNudge = 'Monitor your crops regularly and adjust watering based on weather conditions.';
        isLoadingNudge = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzhavan App'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: temperature == null || windSpeed == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nutrient cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: _NutrientCard(
                          title: 'Potassium',
                          value: '0.8mg',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _NutrientCard(title: 'Sodium', value: '1.8mg'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _NutrientCard(title: 'Salts a', value: '2.8mg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _WeatherCard(
                    temperature: temperature!,
                    windSpeed: windSpeed!,
                    humidity: humidity!,
                    feelsLike: feelsLike!,
                    uvIndex: uvIndex!,
                    condition: condition!,
                    windSpeeds: hourlyWindSpeeds,
                  ),
                  const SizedBox(height: 24),
                  _DailyNudgeCard(
                    nudge: dailyNudge,
                    isLoading: isLoadingNudge,
                  ),
                  const SizedBox(height: 16),
                  const _WannaTalkCard(),
                  const SizedBox(height: 16), // Extra padding at bottom
                ],
              ),
            ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String title;
  final String value;
  const _NutrientCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 198, 255, 176),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontFamily: 'Comic Sans MS',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontFamily: 'Comic Sans MS',
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final double temperature;
  final double windSpeed;
  final double humidity;
  final double feelsLike;
  final double uvIndex;
  final String condition;
  final List<double> windSpeeds;

  const _WeatherCard({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
    required this.uvIndex,
    required this.condition,
    required this.windSpeeds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 198, 255, 176),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Conditions',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Condition: $condition',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temperature: ${temperature.toStringAsFixed(1)}°C',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feels Like: ${feelsLike.toStringAsFixed(1)}°C',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wind Speed: ${windSpeed.toStringAsFixed(1)} km/h',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Humidity: ${humidity.toStringAsFixed(0)}%',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'UV Index: ${uvIndex.toStringAsFixed(1)}',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindSpeedRow extends StatelessWidget {
  final double value;
  const _WindSpeedRow({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.eco, color: AppTheme.accentGreen, size: 20),
              SizedBox(width: 6),
              Text(
                'Wind Speed',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontFamily: 'Comic Sans MS',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Text(
            '${value.toStringAsFixed(1)} km/h',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyNudgeCard extends StatelessWidget {
  final String? nudge;
  final bool isLoading;
  
  const _DailyNudgeCard({
    required this.nudge,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nudge',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Generating personalized advice...',
                  style: TextStyle(
                    color: AppTheme.accentGreen,
                    fontFamily: 'Comic Sans MS',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ],
            )
          else
            Text(
              nudge ?? 'Monitor your crops regularly and adjust watering based on weather conditions.',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontFamily: 'Comic Sans MS',
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}

class _WannaTalkCard extends StatelessWidget {
  const _WannaTalkCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wanna Talk ?',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Talk to our Uzhavan Chatbot for assistance on your crops and also in farming in general.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Start Chatting',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
