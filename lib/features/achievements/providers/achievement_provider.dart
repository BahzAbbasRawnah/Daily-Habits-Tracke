import 'package:flutter/material.dart';
import 'package:daily_habits/features/achievements/models/achievement_model.dart';
import 'package:daily_habits/features/achievements/repositories/achievement_repository.dart';

/// Provider for achievements
class AchievementProvider extends ChangeNotifier {
  final AchievementRepository _repository = AchievementRepository();
  
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlocked = [];
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();
  List<Achievement> get newlyUnlocked => _newlyUnlocked;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get totalAchievements => _achievements.length;
  int get unlockedCount => unlockedAchievements.length;
  double get completionPercentage => totalAchievements > 0 
      ? (unlockedCount / totalAchievements) * 100 
      : 0.0;

  /// Load achievements
  Future<void> loadAchievements(int userID) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final previousAchievements = List<Achievement>.from(_achievements);
      _achievements = await _repository.getAchievements(userID);
      
      // Check for newly unlocked achievements
      if (previousAchievements.isNotEmpty) {
        _newlyUnlocked = await _repository.checkNewAchievements(
          userID,
          previousAchievements,
        );
      }
      
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('Error loading achievements: $e');
      Future.microtask(() => notifyListeners());
    }
  }

  /// Clear newly unlocked achievements
  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
    notifyListeners();
  }

  /// Refresh achievements
  Future<void> refresh(int userID) async {
    await loadAchievements(userID);
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }
}
