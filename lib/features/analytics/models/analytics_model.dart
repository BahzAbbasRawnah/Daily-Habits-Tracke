/// Analytics data model
class AnalyticsData {
  final int totalHabits;
  final int activeHabits;
  final int completedToday;
  final int totalCompletions;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> categoryBreakdown;
  final List<DailyProgress> weeklyProgress;
  final List<DailyProgress> monthlyProgress;

  AnalyticsData({
    required this.totalHabits,
    required this.activeHabits,
    required this.completedToday,
    required this.totalCompletions,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.categoryBreakdown,
    required this.weeklyProgress,
    required this.monthlyProgress,
  });

  factory AnalyticsData.empty() {
    return AnalyticsData(
      totalHabits: 0,
      activeHabits: 0,
      completedToday: 0,
      totalCompletions: 0,
      completionRate: 0.0,
      currentStreak: 0,
      longestStreak: 0,
      categoryBreakdown: {},
      weeklyProgress: [],
      monthlyProgress: [],
    );
  }
}

/// Daily progress data
class DailyProgress {
  final DateTime date;
  final int completed;
  final int total;
  final double percentage;

  DailyProgress({
    required this.date,
    required this.completed,
    required this.total,
    required this.percentage,
  });

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String get weekday {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
}

/// Habit statistics
class HabitStats {
  final String habitId;
  final String habitName;
  final int totalCompletions;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final DateTime? lastCompleted;

  HabitStats({
    required this.habitId,
    required this.habitName,
    required this.totalCompletions,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    this.lastCompleted,
  });
}
