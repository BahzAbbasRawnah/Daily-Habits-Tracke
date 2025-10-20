# Daily Habits Tracker 🎯

<div align="center">
  <img src="assets/icons/app_icon.png" alt="Daily Habits Logo" width="120" height="120">
  <p><strong>Build and sustain small daily habits through simple tracking, motivating visuals, and actionable analytics</strong></p>
</div>

## 📱 Overview

Daily Habits is a comprehensive mobile application built with Flutter that helps users build and maintain positive daily habits. The app features a clean, intuitive interface with full bilingual support (Arabic & English), offline-first architecture, and powerful analytics to track your progress.

### ✨ Key Features

- **📊 Today's Checklist**: Quick access to today's scheduled habits with one-tap completion
- **🔥 Streak Tracking**: Visual streak counters with milestone celebrations
- **📈 Analytics Dashboard**: Weekly/monthly charts, completion rates, and insights
- **🗓️ Flexible Scheduling**: Daily, specific days (Mon-Fri), or custom schedules
- **⏰ Multi-Time Reminders**: Set multiple reminder times per habit
- **📝 Notes Timeline**: Add notes to track context and progress
- **📤 Export Data**: Export to CSV and PDF for backup and analysis
- **🌍 Bilingual Support**: Full Arabic and English localization with RTL support
- **🎨 Customization**: Categories, colors, icons, and themes
- **📴 Offline-First**: Full functionality without internet connection

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── config/              # App configuration (routes, theme, constants)
├── core/                # Core functionality (database, providers)
│   ├── database/        # SQLite database service
│   └── providers/       # Global state providers
├── features/            # Feature modules
│   ├── habits/          # Habit tracking feature
│   │   ├── models/      # Data models (Habit, HabitRecord)
│   │   ├── providers/   # State management (Provider)
│   │   ├── repositories/# Data access layer
│   │   ├── screens/     # UI screens
│   │   ├── services/    # Business logic (analytics, export, notifications)
│   │   └── widgets/     # Reusable widgets
│   ├── profile/         # User profile
│   ├── settings/        # App settings
│   └── notifications/   # Notification management
├── shared/              # Shared widgets and utilities
└── utils/               # Helper functions
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.6.1 or higher)
- Dart SDK (3.6.1 or higher)
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd daily_habits
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

### Build Release APK

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## 🧪 Testing

### Run Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/analytics_service_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

Core business logic has comprehensive unit tests:
- ✅ Streak calculation (daily, specific days, custom schedules)
- ✅ Completion rate calculations
- ✅ Analytics and insights generation
- ✅ Habit model serialization/deserialization
- ✅ Schedule validation

## 📦 Dependencies

### Core
- `flutter_localizations`: Internationalization
- `easy_localization`: Simplified i18n
- `provider`: State management
- `sqflite`: Local database
- `path_provider`: File system access

### UI/UX
- `fl_chart`: Charts and graphs
- `lottie`: Animations
- `shimmer`: Loading effects
- `smooth_page_indicator`: Page indicators

### Notifications
- `flutter_local_notifications`: Local notifications
- `timezone`: Timezone support
- `permission_handler`: Permission management

### Export
- `pdf`: PDF generation
- `intl`: Date formatting
- `share_plus`: Share functionality

## 🎯 Usage Guide

### Creating Your First Habit

1. Open the app and tap the **"+"** button
2. Enter habit details:
   - **Name**: "Drink Water"
   - **Category**: Hydration 💧
   - **Schedule**: Daily or specific days
   - **Target**: 8 times per day
   - **Reminders**: Add times (e.g., 8:00, 12:00, 16:00)
3. Tap **Save**

### Daily Routine

1. Open the app to see **Today's Checklist**
2. Tap the circle icon to mark habits complete
3. View your progress at the top
4. Celebrate when all habits are completed! 🎉

### Viewing Analytics

1. Tap on any habit to see detailed statistics:
   - Current streak 🔥
   - Longest streak 🏆
   - Weekly/monthly completion rates
   - Best time of day
2. View weekly bar chart
3. Read notes timeline

### Exporting Data

1. Go to **Settings** → **Data Export**
2. Choose format (CSV or PDF)
3. Select date range (optional)
4. Tap **Export**
5. Share or save the file

## 🌐 Localization

The app supports English and Arabic with full RTL (Right-to-Left) support.

### Switching Language

1. Go to **Settings**
2. Tap **Language**
3. Select **English** or **العربية**
4. App will restart with new language

### Adding New Translations

1. Edit translation files:
   - `assets/translations/en.json`
   - `assets/translations/ar.json`
2. Add new key-value pairs
3. Use in code: `'key'.tr()`

## 🔔 Notifications

### Setting Up Reminders

1. When creating/editing a habit, tap **Add Reminder**
2. Select time(s) for notifications
3. Enable sound and vibration (optional)
4. Save habit

### Permissions

The app will request notification permissions on first launch. You can manage permissions in:
- **Android**: Settings → Apps → Daily Habits → Notifications
- **iOS**: Settings → Daily Habits → Notifications

## 📊 Data Model

### Habit
```dart
Habit {
  int habitID
  int userID
  String name
  String? description
  HabitCategory category      // exercise, sleep, hydration, etc.
  HabitSchedule schedule      // daily, specificDays, custom
  TargetType targetType       // yesNo, count, duration
  int target
  String? icon
  String? color
  bool isActive
  List<String>? reminderTimes
  DateTime? createdAt
}
```

### HabitRecord
```dart
HabitRecord {
  int recordID
  int habitID
  int userID
  DateTime date
  String status               // done, missed, partial
  int progress
  String? note
  DateTime? createdAt
}
```

## 🔧 Configuration

### Theme Customization

Edit `lib/config/theme.dart` to customize colors, fonts, and styles.

### Database Schema

The app uses SQLite with automatic migrations. Schema version is managed in `lib/core/database/habit_database_service.dart`.

## 🐛 Troubleshooting

### Common Issues

**Issue**: Notifications not working
- **Solution**: Check app permissions in device settings
- Ensure timezone package is initialized

**Issue**: Database errors after update
- **Solution**: Uninstall and reinstall the app (or clear app data)
- Database migrations should handle updates automatically

**Issue**: RTL layout issues
- **Solution**: Ensure `Directionality` widget is properly set
- Check that Arabic translations use proper RTL formatting

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages that made this possible
- All contributors and testers

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
#   D a i l y - H a b i t s - T r a c k e  
 