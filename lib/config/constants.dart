/// Constants used throughout the Daily Habit Tracker application
class AppConstants {
  // App information
  static const String appName = 'Daily Habits';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Daily Habit Tracker Application';

  // Routes
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeDashboard = '/dashboard';
  static const String routeHabits = '/habits';
  static const String routeAddHabit = '/add-habit';
  static const String routeEditHabit = '/edit-habit';
  static const String routeHabitDetails = '/habit-details';
  static const String routeAnalytics = '/analytics';
  static const String routeAchievements = '/achievements';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';

  // Shared preferences keys
  static const String prefIsFirstLaunch = 'is_first_launch';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefUserId = 'user_id';
  static const String prefUserToken = 'user_token';
  static const String prefUserRole = 'user_role';
  static const String prefNotificationsEnabled = 'notifications_enabled';

  // Database
  static const String databaseName = 'daily_habits.db';
  static const int databaseVersion = 1;

  // Habit frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';

  // Habit statuses
  static const String statusDone = 'done';
  static const String statusMissed = 'missed';
  static const String statusPartial = 'partial';

  // Languages
  static const String languageEnglish = 'en';
  static const String languageArabic = 'ar';

  // Validation
  static const int habitNameMinLength = 2;
  static const int habitNameMaxLength = 50;
  static const int habitDescriptionMaxLength = 200;
  static const int minTarget = 1;
  static const int maxTarget = 100;

  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 800);

  // Notification settings
  static const String notificationChannelId = 'habit_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDescription = 'Notifications for habit reminders';

  // Notification types
  static const String notificationTypeHabit = 'habit';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypeAchievement = 'achievement';
}