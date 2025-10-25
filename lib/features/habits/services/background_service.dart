import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'reminder_manager_service.dart';

/// Background service for handling app restarts and device reboots
class BackgroundService {
  static const int _rescheduleAlarmId = 0;
  
  /// Initialize background service
  static Future<void> initialize() async {
    try {
      await AndroidAlarmManager.initialize();
      debugPrint('✅ Background service initialized');
      
      // Schedule periodic reschedule check (every 24 hours)
      await schedulePeriodicReschedule();
    } catch (e) {
      debugPrint('❌ Error initializing background service: $e');
    }
  }
  
  /// Schedule periodic reschedule of all reminders
  static Future<void> schedulePeriodicReschedule() async {
    try {
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        _rescheduleAlarmId,
        _rescheduleCallback,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      debugPrint('📅 Scheduled periodic reminder reschedule');
    } catch (e) {
      debugPrint('❌ Error scheduling periodic reschedule: $e');
    }
  }
  
  /// Callback function for rescheduling reminders
  @pragma('vm:entry-point')
  static Future<void> _rescheduleCallback() async {
    try {
      debugPrint('🔄 Background reschedule triggered');
      final reminderManager = ReminderManagerService();
      await reminderManager.initialize();
      await reminderManager.rescheduleAllReminders();
      debugPrint('✅ Background reschedule completed');
    } catch (e) {
      debugPrint('❌ Error in background reschedule: $e');
    }
  }
  
  /// Manually trigger reschedule (for testing or manual refresh)
  static Future<void> manualReschedule() async {
    await _rescheduleCallback();
  }
}
