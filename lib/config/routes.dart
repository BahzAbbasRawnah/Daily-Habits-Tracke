import 'package:flutter/material.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/features/onboarding/screens/onboarding_screen.dart';
import 'package:daily_habits/features/habits/screens/habits_list_screen.dart';
import 'package:daily_habits/features/habits/screens/add_edit_habit_screen.dart';
import 'package:daily_habits/features/settings/screens/settings_screen.dart';
import 'package:daily_habits/features/profile/screens/profile_screen.dart';
import 'package:daily_habits/features/notifications/screens/notifications_screen.dart';
import 'package:daily_habits/features/notifications/screens/notification_detail_screen.dart';
import 'package:daily_habits/features/auth/screens/login_screen.dart';
import 'package:daily_habits/features/auth/screens/register_screen.dart';
import 'package:daily_habits/features/auth/screens/forgot_password_screen.dart';
import 'package:daily_habits/features/auth/screens/phone_verification_screen.dart';
import 'package:daily_habits/features/auth/screens/reset_password_screen.dart';
import 'package:daily_habits/shared/widgets/main_navigation.dart';
import 'package:daily_habits/features/analytics/screens/analytics_screen.dart';
import 'package:daily_habits/features/achievements/screens/achievements_screen.dart';
import 'package:daily_habits/features/profile/screens/about_screen.dart';
import 'package:daily_habits/features/chat/screens/chat_screen.dart';

/// Route configuration for the Daily Habit Tracker application
class AppRoutes {
  // Define route names as constants
  static const String initial = '/';
  static const String onboarding = AppConstants.routeOnboarding;
  static const String dashboard = AppConstants.routeDashboard;
  static const String habits = AppConstants.routeHabits;
  static const String addHabit = AppConstants.routeAddHabit;
  static const String editHabit = AppConstants.routeEditHabit;
  static const String habitDetails = AppConstants.routeHabitDetails;
  static const String analytics = AppConstants.routeAnalytics;
  static const String achievements = AppConstants.routeAchievements;
  static const String settings = AppConstants.routeSettings;
  static const String profile = AppConstants.routeProfile;
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notification-detail';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String phoneVerification = '/phone-verification';
  static const String resetPassword = '/reset-password';
  static const String mainNavigation = '/main';
  static const String about = '/about';
  static const String chat = '/chat';

  // Define route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    // Extract route arguments if any
    final args = routeSettings.arguments;

    switch (routeSettings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );

      case mainNavigation:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );

      case habits:
        return MaterialPageRoute(
          builder: (_) => const HabitsListScreen(),
        );

      case addHabit:
        return MaterialPageRoute(
          builder: (_) => const AddEditHabitScreen(),
        );

      case editHabit:
        return MaterialPageRoute(
          builder: (_) => const AddEditHabitScreen(),
        );

      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case notificationDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(notificationId: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Invalid notification ID'),
            ),
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case phoneVerification:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => PhoneVerificationScreen(phoneNumber: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Invalid phone number'),
            ),
          ),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        );

      case analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsScreen(),
        );

      case achievements:
        return MaterialPageRoute(
          builder: (_) => const AchievementsScreen(),
        );

      case habitDetails:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Habit Details Screen - Coming Soon'),
            ),
          ),
        );

      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        );

      // If the route is not defined, show an error page
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${routeSettings.name} not found'),
            ),
          ),
        );
    }
  }
}