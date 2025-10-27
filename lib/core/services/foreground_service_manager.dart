import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages the foreground service for background notifications
class ForegroundServiceManager {
  static const MethodChannel _channel =
      MethodChannel('daily_habits/foreground_service');

  /// Start the foreground service to keep notifications working
  static Future<void> startService() async {
    try {
      await _channel.invokeMethod('startForegroundService');
      debugPrint('✅ Foreground service started');
    } catch (e) {
      debugPrint('❌ Error starting foreground service: $e');
    }
  }

  /// Stop the foreground service
  static Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
      debugPrint('✅ Foreground service stopped');
    } catch (e) {
      debugPrint('❌ Error stopping foreground service: $e');
    }
  }

  /// Check if the foreground service is running
  static Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isForegroundServiceRunning');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('❌ Error checking foreground service status: $e');
      return false;
    }
  }
}
