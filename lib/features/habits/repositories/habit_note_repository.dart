import 'package:sqflite/sqflite.dart';
import '../../../core/database/habit_database_service.dart';
import '../models/habit_note_model.dart';

/// Repository for habit notes CRUD operations
class HabitNoteRepository {
  final HabitDatabaseService _dbService = HabitDatabaseService();

  /// Get all notes for a specific habit
  Future<List<HabitNote>> getNotes(String habitId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Habit_Notes',
        where: 'habit_id = ?',
        whereArgs: [habitId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => HabitNote.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  /// Add a new note for a habit
  Future<HabitNote> addNote(String habitId, String content) async {
    try {
      final db = await _dbService.database;
      final note = HabitNote(
        habitId: habitId,
        content: content,
      );

      await db.insert(
        'Habit_Notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return note;
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  /// Update an existing note
  Future<void> updateNote(String noteId, String content) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'Habit_Notes',
        {
          'content': content,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'Habit_Notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Get a single note by ID
  Future<HabitNote?> getNoteById(String noteId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Habit_Notes',
        where: 'id = ?',
        whereArgs: [noteId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return HabitNote.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load note: $e');
    }
  }

  /// Delete all notes for a habit
  Future<void> deleteAllNotesForHabit(String habitId) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'Habit_Notes',
        where: 'habit_id = ?',
        whereArgs: [habitId],
      );
    } catch (e) {
      throw Exception('Failed to delete notes: $e');
    }
  }
}
