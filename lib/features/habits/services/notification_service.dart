import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';

/// Enhanced notification service with multi-time reminder support
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('Notification service initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to habit detail screen
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Schedule notifications for a habit
  Future<void> scheduleHabitNotifications(Habit habit) async {
    if (!_initialized) await initialize();

    // Cancel existing notifications for this habit
    await cancelHabitNotifications(habit.habitID!);

    if (habit.reminderTimes == null || habit.reminderTimes!.isEmpty) {
      return;
    }

    // Schedule notification for each reminder time
    for (int i = 0; i < habit.reminderTimes!.length; i++) {
      final timeString = habit.reminderTimes![i];
      final notificationId = _generateNotificationId(habit.habitID!, i);

      try {
        await _scheduleNotification(
          notificationId: notificationId,
          habit: habit,
          timeString: timeString,
        );
        debugPrint('Scheduled notification $notificationId for ${habit.name} at $timeString');
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int notificationId,
    required Habit habit,
    required String timeString,
  }) async {
    final timeParts = timeString.split(':');
    if (timeParts.length != 2) return;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Notification details
    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Reminders for daily habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule based on habit schedule type
    if (habit.schedule.type == ScheduleType.daily) {
      // Daily notification
      await _notifications.zonedSchedule(
        notificationId,
        habit.name,
        _getNotificationBody(habit),
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (habit.schedule.type == ScheduleType.specificDays) {
      // Schedule for specific days
      final days = habit.schedule.days ?? [];
      for (final day in days) {
        final daysUntilNext = _daysUntilWeekday(now.weekday, day);
        final nextDate = scheduledDate.add(Duration(days: daysUntilNext));

        await _notifications.zonedSchedule(
          notificationId + (day * 1000), // Unique ID per day
          habit.name,
          _getNotificationBody(habit),
          nextDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Get notification body text
  String _getNotificationBody(Habit habit) {
    switch (habit.targetType) {
      case TargetType.yesNo:
        return 'Time to complete your habit!';
      case TargetType.count:
        return 'Complete ${habit.target}x today';
      case TargetType.duration:
        return 'Spend ${habit.target} minutes on this habit';
    }
  }

  /// Calculate days until next weekday
  int _daysUntilWeekday(int currentWeekday, int targetWeekday) {
    int daysUntil = targetWeekday - currentWeekday;
    if (daysUntil <= 0) {
      daysUntil += 7;
    }
    return daysUntil;
  }

  /// Generate unique notification ID
  int _generateNotificationId(int habitId, int reminderIndex) {
    return habitId * 100 + reminderIndex;
  }

  /// Legacy method for backward compatibility
  Future<void> scheduleHabitReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel all notifications for a habit
  Future<void> cancelHabitNotifications(int habitId) async {
    if (!_initialized) await initialize();

    // Cancel up to 10 possible reminder times
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(habitId, i);
      await _notifications.cancel(notificationId);
      
      // Also cancel day-specific notifications
      for (int day = 1; day <= 7; day++) {
        await _notifications.cancel(notificationId + (day * 1000));
      }
    }
    debugPrint('Cancelled notifications for habit $habitId');
  }

  /// Cancel a single notification
  Future<void> cancelNotification(int id) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Show immediate notification (for testing or milestones)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'habit_achievements',
      'Achievements',
      channelDescription: 'Notifications for habit achievements',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return true;
  }

  /// Show milestone notification
  Future<void> showMilestoneNotification({
    required String habitName,
    required int streak,
  }) async {
    await showImmediateNotification(
      id: 999999,
      title: '🎉 Milestone Reached!',
      body: '$habitName: $streak days streak! Keep it up!',
    );
  }

  /// Show daily summary notification
  Future<void> showDailySummaryNotification({
    required int completed,
    required int total,
  }) async {
    await showImmediateNotification(
      id: 999998,
      title: 'Daily Summary',
      body: 'You completed $completed out of $total habits today!',
    );
  }

  /// Reschedule all habit notifications
  Future<void> rescheduleAllNotifications(List<Habit> habits) async {
    await cancelAllNotifications();
    
    for (final habit in habits) {
      if (habit.isActive && habit.reminderTimes != null) {
        await scheduleHabitNotifications(habit);
      }
    }
    
    debugPrint('Rescheduled notifications for ${habits.length} habits');
  }
}