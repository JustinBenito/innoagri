import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/theme.dart';

class SoilScreen extends StatefulWidget {
  const SoilScreen({super.key});

  @override
  State<SoilScreen> createState() => _SoilScreenState();
}

class _SoilScreenState extends State<SoilScreen> {
  double? temperature;
  double? windSpeed;
  List<double> hourlyWindSpeeds = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=13.067439&longitude=80.237617&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['current']['temperature_2m']?.toDouble();
        windSpeed = data['current']['wind_speed_10m']?.toDouble();
        hourlyWindSpeeds = List<double>.from(
          data['hourly']['wind_speed_10m'].take(6).map((w) => w.toDouble()),
        );
      });
    } else {
      print('Failed to load weather data');
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
                    windSpeeds: hourlyWindSpeeds,
                  ),
                  const SizedBox(height: 24),
                  const _DailyNudgeCard(),
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
  final List<double> windSpeeds;

  const _WeatherCard({
    required this.temperature,
    required this.windSpeed,
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
            'Current Temperature: ${temperature.toStringAsFixed(1)} °C',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Wind Speed: ${windSpeed.toStringAsFixed(1)} km/h',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Next 6 hours Wind Speed:',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontFamily: 'Comic Sans MS',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(
              windSpeeds.length,
              (index) => _WindSpeedRow(value: windSpeeds[index]),
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
  const _DailyNudgeCard();

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
          Text(
            'You have a very mineral rich soil and are expecting rains.\nTry to water your plants a bit less than usual',
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
        ],
      ),
    );
  }
}
