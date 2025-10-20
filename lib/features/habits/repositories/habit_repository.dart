import '../models/habit_model.dart';
import '../../../core/database/habit_database_service.dart';

abstract class HabitRepositoryInterface {
  Future<List<Habit>> getAllHabits(int userID);
  Future<Habit?> getHabitById(int habitID);
  Future<int> createHabit(Habit habit);
  Future<int> updateHabit(Habit habit);
  Future<int> deleteHabit(int habitID);
  Future<List<Habit>> getActiveHabits(int userID);
}

class HabitRepository implements HabitRepositoryInterface {
  final HabitDatabaseService _db = HabitDatabaseService();

  @override
  Future<List<Habit>> getAllHabits(int userID) async {
    final database = await _db.database;
    final maps = await database.query(
      'Habits',
      where: 'UserID = ?',
      whereArgs: [userID],
      orderBy: 'CreatedAt DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  @override
  Future<Habit?> getHabitById(int habitID) async {
    final database = await _db.database;
    final maps = await database.query(
      'Habits',
      where: 'HabitID = ?',
      whereArgs: [habitID],
      limit: 1,
    );
    return maps.isNotEmpty ? Habit.fromMap(maps.first) : null;
  }

  @override
  Future<int> createHabit(Habit habit) async {
    final database = await _db.database;
    return await database.insert('Habits', habit.toMap());
  }

  @override
  Future<int> updateHabit(Habit habit) async {
    final database = await _db.database;
    return await database.update(
      'Habits',
      habit.toMap(),
      where: 'HabitID = ?',
      whereArgs: [habit.habitID],
    );
  }

  @override
  Future<int> deleteHabit(int habitID) async {
    final database = await _db.database;
    return await database.delete(
      'Habits',
      where: 'HabitID = ?',
      whereArgs: [habitID],
    );
  }

  @override
  Future<List<Habit>> getActiveHabits(int userID) async {
    final database = await _db.database;
    final maps = await database.query(
      'Habits',
      where: 'UserID = ? AND IsActive = 1',
      whereArgs: [userID],
      orderBy: 'CreatedAt DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }
}