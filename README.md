# Daily Habits Tracker 🎯

<div align="center">
  <img src="assets/icons/app_icon.png" alt="Daily Habits Logo" width="120" height="120">
  <p><strong>Build better habits, track your progress, and achieve your goals</strong></p>
</div>

---

## 📖 Project Description

**Daily Habits** is a comprehensive mobile application built with Flutter that empowers users to build, track, and maintain positive daily habits. The app combines an intuitive user interface with powerful features to help users stay consistent and achieve their personal goals.

Whether you want to exercise more, drink more water, read daily, or develop any positive habit, Daily Habits provides the tools and motivation you need to succeed. With features like streak tracking, detailed analytics, smart reminders, and progress visualization, the app makes habit building engaging and rewarding.

The application supports both **Arabic** and **English** languages with full RTL (Right-to-Left) support, making it accessible to a wider audience. It works completely offline, ensuring your data is private and always available.

**Key Highlights:**
- 🎯 Intuitive habit creation and management
- 📊 Comprehensive analytics and insights
- 🔔 Smart reminders and notifications
- 🌍 Bilingual support (Arabic & English)
- 🔐 Secure authentication with Google Sign-In
- 📴 Offline-first architecture
- 📤 Data export (CSV & PDF)

---

## ✨ Features

### 🎯 Core Features
- **Habit Management**: Create, edit, and delete habits with customizable names, descriptions, categories, and icons
- **Today's Dashboard**: Quick overview of today's scheduled habits with one-tap completion
- **Flexible Scheduling**: Support for daily, weekly (specific days), and custom schedules
- **Progress Tracking**: Track completion status (done, missed, partial) with progress indicators
- **Target Types**: Support for Yes/No, count-based, and duration-based habits

### 📊 Analytics & Insights
- **Streak Tracking**: Visual streak counters showing current and longest streaks
- **Completion Rates**: Weekly and monthly completion rate calculations
- **Progress Charts**: Interactive charts displaying weekly and monthly progress
- **Category Breakdown**: Analyze habits by category with visual representations
- **Performance Insights**: Identify most consistent habits and those needing attention

### 🔔 Reminders & Notifications
- **Multi-Time Reminders**: Set multiple reminder times for each habit
- **Smart Notifications**: Local notifications with customizable sound and vibration
- **Notification Management**: View, filter, and manage all notifications in one place

### 🔐 Authentication
- **Email/Password Login**: Traditional authentication with secure password handling
- **Google Sign-In**: Quick and secure authentication using Google accounts
- **Biometric Support**: Fingerprint and face recognition for quick access

### 📤 Data Export & Sharing
- **CSV Export**: Export habit data to CSV format for analysis
- **PDF Reports**: Generate comprehensive PDF reports with charts and statistics
- **Share Functionality**: Share exported files via email, messaging, or cloud storage

### 🌍 Localization
- **Bilingual Support**: Full support for English and Arabic languages
- **RTL Support**: Complete Right-to-Left layout for Arabic
- **Dynamic Language Switching**: Change language without restarting the app

### 🎨 Customization
- **Theme Support**: Light and dark mode with system default option
- **Custom Colors**: Choose from multiple color schemes for habits
- **Icon Library**: Wide selection of icons for different habit types
- **Categories**: Pre-defined categories (Exercise, Sleep, Hydration, Nutrition, etc.)

---

## 🛠️ Technologies & Packages

### Framework
- **Flutter SDK**: 3.6.1+
- **Dart SDK**: 3.6.1+

### Key Dependencies
- `provider: ^6.1.1` - State management
- `sqflite: ^2.3.3+1` - Local SQLite database
- `easy_localization: ^3.0.3` - Internationalization
- `google_sign_in: ^6.2.1` - Google authentication
- `local_auth: ^2.1.8` - Biometric authentication
- `flutter_local_notifications: ^17.2.2` - Local notifications
- `fl_chart: ^0.66.0` - Charts and graphs
- `pdf: ^3.10.7` - PDF generation
- `lottie: ^3.3.1` - Animations
- `share_plus: ^11.0.0` - Share functionality

For complete list, see `pubspec.yaml`

---

## 🏗️ Project Structure

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

---

## 🚀 Installation & Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.6.1 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Version 3.6.1 or higher (included with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **For Android**:
  - Android Studio
  - Android SDK (API level 21 or higher)
  - Java Development Kit (JDK) 11+
- **For iOS** (macOS only):
  - Xcode 14 or higher
  - CocoaPods

### Installation Steps

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd daily_habits
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Verify Flutter Installation
```bash
flutter doctor
```
Ensure all checks pass. Fix any issues reported.

#### 4. Check Connected Devices
```bash
flutter devices
```

### Running the App

#### Development Mode
```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with verbose logging
flutter run -v
```

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

### Building Release Versions

#### Android APK
```bash
# Standard APK
flutter build apk --release

# Split APKs per ABI (smaller size)
flutter build apk --split-per-abi --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

#### iOS (macOS only)
```bash
flutter build ios --release
# or
flutter build ipa --release
```
Output: `build/ios/ipa/`

### Google Sign-In Configuration

#### Android Setup
1. Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android app to Firebase
3. Download `google-services.json` and place in `android/app/`
4. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Add SHA-1 to Firebase Console

#### iOS Setup (macOS only)
1. Add iOS app to Firebase project
2. Download `GoogleService-Info.plist` and add to `ios/Runner/` in Xcode
3. Add URL scheme to `ios/Runner/Info.plist`

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/analytics_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage
Core business logic has comprehensive unit tests:
- ✅ Streak calculation (daily, specific days, custom schedules)
- ✅ Completion rate calculations
- ✅ Analytics and insights generation
- ✅ Habit model serialization/deserialization
- ✅ Schedule validation

---

## 🎯 Usage Guide

### Quick Start
1. **Create an account** - Sign up with email/password or Google
2. **Create your first habit** - Tap the "+" button
3. **Set up reminders** - Add notification times
4. **Track daily** - Mark habits complete each day
5. **View analytics** - Monitor your progress and streaks

### Creating a Habit
1. Tap the **"+"** floating action button
2. Fill in habit details (name, category, schedule, target)
3. Add reminders (optional)
4. Tap **Save**

### Daily Usage
1. Open app to see today's habits
2. Tap circle to mark complete
3. View progress and streaks
4. Add notes for context

### Exporting Data
1. Go to **Settings** → **Data Export**
2. Choose CSV or PDF format
3. Select date range (optional)
4. Share or save the file

---

## 🐛 Troubleshooting

### Common Issues

**`flutter pub get` fails**
```bash
flutter clean
flutter pub get
```

**Android build fails**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

**iOS build fails** (macOS only)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

**Google Sign-In not working**
- Verify Firebase configuration files are in place
- Check SHA-1 fingerprints are added to Firebase Console

**Notifications not appearing**
- Check app permissions in device settings
- Ensure notification permissions are granted

**Database errors after update**
- Clear app data or reinstall the app
- Database migrations should handle updates automatically

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