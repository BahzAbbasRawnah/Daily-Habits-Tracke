# 🔔 Notification Testing Guide

## ✅ What I Fixed

1. **Enhanced notification importance** to `Importance.max` and `Priority.max`
2. **Added BigTextStyleInformation** for better visibility
3. **Added ticker** for notification preview
4. **Hardcoded Arabic action buttons** ("تم الإنجاز", "غفوة")
5. **Improved test notification** with all features

## 🧪 How to Test Notifications

### Method 1: Test Notification (Immediate)

Add this temporary code to test notifications immediately:

**In `add_edit_habit_screen.dart`, add a test button:**

```dart
// Add this in the build method, maybe in the app bar actions
IconButton(
  icon: Icon(Icons.notifications_active),
  onPressed: () async {
    final notificationService = NotificationService();
    await notificationService.showTestNotification('Test Habit', 999);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test notification sent!')),
    );
  },
)
```

### Method 2: Schedule Real Reminder (2 Minutes)

1. **Create a new habit**
2. **Add a reminder** for **2 minutes from now**
   - Example: If it's 8:00 PM, set reminder for 8:02 PM
3. **Save the habit**
4. **Watch console** for:
   ```
   🕐 Current time: 2025-10-24 20:00:00
   ⏰ Scheduled time: 2025-10-24 20:02:00
   ⏱️ Time until notification: 2 minutes
   ✅ Scheduled reminder for Test at 2025-10-24 20:02:00 (ID: XXXX)
   ✅ Verified: Notification is in pending list
   ```
5. **Close the app** completely (swipe away from recents)
6. **Wait 2 minutes**
7. **Notification should appear!** 🔔

## 📱 Expected Notification Appearance

### On Android:

**Notification will show:**
- **Title**: Habit name (e.g., "منبه")
- **Message**: "حان وقت العمل على منبه!" (Time to work on your habit!)
- **Icon**: App icon
- **Sound**: ✅ Plays
- **Vibration**: ✅ Vibrates
- **LED**: ✅ Lights up (if device supports)
- **Action Buttons**:
  - **"تم الإنجاز"** (Mark Done) - Marks habit as completed
  - **"غفوة"** (Snooze) - Delays reminder by 10 minutes

### Visual Example:
```
┌─────────────────────────────────────┐
│ 🔔 Habits Tracker        8:02 PM    │
├─────────────────────────────────────┤
│ منبه                                │
│ حان وقت العمل على منبه!            │
│                                     │
│ [تم الإنجاز]  [غفوة]               │
└─────────────────────────────────────┘
```

## 🔍 Troubleshooting

### Issue 1: No Notification Appears

**Check Console:**
```
✅ Scheduled reminder for [habit] at [time] (ID: XXXX)
✅ Verified: Notification is in pending list
```

If you see these messages, the notification IS scheduled. If it doesn't appear:

1. **Check Do Not Disturb**: Make sure DND is OFF
2. **Check Battery Optimization**: 
   - Settings → Apps → Habits Tracker → Battery → Unrestricted
3. **Check Notification Settings**:
   - Settings → Apps → Habits Tracker → Notifications → Enabled
4. **Check Exact Alarm Permission**:
   - Settings → Apps → Habits Tracker → Alarms & reminders → Enabled

### Issue 2: Notification Appears But No Sound

1. **Long-press notification**
2. **Tap "All categories"**
3. **Find "Habit Reminders"**
4. **Enable Sound and Vibration**

### Issue 3: Notification Appears But No Action Buttons

This is normal on some Android versions. The notification will still show, just without the action buttons.

### Issue 4: Scheduled Time is in the Past

Console will show:
```
⚠️ Scheduled time is in the past! Adjusting to next occurrence...
```

**Solution**: Make sure you set the reminder time in the future!

## 🎯 Quick Test Checklist

- [ ] Permissions granted (Notification + Exact Alarm)
- [ ] Create habit with reminder 2 minutes in future
- [ ] Console shows "✅ Verified: Notification is in pending list"
- [ ] Close app completely
- [ ] Wait for scheduled time
- [ ] Notification appears with sound/vibration
- [ ] Action buttons visible and working

## 📊 Console Output to Verify

### When Creating Reminder:
```
📱 Notification: true, ⏰ Exact Alarm: true
🕐 Current time: 2025-10-24 20:00:00.000+0300
⏰ Scheduled time: 2025-10-24 20:02:00.000+0300
⏱️ Time until notification: 2 minutes
✅ Scheduled reminder for منبه at 2025-10-24 20:02:00.000+0300 (ID: 6000)
✅ Verified: Notification is in pending list
```

### When Notification Triggers (if app is open):
```
📢 Notification received: habitId|reminderId|habitName
```

## 🚀 Next Steps

1. **Hot restart the app** to load the new notification code
2. **Test immediate notification** using the test button (if you add it)
3. **Test scheduled notification** by creating a habit with reminder 2 minutes away
4. **Share console output** if it doesn't work

## 💡 Tips

- **Test during daytime** when you're actively using the phone
- **Keep phone unlocked** for first test to see notification immediately
- **Check notification shade** - swipe down from top of screen
- **Don't use "Do Not Disturb" mode** during testing
- **Make sure app has all permissions** before testing

## 🎉 Success Indicators

✅ Console shows notification is scheduled
✅ Console shows notification is in pending list
✅ Notification appears at scheduled time
✅ Sound and vibration work
✅ Action buttons are visible
✅ Tapping "تم الإنجاز" marks habit as done
✅ Tapping "غفوة" delays reminder by 10 minutes

---

**If notifications still don't work after following this guide, please share:**
1. Complete console output when creating the reminder
2. Android version
3. Phone model
4. Any error messages
