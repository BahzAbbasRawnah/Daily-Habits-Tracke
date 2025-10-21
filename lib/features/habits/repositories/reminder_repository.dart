import 'package:daily_habits/core/database/habit_database_service.dart';
import '../models/reminder_model.dart';

/// Repository for managing reminders in the database
class ReminderRepository {
  final HabitDatabaseService _db = HabitDatabaseService();

  /// Get all reminders for a specific habit
  Future<List<HabitReminder>> getRemindersByHabit(int habitID) async {
    final database = await _db.database;
    final results = await database.query(
      'Reminders',
      where: 'HabitID = ?',
      whereArgs: [habitID],
      orderBy: 'Time ASC',
    );
    return results.map((map) => HabitReminder.fromMap(map)).toList();
  }

  /// Get all reminders for all habits (with habit details)
  Future<List<Map<String, dynamic>>> getAllRemindersWithHabits() async {
    final database = await _db.database;
    return await database.rawQuery('''
      SELECT 
        r.ReminderID,
        r.HabitID,
        r.Time,
        r.Weekdays,
        r.IsActive,
        r.IsRecurring,
        r.ScheduledDate,
        r.SnoozeMinutes,
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
  Future<List<HabitReminder>> getEnabledReminders() async {
    final database = await _db.database;
    final results = await database.query(
      'Reminders',
      where: 'IsActive = 1',
      orderBy: 'Time ASC',
    );
    return results.map((map) => HabitReminder.fromMap(map)).toList();
  }

  /// Create a new reminder
  Future<int> createReminder(HabitReminder reminder) async {
    final database = await _db.database;
    return await database.insert('Reminders', reminder.toMap());
  }

  /// Update a reminder
  Future<int> updateReminder(HabitReminder reminder) async {
    final database = await _db.database;
    return await database.update(
      'Reminders',
      reminder.toMap(),
      where: 'ReminderID = ?',
      whereArgs: [reminder.reminderID],
    );
  }

  /// Toggle reminder enabled status
  Future<int> toggleReminderStatus(int reminderID, bool isActive) async {
    final database = await _db.database;
    return await database.update(
      'Reminders',
      {'IsActive': isActive ? 1 : 0},
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
  Future<HabitReminder?> getReminderById(int reminderID) async {
    final database = await _db.database;
    final results = await database.query(
      'Reminders',
      where: 'ReminderID = ?',
      whereArgs: [reminderID],
    );
    return results.isNotEmpty ? HabitReminder.fromMap(results.first) : null;
  }

  /// Get reminders for today (based on day of week)
  Future<List<HabitReminder>> getTodayReminders() async {
    final database = await _db.database;
    final dayOfWeek = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final results = await database.rawQuery('''
      SELECT r.*
      FROM Reminders r
      INNER JOIN Habits h ON r.HabitID = h.HabitID
      WHERE r.IsActive = 1 
        AND h.IsActive = 1
        AND (
          (r.IsRecurring = 1 AND (r.Weekdays IS NULL OR r.Weekdays LIKE '%$dayOfWeek%'))
          OR (r.IsRecurring = 0 AND DATE(r.ScheduledDate) = '$todayStr')
        )
      ORDER BY r.Time ASC
    ''');
    
    return results.map((map) => HabitReminder.fromMap(map)).toList();
  }
  
  /// Get all active reminders
  Future<List<HabitReminder>> getAllActiveReminders() async {
    final database = await _db.database;
    final results = await database.query(
      'Reminders',
      where: 'IsActive = 1',
      orderBy: 'Time ASC',
    );
    return results.map((map) => HabitReminder.fromMap(map)).toList();
  }
}
