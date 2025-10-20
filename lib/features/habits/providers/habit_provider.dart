import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHabits(int userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _repository.getAllHabits(userID);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _repository.createHabit(habit);
      await loadHabits(habit.userID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      await loadHabits(habit.userID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(int habitID, int userID) async {
    try {
      await _repository.deleteHabit(habitID);
      await loadHabits(userID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}