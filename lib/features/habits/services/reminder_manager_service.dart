import 'package:daily_habits/features/habits/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/habit_repository.dart';

/// Reminder Manager Service
/// Handles scheduling, rescheduling, and managing all habit reminders
class ReminderManagerService {
  static final ReminderManagerService _instance = ReminderManagerService._internal();
  factory ReminderManagerService() => _instance;
  ReminderManagerService._internal();

  final ReminderRepository _reminderRepo = ReminderRepository();
  final HabitRepository _habitRepo = HabitRepository();
  final NotificationService _notificationService = NotificationService();

  bool _initialized = false;

  /// Initialize the reminder manager
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize notification service with action handlers
    await _notificationService.initialize(
      onMarkDone: _handleMarkDoneAction,
      onSnooze: _handleSnoozeAction,
    );

    _initialized = true;
    debugPrint('✅ Reminder Manager initialized');
  }

  /// Handle Mark Done action from notification
  Future<void> _handleMarkDoneAction(int habitId, String habitName) async {
    debugPrint('✅ Handling Mark Done for habit: $habitName (ID: $habitId)');
    // The actual record insertion is handled in EnhancedNotificationService
    // This is just for additional logic if needed
  }

  /// Handle Snooze action from notification
  Future<void> _handleSnoozeAction(int habitId, int reminderId) async {
    try {
      final reminder = await _reminderRepo.getReminderById(reminderId);
      final habit = await _habitRepo.getHabitById(habitId);

      if (reminder != null && habit != null) {
        await _notificationService.snoozeReminder(
          reminder: reminder,
          habit: habit,
        );
        debugPrint('⏰ Snoozed reminder $reminderId for habit ${habit.name}');
      }
    } catch (e) {
      debugPrint('❌ Error handling snooze action: $e');
    }
  }

  /// Create reminders from habit's reminderTimes and schedule them
  Future<void> createAndScheduleRemindersFromHabit(int habitId) async {
    try {
      final habit = await _habitRepo.getHabitById(habitId);
      
      if (habit == null) {
        debugPrint('⚠️ Habit not found: $habitId');
        return;
      }

      // Check if habit has reminder times
      if (habit.reminderTimes == null || habit.reminderTimes!.isEmpty) {
        debugPrint('ℹ️ No reminder times set for habit: ${habit.name}');
        return;
      }

      // Delete existing reminders for this habit
      await _reminderRepo.deleteRemindersByHabit(habitId);

      // Create new reminders from habit's reminderTimes
      final createdReminders = <HabitReminder>[];
      for (final timeString in habit.reminderTimes!) {
        final reminder = HabitReminder(
          habitID: habitId,
          time: timeString,
          weekdays: habit.schedule.days, // Use habit's schedule days
          isActive: true,
          isRecurring: true,
          snoozeMinutes: 10,
          createdAt: DateTime.now(),
        );
        
        final reminderId = await _reminderRepo.createReminder(reminder);
        createdReminders.add(reminder.copyWith(reminderID: reminderId));
      }

      // Schedule notifications for created reminders
      if (createdReminders.isNotEmpty) {
        await _notificationService.scheduleHabitReminders(
          reminders: createdReminders,
          habit: habit,
        );
        debugPrint('✅ Created and scheduled ${createdReminders.length} reminders for ${habit.name}');
      }
    } catch (e) {
      debugPrint('❌ Error creating reminders from habit: $e');
    }
  }

  /// Schedule all active reminders for a habit
  Future<void> scheduleHabitReminders(int habitId) async {
    try {
      final reminders = await _reminderRepo.getRemindersByHabit(habitId);
      final habit = await _habitRepo.getHabitById(habitId);

      if (habit == null) {
        debugPrint('⚠️ Habit not found: $habitId');
        return;
      }

      // Cancel existing notifications first
      await _notificationService.cancelHabitReminders(habitId);

      // Schedule active reminders
      final activeReminders = reminders.where((r) => r.isActive).toList();
      
      if (activeReminders.isEmpty) {
        debugPrint('ℹ️ No active reminders for habit: ${habit.name}');
        return;
      }

      await _notificationService.scheduleHabitReminders(
        reminders: activeReminders,
        habit: habit,
      );

      debugPrint('📅 Scheduled ${activeReminders.length} reminders for ${habit.name}');
    } catch (e) {
      debugPrint('❌ Error scheduling habit reminders: $e');
    }
  }

  /// Schedule a single reminder
  Future<void> scheduleReminder(int reminderId) async {
    try {
      final reminder = await _reminderRepo.getReminderById(reminderId);
      if (reminder == null) {
        debugPrint('⚠️ Reminder not found: $reminderId');
        return;
      }

      final habit = await _habitRepo.getHabitById(reminder.habitID);
      if (habit == null) {
        debugPrint('⚠️ Habit not found: ${reminder.habitID}');
        return;
      }

      if (reminder.isActive) {
        await _notificationService.scheduleReminder(
          reminder: reminder,
          habit: habit,
        );
        debugPrint('📅 Scheduled reminder $reminderId for ${habit.name}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(int habitId, int reminderId) async {
    try {
      await _notificationService.cancelReminder(habitId, reminderId);
      debugPrint('🚫 Cancelled reminder $reminderId');
    } catch (e) {
      debugPrint('❌ Error cancelling reminder: $e');
    }
  }

  /// Cancel all reminders for a habit
  Future<void> cancelHabitReminders(int habitId) async {
    try {
      await _notificationService.cancelHabitReminders(habitId);
      debugPrint('🚫 Cancelled all reminders for habit $habitId');
    } catch (e) {
      debugPrint('❌ Error cancelling habit reminders: $e');
    }
  }

  /// Reschedule all active reminders (e.g., after device reboot)
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 Rescheduling all active reminders...');
      
      final allReminders = await _reminderRepo.getAllActiveReminders();
      
      // Group reminders by habit
      final Map<int, List<HabitReminder>> remindersByHabit = {};
      for (final reminder in allReminders) {
        if (!remindersByHabit.containsKey(reminder.habitID)) {
          remindersByHabit[reminder.habitID] = [];
        }
        remindersByHabit[reminder.habitID]!.add(reminder);
      }

      // Schedule reminders for each habit
      int totalScheduled = 0;
      for (final habitId in remindersByHabit.keys) {
        final habit = await _habitRepo.getHabitById(habitId);
        if (habit != null && habit.isActive) {
          await _notificationService.scheduleHabitReminders(
            reminders: remindersByHabit[habitId]!,
            habit: habit,
          );
          totalScheduled += remindersByHabit[habitId]!.length;
        }
      }

      debugPrint('✅ Rescheduled $totalScheduled reminders for ${remindersByHabit.length} habits');
    } catch (e) {
      debugPrint('❌ Error rescheduling all reminders: $e');
    }
  }

  /// Create a new reminder
  Future<int?> createReminder(HabitReminder reminder) async {
    try {
      final reminderId = await _reminderRepo.createReminder(reminder);
      
      // Schedule the notification
      if (reminder.isActive) {
        final newReminder = reminder.copyWith(reminderID: reminderId);
        final habit = await _habitRepo.getHabitById(reminder.habitID);
        
        if (habit != null) {
          await _notificationService.scheduleReminder(
            reminder: newReminder,
            habit: habit,
          );
        }
      }

      debugPrint('✅ Created and scheduled reminder $reminderId');
      return reminderId;
    } catch (e) {
      debugPrint('❌ Error creating reminder: $e');
      return null;
    }
  }

  /// Update an existing reminder
  Future<bool> updateReminder(HabitReminder reminder) async {
    try {
      await _reminderRepo.updateReminder(reminder);
      
      // Reschedule the notification
      final habit = await _habitRepo.getHabitById(reminder.habitID);
      if (habit != null) {
        // Cancel old notification
        await _notificationService.cancelReminder(
          reminder.habitID,
          reminder.reminderID!,
        );
        
        // Schedule new one if active
        if (reminder.isActive) {
          await _notificationService.scheduleReminder(
            reminder: reminder,
            habit: habit,
          );
        }
      }

      debugPrint('✅ Updated reminder ${reminder.reminderID}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
      return false;
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(int habitId, int reminderId) async {
    try {
      // Cancel notification first
      await _notificationService.cancelReminder(habitId, reminderId);
      
      // Delete from database
      await _reminderRepo.deleteReminder(reminderId);
      
      debugPrint('✅ Deleted reminder $reminderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      return false;
    }
  }

  /// Toggle reminder active status
  Future<bool> toggleReminderStatus(int reminderId, bool isActive) async {
    try {
      await _reminderRepo.toggleReminderStatus(reminderId, isActive);
      
      final reminder = await _reminderRepo.getReminderById(reminderId);
      if (reminder != null) {
        if (isActive) {
          // Schedule notification
          await scheduleReminder(reminderId);
        } else {
          // Cancel notification
          await _notificationService.cancelReminder(
            reminder.habitID,
            reminderId,
          );
        }
      }

      debugPrint('✅ Toggled reminder $reminderId to ${isActive ? "active" : "inactive"}');
      return true;
    } catch (e) {
      debugPrint('❌ Error toggling reminder status: $e');
      return false;
    }
  }

  /// Get all reminders for a habit
  Future<List<HabitReminder>> getHabitReminders(int habitId) async {
    return await _reminderRepo.getRemindersByHabit(habitId);
  }

  /// Get today's reminders
  Future<List<HabitReminder>> getTodayReminders() async {
    return await _reminderRepo.getTodayReminders();
  }

  /// Show test notification
  Future<void> showTestNotification(String habitName, int habitId) async {
    await _notificationService.showTestNotification(
      habitName: habitName,
      habitId: habitId,
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Check if permissions are granted
  Future<bool> arePermissionsGranted() async {
    return await _notificationService.arePermissionsGranted();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }
}
