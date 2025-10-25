import 'package:flutter/material.dart';
import 'package:daily_habits/features/habits/screens/habits_list_screen.dart';
import 'package:daily_habits/features/dashboard/screens/dashboard_screen.dart';
import 'package:daily_habits/features/notifications/screens/notifications_screen.dart';
import 'package:daily_habits/features/profile/screens/profile_screen.dart';
import 'package:daily_habits/features/chat/screens/chat_screen.dart';
import 'package:daily_habits/shared/widgets/custom_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HabitsListScreen(),
    const ChatScreen(), // Chatbot in center
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}