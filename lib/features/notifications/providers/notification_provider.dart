import 'package:flutter/material.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/features/habits/repositories/reminder_repository.dart';

/// Provider to manage notifications
class NotificationProvider extends ChangeNotifier {
  final ReminderRepository _reminderRepository = ReminderRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  /// Get all notifications
  List<NotificationModel> get notifications => _notifications;
  
  /// Get unread notifications
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((notification) => !notification.isRead).toList();
  
  /// Get the number of unread notifications
  int get unreadCount => unreadNotifications.length;
  
  /// Check if notifications are loading
  bool get isLoading => _isLoading;
  
  /// Get the error message
  String? get error => _error;
  
  /// Fetch notifications from Reminders table
  Future<void> fetchNotifications() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    
    _isLoading = true;
    _error = null;
    
    // Use Future.microtask to defer notifyListeners until after build
    Future.microtask(() => notifyListeners());
    
    try {
      // Fetch reminders from database
      final reminders = await _reminderRepository.getAllRemindersWithHabits();
      
      // Convert reminders to notifications
      _notifications = reminders.map((reminder) {
        final time = reminder['Time'] as String;
        final habitName = reminder['HabitName'] as String;
        final isActive = reminder['IsActive'] != null ? (reminder['IsActive'] as int) == 1 : true;
        final createdAt = reminder['CreatedAt'] != null 
            ? DateTime.parse(reminder['CreatedAt'] as String)
            : DateTime.now();
        
        return NotificationModel(
          id: reminder['ReminderID'].toString(),
          title: isActive ? 'Habit Reminder' : 'Reminder Disabled',
          message: isActive 
              ? 'Time to complete your "$habitName" habit at $time'
              : 'Reminder for "$habitName" at $time is currently disabled',
          type: NotificationType.habit,
          createdAt: createdAt,
          isRead: !isActive, // Disabled reminders are marked as "read"
          data: {
            'habitId': reminder['HabitID'].toString(),
            'habitName': habitName,
            'reminderTime': time,
            'enabled': isActive,
            'habitIcon': reminder['HabitIcon'],
            'habitColor': reminder['HabitColor'],
          },
        );
      }).toList();
      
      // Sort by creation date (newest first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('Error fetching notifications: $e');
      Future.microtask(() => notifyListeners());
    }
  }
  
  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index == -1) return;
    
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    
    try {
      // Update reminder status in database
      final reminderId = int.tryParse(notificationId);
      if (reminderId != null) {
        await _reminderRepository.toggleReminderStatus(reminderId, false);
      }
    } catch (e) {
      // If the update fails, revert the change
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.where((notification) => !notification.isRead).toList();
    if (unreadNotifications.isEmpty) return;
    
    // Update local state
    _notifications = _notifications.map((notification) => 
        notification.copyWith(isRead: true)).toList();
    notifyListeners();
    
    try {
      // Update all reminders to be marked as inactive (read)
      for (var notification in unreadNotifications) {
        final reminderId = int.tryParse(notification.id);
        if (reminderId != null) {
          await _reminderRepository.toggleReminderStatus(reminderId, false);
        }
      }
    } catch (e) {
      // If the update fails, revert the change
      _notifications = _notifications.map((notification) {
        final wasUnread = unreadNotifications.any((n) => n.id == notification.id);
        return wasUnread ? notification.copyWith(isRead: false) : notification;
      }).toList();
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index == -1) return;
    
    final deletedNotification = _notifications[index];
    _notifications.removeAt(index);
    notifyListeners();
    
    try {
      // Delete reminder from database
      final reminderId = int.tryParse(notificationId);
      if (reminderId != null) {
        await _reminderRepository.deleteReminder(reminderId);
      }
    } catch (e) {
      // If the delete fails, revert the change
      _notifications.insert(index, deletedNotification);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_notifications.isEmpty) return;
    
    final oldNotifications = List<NotificationModel>.from(_notifications);
    _notifications = [];
    notifyListeners();
    
    try {
      // Delete all reminders from database
      for (var notification in oldNotifications) {
        final reminderId = int.tryParse(notification.id);
        if (reminderId != null) {
          await _reminderRepository.deleteReminder(reminderId);
        }
      }
    } catch (e) {
      // If the delete fails, revert the change
      _notifications = oldNotifications;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }
  
  /// Get notifications by date range
  List<NotificationModel> getNotificationsByDateRange(DateTime startDate, DateTime endDate) {
    return _notifications.where((notification) => 
        notification.createdAt.isAfter(startDate) && 
        notification.createdAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
  }
}
