import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../screens/chatbot_screen.dart';
import '../screens/forum_screen.dart';
import '../screens/soil_screen.dart';
import '../providers/language_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SoilScreen(),
    const ChatbotScreen(),
    const FarmingForumScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final isTamil = locale.languageCode == 'ta';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Language button at top right
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF1B5E20),
                child: InkWell(
                  onTap: () {
                    ref.read(languageProvider.notifier).toggleLanguage();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'EN' : 'தமிழ்',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grass),
            activeIcon: const Icon(Icons.grass),
            label: l10n.soilTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: l10n.chatbotTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum_outlined),
            activeIcon: const Icon(Icons.forum),
            label: l10n.forumTitle,
          ),
        ],
      ),
    );
  }
}
