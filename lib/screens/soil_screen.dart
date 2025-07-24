import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SoilScreen extends StatelessWidget {
  const SoilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzhavan App'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nutrient cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _NutrientCard(title: 'Potassium', value: '0.8mg'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _NutrientCard(title: 'Sodium', value: '1.8mg'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _NutrientCard(title: 'Salts a', value: '2.8mg'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Wind speed list
            _WindSpeedCard(),
            const SizedBox(height: 24),
            // Daily Nudge
            _DailyNudgeCard(),
            const SizedBox(height: 16),
            // Wanna Talk
            _WannaTalkCard(),
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

class _WindSpeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 198, 255, 176),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
      ),
      child: Column(children: List.generate(6, (index) => _WindSpeedRow())),
    );
  }
}

class _WindSpeedRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 6),
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
            '0.4km/hr',
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
        // Add a pattern background if desired
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
