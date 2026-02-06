# Notification System Integration Map

This document shows where to add notification calls in your app screens.

## App Flow with Notifications

```
StartUp
  ↓
main.dart → NotificationManager.initialize() ✅ DONE
  ↓
MyApp
  ↓
LoginScreen / OnboardingScreen
  ↓
OnboardingFlow
  ├→ CycleInfoScreen
  │   └→ User enters cycle info
  │       └→ CALL: scheduleFertileWindowReminders()
  │
  └→ NotificationSetupScreen
      └→ User enables notifications
          └→ CALL: subscribeToNotifications()
          └→ CALL: setReminderEnabled()
  ↓
HomeScreen (Main App)
  ├→ PeriodLoggingButton/Screen
  │   └→ User logs period
  │       └→ CALL: schedulePeriodReminders()
  │
  ├→ SymptomTrackingButton/Screen
  │   └→ User starts symptom tracking
  │       └→ CALL: scheduleSymptomReminders()
  │
  └→ SettingsScreen
      └→ NotificationPreferencesWidget ✅ DONE
          ├→ Toggle fertile window notifications
          ├→ Toggle symptom reminders
          ├→ Toggle period reminders
          └→ Send test notification
```

## Screen-by-Screen Integration

### 1. Main App Initialization
```
✅ ALREADY DONE IN: lib/main.dart

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

### 2. Onboarding: Cycle Information Entry
```
📍 LOCATION: screens/onboarding/ or screens/setup/

class CycleSetupScreen extends StatelessWidget {
  void _onCycleInfoSubmitted({
    required DateTime cycleStartDate,
    required int cycleLength,
  }) async {
    // NEW CODE: Schedule fertility reminders
    final notificationManager = NotificationManager();
    
    try {
      await notificationManager.scheduleFertileWindowReminders(
        cycleStartDate,
        cycleLength,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cycle saved! Fertility reminders scheduled.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting reminders: $e')),
      );
    }
  }
}
```

### 3. Onboarding: Notification Setup
```
📍 LOCATION: Create new or add to existing onboarding

import 'package:fertipath/examples/notification_usage_examples.dart';

class NotificationSetupScreen extends Stateless {
  void _enableNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CycleSetupNotificationsExample(),
      ),
    );
  }
}
```

### 4. Home Screen: Period Logging
```
📍 LOCATION: screens/home/ or screens/cycle_tracking/

class HomeScreen extends StatelessWidget {
  void _logPeriod(DateTime periodDate, int cycleLength) async {
    final notificationManager = NotificationManager();
    
    try {
      // Schedule period reminders
      await notificationManager.schedulePeriodReminders(
        periodDate,
        cycleLength,
      );
      
      // Also schedule fertility window for this cycle
      await notificationManager.scheduleFertileWindowReminders(
        periodDate,
        cycleLength,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Period logged! Reminders updated.')),
      );
    } catch (e) {
      debugPrint('Error logging period: $e');
    }
  }
}
```

### 5. Home Screen: Symptom Tracking Start
```
📍 LOCATION: screens/symptoms/ or screens/tracking/

class SymptomLogScreen extends StatelessWidget {
  void _enableSymptomTracking() async {
    final notificationManager = NotificationManager();
    
    try {
      // Schedule daily symptom reminders
      await notificationManager.scheduleSymptomReminders(DateTime.now());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Symptom tracking enabled! Daily reminders set.'),
        ),
      );
    } catch (e) {
      debugPrint('Error enabling symptom tracking: $e');
    }
  }
}
```

### 6. Settings Screen: Notification Preferences
```
✅ ALREADY DONE: lib/widgets/notification_preferences_widget.dart

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // ... other settings ...
          
          // NEW: Add notification preferences
          NotificationPreferencesWidget(),
          
          // ... more settings ...
        ],
      ),
    );
  }
}
```

## Integration Checklist by Screen

### Onboarding/Setup Screens
- [ ] **Cycle Info Entry**: Call `scheduleFertileWindowReminders()`
- [ ] **Notification Setup**: Show `CycleSetupNotificationsExample` widget
- [ ] **Verification**: Confirm reminders appear in settings

### Main App Screens
- [ ] **Home Screen**: Add period logging trigger
  - [ ] Call `schedulePeriodReminders()` when period logged
  - [ ] Call `scheduleFertileWindowReminders()` for new cycle

- [ ] **Symptom Screen**: Add tracking start trigger
  - [ ] Call `scheduleSymptomReminders()` when tracking enabled

- [ ] **Settings Screen**: Add notification settings
  - [ ] Integrate `NotificationPreferencesWidget`
  - [ ] Verify all toggles work

### Backend Integration
- [ ] **Sync User Profile**: Send FCM token to backend
  ```dart
  final token = await notificationManager.getFcmToken();
  await sendTokenToBackend(userId: user.id, token: token);
  ```

- [ ] **Calendar/Sync Screen**: Offer to re-sync reminders
  ```dart
  void _syncReminders() async {
    // Clear old reminders
    await notificationManager.cancelAllNotifications();
    
    // Re-schedule with latest data
    await notificationManager.scheduleFertileWindowReminders(...);
    await notificationManager.scheduleSymptomReminders(...);
    await notificationManager.schedulePeriodReminders(...);
  }
  ```

## Code Templates

### Template 1: Period Logging with Notifications
```dart
Future<void> _handlePeriodLogged(DateTime date, int cycleLength) async {
  LoadingDialog.show(context);
  
  try {
    // Save period to database
    await _periodService.logPeriod(date);
    
    // Schedule notifications
    final notificationManager = NotificationManager();
    await notificationManager.schedulePeriodReminders(date, cycleLength);
    await notificationManager.scheduleFertileWindowReminders(date, cycleLength);
    
    LoadingDialog.hide(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Period logged! Reminders updated.'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    LoadingDialog.hide(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Template 2: Notification Settings Toggle
```dart
Future<void> _toggleNotificationType(String type, bool enabled) async {
  try {
    final notificationManager = NotificationManager();
    
    await notificationManager.setReminderEnabled(type, enabled);
    
    setState(() {
      _settings[type] = enabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled ? 'Notifications enabled' : 'Notifications disabled',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Template 3: FCM Token Backend Sync
```dart
Future<void> _syncFcmTokenWithBackend() async {
  try {
    final notificationManager = NotificationManager();
    final token = await notificationManager.getFcmToken();
    
    if (token != null) {
      await _apiService.post(
        '/api/fcm-tokens',
        {'user_id': user.id, 'token': token},
      );
      
      debugPrint('FCM token synced to backend');
    }
  } catch (e) {
    debugPrint('Error syncing FCM token: $e');
  }
}
```

### Template 4: Complete Cycle Setup
```dart
Future<void> _completeCycleSetup({
  required DateTime periodDate,
  required int cycleLength,
  required bool enableNotifications,
}) async {
  try {
    // 1. Save cycle data
    await _cycleService.saveCycleInfo(
      startDate: periodDate,
      length: cycleLength,
    );
    
    // 2. Setup notifications if enabled
    if (enableNotifications) {
      final nm = NotificationManager();
      
      await Future.wait([
        nm.schedulePeriodReminders(periodDate, cycleLength),
        nm.scheduleFertileWindowReminders(periodDate, cycleLength),
        nm.scheduleSymptomReminders(periodDate),
        nm.subscribeToNotifications(
          fertileWindow: true,
          symptomLog: true,
          periodLog: true,
        ),
      ]);
      
      // 3. Send FCM token to backend
      final token = await nm.getFcmToken();
      if (token != null) {
        await _apiService.post(
          '/api/fcm-tokens',
          {'user_id': user.id, 'token': token},
        );
      }
    }
    
    // 4. Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Setup complete! Your reminders are ready.'),
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Setup error: $e')),
    );
  }
}
```

## Error Handling Pattern

Use this pattern in all notification calls:

```dart
try {
  // Attempt notification operation
  await notificationManager.schedulePeriodReminders(date, length);
  
  // Show success
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Reminders set successfully'),
      duration: Duration(seconds: 2),
    ),
  );
} catch (e) {
  // Log error
  debugPrint('Notification error: $e');
  
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to set reminders. Please try again.'),
      duration: Duration(seconds: 2),
    ),
  );
}
```

## Testing Integration

After integrating, test these scenarios:

1. **App Startup**
   - [ ] Notification system initializes
   - [ ] No crashes or errors
   - [ ] FCM token is generated

2. **Onboarding**
   - [ ] Cycle info triggers reminder scheduling
   - [ ] Notification toggle works
   - [ ] Settings persist

3. **Daily Use**
   - [ ] Period logging updates reminders
   - [ ] Symptom tracking reminders work
   - [ ] Settings UI updates correctly

4. **Push Notifications**
   - [ ] Test notification from Firebase Console
   - [ ] Notification displays correctly
   - [ ] Tapping opens app

## File Structure After Integration

```
lib/
  ├── main.dart                     ✅ DONE
  ├── screens/
  │   ├── onboarding/
  │   │   ├── cycle_setup_screen.dart      ← Add period reminder scheduling
  │   │   └── notification_setup_screen.dart   ← Add notification setup
  │   ├── home/
  │   │   └── home_screen.dart              ← Add period logging trigger
  │   ├── symptoms/
  │   │   └── symptom_screen.dart           ← Add symptom tracking trigger
  │   └── settings/
  │       └── settings_screen.dart          ← Add NotificationPreferencesWidget
  ├── services/
  │   ├── notification_manager.dart         ✅ DONE
  │   ├── local_notification_service.dart   ✅ DONE
  │   ├── firebase_messaging_service.dart   ✅ DONE
  │   └── notification_reminder_service.dart ✅ DONE
  ├── widgets/
  │   └── notification_preferences_widget.dart ✅ DONE
  └── examples/
      └── notification_usage_examples.dart   ✅ DONE
```

## Next Steps

1. ✅ Notification services created
2. ✅ Widget created
3. ⏳ **Integrate into your screens** (this document)
4. ⏳ Setup Firebase configuration
5. ⏳ Test end-to-end

---

**Guide Version**: 1.0  
**Status**: Ready for Integration  
**Time to Complete**: 2-4 hours per screen
