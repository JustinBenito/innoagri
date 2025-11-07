import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../utils/theme.dart';
import '../services/daily_nudge_service.dart';
import '../services/thingsboard_service.dart';
import 'chatbot_screen.dart';
import 'plant_disease_screen.dart';

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
  String location = 'Chennai, India';
  String? dailyNudge;
  bool isLoadingNudge = false;

  // Sensor data from ThingsBoard
  double? soilPh;
  double? soilMoisture;
  Map<String, String> mineralValues = {
    'Potassium': '0.8mg',
    'Sodium': '1.8mg',
    'Salts': '2.8mg',
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    fetchThingsBoardData();
  }

  Future<void> fetchThingsBoardData() async {
    try {
      final data = await ThingsBoardService.getLatestTelemetry();
      if (data != null) {
        setState(() {
          soilPh = data['pH']?[0]?['value']?.toDouble();
          soilMoisture = data['soilMoisture']?[0]?['value']?.toDouble();

          // Estimate minerals from pH and moisture
          if (soilPh != null && soilMoisture != null) {
            mineralValues = ThingsBoardService.estimateMinerals(
              pH: soilPh!,
              soilMoisture: soilMoisture!,
            );
          }
        });
        print('ThingsBoard data: pH=$soilPh, Moisture=$soilMoisture');
      }
    } catch (e) {
      print('Error fetching ThingsBoard data: $e');
    }
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
      });

      // Generate daily nudge after weather data is loaded
      await _generateDailyNudge();
    } else {
      print('Failed to load weather data');
    }
  }

  Future<void> _generateDailyNudge({bool forceRefresh = false}) async {
    if (temperature == null ||
        windSpeed == null ||
        humidity == null ||
        uvIndex == null ||
        condition == null) {
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
        forceRefresh: forceRefresh,
      );

      setState(() {
        dailyNudge = nudge;
        isLoadingNudge = false;
      });
    } catch (e) {
      print('Error generating daily nudge: $e');
      setState(() {
        dailyNudge =
            'Monitor your crops regularly and adjust watering based on weather conditions.';
        isLoadingNudge = false;
      });
    }
  }

  String getCurrentDay() {
    return DateFormat('EEEE').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: temperature == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FarConnect Header with image
                  _FarConnectHeader(
                    temperature: temperature!,
                    day: getCurrentDay(),
                    location: location,
                  ),

                  const SizedBox(height: 24),

                  // Weather Data Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weather Conditions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _WeatherRow(
                          name: 'Temperature',
                          value: '${temperature!.toStringAsFixed(1)}°C',
                        ),
                        const SizedBox(height: 8),
                        _WeatherRow(
                          name: 'Wind Speed',
                          value: '${windSpeed!.toStringAsFixed(1)} km/h',
                        ),
                        const SizedBox(height: 8),
                        _WeatherRow(
                          name: 'Humidity',
                          value: '${humidity!.toStringAsFixed(0)}%',
                        ),
                        const SizedBox(height: 8),
                        _WeatherRow(
                          name: 'UV Index',
                          value: '${uvIndex!.toStringAsFixed(1)}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FarConnect Sensor Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FarConnect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SensorRow(
                          name: 'Temperature',
                          value: soilPh != null
                              ? '${temperature!.toStringAsFixed(1)}°C'
                              : 'Loading...',
                        ),
                        const SizedBox(height: 8),
                        _SensorRow(
                          name: 'Moisture',
                          value: soilMoisture != null
                              ? '${soilMoisture!.toStringAsFixed(1)}%'
                              : 'Loading...',
                        ),
                        const SizedBox(height: 8),
                        _SensorRow(
                          name: 'pH',
                          value: soilPh != null
                              ? soilPh!.toStringAsFixed(2)
                              : 'Loading...',
                        ),
                        const SizedBox(height: 8),
                        _SensorRow(
                          name: 'Humidity',
                          value: humidity != null
                              ? '${humidity!.toStringAsFixed(0)}%'
                              : 'Loading...',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Daily Nudge Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _DailyNudgeCard(
                      nudge: dailyNudge,
                      isLoading: isLoadingNudge,
                      onRefresh: () => _generateDailyNudge(forceRefresh: true),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Wanna Talk Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _WannaTalkCard(),
                  ),

                  const SizedBox(height: 16),

                  // Plant Disease Detection Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _PlantDiseaseCard(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
      // No bottom navigation bar
    );
  }
}

class _FarConnectHeader extends StatelessWidget {
  final double temperature;
  final String day;
  final String location;

  const _FarConnectHeader({
    required this.temperature,
    required this.day,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Green header with FarConnect title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF1B5E20)),
              child: const Center(
                child: Text(
                  'FarConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Brush Script MT',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

            // Farm image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1560493676-04071c5f467b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1074',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),

        // Temperature card overlay with frosted glass effect
        Positioned(
          top: 85,
          left: 16,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${temperature.toInt()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherRow extends StatelessWidget {
  final String name;
  final String value;

  const _WeatherRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SensorRow extends StatelessWidget {
  final String name;
  final String value;

  const _SensorRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DailyNudgeCard extends StatelessWidget {
  final String? nudge;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _DailyNudgeCard({
    required this.nudge,
    required this.isLoading,
    required this.onRefresh,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              IconButton(
                icon: Icon(Icons.refresh, color: AppTheme.accentGreen),
                onPressed: isLoading ? null : onRefresh,
                tooltip: 'Regenerate nudge',
              ),
            ],
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentGreen,
                    ),
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
              nudge ??
                  'Monitor your crops regularly and adjust watering based on weather conditions.',
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

class _PlantDiseaseCard extends StatelessWidget {
  const _PlantDiseaseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identify Plant Disease',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload or take a photo of your plant to detect diseases and get treatment recommendations.',
            style: TextStyle(
              color: AppTheme.accentGreen,
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
                    builder: (context) => const PlantDiseaseScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Scan Plant',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
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
