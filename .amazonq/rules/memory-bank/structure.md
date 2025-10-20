# Daily Habits - Project Structure

## Directory Organization

### Core Application (`lib/`)
- **`config/`**: Application configuration (constants, routes, theme, localization)
- **`core/`**: Core services (database, providers)
- **`features/`**: Feature-based modules using clean architecture
- **`shared/`**: Reusable UI components and widgets
- **`utils/`**: Utility functions and helpers
- **`main.dart`**: Application entry point with provider setup

### Feature Modules (`lib/features/`)
- **`auth/`**: Authentication system (login, register, password recovery)
- **`habits/`**: Core habit management (CRUD, tracking, notifications)
- **`dashboard/`**: Analytics and overview screens
- **`profile/`**: User and tenant management
- **`notifications/`**: Notification handling and display
- **`onboarding/`**: First-time user experience
- **`settings/`**: App configuration and preferences

### Platform-Specific Code
- **`android/`**: Android native configuration and resources
- **`ios/`**: iOS native configuration and resources
- **`windows/`**: Windows desktop implementation
- **`macos/`**: macOS desktop implementation
- **`linux/`**: Linux desktop implementation
- **`web/`**: Web platform assets and configuration

### Assets (`assets/`)
- **`fonts/`**: Custom fonts (Roboto, SFPro)
- **`images/`**: Static images and product assets
- **`icons/`**: App icons and UI icons
- **`translations/`**: Localization files (en.json, ar.json)
- **`animations/`**: Lottie animation files
- **`data/`**: Static data files

## Architectural Patterns

### Feature-Based Architecture
Each feature follows a consistent structure:
- **`models/`**: Data models and entities
- **`providers/`**: State management with Provider pattern
- **`repositories/`**: Data access layer
- **`screens/`**: UI screens and pages
- **`services/`**: Business logic and external integrations
- **`widgets/`**: Feature-specific reusable components

### State Management
- **Provider Pattern**: Used throughout for state management
- **Repository Pattern**: Separates data access from business logic
- **Service Layer**: Handles external dependencies and complex operations

### Database Architecture
- **SQLite**: Local database using sqflite package
- **Repository Pattern**: Abstracts database operations
- **Model-based**: Structured data models for type safety