import 'package:flutter/material.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/config/theme.dart';

/// Enum representing different notification types
enum NotificationType {
  habit,
  system,
  achievement,
}

/// Extension to provide additional functionality to NotificationType enum
extension NotificationTypeExtension on NotificationType {
  /// Get the translation key for the notification type
  String get translationKey {
    switch (this) {
      case NotificationType.habit:
        return 'notificationTypeHabit';
      case NotificationType.system:
        return 'notificationTypeSystem';
      case NotificationType.achievement:
        return 'notificationTypeAchievement';
    }
  }
  
  /// Get the icon for the notification type
  IconData get icon {
    switch (this) {
      case NotificationType.habit:
        return Icons.check_circle_outline;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.achievement:
        return Icons.emoji_events;
    }
  }
  
  /// Get the color for the notification type
  Color get color {
    switch (this) {
      case NotificationType.habit:
        return AppTheme.primaryColor;
      case NotificationType.system:
        return AppTheme.accentColor;
      case NotificationType.achievement:
        return AppTheme.warningColor;
    }
  }
  
  /// Get the string value of the notification type
  String get value {
    switch (this) {
      case NotificationType.habit:
        return AppConstants.notificationTypeHabit;
      case NotificationType.system:
        return AppConstants.notificationTypeSystem;
      case NotificationType.achievement:
        return AppConstants.notificationTypeAchievement;
    }
  }
  
  /// Get the notification type from a string value
  static NotificationType fromString(String value) {
    switch (value) {
      case AppConstants.notificationTypeHabit:
        return NotificationType.habit;
      case AppConstants.notificationTypeSystem:
        return NotificationType.system;
      case AppConstants.notificationTypeAchievement:
        return NotificationType.achievement;
      default:
        return NotificationType.system;
    }
  }
}

/// Model representing a notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });
  
  /// Create a copy of this notification with the given fields replaced with the new values
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
  
  /// Create a notification from a JSON object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationTypeExtension.fromString(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : null,
    );
  }
  
  /// Convert this notification to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'data': data,
    };
  }
  
  /// Get the relative time string for the notification
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
  
  /// Get the formatted date string for the notification
  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    
    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(createdAt).inDays < 7) {
      // Return day of week
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[createdAt.weekday - 1];
    } else {
      // Return formatted date
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
    }
  }
}
