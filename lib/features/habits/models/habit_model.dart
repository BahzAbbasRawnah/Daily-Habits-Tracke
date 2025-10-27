/// Habit categories
enum HabitCategory {
  exercise,
  sleep,
  hydration,
  nutrition,
  mindfulness,
  productivity,
  learning,
  social,
  health,
  other
}

/// Target types for habits
enum TargetType {
  yesNo, // Simple yes/no completion
  count, // Times per day (e.g., 3x per day)
  duration, // Duration in minutes
}

/// Schedule types
enum ScheduleType {
  daily,
  specificDays, // Mon-Fri, weekends, etc.
  custom, // User-defined pattern
}

/// Schedule configuration for habits
class HabitSchedule {
  final ScheduleType type;
  final List<int>? days; // 1=Monday, 7=Sunday
  final int? times; // Times per day

  const HabitSchedule({
    required this.type,
    this.days,
    this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'days': days?.join(','),
      'times': times,
    };
  }

  factory HabitSchedule.fromMap(Map<String, dynamic> map) {
    return HabitSchedule(
      type: ScheduleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ScheduleType.daily,
      ),
      days: map['days'] != null
          ? (map['days'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      times: map['times'],
    );
  }

  String toJson() {
    return '${type.name}|${days?.join(',') ?? ''}|${times ?? ''}';
  }

  factory HabitSchedule.fromJson(String json) {
    final parts = json.split('|');
    return HabitSchedule(
      type: ScheduleType.values.firstWhere(
        (e) => e.name == parts[0],
        orElse: () => ScheduleType.daily,
      ),
      days: parts.length > 1 && parts[1].isNotEmpty
          ? parts[1].split(',').map((e) => int.parse(e)).toList()
          : null,
      times: parts.length > 2 && parts[2].isNotEmpty
          ? int.tryParse(parts[2])
          : null,
    );
  }
}

class Habit {
  final int? habitID;
  final int userID;
  final String name;
  final String? description;
  final HabitCategory category;
  final String frequency; // Kept for backward compatibility
  final HabitSchedule schedule;
  final TargetType targetType;
  final int target;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime? createdAt;
  final List<String>? reminderTimes; // Multiple reminder times

  Habit({
    this.habitID,
    required this.userID,
    required this.name,
    this.description,
    this.category = HabitCategory.other,
    required this.frequency,
    HabitSchedule? schedule,
    this.targetType = TargetType.yesNo,
    this.target = 1,
    this.icon,
    this.color,
    this.isActive = true,
    this.createdAt,
    this.reminderTimes,
  }) : schedule = schedule ?? const HabitSchedule(type: ScheduleType.daily);

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      habitID: map['HabitID'],
      userID: map['UserID'],
      name: map['Name'],
      description: map['Description'],
      category: map['Category'] != null
          ? HabitCategory.values.firstWhere(
              (e) => e.name == map['Category'],
              orElse: () => HabitCategory.other,
            )
          : HabitCategory.other,
      frequency: map['Frequency'] ?? 'daily',
      schedule: map['Schedule'] != null
          ? HabitSchedule.fromJson(map['Schedule'])
          : const HabitSchedule(type: ScheduleType.daily),
      targetType: map['TargetType'] != null
          ? TargetType.values.firstWhere(
              (e) => e.name == map['TargetType'],
              orElse: () => TargetType.yesNo,
            )
          : TargetType.yesNo,
      target: map['Target'] ?? 1,
      icon: map['Icon'],
      color: map['Color'],
      isActive: map['IsActive'] == 1,
      createdAt:
          map['CreatedAt'] != null ? DateTime.parse(map['CreatedAt']) : null,
      reminderTimes: map['ReminderTimes'] != null
          ? (map['ReminderTimes'] as String).split(',')
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'HabitID': habitID,
      'UserID': userID,
      'Name': name,
      'Description': description,
      'Category': category.name,
      'Frequency': frequency,
      'Schedule': schedule.toJson(),
      'TargetType': targetType.name,
      'Target': target,
      'Icon': icon,
      'Color': color,
      'IsActive': isActive ? 1 : 0,
      'CreatedAt': createdAt?.toIso8601String(),
      'ReminderTimes': reminderTimes?.join(','),
    };
  }

  /// Check if habit should be shown on a specific date
  bool isScheduledFor(DateTime date) {
    switch (schedule.type) {
      case ScheduleType.daily:
        return true;
      case ScheduleType.specificDays:
        if (schedule.days == null) {
          return true;
        }
        return schedule.days!.contains(date.weekday);
      case ScheduleType.custom:
        if (schedule.days == null) {
          return true;
        }
        return schedule.days!.contains(date.weekday);
    }
  }

  /// Get category display name (returns translation key)
  String getCategoryName() {
    return category.name;
  }

  /// Get category icon
  String getCategoryIcon() {
    switch (category) {
      case HabitCategory.exercise:
        return '🏃';
      case HabitCategory.sleep:
        return '😴';
      case HabitCategory.hydration:
        return '💧';
      case HabitCategory.nutrition:
        return '🥗';
      case HabitCategory.mindfulness:
        return '🧘';
      case HabitCategory.productivity:
        return '📊';
      case HabitCategory.learning:
        return '📚';
      case HabitCategory.social:
        return '👥';
      case HabitCategory.health:
        return '❤️';
      case HabitCategory.other:
        return '⭐';
    }
  }

  Habit copyWith({
    int? habitID,
    int? userID,
    String? name,
    String? description,
    HabitCategory? category,
    String? frequency,
    HabitSchedule? schedule,
    TargetType? targetType,
    int? target,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    List<String>? reminderTimes,
  }) {
    return Habit(
      habitID: habitID ?? this.habitID,
      userID: userID ?? this.userID,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      schedule: schedule ?? this.schedule,
      targetType: targetType ?? this.targetType,
      target: target ?? this.target,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}
