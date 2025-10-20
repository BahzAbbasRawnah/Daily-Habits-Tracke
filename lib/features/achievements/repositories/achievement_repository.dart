// COMPLETE FIXED VERSION OF achievement_repository.dart
// Replace the entire content of lib/features/achievements/repositories/achievement_repository.dart with this:

import 'package:daily_habits/core/database/habit_database_service.dart';
import 'package:daily_habits/features/achievements/models/achievement_model.dart';

/// Repository for achievements
class AchievementRepository {
  final HabitDatabaseService _db = HabitDatabaseService();

  /// Get all achievements with current progress
  Future<List<Achievement>> getAchievements(int userID) async {
    final database = await _db.database;
    
    // Get user stats
    final stats = await _getUserStats(userID);
    
    // Get achievement definitions from database
    final achievementDefs = await database.query('Achievement_Definitions');
    
    // If no achievements in database, return empty list
    if (achievementDefs.isEmpty) {
      return [];
    }
    
    // Get user's achievement progress
    final userAchievements = await database.query(
      'User_Achievements',
      where: 'UserID = ?',
      whereArgs: [userID],
    );
    
    // Create map of user progress
    final progressMap = <String, Map<String, dynamic>>{};
    for (final ua in userAchievements) {
      progressMap[ua['AchievementDefID'] as String] = ua;
    }
    
    final achievements = <Achievement>[];
    
    // Process each achievement definition
    for (final def in achievementDefs) {
      final achievementId = def['AchievementDefID'] as String;
      final title = def['Title'] as String;
      final description = def['Description'] as String;
      final icon = def['Icon'] as String;
      final typeStr = def['Type'] as String;
      final target = def['Target'] as int;
      final color = def['Color'] as String;
      
      // Calculate current progress based on type
      int currentProgress = 0;
      bool isUnlocked = false;
      DateTime? unlockedAt;
      
      // Check if user has existing progress
      if (progressMap.containsKey(achievementId)) {
        currentProgress = progressMap[achievementId]!['CurrentProgress'] as int;
        isUnlocked = (progressMap[achievementId]!['IsUnlocked'] as int) == 1;
        final unlockedAtStr = progressMap[achievementId]!['UnlockedAt'] as String?;
        unlockedAt = unlockedAtStr != null ? DateTime.parse(unlockedAtStr) : null;
      } else {
        // Calculate progress from stats
        switch (typeStr) {
          case 'streak':
            currentProgress = stats['currentStreak'] ?? 0;
            break;
          case 'completion':
            currentProgress = stats['totalCompletions'] ?? 0;
            break;
          case 'perfect':
            currentProgress = stats['perfectDays'] ?? 0;
            break;
          case 'habits':
            currentProgress = stats['activeHabits'] ?? 0;
            break;
        }
        
        // Check if unlocked
        isUnlocked = currentProgress >= target;
        if (isUnlocked) {
          unlockedAt = DateTime.now();
        }
      }
      
      // Convert type string to enum
      AchievementType type;
      switch (typeStr) {
        case 'streak':
          type = AchievementType.streak;
          break;
        case 'completion':
          type = AchievementType.completion;
          break;
        case 'perfect':
          type = AchievementType.perfect;
          break;
        case 'habits':
          type = AchievementType.habits;
          break;
        case 'category':
          type = AchievementType.category;
          break;
        default:
          type = AchievementType.streak;
      }
      
      // Create Achievement object
      achievements.add(Achievement(
        id: achievementId,
        title: title,
        description: description,
        icon: icon,
        type: type,
        target: target,
        current: currentProgress,
        isUnlocked: isUnlocked,
        unlockedAt: unlockedAt,
        color: color,
      ));
    }
    
    return achievements;
  }

  /// Get user statistics for achievements
  Future<Map<String, int>> _getUserStats(int userID) async {
    final database = await _db.database;
    
    // Get total completions
    final completionsResult = await database.rawQuery('''
      SELECT COUNT(*) as total
      FROM Habit_Records
      WHERE UserID = ? AND Status = 'done'
    ''', [userID]);
    
    final totalCompletions = completionsResult.first['total'] as int? ?? 0;
    
    // Get active habits count
    final habitsResult = await database.rawQuery('''
      SELECT COUNT(*) as total
      FROM Habits
      WHERE UserID = ? AND IsActive = 1
    ''', [userID]);
    
    final activeHabits = habitsResult.first['total'] as int? ?? 0;
    
    // Calculate streaks
    final streaks = await _calculateStreaks(userID);
    
    // Calculate perfect days
    final perfectDays = await _calculatePerfectDays(userID);
    
    return {
      'totalCompletions': totalCompletions,
      'activeHabits': activeHabits,
      'currentStreak': streaks['current'] ?? 0,
      'longestStreak': streaks['longest'] ?? 0,
      'perfectDays': perfectDays,
    };
  }

  /// Calculate current and longest streaks
  Future<Map<String, int>> _calculateStreaks(int userID) async {
    final database = await _db.database;
    
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

  /// Calculate perfect days (days where all habits were completed)
  Future<int> _calculatePerfectDays(int userID) async {
    final database = await _db.database;
    
    // Get days where completion rate was 100%
    final result = await database.rawQuery('''
      SELECT DATE(Date) as date,
             COUNT(*) as total,
             SUM(CASE WHEN Status = 'done' THEN 1 ELSE 0 END) as completed
      FROM Habit_Records
      WHERE UserID = ?
      GROUP BY DATE(Date)
      HAVING total = completed AND total > 0
    ''', [userID]);
    
    return result.length;
  }

  /// Check for newly unlocked achievements
  Future<List<Achievement>> checkNewAchievements(int userID, List<Achievement> previousAchievements) async {
    final currentAchievements = await getAchievements(userID);
    final newlyUnlocked = <Achievement>[];
    
    for (var current in currentAchievements) {
      if (current.isUnlocked) {
        final previous = previousAchievements.firstWhere(
          (a) => a.id == current.id,
          orElse: () => current,
        );
        
        if (!previous.isUnlocked) {
          newlyUnlocked.add(current);
        }
      }
    }
    
    return newlyUnlocked;
  }
}
