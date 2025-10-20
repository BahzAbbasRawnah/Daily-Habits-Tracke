import 'package:flutter/material.dart';
import 'package:daily_habits/features/habits/models/user_model.dart';
import 'package:daily_habits/core/database/habit_database_service.dart';

/// Provider to manage user data
class UserProvider extends ChangeNotifier {
  final HabitDatabaseService _db = HabitDatabaseService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  int? _currentUserId = 1; // Default user ID

  /// Get the current user
  User? get user => _user;

  /// Check if the user is loading
  bool get isLoading => _isLoading;

  /// Get the error message
  String? get error => _error;

  /// Check if the user is logged in
  bool get isLoggedIn => _user != null;

  /// Get current user ID
  int? get currentUserId => _currentUserId;

  /// Set the current user
  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  /// Clear the current user
  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Set the error message
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear the error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetch the user data from database
  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUserId == null) {
        throw Exception('No user ID set');
      }

      final database = await _db.database;
      final userMaps = await database.query(
        'Users',
        where: 'UserID = ?',
        whereArgs: [_currentUserId],
      );

      if (userMaps.isEmpty) {
        throw Exception('User not found');
      }

      _user = User.fromMap(userMaps.first);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error fetching user: $e');
    }
  }

  /// Set current user ID
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /// Update the user data
  Future<bool> updateUser({
    String? name,
    String? email,
  }) async {
    if (_user == null || _user!.userID == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      // Update user in database
      await database.update(
        'Users',
        {
          'Name': name ?? _user!.name,
          'Email': email ?? _user!.email,
          'UpdatedAt': DateTime.now().toIso8601String(),
        },
        where: 'UserID = ?',
        whereArgs: [_user!.userID],
      );

      // Refresh user data
      await fetchUser();

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  /// Update user language preference
  Future<bool> updateLanguage(String language) async {
    if (_user == null || _user!.userID == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      await database.update(
        'Users',
        {
          'Language': language,
          'UpdatedAt': DateTime.now().toIso8601String(),
        },
        where: 'UserID = ?',
        whereArgs: [_user!.userID],
      );

      // Refresh user data
      await fetchUser();

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating language: $e');
      return false;
    }
  }

  /// Update user theme preference
  Future<bool> updateTheme(String theme) async {
    if (_user == null || _user!.userID == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      await database.update(
        'Users',
        {
          'Theme': theme,
          'UpdatedAt': DateTime.now().toIso8601String(),
        },
        where: 'UserID = ?',
        whereArgs: [_user!.userID],
      );

      // Refresh user data
      await fetchUser();

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating theme: $e');
      return false;
    }
  }
}