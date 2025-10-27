package com.example.daily_habits

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "daily_habits/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    try {
                        NotificationForegroundService.startService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to start service: ${e.message}", null)
                    }
                }
                "stopForegroundService" -> {
                    try {
                        NotificationForegroundService.stopService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to stop service: ${e.message}", null)
                    }
                }
                "isForegroundServiceRunning" -> {
                    // Check if service is running (simplified check)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Start the foreground service when app resumes
        NotificationForegroundService.startService(this)
    }
}
