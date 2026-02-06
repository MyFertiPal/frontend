# Notification System Integration Guide

This guide covers implementing the complete push notification system for Fertipath, including local notifications, Firebase Cloud Messaging (FCM), and the notification preferences UI.

## Overview

The notification system consists of:
- **LocalNotificationService**: Displays notifications on device
- **FirebaseMessagingService**: Handles cloud push notifications via Firebase
- **NotificationManager**: Unified interface that coordinates both
- **NotificationReminderService**: Stores and manages reminder schedules
- **NotificationPreferencesWidget**: UI for users to manage notification settings

## Step 1: Dependencies

All required dependencies have been added to `pubspec.yaml`:
```yaml
flutter_local_notifications: ^15.1.0
firebase_core: ^2.24.0
firebase_messaging: ^14.6.0
workmanager: ^0.5.2
```

Run `flutter pub get` to install them.

## Step 2: Firebase Project Setup

### Android Setup

1. **Download google-services.json**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new Firebase project or select existing
   - Add Android app with package name: `com.fertipath.app` (or your app's package)
   - Download `google-services.json` and place in `android/app/`

2. **Update android/build.gradle.kts**:
   ```kotlin
   plugins {
       id("com.google.gms.google-services") version "4.3.15" apply false
   }
   ```

3. **Update android/app/build.gradle.kts**:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("com.google.gms.google-services")
       id("dev.flutter.flutter-gradle-plugin")
   }
   ```

### iOS Setup

1. **Download GoogleService-Info.plist**:
   - In Firebase Console, download the iOS configuration file
   - Open `ios/Runner.xcworkspace` (not .xcodeproj)
   - Add `GoogleService-Info.plist` to the project (check "Copy items if needed")
   - Build phases: Ensure it's included in "Copy Bundle Resources"

2. **Enable Push Notifications Capability**:
   - In Xcode: Runner → Signing & Capabilities
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes" and enable:
     - Background fetch
     - Remote notifications

3. **Configure APNs in Firebase Console**:
   - Go to Project Settings → Cloud Messaging tab
   - Upload APNs certificate for push notifications

## Step 3: Android Platform Configuration

### AndroidManifest.xml

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Notification permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:label="Fertipath"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Firebase Services -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Notification broadcast receiver -->
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

        <!-- Rest of your app configuration -->
        
    </application>
</manifest>
```

## Step 4: iOS Platform Configuration

### Info.plist

Update `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Firebase Configuration -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <true/>
    
    <!-- Notification request behavior -->
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    
    <!-- Rest of your plist configuration -->
</dict>
</plist>
```

### Runner/GeneratedPluginRegistry.swift

Ensure Firebase is properly registered with:
```swift
GeneratedPluginRegistrant.register(with: self)
```

## Step 5: Integrate Notification Preferences UI

### Option A: Add to Existing Settings Screen

In your settings/profile screen widget:

```dart
import 'package:fertipath/widgets/notification_preferences_widget.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // Other settings...
          
          // Notification settings section
          NotificationPreferencesWidget(),
        ],
      ),
    );
  }
}
```

### Option B: Create Dedicated Notifications Screen

```dart
import 'package:fertipath/widgets/notification_preferences_widget.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: NotificationPreferencesWidget(),
    );
  }
}
```

Then add to your navigation:
```dart
ListTile(
  title: Text('Notification Settings'),
  trailing: Icon(Icons.notifications),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NotificationsScreen()),
  ),
)
```

## Step 6: Initialize Notifications in App

The `main.dart` has already been updated with:

```dart
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

## Step 7: Backend API Integration (Required for Cloud Push)

You need a backend endpoint to:
1. Save FCM tokens
2. Send push notifications

### Save FCM Token

Update `lib/services/firebase_messaging_service.dart` line ~120:

```dart
Future<void> _saveFcmTokenToBackend(String token) async {
  try {
    final response = await http.post(
      Uri.parse('https://your-api.com/api/fcm-tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,  // Get from your auth service
        'token': token,
        'device': 'ios', // or 'android'
      }),
    );
    
    if (response.statusCode == 200) {
      debugPrint('FCM token saved to backend');
    }
  } catch (e) {
    debugPrint('Error saving FCM token: $e');
  }
}
```

### Send Push Notifications from Backend

Example using Node.js:

```javascript
const admin = require('firebase-admin');

async function sendNotification(topic, title, body) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    android: {
      ttl: 3600,
      notification: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
      },
    },
  };

  try {
    const response = await admin
      .messaging()
      .sendToTopic(topic, message);
    
    console.log('Message sent:', response);
  } catch (error) {
    console.error('Error sending message:', error);
  }
}

// Send to fertile window topic
await sendNotification(
  'fertile_window_reminders',
  'Your Fertile Window Begins',
  'Your most fertile days are here!',
);
```

## Step 8: Test Notifications

### Test Local Notifications

Use the notification preferences widget:
1. Go to notification settings
2. Click "Send Test Notification"
3. You should see a notification on your device

### Test Firebase Push Notifications

From Firebase Console:

1. Go to Cloud Messaging section
2. Click "Send your first message"
3. Create notification:
   - **Title**: "Test Notification"
   - **Body**: "This is a test"
   - **Target**: Select topic `fertile_window_reminders`
4. Click Send

You should receive the notification on any device subscribed to that topic.

### Test via Backend API

```bash
curl -X POST https://your-api.com/api/send-notification \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "fertile_window_reminders",
    "title": "Test",
    "body": "Testing notifications"
  }'
```

## Available Notification Topics

Users can be subscribed to these topics:
- `fertile_window_reminders` - Fertile window alerts
- `symptom_log_reminders` - Daily symptom logging reminders
- `period_log_reminders` - Period logging reminders

## API Reference

### NotificationManager

```dart
final notificationManager = NotificationManager();

// Initialize
await notificationManager.initialize();

// Schedule reminders
await notificationManager.scheduleFertileWindowReminders(startDate, cycleLength);
await notificationManager.scheduleSymptomReminders(lastSymptomDate);
await notificationManager.schedulePeriodReminders(lastPeriodDate, cycleLength);

// Get pending reminders
final pending = await notificationManager.getPendingReminders();

// Cancel notifications
await notificationManager.cancelNotification(reminderId);
await notificationManager.cancelAllNotifications();

// FCM token
final token = await notificationManager.getFcmToken();

// Subscribe/unsubscribe
await notificationManager.subscribeToNotifications(
  fertileWindow: true,
  symptomLog: true,
  periodLog: true,
);
await notificationManager.unsubscribeFromAllNotifications();

// Settings
final settings = await notificationManager.getReminderSettings();
await notificationManager.setReminderEnabled('fertile_window', true);

// Test
await notificationManager.sendTestNotification();
```

## Troubleshooting

### Notifications not appearing on Android

1. Check app has "notifications" permission:
   - Settings → Apps → Fertipath → Notifications → Allow
2. Check `POST_NOTIFICATIONS` permission in AndroidManifest.xml
3. Verify app isn't running in battery saver mode

### Notifications not appearing on iOS

1. Check Settings → Fertipath → Notifications is enabled
2. Verify APNs certificate is uploaded in Firebase Console
3. Check device has internet connection
4. Ensure app is signed with provisioning profile that supports push notifications

### FCM Token not being saved

1. Ensure device has network connection
2. Check firebaseMessagingService initialization completed
3. Look at console output for errors
4. Verify Firebase project is properly configured

### Permissions denied

- **Android 13+**: App must request notification permission at runtime
  - Added automatically by flutter_local_notifications
  - User must accept when prompted
- **iOS**: Automatic when app launches

## Next Steps

1. Complete Firebase Console setup (Steps 2-3)
2. Configure Android & iOS platforms (Steps 3-4)
3. Add NotificationPreferencesWidget to your UI (Step 5)
4. Implement backend API for token saving & push notifications (Step 7)
5. Test using Firebase Console (Step 8)

## Support

For issues:
1. Check Flutter console for error messages
2. Enable debug mode: `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;`
3. Check Firebase Console logs
4. Verify all platform-specific configurations are complete
