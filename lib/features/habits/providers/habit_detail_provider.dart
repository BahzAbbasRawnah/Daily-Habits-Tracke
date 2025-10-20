import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';
import '../models/habit_note_model.dart';
import '../repositories/habit_repository.dart';
import '../repositories/habit_record_repository.dart';
import '../repositories/habit_note_repository.dart';
import 'package:intl/intl.dart';

/// Comprehensive provider for habit detail screen
class HabitDetailProvider with ChangeNotifier {
  final HabitRepository _habitRepository = HabitRepository();
  final HabitRecordRepository _recordRepository = HabitRecordRepository();
  final HabitNoteRepository _noteRepository = HabitNoteRepository();

  Habit? _habit;
  List<HabitRecord> _records = [];
  List<HabitNote> _notes = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _isLoading = false;
  String? _error;
  
  // Undo state
  DateTime? _undoDeadline;

  Habit? get habit => _habit;
  List<HabitRecord> get records => _records;
  List<HabitNote> get notes => _notes;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canUndo => _undoDeadline != null && DateTime.now().isBefore(_undoDeadline!);

  /// Load all habit details
  Future<void> loadHabitDetails(int habitId, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load habit
      _habit = await _habitRepository.getHabitById(habitId);
      
      if (_habit == null) {
        throw Exception('Habit not found');
      }

      // Load records for last 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      _records = await _recordRepository.getRecords(habitId, startDate, endDate);

      // Load notes
      _notes = await _noteRepository.getNotes(habitId.toString());

      // Calculate streaks
      _currentStreak = await _recordRepository.getCurrentStreak(habitId);
      _bestStreak = await _recordRepository.getBestStreak(habitId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark habit as completed for today
  Future<bool> markCompletedToday(int userId, {String? noteContent}) async {
    if (_habit == null) return false;

    try {
      final today = DateTime.now();
      String? noteId;

      // Create note if content provided
      if (noteContent != null && noteContent.isNotEmpty) {
        final note = await _noteRepository.addNote(
          _habit!.habitID.toString(),
          noteContent,
        );
        noteId = note.id;
        _notes.insert(0, note);
      }

      // Mark as completed with transaction
      await _recordRepository.markCompleted(
        _habit!.habitID!,
        userId,
        today,
        noteId: noteId,
      );

      // Reload data
      await _refreshData(userId);

      // Set undo deadline (5 seconds)
      _undoDeadline = DateTime.now().add(const Duration(seconds: 5));
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Undo last completion
  Future<bool> undoCompletion(int userId) async {
    if (_habit == null || !canUndo) return false;

    try {
      final today = DateTime.now();
      await _recordRepository.unmarkCompleted(_habit!.habitID!, today);

      // Reload data
      await _refreshData(userId);

      _undoDeadline = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Check if habit is completed today
  bool isCompletedToday() {
    if (_records.isEmpty) return false;
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _records.any((r) => 
      r.date.toIso8601String().split('T')[0] == today && 
      r.status == 'done'
    );
  }

  /// Get completion rate for a period
  double getCompletionRate(int days) {
    if (_records.isEmpty) return 0.0;

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final relevantRecords = _records.where((r) => 
      r.date.isAfter(startDate) || r.date.isAtSameMomentAs(startDate)
    ).toList();

    if (relevantRecords.isEmpty) return 0.0;

    final completedCount = relevantRecords.where((r) => r.status == 'done').length;
    return (completedCount / relevantRecords.length) * 100;
  }

  /// Get weekly chart data (last 7 days)
  List<ChartData> getWeeklyChartData() {
    final List<ChartData> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('E').format(date);

      final record = _records.firstWhere(
        (r) => r.date.toIso8601String().split('T')[0] == dateStr,
        orElse: () => HabitRecord(
          habitID: _habit?.habitID ?? 0,
          userID: 1,
          date: date,
          status: 'missed',
          progress: 0,
        ),
      );

      data.add(ChartData(
        day: dayName,
        value: record.status == 'done' ? 1.0 : 0.0,
        date: date,
      ));
    }

    return data;
  }

  /// Get monthly chart data (last 30 days)
  List<ChartData> getMonthlyChartData() {
    final List<ChartData> data = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('d').format(date);

      final record = _records.firstWhere(
        (r) => r.date.toIso8601String().split('T')[0] == dateStr,
        orElse: () => HabitRecord(
          habitID: _habit?.habitID ?? 0,
          userID: 1,
          date: date,
          status: 'missed',
          progress: 0,
        ),
      );

      data.add(ChartData(
        day: dayLabel,
        value: record.status == 'done' ? 1.0 : 0.0,
        date: date,
      ));
    }

    return data;
  }

  /// Add a note
  Future<bool> addNote(String content) async {
    if (_habit == null) return false;

    try {
      final note = await _noteRepository.addNote(
        _habit!.habitID.toString(),
        content,
      );
      _notes.insert(0, note);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update a note
  Future<bool> updateNote(String noteId, String content) async {
    try {
      await _noteRepository.updateNote(noteId, content);
      
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      await _noteRepository.deleteNote(noteId);
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh data after changes
  Future<void> _refreshData(int userId) async {
    if (_habit == null) return;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    _records = await _recordRepository.getRecords(_habit!.habitID!, startDate, endDate);
    _currentStreak = await _recordRepository.getCurrentStreak(_habit!.habitID!);
    _bestStreak = await _recordRepository.getBestStreak(_habit!.habitID!);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear undo deadline
  void clearUndo() {
    _undoDeadline = null;
    notifyListeners();
  }
}

/// Chart data model
class ChartData {
  final String day;
  final double value;
  final DateTime date;

  ChartData({
    required this.day,
    required this.value,
    required this.date,
  });
}
