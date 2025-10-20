import 'package:flutter/foundation.dart';
import '../models/habit_note_model.dart';
import '../repositories/habit_note_repository.dart';

/// Provider for managing habit notes
class HabitNoteProvider with ChangeNotifier {
  final HabitNoteRepository _repository = HabitNoteRepository();
  
  List<HabitNote> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<HabitNote> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load notes for a specific habit
  Future<void> loadNotes(String habitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _repository.getNotes(habitId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new note
  Future<HabitNote?> addNote(String habitId, String content) async {
    try {
      final note = await _repository.addNote(habitId, content);
      _notes.insert(0, note); // Add to beginning (newest first)
      notifyListeners();
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update an existing note
  Future<bool> updateNote(String noteId, String content) async {
    try {
      await _repository.updateNote(noteId, content);
      
      // Update local list
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
      await _repository.deleteNote(noteId);
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get note count for a habit
  int getNoteCount(String habitId) {
    return _notes.where((n) => n.habitId == habitId).length;
  }
}
