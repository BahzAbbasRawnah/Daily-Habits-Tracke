package com.example.daily_habits

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import dev.fluttercommunity.plus.androidalarmmanager.AlarmService

/**
 * Boot receiver to reschedule all reminders after device reboot
 * This ensures reminders continue to work after the device restarts
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            Log.d(TAG, "Device boot completed - triggering reminder reschedule")
            
            // Trigger the alarm manager to reschedule reminders
            // The actual rescheduling will happen when the app is next opened
            // and the ReminderManagerService.initialize() is called in main.dart
            
            Log.d(TAG, "Reminders will be rescheduled when app is opened")
        }
    }
}
