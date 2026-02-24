import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'emergency_screen.dart';
import 'timeline_screen.dart';
import 'device_dashboard_screen.dart';
import 'contacts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmergencyScreen(),
    const TimelineScreen(),
    const DeviceDashboardScreen(),
    const ContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.emergencyRed,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Устройство',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Контакты',
          ),
        ],
      ),
    );
  }
}

