import 'package:daily_habits/features/habits/models/habit_model.dart';
import 'package:daily_habits/features/habits/models/habit_record_model.dart';

/// Analytics service for calculating streaks, completion rates, and insights
class AnalyticsService {
  /// Calculate current streak for a habit
  static int calculateStreak(List<HabitRecord> records, Habit habit) {
    if (records.isEmpty) return 0;

    // Sort records by date descending
    final sortedRecords = List<HabitRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Normalize to start of day
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (int i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);

      // Check if habit is scheduled for this date
      if (!habit.isScheduledFor(recordDate)) {
        // Skip days not scheduled
        currentDate = recordDate.subtract(const Duration(days: 1));
        continue;
      }

      // Check if record is for current date
      if (recordDate.isAtSameMomentAs(currentDate)) {
        if (record.status == 'done') {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break; // Streak broken
        }
      } else if (recordDate.isBefore(currentDate)) {
        // Gap in records - streak broken
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak for a habit
  static int calculateLongestStreak(List<HabitRecord> records, Habit habit) {
    if (records.isEmpty) return 0;

    final sortedRecords = List<HabitRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final record in sortedRecords) {
      if (record.status != 'done') {
        currentStreak = 0;
        lastDate = null;
        continue;
      }

      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = recordDate.difference(lastDate).inDays;
        if (daysDiff == 1 || (daysDiff > 1 && !_hasScheduledDaysBetween(habit, lastDate, recordDate))) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      lastDate = recordDate;
    }

    return maxStreak;
  }

  /// Check if there are scheduled days between two dates
  static bool _hasScheduledDaysBetween(Habit habit, DateTime start, DateTime end) {
    DateTime current = start.add(const Duration(days: 1));
    while (current.isBefore(end)) {
      if (habit.isScheduledFor(current)) {
        return true;
      }
      current = current.add(const Duration(days: 1));
    }
    return false;
  }

  /// Calculate completion rate for a date range
  static double calculateCompletionRate(
    List<HabitRecord> records,
    Habit habit,
    DateTime startDate,
    DateTime endDate,
  ) {
    int scheduledDays = 0;
    int completedDays = 0;

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (habit.isScheduledFor(current)) {
        scheduledDays++;
        
        final record = records.firstWhere(
          (r) {
            final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
            return recordDate.isAtSameMomentAs(current);
          },
          orElse: () => HabitRecord(
            habitID: habit.habitID!,
            userID: habit.userID,
            date: current,
            status: 'missed',
            progress: 0,
          ),
        );

        if (record.status == 'done') {
          completedDays++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return scheduledDays > 0 ? (completedDays / scheduledDays) * 100 : 0;
  }

  /// Get weekly completion data for charts
  static List<double> getWeeklyCompletionData(
    List<HabitRecord> records,
    Habit habit,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<double> data = [];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (!habit.isScheduledFor(date)) {
        data.add(0);
        continue;
      }

      final record = records.firstWhere(
        (r) {
          final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
          final checkDate = DateTime(date.year, date.month, date.day);
          return recordDate.isAtSameMomentAs(checkDate);
        },
        orElse: () => HabitRecord(
          habitID: habit.habitID!,
          userID: habit.userID,
          date: date,
          status: 'missed',
          progress: 0,
        ),
      );

      data.add(record.status == 'done' ? 1.0 : 0.0);
    }

    return data;
  }

  /// Get monthly completion data
  static Map<int, double> getMonthlyCompletionData(
    List<HabitRecord> records,
    Habit habit,
    int year,
    int month,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final Map<int, double> data = {};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      
      if (!habit.isScheduledFor(date)) {
        data[day] = 0;
        continue;
      }

      final record = records.firstWhere(
        (r) {
          final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
          return recordDate.isAtSameMomentAs(date);
        },
        orElse: () => HabitRecord(
          habitID: habit.habitID!,
          userID: habit.userID,
          date: date,
          status: 'missed',
          progress: 0,
        ),
      );

      data[day] = record.status == 'done' ? 1.0 : 0.0;
    }

    return data;
  }

  /// Calculate best time of day for habit completion
  static String? getBestTimeOfDay(List<HabitRecord> records) {
    if (records.isEmpty) return null;

    final Map<String, int> timeSlots = {
      'morning': 0,   // 5am - 12pm
      'afternoon': 0, // 12pm - 5pm
      'evening': 0,   // 5pm - 9pm
      'night': 0,     // 9pm - 5am
    };

    for (final record in records) {
      if (record.status != 'done') continue;

      final hour = record.createdAt?.hour ?? 12;
      if (hour >= 5 && hour < 12) {
        timeSlots['morning'] = timeSlots['morning']! + 1;
      } else if (hour >= 12 && hour < 17) {
        timeSlots['afternoon'] = timeSlots['afternoon']! + 1;
      } else if (hour >= 17 && hour < 21) {
        timeSlots['evening'] = timeSlots['evening']! + 1;
      } else {
        timeSlots['night'] = timeSlots['night']! + 1;
      }
    }

    String? bestTime;
    int maxCount = 0;
    timeSlots.forEach((time, count) {
      if (count > maxCount) {
        maxCount = count;
        bestTime = time;
      }
    });

    return bestTime;
  }

  /// Get habit insights
  static Map<String, dynamic> getHabitInsights(
    List<HabitRecord> records,
    Habit habit,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return {
      'currentStreak': calculateStreak(records, habit),
      'longestStreak': calculateLongestStreak(records, habit),
      'weeklyCompletionRate': calculateCompletionRate(records, habit, weekStart, now),
      'monthlyCompletionRate': calculateCompletionRate(records, habit, monthStart, now),
      'totalCompletions': records.where((r) => r.status == 'done').length,
      'bestTimeOfDay': getBestTimeOfDay(records),
    };
  }

  /// Calculate overall user statistics
  static Map<String, dynamic> getUserStatistics(
    List<Habit> habits,
    Map<int, List<HabitRecord>> habitRecords,
  ) {
    int totalHabits = habits.length;
    int activeHabits = habits.where((h) => h.isActive).length;
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    int completedToday = 0;
    int scheduledToday = 0;
    
    for (final habit in habits) {
      if (!habit.isActive) continue;
      if (!habit.isScheduledFor(todayStart)) continue;
      
      scheduledToday++;
      final records = habitRecords[habit.habitID] ?? [];
      final todayRecord = records.firstWhere(
        (r) {
          final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
          return recordDate.isAtSameMomentAs(todayStart);
        },
        orElse: () => HabitRecord(
          habitID: habit.habitID!,
          userID: habit.userID,
          date: todayStart,
          status: 'missed',
          progress: 0,
        ),
      );
      
      if (todayRecord.status == 'done') {
        completedToday++;
      }
    }

    // Calculate average streak
    double averageStreak = 0;
    if (habits.isNotEmpty) {
      int totalStreak = 0;
      for (final habit in habits) {
        final records = habitRecords[habit.habitID] ?? [];
        totalStreak += calculateStreak(records, habit);
      }
      averageStreak = totalStreak / habits.length;
    }

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'completedToday': completedToday,
      'scheduledToday': scheduledToday,
      'todayCompletionRate': scheduledToday > 0 
          ? (completedToday / scheduledToday) * 100 
          : 0,
      'averageStreak': averageStreak,
    };
  }

  /// Get most consistent habits (highest completion rate)
  static List<Map<String, dynamic>> getMostConsistentHabits(
    List<Habit> habits,
    Map<int, List<HabitRecord>> habitRecords,
    {int limit = 5}
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final habitStats = <Map<String, dynamic>>[];
    
    for (final habit in habits) {
      if (!habit.isActive) continue;
      final records = habitRecords[habit.habitID] ?? [];
      final completionRate = calculateCompletionRate(records, habit, monthStart, now);
      
      habitStats.add({
        'habit': habit,
        'completionRate': completionRate,
        'streak': calculateStreak(records, habit),
      });
    }
    
    habitStats.sort((a, b) => 
      (b['completionRate'] as double).compareTo(a['completionRate'] as double)
    );
    
    return habitStats.take(limit).toList();
  }

  /// Get habits that need attention (low completion rate)
  static List<Map<String, dynamic>> getHabitsNeedingAttention(
    List<Habit> habits,
    Map<int, List<HabitRecord>> habitRecords,
    {int limit = 5}
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final habitStats = <Map<String, dynamic>>[];
    
    for (final habit in habits) {
      if (!habit.isActive) continue;
      final records = habitRecords[habit.habitID] ?? [];
      final completionRate = calculateCompletionRate(records, habit, weekStart, now);
      
      if (completionRate < 50) {
        habitStats.add({
          'habit': habit,
          'completionRate': completionRate,
          'missedDays': _calculateMissedDays(records, habit, weekStart, now),
        });
      }
    }
    
    habitStats.sort((a, b) => 
      (a['completionRate'] as double).compareTo(b['completionRate'] as double)
    );
    
    return habitStats.take(limit).toList();
  }

  static int _calculateMissedDays(
    List<HabitRecord> records,
    Habit habit,
    DateTime startDate,
    DateTime endDate,
  ) {
    int missedDays = 0;
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (habit.isScheduledFor(current)) {
        final record = records.firstWhere(
          (r) {
            final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
            return recordDate.isAtSameMomentAs(current);
          },
          orElse: () => HabitRecord(
            habitID: habit.habitID!,
            userID: habit.userID,
            date: current,
            status: 'missed',
            progress: 0,
          ),
        );

        if (record.status == 'missed') {
          missedDays++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return missedDays;
  }
}
