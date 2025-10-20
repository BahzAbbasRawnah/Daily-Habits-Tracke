import 'package:daily_habits/core/database/habit_database_service.dart';

/// Repository for managing reminders in the database
class ReminderRepository {
  final HabitDatabaseService _db = HabitDatabaseService();

  /// Get all reminders for a specific habit
  Future<List<Map<String, dynamic>>> getRemindersByHabit(int habitID) async {
    final database = await _db.database;
    return await database.query(
      'Reminders',
      where: 'HabitID = ?',
      whereArgs: [habitID],
      orderBy: 'Time ASC',
    );
  }

  /// Get all reminders for all habits (with habit details)
  Future<List<Map<String, dynamic>>> getAllRemindersWithHabits() async {
    final database = await _db.database;
    return await database.rawQuery('''
      SELECT 
        r.ReminderID,
        r.HabitID,
        r.Time,
        r.Days,
        r.Enabled,
        r.CreatedAt,
        h.Name as HabitName,
        h.Icon as HabitIcon,
        h.Color as HabitColor,
        h.IsActive as HabitIsActive
      FROM Reminders r
      INNER JOIN Habits h ON r.HabitID = h.HabitID
      WHERE h.IsActive = 1
      ORDER BY r.Time ASC
    ''');
  }

  /// Get enabled reminders only
  Future<List<Map<String, dynamic>>> getEnabledReminders() async {
    final database = await _db.database;
    return await database.rawQuery('''
      SELECT 
        r.ReminderID,
        r.HabitID,
        r.Time,
        r.Days,
        r.Enabled,
        r.CreatedAt,
        h.Name as HabitName,
        h.Icon as HabitIcon,
        h.Color as HabitColor
      FROM Reminders r
      INNER JOIN Habits h ON r.HabitID = h.HabitID
      WHERE r.Enabled = 1 AND h.IsActive = 1
      ORDER BY r.Time ASC
    ''');
  }

  /// Create a new reminder
  Future<int> createReminder(Map<String, dynamic> reminder) async {
    final database = await _db.database;
    return await database.insert('Reminders', reminder);
  }

  /// Update a reminder
  Future<int> updateReminder(int reminderID, Map<String, dynamic> reminder) async {
    final database = await _db.database;
    return await database.update(
      'Reminders',
      reminder,
      where: 'ReminderID = ?',
      whereArgs: [reminderID],
    );
  }

  /// Toggle reminder enabled status
  Future<int> toggleReminderStatus(int reminderID, bool enabled) async {
    final database = await _db.database;
    return await database.update(
      'Reminders',
      {'Enabled': enabled ? 1 : 0},
      where: 'ReminderID = ?',
      whereArgs: [reminderID],
    );
  }

  /// Delete a reminder
  Future<int> deleteReminder(int reminderID) async {
    final database = await _db.database;
    return await database.delete(
      'Reminders',
      where: 'ReminderID = ?',
      whereArgs: [reminderID],
    );
  }

  /// Delete all reminders for a habit
  Future<int> deleteRemindersByHabit(int habitID) async {
    final database = await _db.database;
    return await database.delete(
      'Reminders',
      where: 'HabitID = ?',
      whereArgs: [habitID],
    );
  }

  /// Get reminder by ID
  Future<Map<String, dynamic>?> getReminderById(int reminderID) async {
    final database = await _db.database;
    final results = await database.query(
      'Reminders',
      where: 'ReminderID = ?',
      whereArgs: [reminderID],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get reminders for today (based on day of week)
  Future<List<Map<String, dynamic>>> getTodayReminders() async {
    final database = await _db.database;
    final dayOfWeek = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    
    return await database.rawQuery('''
      SELECT 
        r.ReminderID,
        r.HabitID,
        r.Time,
        r.Days,
        r.Enabled,
        h.Name as HabitName,
        h.Icon as HabitIcon,
        h.Color as HabitColor
      FROM Reminders r
      INNER JOIN Habits h ON r.HabitID = h.HabitID
      WHERE r.Enabled = 1 
        AND h.IsActive = 1
        AND (r.Days IS NULL OR r.Days LIKE '%$dayOfWeek%')
      ORDER BY r.Time ASC
    ''');
  }
}
