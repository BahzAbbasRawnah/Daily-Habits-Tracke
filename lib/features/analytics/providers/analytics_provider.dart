import 'package:flutter/material.dart';
import 'package:daily_habits/features/analytics/models/analytics_model.dart';
import 'package:daily_habits/features/analytics/repositories/analytics_repository.dart';

/// Provider for analytics data
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository = AnalyticsRepository();
  
  AnalyticsData _analyticsData = AnalyticsData.empty();
  List<HabitStats> _habitStats = [];
  bool _isLoading = false;
  String? _error;
  int _selectedPeriod = 30; // days

  AnalyticsData get analyticsData => _analyticsData;
  List<HabitStats> get habitStats => _habitStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedPeriod => _selectedPeriod;

  /// Load analytics data
  Future<void> loadAnalytics(int userID) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _analyticsData = await _repository.getAnalyticsData(
        userID,
        days: _selectedPeriod,
      );
      _habitStats = await _repository.getHabitStats(userID);
      
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('Error loading analytics: $e');
      Future.microtask(() => notifyListeners());
    }
  }

  /// Change selected period
  void changePeriod(int days, int userID) {
    _selectedPeriod = days;
    loadAnalytics(userID);
  }

  /// Refresh analytics data
  Future<void> refresh(int userID) async {
    await loadAnalytics(userID);
  }
}
