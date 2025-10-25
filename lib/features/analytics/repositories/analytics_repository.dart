import 'package:daily_habits/core/database/habit_database_service.dart';
import 'package:daily_habits/features/analytics/models/analytics_model.dart';

/// Repository for analytics data
class AnalyticsRepository {
  final HabitDatabaseService _db = HabitDatabaseService();

  /// Get analytics data for a specific period
  Future<AnalyticsData> getAnalyticsData(int userID, {int days = 30}) async {
    final database = await _db.database;
    
    // Get total habits
    final habitsResult = await database.rawQuery('''
      SELECT COUNT(*) as total, 
             SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) as active
      FROM Habits
      WHERE UserID = ?
    ''', [userID]);
    
    final totalHabits = habitsResult.first['total'] as int? ?? 0;
    final activeHabits = habitsResult.first['active'] as int? ?? 0;
    
    // Get today's completions
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final todayResult = await database.rawQuery('''
      SELECT COUNT(*) as completed
      FROM Habit_Records
      WHERE UserID = ? AND Date >= ? AND Status = 'done'
    ''', [userID, startOfDay.toIso8601String()]);
    
    final completedToday = todayResult.first['completed'] as int? ?? 0;
    
    // Get total completions
    final totalResult = await database.rawQuery('''
      SELECT COUNT(*) as total
      FROM Habit_Records
      WHERE UserID = ? AND Status = 'done'
    ''', [userID]);
    
    final totalCompletions = totalResult.first['total'] as int? ?? 0;
    
    // Calculate completion rate
    final totalRecords = await database.rawQuery('''
      SELECT COUNT(*) as total
      FROM Habit_Records
      WHERE UserID = ?
    ''', [userID]);
    
    final totalRecordsCount = totalRecords.first['total'] as int? ?? 0;
    final completionRate = totalRecordsCount > 0 
        ? (totalCompletions / totalRecordsCount) * 100 
        : 0.0;
    
    // Get category breakdown
    final categoryResult = await database.rawQuery('''
      SELECT h.Category, COUNT(*) as count
      FROM Habits h
      WHERE h.UserID = ? AND h.IsActive = 1
      GROUP BY h.Category
    ''', [userID]);
    
    final categoryBreakdown = <String, int>{};
    for (final row in categoryResult) {
      categoryBreakdown[row['Category'] as String] = row['count'] as int;
    }
    
    // Get weekly progress (last 7 days)
    final weeklyProgress = await _getDailyProgress(userID, 7);
    
    // Get monthly progress (last 30 days)
    final monthlyProgress = await _getDailyProgress(userID, days);
    
    // Calculate streaks
    final streaks = await _calculateStreaks(userID);
    
    return AnalyticsData(
      totalHabits: totalHabits,
      activeHabits: activeHabits,
      completedToday: completedToday,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      categoryBreakdown: categoryBreakdown,
      weeklyProgress: weeklyProgress,
      monthlyProgress: monthlyProgress,
    );
  }

  /// Get daily progress for a specific period
  Future<List<DailyProgress>> _getDailyProgress(int userID, int days) async {
    final database = await _db.database;
    final progress = <DailyProgress>[];
    final today = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Get completed habits for this day
      final completedResult = await database.rawQuery('''
        SELECT COUNT(*) as completed
        FROM Habit_Records
        WHERE UserID = ? 
          AND Date >= ? 
          AND Date < ?
          AND Status = 'done'
      ''', [userID, startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
      
      // Get total habits for this day
      final totalResult = await database.rawQuery('''
        SELECT COUNT(*) as total
        FROM Habit_Records
        WHERE UserID = ? 
          AND Date >= ? 
          AND Date < ?
      ''', [userID, startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
      
      final completed = completedResult.first['completed'] as int? ?? 0;
      final total = totalResult.first['total'] as int? ?? 0;
      final percentage = total > 0 ? (completed / total) * 100 : 0.0;
      
      progress.add(DailyProgress(
        date: startOfDay,
        completed: completed,
        total: total,
        percentage: percentage,
      ));
    }
    
    return progress;
  }

  /// Calculate current and longest streaks
  Future<Map<String, int>> _calculateStreaks(int userID) async {
    final database = await _db.database;
    
    // Get all completion dates
    final result = await database.rawQuery('''
      SELECT DISTINCT DATE(Date) as date
      FROM Habit_Records
      WHERE UserID = ? AND Status = 'done'
      ORDER BY date DESC
    ''', [userID]);
    
    if (result.isEmpty) {
      return {'current': 0, 'longest': 0};
    }
    
    final dates = result.map((r) => DateTime.parse(r['date'] as String)).toList();
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if streak is current
    if (dates.first.year == today.year && 
        dates.first.month == today.month && 
        dates.first.day == today.day) {
      currentStreak = 1;
    } else if (dates.first.year == yesterday.year && 
               dates.first.month == yesterday.month && 
               dates.first.day == yesterday.day) {
      currentStreak = 1;
    }
    
    // Calculate streaks
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      
      if (diff == 1) {
        tempStreak++;
        if (i == 0 || currentStreak > 0) {
          currentStreak = tempStreak;
        }
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    return {'current': currentStreak, 'longest': longestStreak};
  }

  /// Get habit-specific statistics
  Future<List<HabitStats>> getHabitStats(int userID) async {
    final database = await _db.database;
    
    final result = await database.rawQuery('''
      SELECT 
        h.HabitID,
        h.Name,
        COUNT(CASE WHEN hr.Status = 'done' THEN 1 END) as completions,
        MAX(hr.Date) as lastCompleted
      FROM Habits h
      LEFT JOIN Habit_Records hr ON h.HabitID = hr.HabitID
      WHERE h.UserID = ? AND h.IsActive = 1
      GROUP BY h.HabitID, h.Name
    ''', [userID]);
    
    final stats = <HabitStats>[];
    
    for (final row in result) {
      final habitId = row['HabitID'].toString();
      final habitName = row['Name'] as String;
      final completions = row['completions'] as int? ?? 0;
      final lastCompletedStr = row['lastCompleted'] as String?;
      
      // Calculate streaks for this habit
      final streaks = await _calculateHabitStreaks(int.parse(habitId));
      
      // Calculate completion rate
      final totalRecords = await database.rawQuery('''
        SELECT COUNT(*) as total
        FROM Habit_Records
        WHERE HabitID = ?
      ''', [int.parse(habitId)]);
      
      final total = totalRecords.first['total'] as int? ?? 0;
      final rate = total > 0 ? (completions / total) * 100 : 0.0;
      
      stats.add(HabitStats(
        habitId: habitId,
        habitName: habitName,
        totalCompletions: completions,
        currentStreak: streaks['current'] ?? 0,
        longestStreak: streaks['longest'] ?? 0,
        completionRate: rate,
        lastCompleted: lastCompletedStr != null 
            ? DateTime.parse(lastCompletedStr) 
            : null,
      ));
    }
    
    return stats;
  }

  /// Calculate streaks for a specific habit
  Future<Map<String, int>> _calculateHabitStreaks(int habitID) async {
    final database = await _db.database;
    
    final result = await database.rawQuery('''
      SELECT DISTINCT DATE(Date) as date
      FROM Habit_Records
      WHERE HabitID = ? AND Status = 'done'
      ORDER BY date DESC
    ''', [habitID]);
    
    if (result.isEmpty) {
      return {'current': 0, 'longest': 0};
    }
    
    final dates = result.map((r) => DateTime.parse(r['date'] as String)).toList();
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if streak is current
    if (dates.first.year == today.year && 
        dates.first.month == today.month && 
        dates.first.day == today.day) {
      currentStreak = 1;
    } else if (dates.first.year == yesterday.year && 
               dates.first.month == yesterday.month && 
               dates.first.day == yesterday.day) {
      currentStreak = 1;
    }
    
    // Calculate streaks
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      
      if (diff == 1) {
        tempStreak++;
        if (i == 0 || currentStreak > 0) {
          currentStreak = tempStreak;
        }
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    return {'current': currentStreak, 'longest': longestStreak};
  }
}
