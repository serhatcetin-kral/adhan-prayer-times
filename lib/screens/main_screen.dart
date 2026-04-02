import 'package:flutter/material.dart';
import 'prayer_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PrayerScreen(),
    QiblaScreen(),
    SettingsScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _navIcon(String path) {
    return Image.asset(
      path,
      width: 54,
      height: 54,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: _navIcon('assets/prayer_icon.png'),
            label: "Prayer",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/qibla_icon.png'),
            label: "Qibla",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/settings_icon.png'),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/more_icon.png'),
            label: "More",
          ),
        ],
      ),
    );
  }
}