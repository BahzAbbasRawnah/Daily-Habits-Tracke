import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/core/providers/theme_provider.dart';
import 'package:daily_habits/core/providers/app_state_provider.dart';
import 'package:daily_habits/features/profile/providers/user_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_record_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_note_provider.dart';
import 'package:daily_habits/features/notifications/providers/notification_provider.dart';
import 'package:daily_habits/features/analytics/providers/analytics_provider.dart';
import 'package:daily_habits/features/achievements/providers/achievement_provider.dart';
import 'package:daily_habits/features/chat/providers/chat_provider.dart';
import 'package:daily_habits/shared/widgets/app_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:daily_habits/features/habits/services/reminder_manager_service.dart';
import 'package:daily_habits/features/habits/services/background_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize reminder manager service
  try {
    final reminderManager = ReminderManagerService();
    await reminderManager.initialize();
    
    // Request notification permissions
    final permissionGranted = await reminderManager.requestPermissions();
    if (permissionGranted) {
      debugPrint('✅ Notification permissions granted');
      // Reschedule all active reminders on app start
      await reminderManager.rescheduleAllReminders();
      
      // Initialize background service for Android only
      if (Platform.isAndroid) {
        await BackgroundService.initialize();
      }
    } else {
      debugPrint('⚠️ Notification permissions denied');
    }
  } catch (e) {
    debugPrint('❌ Error initializing reminder manager: $e');
  }
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'), // Default to Arabic
      useOnlyLangCode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => HabitProvider()),
          ChangeNotifierProvider(create: (_) => HabitRecordProvider()),
          ChangeNotifierProvider(create: (_) => HabitNoteProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
          ChangeNotifierProvider(create: (_) => AchievementProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  // Initialize providers
  Future<void> _initializeProviders() async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    await Future.wait([
      appStateProvider.initialize(),
      themeProvider.initialize(),
    ]);

    if (mounted) {
      debugPrint('Providers initialized successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AppWrapper(),
    );
  }
}
