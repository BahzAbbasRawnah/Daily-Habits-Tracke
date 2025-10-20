import 'package:flutter/foundation.dart';
import '../models/habit_record_model.dart';
import '../repositories/habit_record_repository.dart';

class HabitRecordProvider extends ChangeNotifier {
  final HabitRecordRepository _repository = HabitRecordRepository();
  List<HabitRecord> _records = [];
  List<HabitRecord> _todayRecords = [];
  bool _isLoading = false;
  String? _error;

  List<HabitRecord> get records => _records;
  List<HabitRecord> get todayRecords => _todayRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecordsByHabit(int habitID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.getRecordsByHabit(habitID);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markHabitComplete(int habitID, int userID, DateTime date, {String? note}) async {
    try {
      final existingRecord = await _repository.getRecordByDate(habitID, date);
      
      if (existingRecord != null) {
        final updatedRecord = HabitRecord(
          recordID: existingRecord.recordID,
          habitID: habitID,
          userID: userID,
          date: date,
          progress: 1,
          status: 'done',
          note: note,
        );
        await _repository.updateRecord(updatedRecord);
      } else {
        final newRecord = HabitRecord(
          habitID: habitID,
          userID: userID,
          date: date,
          progress: 1,
          status: 'done',
          note: note,
        );
        await _repository.createRecord(newRecord);
      }
      
      await loadRecordsByHabit(habitID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markHabitMissed(int habitID, int userID, DateTime date) async {
    try {
      final existingRecord = await _repository.getRecordByDate(habitID, date);
      
      if (existingRecord != null) {
        final updatedRecord = HabitRecord(
          recordID: existingRecord.recordID,
          habitID: habitID,
          userID: userID,
          date: date,
          progress: 0,
          status: 'missed',
        );
        await _repository.updateRecord(updatedRecord);
      } else {
        final newRecord = HabitRecord(
          habitID: habitID,
          userID: userID,
          date: date,
          progress: 0,
          status: 'missed',
        );
        await _repository.createRecord(newRecord);
      }
      
      await loadRecordsByHabit(habitID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Load today's records for a specific user
  Future<void> loadTodayRecords(int userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      _todayRecords = await _repository.getRecordsByDateRange(userID, startOfDay, startOfDay);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get today's record for a specific habit
  HabitRecord? getTodayRecord(int habitID) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    try {
      return _todayRecords.firstWhere(
        (record) => 
          record.habitID == habitID && 
          record.date.year == startOfDay.year &&
          record.date.month == startOfDay.month &&
          record.date.day == startOfDay.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Create a new habit record
  Future<void> createRecord(HabitRecord record) async {
    try {
      await _repository.createRecord(record);
      
      // Refresh today's records if the record is for today
      final today = DateTime.now();
      final recordDate = record.date;
      if (recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day) {
        await loadTodayRecords(record.userID);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update an existing habit record
  Future<void> updateRecord(HabitRecord record) async {
    try {
      await _repository.updateRecord(record);
      
      // Refresh today's records if the record is for today
      final today = DateTime.now();
      final recordDate = record.date;
      if (recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day) {
        await loadTodayRecords(record.userID);
      }
      
      // Also refresh the habit-specific records if they're loaded
      if (_records.isNotEmpty && _records.first.habitID == record.habitID) {
        await loadRecordsByHabit(record.habitID);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}