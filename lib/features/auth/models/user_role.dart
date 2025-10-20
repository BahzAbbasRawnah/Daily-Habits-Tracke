import 'package:daily_habits/config/constants.dart';

/// Enum representing different user roles in the system
enum UserRole {
tenant,
  user;

  /// Get the string representation of the role
  String get value {
    switch (this) {
      case UserRole.tenant:
        return "tenant";
      case UserRole.user:
        return "user";
    }
  }

  /// Get the display name of the role
  String get displayName {
    switch (this) {
      case UserRole.tenant:
        return 'Administrator';
      case UserRole.user:
        return 'User';
     
    }
  }

  /// Create UserRole from string
  static UserRole fromString(String role) {
    switch (role) {
      case "tenant":
        return UserRole.tenant;
      case "user":
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }


}
