/// Reminder model for scheduling habit notifications
class HabitReminder {
  final int? reminderID;
  final int habitID;
  final String time; // Format: HH:mm (24-hour)
  final List<int>? weekdays; // 1=Monday, 7=Sunday, null=one-off
  final bool isActive;
  final bool isRecurring;
  final DateTime? scheduledDate; // For one-off reminders
  final int snoozeMinutes; // Default snooze duration
  final DateTime? createdAt;

  HabitReminder({
    this.reminderID,
    required this.habitID,
    required this.time,
    this.weekdays,
    this.isActive = true,
    this.isRecurring = true,
    this.scheduledDate,
    this.snoozeMinutes = 10,
    this.createdAt,
  });

  factory HabitReminder.fromMap(Map<String, dynamic> map) {
    return HabitReminder(
      reminderID: map['ReminderID'],
      habitID: map['HabitID'],
      time: map['Time'],
      weekdays: map['Weekdays'] != null && (map['Weekdays'] as String).isNotEmpty
          ? (map['Weekdays'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      isActive: map['IsActive'] == 1,
      isRecurring: map['IsRecurring'] == 1,
      scheduledDate: map['ScheduledDate'] != null
          ? DateTime.parse(map['ScheduledDate'])
          : null,
      snoozeMinutes: map['SnoozeMinutes'] ?? 10,
      createdAt: map['CreatedAt'] != null
          ? DateTime.parse(map['CreatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ReminderID': reminderID,
      'HabitID': habitID,
      'Time': time,
      'Weekdays': weekdays?.join(','),
      'IsActive': isActive ? 1 : 0,
      'IsRecurring': isRecurring ? 1 : 0,
      'ScheduledDate': scheduledDate?.toIso8601String(),
      'SnoozeMinutes': snoozeMinutes,
      'CreatedAt': createdAt?.toIso8601String(),
    };
  }

  /// Get the next scheduled DateTime for this reminder
  DateTime? getNextScheduledTime() {
    final now = DateTime.now();
    final timeParts = time.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;

    if (!isRecurring && scheduledDate != null) {
      // One-off reminder
      final scheduled = DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        hour,
        minute,
      );
      return scheduled.isAfter(now) ? scheduled : null;
    }

    // Recurring reminder - find next occurrence
    if (weekdays == null || weekdays!.isEmpty) {
      // Daily reminder
      var nextTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (nextTime.isBefore(now) || nextTime.isAtSameMomentAs(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
      return nextTime;
    }

    // Specific weekdays
    for (int i = 0; i < 8; i++) {
      final checkDate = now.add(Duration(days: i));
      if (weekdays!.contains(checkDate.weekday)) {
        var nextTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          hour,
          minute,
        );
        if (nextTime.isAfter(now)) {
          return nextTime;
        }
      }
    }

    return null;
  }

  HabitReminder copyWith({
    int? reminderID,
    int? habitID,
    String? time,
    List<int>? weekdays,
    bool? isActive,
    bool? isRecurring,
    DateTime? scheduledDate,
    int? snoozeMinutes,
    DateTime? createdAt,
  }) {
    return HabitReminder(
      reminderID: reminderID ?? this.reminderID,
      habitID: habitID ?? this.habitID,
      time: time ?? this.time,
      weekdays: weekdays ?? this.weekdays,
      isActive: isActive ?? this.isActive,
      isRecurring: isRecurring ?? this.isRecurring,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
