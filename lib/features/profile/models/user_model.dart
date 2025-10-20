import 'package:flutter/material.dart';
import 'package:daily_habits/features/profile/models/tenant_model.dart';

/// User model representing a user in the application
class User {
  final Tenant tenant;
  final String id;
  final String name;
  final String phoneNumber; // Primary identifier
  final String? email; // Optional
  final String? profileImageUrl;
  final String role;
  final UserStatus status;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.tenant,
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.preferences,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Create a copy of this user with the given fields replaced with the new values
  User copyWith({
    Tenant? tenant,
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? role,
    UserStatus? status,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      tenant: tenant ?? this.tenant,
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Create a user from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      tenant: Tenant.fromJson(json['tenant'] as Map<String, dynamic>),
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Convert this user to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'tenant': tenant.toJson(),
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'profile_image_url': profileImageUrl,
      'role': role,
      'status': status.toString().split('.').last,
      'preferences': preferences.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

/// Enum representing different user statuses
enum UserStatus {
  active,
  inactive,
  suspended,
}

/// Extension to provide additional functionality to UserStatus enum
extension UserStatusExtension on UserStatus {
  String get translationKey {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.suspended:
        return 'suspended';
    }
  }

  Color get color {
    switch (this) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.grey;
      case UserStatus.suspended:
        return Colors.red;
    }
  }
}

/// User preferences model
class UserPreferences {
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool biometricAuthEnabled;

  const UserPreferences({
    required this.notificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.biometricAuthEnabled,
  });

  /// Create a copy of this preferences with the given fields replaced with the new values
  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? biometricAuthEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
    );
  }

  /// Create preferences from a JSON object
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] == 1 ||
          json['notifications_enabled'] == true,
      emailNotificationsEnabled: json['email_notifications_enabled'] == 1 ||
          json['email_notifications_enabled'] == true,
      pushNotificationsEnabled: json['push_notifications_enabled'] == 1 ||
          json['push_notifications_enabled'] == true,
      smsNotificationsEnabled: json['sms_notifications_enabled'] == 1 ||
          json['sms_notifications_enabled'] == true,
      biometricAuthEnabled: json['biometric_auth_enabled'] == 1 ||
          json['biometric_auth_enabled'] == true,
    );
  }

  /// Convert these preferences to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'push_notifications_enabled': pushNotificationsEnabled,
      'sms_notifications_enabled': smsNotificationsEnabled,
      'biometric_auth_enabled': biometricAuthEnabled,
    };
  }
}
