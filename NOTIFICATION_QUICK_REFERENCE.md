# Notification System - Quick Reference

## 🎯 Essential Code

### Initialize Notifications
```dart
// In main.dart - already done!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final notificationManager = NotificationManager();
    await notificationManager.initialize();
  } catch (e) {
    debugPrint('Failed to initialize notifications: $e');
  }
  runApp(const MyApp());
}
```

### Send Test Notification
```dart
final notificationManager = NotificationManager();
await notificationManager.sendTestNotification();
```

### Schedule All Reminder Types
```dart
final notificationManager = NotificationManager();

// After user logs period (day 1 of cycle)
await notificationManager.schedulePeriodReminders(
  DateTime.now(),  // Period date
  28,              // Cycle length
);

// For fertile window (calculates automatically)
await notificationManager.scheduleFertileWindowReminders(
  DateTime.now(),  // Cycle start
  28,              // Cycle length
);

// For symptom tracking
await notificationManager.scheduleSymptomReminders(DateTime.now());
```

### Get FCM Token (for Backend)
```dart
final token = await notificationManager.getFcmToken();
// Send this token to your backend API
```

### Toggle Notification Types
```dart
// Enable
await notificationManager.setReminderEnabled('fertile_window', true);
await notificationManager.setReminderEnabled('symptom_log', true);
await notificationManager.setReminderEnabled('period_log', true);

// Disable
await notificationManager.setReminderEnabled('fertile_window', false);
```

### Add Settings UI to Your Screen
```dart
import 'package:fertipath/widgets/notification_preferences_widget.dart';

// In your settings/profile screen:
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // ... other settings
          
          NotificationPreferencesWidget(),
          
          // ... more settings
        ],
      ),
    );
  }
}
```

### Check Pending Reminders
```dart
final pending = await notificationManager.getPendingReminders();
for (final reminder in pending) {
  print('${reminder.type}: ${reminder.title}');
  print('Scheduled for: ${reminder.scheduledTime}');
}
```

### Get Current Settings
```dart
final settings = await notificationManager.getReminderSettings();
print('Fertile window enabled: ${settings['fertile_window']}');
print('Symptom log enabled: ${settings['symptom_log']}');
print('Period log enabled: ${settings['period_log']}');
```

### Cancel Specific Reminder
```dart
await notificationManager.cancelNotification(reminderId);
```

### Cancel All Reminders
```dart
await notificationManager.cancelAllNotifications();
```

## 📱 UI Component

### Add Notification Preferences
```dart
import 'package:fertipath/widgets/notification_preferences_widget.dart';

// Single line integration:
NotificationPreferencesWidget()

// Features included:
// - Toggle switches for each notification type
// - Test notification button
// - Helpful information section
// - Automatic settings persistence
```

## 🏗️ Files & Locations

| File | Purpose |
|------|---------|
| `lib/services/notification_manager.dart` | Main manager - use this! |
| `lib/services/local_notification_service.dart` | Local notifications |
| `lib/services/firebase_messaging_service.dart` | Cloud push notifications |
| `lib/services/notification_reminder_service.dart` | Reminder scheduling |
| `lib/widgets/notification_preferences_widget.dart` | Settings UI |
| `lib/examples/notification_usage_examples.dart` | Code examples |
| `NOTIFICATION_SETUP.md` | Complete setup guide |
| `NOTIFICATION_IMPLEMENTATION_CHECKLIST.md` | Implementation tracking |

## 🔑 Key Classes

### NotificationReminder
```dart
class NotificationReminder {
  final String id;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final String type; // 'fertile_window', 'symptom_log', 'period_log'
  bool isSent;
}
```

### NotificationManager API
```dart
class NotificationManager {
  // Lifecycle
  Future<void> initialize()
  
  // Scheduling
  Future<void> scheduleFertileWindowReminders(DateTime, int)
  Future<void> scheduleSymptomReminders(DateTime)
  Future<void> schedulePeriodReminders(DateTime, int)
  
  // Management
  Future<void> cancelNotification(String)
  Future<void> cancelAllNotifications()
  Future<List<NotificationReminder>> getPendingReminders()
  
  // Settings
  Future<void> setReminderEnabled(String, bool)
  Future<Map<String, dynamic>> getReminderSettings()
  
  // FCM
  Future<String?> getFcmToken()
  Future<void> subscribeToNotifications({...})
  Future<void> unsubscribeFromAllNotifications()
  
  // Testing
  Future<void> sendTestNotification()
}
```

## 🌍 Notification Topics (Backend)

Send FCM messages to these topics:

```
fertile_window_reminders
symptom_log_reminders
period_log_reminders
```

**Example from Firebase Console**:
1. Go to Cloud Messaging tab
2. Click "Send your first message"
3. Title: "Your Fertile Window Begins"
4. Body: "Your most fertile days are here!"
5. Target: Topic → `fertile_window_reminders`
6. Click Send

**Example from Backend**:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "message": {
      "topic": "fertile_window_reminders",
      "notification": {
        "title": "Your Fertile Window Begins",
        "body": "Your most fertile days are here!"
      }
    }
  }'
```

## 🔧 Configuration Files

### To Find
```
android/app/google-services.json       ← Add from Firebase
ios/Runner/GoogleService-Info.plist    ← Add from Firebase
android/app/src/main/AndroidManifest.xml ← Update with permissions
ios/Runner/Info.plist                  ← Update with capabilities
```

## 🚨 Common Errors

### "Firebase not initialized"
```dart
// Fix: Call initialize() before using
await notificationManager.initialize();
```

### "Notifications not appearing"
- Android: Check Settings → Apps → Fertipath → Notifications
- iOS: Check Settings → Fertipath → Notifications
- Both: Ensure app has internet

### "FCM token is null"
```dart
// May indicate Firebase initialization failed
// Check logcat/Xcode logs for Firebase errors
```

### "Permission denied"
- Android 13+: App shows permission request automatically
- If dismissed: Go to Settings → Apps → Fertipath → Notifications

## 📊 Default Reminder Times

**Fertile Window**: 8:00 AM daily during fertile window  
**Symptom Log**: 8:00 PM daily  
**Period Log**: 8:00 AM when period due  

Customize in `notification_reminder_service.dart`

## ✅ Pre-Launch Checklist

Before releasing:
```
☐ google-services.json added
☐ GoogleService-Info.plist added
☐ AndroidManifest.xml updated
☐ iOS capabilities enabled
☐ APNs certificate uploaded to Firebase
☐ NotificationPreferencesWidget integrated
☐ Test notifications work
☐ FCM messages tested
☐ All 3 notification types tested
☐ Background notifications tested
```

## 🎨 Customization

### Change Notification Color
In `local_notification_service.dart`:
```dart
AndroidNotificationDetails(
  color: Color(0xFF2E683D),  // Change this
)
```

### Change Reminder Times
In `notification_reminder_service.dart`:
```dart
// Morning reminder
scheduledTime: DateTime(
  fertileStart.year,
  fertileStart.month,
  fertileStart.day,
  8,  // Hour - change this (0-23)
  0,  // Minute
)
```

### Change Reminder Messages
In `notification_reminder_service.dart`:
```dart
NotificationReminder(
  title: 'Your Fertile Window Begins',  // Customize
  message: 'Your most fertile days...',  // Customize
)
```

## 🔗 Links

- [Complete Setup Guide](../NOTIFICATION_SETUP.md)
- [Implementation Checklist](../NOTIFICATION_IMPLEMENTATION_CHECKLIST.md)
- [Usage Examples](../lib/examples/notification_usage_examples.dart)
- [Notification README](NOTIFICATION_README.md)
- [Service Code](notification_manager.dart)

## 💡 Pro Tips

1. **Always call `initialize()` in main()**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await NotificationManager().initialize();
     runApp(MyApp());
   }
   ```

2. **Test notifications early in development**
   ```dart
   // Add test button during development
   ElevatedButton(
     onPressed: () => NotificationManager().sendTestNotification(),
     child: Text('Send Test'),
   )
   ```

3. **Check pending reminders for debugging**
   ```dart
   final pending = await NotificationManager().getPendingReminders();
   debugPrint('Pending: ${pending.map((r) => r.title).toList()}');
   ```

4. **FCM topics use underscores, not hyphens**
   ```dart
   // ✅ Correct
   await _fcmService.subscribeTopic('fertile_window_reminders');
   
   // ❌ Wrong
   await _fcmService.subscribeTopic('fertile-window-reminders');
   ```

5. **Settings persist automatically**
   ```dart
   // No need to manually save - stored in SharedPreferences
   await notificationManager.setReminderEnabled('fertile_window', false);
   ```

---

**Quick Ref Version**: 1.0  
**Status**: Ready to Use  
**Last Updated**: Phase 3 Complete
