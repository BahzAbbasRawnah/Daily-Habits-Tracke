import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/core/providers/app_state_provider.dart';
import 'package:daily_habits/features/onboarding/screens/onboarding_screen.dart';
import 'package:daily_habits/features/auth/screens/login_screen.dart';
import 'package:daily_habits/shared/widgets/main_navigation.dart';
import 'package:daily_habits/shared/widgets/splash_screen.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const SplashScreen();
        }

        if (appState.isFirstLaunch) {
          return const OnboardingScreen();
        }

        if (!appState.isLoggedIn) {
          return const LoginScreen();
        }

        return const MainNavigation();
      },
    );
  }
}