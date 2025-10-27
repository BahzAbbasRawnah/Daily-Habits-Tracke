import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/habit_model.dart';
import '../models/reminder_model.dart';
import '../models/habit_record_model.dart';
import '../repositories/habit_record_repository.dart';
import '../../auth/services/auth_service.dart';

/// Enhanced notification service with actionable buttons
/// Supports: Mark Done, Snooze, Dismiss actions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Action IDs
  static const String actionMarkDone = 'MARK_DONE';
  static const String actionSnooze = 'SNOOZE';
  static const String actionDismiss = 'DISMISS';

  // Notification channel
  static const String channelId = 'habit_reminders';
  static const String channelName = 'Habit Reminders';
  static const String channelDescription = 'Notifications for habit reminders';

  /// Initialize notification service with action handlers
  Future<void> initialize({
    Function(int habitId, String habitName)? onMarkDone,
    Function(int habitId, int reminderId)? onSnooze,
  }) async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Set local timezone
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('📍 Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Error setting timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Android initialization settings with actions
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response, onMarkDone, onSnooze);
      },
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
      await checkExactAlarmStatus(); // Diagnose exact alarm permission
    }

    _initialized = true;
    debugPrint('✅ Enhanced notification service initialized');
  }

  /// Create Android notification channel with sound
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    debugPrint('📢 Android notification channel created');
    debugPrint('📢 Channel ID: $channelId');
    debugPrint('📢 Importance: ${androidChannel.importance}');
  }

  /// Handle notification response (foreground/background)
  void _handleNotificationResponse(
    NotificationResponse response,
    Function(int, String)? onMarkDone,
    Function(int, int)? onSnooze,
  ) {
    debugPrint(
        '🔔 Notification response: ${response.actionId}, payload: ${response.payload}');

    if (response.payload == null) return;

    final parts = response.payload!.split('|');
    if (parts.length < 3) return;

    final habitId = int.tryParse(parts[0]);
    final reminderId = int.tryParse(parts[1]);
    final habitName = parts[2];

    if (habitId == null || reminderId == null) return;

    switch (response.actionId) {
      case actionMarkDone:
        debugPrint('✅ Mark Done action triggered for habit: $habitName');
        _handleMarkDone(habitId, habitName);
        onMarkDone?.call(habitId, habitName);
        break;
      case actionSnooze:
        debugPrint('⏰ Snooze action triggered for habit: $habitName');
        onSnooze?.call(habitId, reminderId);
        break;
      case actionDismiss:
        debugPrint('❌ Dismiss action triggered');
        break;
      default:
        // Notification tapped (no action button)
        debugPrint('👆 Notification tapped - open habit details');
      // TODO: Navigate to habit details
    }
  }

  /// Background notification response handler (must be top-level function)
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(
      NotificationResponse response) {
    debugPrint('🔔 Background notification response: ${response.actionId}');
    // Handle background actions here
  }

  /// Handle Mark Done action - insert habit record
  Future<void> _handleMarkDone(int habitId, String habitName) async {
    try {
      final repository = HabitRecordRepository();
      final today = DateTime.now();

      // Get actual logged-in user ID
      final userId = await AuthService.getSavedUserId();
      if (userId == null) {
        debugPrint('⚠️ No logged-in user found');
        return;
      }

      // Check if record already exists
      final existing = await repository.getRecordByDate(habitId, today);

      if (existing == null) {
        // Create new record with actual user ID
        final record = HabitRecord(
          habitID: habitId,
          userID: userId,
          date: today,
          progress: 1,
          status: 'done',
          createdAt: DateTime.now(),
        );

        await repository.createRecord(record);

        debugPrint('✅ Habit record created for $habitName (User: $userId)');

        // Show confirmation notification
        await _showConfirmationNotification(habitName);
      } else {
        debugPrint('ℹ️ Habit already marked as done today');
      }
    } catch (e) {
      debugPrint('❌ Error marking habit as done: $e');
    }
  }

  /// Show confirmation notification after marking done
  Future<void> _showConfirmationNotification(String habitName) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'habit_completed'.tr(),
      'habit_marked_done'.tr(namedArgs: {'habit': habitName}),
      notificationDetails,
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission
      final notificationStatus = await Permission.notification.request();
      debugPrint('📱 Notification permission: ${notificationStatus.isGranted}');

      // Check and request exact alarm permission for Android 12+
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('⏰ Exact alarm permission status: $exactAlarmStatus');

      if (exactAlarmStatus.isDenied || exactAlarmStatus.isPermanentlyDenied) {
        debugPrint(
            '⚠️ Exact alarm permission not granted - notifications may not work');
        debugPrint(
            '💡 User needs to enable "Alarms & reminders" in app settings');
        // On Android 13+, this opens the exact alarm settings page
        await Permission.scheduleExactAlarm.request();
      }

      return notificationStatus.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Check if permissions are granted
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final notificationGranted = await Permission.notification.isGranted;
      final exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
      debugPrint(
          '📱 Notification: $notificationGranted, ⏰ Exact Alarm: $exactAlarmGranted');
      return notificationGranted && exactAlarmGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't have a direct way to check, assume granted if requested before
      return true;
    }
    return true;
  }

  /// Diagnostic: Check exact alarm status on Android 13+
  Future<void> checkExactAlarmStatus() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      debugPrint('🔍 Exact Alarm Permission Status: $status');
      debugPrint('🔍 Is Granted: ${status.isGranted}');
      debugPrint('🔍 Is Denied: ${status.isDenied}');
      debugPrint('🔍 Is Permanently Denied: ${status.isPermanentlyDenied}');

      if (!status.isGranted) {
        debugPrint('⚠️ Exact alarms are NOT enabled!');
        debugPrint(
            '💡 User needs to enable in Settings → Apps → Habits Tracker → Alarms & reminders');
      } else {
        debugPrint('✅ Exact alarms ARE enabled');
      }
    }
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder({
    required HabitReminder reminder,
    required Habit habit,
  }) async {
    if (!_initialized) await initialize();

    final nextScheduledTime = reminder.getNextScheduledTime();
    if (nextScheduledTime == null) {
      debugPrint(
          '⚠️ No next scheduled time for reminder ${reminder.reminderID}');
      return;
    }

    final notificationId =
        _generateNotificationId(habit.habitID!, reminder.reminderID ?? 0);

    // Create notification with action buttons
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      enableLights: true,
      showWhen: true,
      ticker: 'reminders'.tr(),
      color: _parseColor(habit.color),
      styleInformation: BigTextStyleInformation(
        'reminder_message'.tr(namedArgs: {'habit': habit.name}),
        contentTitle: habit.name,
      ),
      actions: [
        AndroidNotificationAction(
          actionMarkDone,
          'mark_done'.tr(),
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionSnooze,
          'snooze'.tr(),
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    debugPrint('📢 Notification details created for habit: ${habit.name}');
    debugPrint('📢 Channel: $channelId');
    debugPrint('📢 Importance: ${androidDetails.importance}');
    debugPrint('📢 Priority: ${androidDetails.priority}');

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.wav',
      categoryIdentifier: 'habitReminder',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Payload format: habitId|reminderId|habitName
    final payload = '${habit.habitID}|${reminder.reminderID}|${habit.name}';

    try {
      final scheduledDate = tz.TZDateTime.from(nextScheduledTime, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      debugPrint('🕐 Current time: $now');
      debugPrint('⏰ Scheduled time: $scheduledDate');
      debugPrint(
          '⏱️ Time until notification: ${scheduledDate.difference(now).inMinutes} minutes');
      debugPrint('📝 Notification ID: $notificationId');
      debugPrint('📝 Payload: $payload');

      // Check if scheduled time is in the future
      if (scheduledDate.isBefore(now)) {
        debugPrint(
            '⚠️ Scheduled time is in the past! This should not happen for new reminders.');
        return;
      }

      // Try exact alarm mode, fall back to inexact if it fails
      try {
        await _notifications.zonedSchedule(
          notificationId,
          habit.name,
          'reminder_message'.tr(namedArgs: {'habit': habit.name}),
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
          matchDateTimeComponents:
              reminder.isRecurring ? DateTimeComponents.time : null,
        );
        debugPrint('✅ Successfully scheduled with exactAllowWhileIdle');
      } catch (e) {
        debugPrint('⚠️ Failed with exactAllowWhileIdle: $e');
        debugPrint('🔄 Retrying with exact mode...');

        // Fallback to exact mode
        await _notifications.zonedSchedule(
          notificationId,
          habit.name,
          'reminder_message'.tr(namedArgs: {'habit': habit.name}),
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
          matchDateTimeComponents:
              reminder.isRecurring ? DateTimeComponents.time : null,
        );
        debugPrint('✅ Successfully scheduled with exact mode');
      }

      debugPrint(
          '✅ Scheduled reminder for ${habit.name} at $scheduledDate (ID: $notificationId)');

      // Verify the notification was scheduled
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pending.length}');
      for (var n in pending.take(5)) {
        debugPrint('  - ID: ${n.id}, Title: ${n.title}, Body: ${n.body}');
      }
      final scheduled = pending.where((n) => n.id == notificationId).toList();
      if (scheduled.isEmpty) {
        debugPrint('⚠️ WARNING: Notification not found in pending list!');
      } else {
        debugPrint('✅ Verified: Notification is in pending list');
        debugPrint(
            '✅ Full notification: ID=${scheduled[0].id}, Title=${scheduled[0].title}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
    }
  }

  /// Schedule multiple reminders for a habit
  Future<void> scheduleHabitReminders({
    required List<HabitReminder> reminders,
    required Habit habit,
  }) async {
    for (final reminder in reminders) {
      if (reminder.isActive) {
        await scheduleReminder(reminder: reminder, habit: habit);
      }
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(int habitId, int reminderId) async {
    final notificationId = _generateNotificationId(habitId, reminderId);
    await _notifications.cancel(notificationId);
    debugPrint('🚫 Cancelled reminder notification $notificationId');
  }

  /// Cancel all reminders for a habit
  Future<void> cancelHabitReminders(int habitId) async {
    // Cancel up to 10 possible reminders per habit
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(habitId, i);
      await _notifications.cancel(notificationId);
    }
    debugPrint('🚫 Cancelled all reminders for habit $habitId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🚫 Cancelled all notifications');
  }

  /// Show immediate test notification (for debugging)
  Future<void> showImmediateTestNotification(String message) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      'Test Notification',
      message,
      notificationDetails,
    );

    debugPrint('📢 Immediate test notification shown: $message');
  }

  /// Show immediate test notification
  Future<void> showTestNotification({
    required String habitName,
    required int habitId,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showWhen: true,
      ticker: 'Habit Reminder',
      styleInformation: BigTextStyleInformation(''),
      actions: [
        AndroidNotificationAction(
          actionMarkDone,
          'تم الإنجاز',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionSnooze,
          'غفوة',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      habitName,
      'reminder_message'.tr(namedArgs: {'habit': habitName}),
      notificationDetails,
      payload: '$habitId|0|$habitName',
    );

    debugPrint('📢 Test notification shown for $habitName');
  }

  /// Snooze a reminder (reschedule for X minutes later)
  Future<void> snoozeReminder({
    required HabitReminder reminder,
    required Habit habit,
    int? customMinutes,
  }) async {
    final snoozeMinutes = customMinutes ?? reminder.snoozeMinutes;
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final notificationId =
        _generateNotificationId(habit.habitID!, reminder.reminderID ?? 0);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      actions: [
        AndroidNotificationAction(
          actionMarkDone,
          'mark_done'.tr(),
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = '${habit.habitID}|${reminder.reminderID}|${habit.name}';

    try {
      final scheduledDate = tz.TZDateTime.from(snoozeTime, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        habit.name,
        'snoozed_reminder_message'.tr(namedArgs: {'habit': habit.name}),
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('⏰ Snoozed reminder for ${habit.name} to $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error snoozing reminder: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Generate unique notification ID
  int _generateNotificationId(int habitId, int reminderId) {
    return (habitId * 1000) + reminderId;
  }

  /// Parse color string to Color object
  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      final cleanColor = colorString.replaceFirst('#', '0xff');
      return Color(int.parse(cleanColor));
    } catch (e) {
      return null;
    }
  }
}
