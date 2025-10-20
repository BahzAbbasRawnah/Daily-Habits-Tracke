import 'package:sqflite/sqflite.dart';
import '../models/habit_record_model.dart';
import '../../../core/database/habit_database_service.dart';
import 'package:intl/intl.dart';

abstract class HabitRecordRepositoryInterface {
  Future<List<HabitRecord>> getRecordsByHabit(int habitID);
  Future<HabitRecord?> getRecordByDate(int habitID, DateTime date);
  Future<int> createRecord(HabitRecord record);
  Future<int> updateRecord(HabitRecord record);
  Future<int> deleteRecord(int recordID);
  Future<List<HabitRecord>> getRecordsByDateRange(int userID, DateTime start, DateTime end);
  Future<void> markCompleted(int habitID, int userID, DateTime date, {String? noteId});
  Future<void> unmarkCompleted(int habitID, DateTime date);
  Future<List<HabitRecord>> getRecords(int habitID, DateTime rangeStart, DateTime rangeEnd);
}

class HabitRecordRepository implements HabitRecordRepositoryInterface {
  final HabitDatabaseService _db = HabitDatabaseService();

  @override
  Future<List<HabitRecord>> getRecordsByHabit(int habitID) async {
    final database = await _db.database;
    final maps = await database.query(
      'Habit_Records',
      where: 'HabitID = ?',
      whereArgs: [habitID],
      orderBy: 'Date DESC',
    );
    return maps.map((map) => HabitRecord.fromMap(map)).toList();
  }

  @override
  Future<HabitRecord?> getRecordByDate(int habitID, DateTime date) async {
    final database = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await database.query(
      'Habit_Records',
      where: 'HabitID = ? AND Date = ?',
      whereArgs: [habitID, dateStr],
      limit: 1,
    );
    return maps.isNotEmpty ? HabitRecord.fromMap(maps.first) : null;
  }

  @override
  Future<int> createRecord(HabitRecord record) async {
    final database = await _db.database;
    return await database.insert('Habit_Records', record.toMap());
  }

  @override
  Future<int> updateRecord(HabitRecord record) async {
    final database = await _db.database;
    return await database.update(
      'Habit_Records',
      record.toMap(),
      where: 'RecordID = ?',
      whereArgs: [record.recordID],
    );
  }

  @override
  Future<int> deleteRecord(int recordID) async {
    final database = await _db.database;
    return await database.delete(
      'Habit_Records',
      where: 'RecordID = ?',
      whereArgs: [recordID],
    );
  }

  @override
  Future<List<HabitRecord>> getRecordsByDateRange(int userID, DateTime start, DateTime end) async {
    final database = await _db.database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final maps = await database.query(
      'Habit_Records',
      where: 'UserID = ? AND Date BETWEEN ? AND ?',
      whereArgs: [userID, startStr, endStr],
      orderBy: 'Date DESC',
    );
    return maps.map((map) => HabitRecord.fromMap(map)).toList();
  }

  @override
  Future<void> markCompleted(int habitID, int userID, DateTime date, {String? noteId}) async {
    final database = await _db.database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    // Use transaction to ensure atomicity
    await database.transaction((txn) async {
      // Check if record exists
      final existing = await txn.query(
        'Habit_Records',
        where: 'HabitID = ? AND Date = ?',
        whereArgs: [habitID, dateStr],
        limit: 1,
      );

      final recordData = {
        'HabitID': habitID,
        'UserID': userID,
        'Date': dateStr,
        'Status': 'done',
        'Progress': 100,
        'Timestamp': DateTime.now().millisecondsSinceEpoch,
        'NoteID': noteId,
      };

      if (existing.isEmpty) {
        // Insert new record
        await txn.insert(
          'Habit_Records',
          recordData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        // Update existing record
        await txn.update(
          'Habit_Records',
          recordData,
          where: 'HabitID = ? AND Date = ?',
          whereArgs: [habitID, dateStr],
        );
      }
    });
  }

  @override
  Future<void> unmarkCompleted(int habitID, DateTime date) async {
    final database = await _db.database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    await database.update(
      'Habit_Records',
      {
        'Status': 'missed',
        'Progress': 0,
        'Timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'HabitID = ? AND Date = ?',
      whereArgs: [habitID, dateStr],
    );
  }

  @override
  Future<List<HabitRecord>> getRecords(int habitID, DateTime rangeStart, DateTime rangeEnd) async {
    final database = await _db.database;
    final startStr = DateFormat('yyyy-MM-dd').format(rangeStart);
    final endStr = DateFormat('yyyy-MM-dd').format(rangeEnd);
    
    final maps = await database.query(
      'Habit_Records',
      where: 'HabitID = ? AND Date BETWEEN ? AND ?',
      whereArgs: [habitID, startStr, endStr],
      orderBy: 'Date DESC',
    );
    
    return maps.map((map) => HabitRecord.fromMap(map)).toList();
  }

  /// Calculate current streak for a habit
  Future<int> getCurrentStreak(int habitID) async {
    final database = await _db.database;
    final today = DateTime.now();
    int streak = 0;
    
    // Check backwards from today
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      
      final maps = await database.query(
        'Habit_Records',
        where: 'HabitID = ? AND Date = ? AND Status = ?',
        whereArgs: [habitID, dateStr, 'done'],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        break;
      }
      streak++;
    }
    
    return streak;
  }

  /// Calculate best streak for a habit
  Future<int> getBestStreak(int habitID) async {
    final database = await _db.database;
    final maps = await database.query(
      'Habit_Records',
      where: 'HabitID = ? AND Status = ?',
      whereArgs: [habitID, 'done'],
      orderBy: 'Date ASC',
    );
    
    if (maps.isEmpty) return 0;
    
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final map in maps) {
      final dateStr = map['Date'] as String;
      final date = DateTime.parse(dateStr);
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
          currentStreak = 1;
        }
      }
      
      lastDate = date;
    }
    
    return currentStreak > maxStreak ? currentStreak : maxStreak;
  }
}