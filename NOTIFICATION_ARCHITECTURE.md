# Notification System Architecture

## High-Level System Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        FERTIPATH APP                           │
│                                                                │
│  ┌──────────────────┐                                          │
│  │   User Opens App │                                          │
│  └────────┬─────────┘                                          │
│           │                                                    │
│           ▼                                                    │
│  ┌──────────────────────────────────────┐                     │
│  │    main() Async Entry Point          │                     │
│  │  - Ensures Widget Binding            │                     │
│  │  - Initializes NotificationManager   │                     │
│  │  - Has Error Handling                │                     │
│  └────────┬─────────────────────────────┘                     │
│           │                                                    │
│           ▼                                                    │
│  ┌────────────────────────────────────┐                       │
│  │    NotificationManager              │                       │
│  │    (Singleton Pattern)              │                       │
│  └────────┬────────────────────────────┘                       │
│           │                                                    │
│    ┌──────┴─────┬──────────────┐                              │
│    │            │              │                              │
│    ▼            ▼              ▼                              │
│  ┌────────┐  ┌─────────────┐  ┌─────────────────┐             │
│  │ Local  │  │ Firebase    │  │ Notification    │             │
│  │Notif.  │  │ Messaging   │  │ Reminder        │             │
│  │Service │  │ Service     │  │ Service         │             │
│  └────────┘  └─────────────┘  └─────────────────┘             │
│                                                                │
└────────────────────────────────────────────────────────────────┘
         │                      │                  │
         │ Device Local         │ Cloud Messages   │ Stored
         │ Notifications        │                  │ Reminders
         ▼                      ▼                  ▼
    ┌──────────────┐      ┌──────────────┐   ┌─────────────┐
    │ Android/iOS  │      │ FCM Service  │   │SharedPrefs  │
    │ Notification │      │ (Firebase)   │   │             │
    │ System       │      │              │   └─────────────┘
    └──────────────┘      └──────────────┘
```

## Service Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  NotificationManager                        │
│              (Unified Public Interface)                     │
│                                                             │
│ • initialize()                                              │
│ • scheduleFertileWindowReminders()                          │
│ • scheduleSymptomReminders()                                │
│ • schedulePeriodReminders()                                 │
│ • setReminderEnabled()                                      │
│ • getReminderSettings()                                     │
│ • getPendingReminders()                                     │
│ • getFcmToken()                                             │
│ • sendTestNotification()                                    │
└─────────────────────────────────────────────────────────────┘
        │                       │                  │
        │                       │                  │
        ▼                       ▼                  ▼
┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   LocalNotif   │  │   FCMService     │  │  ReminderService │
│   Service      │  │                  │  │                  │
│                │  │                  │  │                  │
│ • initialize() │  │ • initialize()   │  │ • initialize()   │
│ • show()       │  │ • getFcmToken()  │  │ • schedule*()    │
│ • schedule()   │  │ • subscribe()    │  │ • setEnabled()   │
│ • cancel()     │  │ • unsubscribe()  │  │ • getSettings()  │
│ • get()        │  │ • handle msgs()  │  │ • clear()        │
└────────────────┘  └──────────────────┘  └──────────────────┘
        │                   │                     │
        │                   │                     │
        ▼                   ▼                     ▼
   Platform        Firebase Cloud      Device Storage
   APIs            Messaging APIs       (SharedPrefs)
```

## Data Flow: Schedule Fertile Window Reminder

```
User Action
    │
    ▼ (e.g., enters cycle date)
App Screen calls:
scheduleFertileWindowReminders(DateTime, cycleLength)
    │
    ▼
NotificationManager receives request
    │
    ├─→ NotificationReminderService
    │       • Calculate fertile window dates
    │       • Create reminder objects
    │       • Save to SharedPreferences
    │       • Return reminder list
    │
    ├─→ For each reminder:
    │   └─→ LocalNotificationService
    │       • Show/Schedule notification
    │       • Set time + sound + vibration
    │
    └─→ FirebaseMessagingService
        • Subscribe to topic
        • Ready to receive cloud messages

Result:
• Local notifications scheduled
• Reminders stored locally
• Topic subscribed (for cloud push)
```

## Notification Flow: From Trigger to Display

```
SCENARIO 1: LOCAL NOTIFICATION
─────────────────────────────
App calls:
  notificationManager.schedulePeriodReminders(date, length)
    │
    ▼
NotificationReminderService calculates dates:
    Period: Jan 5-9
    Fertile Window: Jan 16-20
    Symptom Reminders: Every day at 8 PM
    │
    ▼
Save scheduling info to √ SharedPreferences
    │
    ▼
LocalNotificationService receives scheduled times:
    │
    ├─ Jan 9, 8:00 AM: "Log your period"
    ├─ Jan 16, 8:00 AM: "Fertile window starts"
    └─ Every day, 8:00 PM: "Log your symptoms"
    │
    ▼
Device Native Layer (Android/iOS)
    Holds notifications in queue
    │
    ▼ (When time arrives)
Platform fires notification
    │
    ▼
LocalNotifications Framework
    • May show icon in system tray
    • Sound plays (if enabled)
    • Vibration occurs (if enabled)
    • LED blinks (Android, if enabled)
    │
    ▼
User sees notification
User taps notification
App opens with context


SCENARIO 2: CLOUD PUSH NOTIFICATION
──────────────────────────────────
Backend Server has FCM token (from earlier sync)
    │
    ▼
Backend sends FCM message to topic:
    Topic: "fertile_window_reminders"
    Title: "Your Fertile Window Begins"
    Body: "Your most fertile days..."
    │
    ▼
FCM (Cloud Service)
    Routes message to all devices subscribed to topic
    │
    ▼
device-operating-system receives FCM message
    │
    ├─→ App is in FOREGROUND
    │   └─→ FirebaseMessagingService.onMessage listener fires
    │       └─→ Immediately show via LocalNotificationService
    │
    ├─→ App is in BACKGROUND
    │   └─→ FirebaseMessagingService.onBackgroundMessage fires
    │       └─→ Initialize LocalNotifications
    │       └─→ Show notification
    │
    └─→ App is CLOSED
        └─→ OS queues notification
            └─→ System tray shows notification
            └─→ User taps → App starts and receives intent

Result in all cases:
    User sees notification in system tray
    Tapping possibly opens app with context
```

## Reminder Scheduling Algorithm

```
User provides:
    • Period Start Date: Jan 5, 2025
    • Cycle Length: 28 days

Algorithm calculates:

PERIOD WINDOW (5 days)
    Start: Jan 5
    End: Jan 9
    Reminder: Jan 9 at 8:00 AM
    Action: "Log your period info"

FERTILE WINDOW (5 days, typically day 12-16 of cycle)
    Start: Jan 16 (Day 12)
    End: Jan 20 (Day 16)
    Reminders: 
        • Jan 16, 8:00 AM: "Your fertile window begins"
        • Jan 17, 8:00 AM: "Still in fertile window"
        • Jan 18, 8:00 AM: "Still in fertile window"
        • Jan 19, 8:00 AM: "Still in fertile window"
        • Jan 20, 8:00 AM: "Last day of fertile window"

SYMPTOM REMINDERS (Daily)
    Every day at 8:00 PM: "Log your symptoms"
    Continues until next period

NEXT CYCLE
    Feb 2 (28 days later): Calculate next period window
    Process repeats automatically as user logs periods
```

## State Management

```
Notification State stored in SharedPreferences:
┌─────────────────────────────────────┐
│ "reminder_settings" (JSON String)   │
├─────────────────────────────────────┤
│ {                                   │
│   "fertile_window": true/false,     │
│   "symptom_log": true/false,        │
│   "period_log": true/false          │
│ }                                   │
└─────────────────────────────────────┘

Reminders stored in SharedPreferences:
┌─────────────────────────────────────────────┐
│ "fertility_reminders" (JSON Array)          │
├─────────────────────────────────────────────┤
│ [                                           │
│   {                                         │
│     "id": "unique_id",                      │
│     "title": "Your Fertile Window Begins",  │
│     "message": "Best days to try...",       │
│     "scheduledTime": "2025-01-16T08:00",   │
│     "type": "fertile_window",               │
│     "isSent": false                         │
│   },                                        │
│   { ... more reminders ... }                │
│ ]                                           │
└─────────────────────────────────────────────┘

Runtime State (In Memory):
┌────────────────────────────────────┐
│ NotificationManager Instance       │
├────────────────────────────────────┤
│ • _isInitialized: boolean          │
│ • _localNotificationService: obj   │
│ • _fcmService: obj                 │
│ • _reminderService: obj            │
└────────────────────────────────────┘
```

## Permission Flows

```
ANDROID (API 31+)
─────────────────
App Start
    │
    ▼
NotificationManager.initialize()
    │
    ▼
LocalNotificationService.initialize()
    • Creates notification channel
    • Sets importance level
    ▼
FirebaseMessagingService.initialize()
    • Requests POST_NOTIFICATIONS permission
    • User sees dialog: "Allow notifications?"
    │
    ├─→ User taps ALLOW
    │   └─→ Permission granted
    │       └─→ Can show notifications
    │
    └─→ User taps DENY
        └─→ Permission denied
            └─→ Can still show local (silently)
            └─→ Cannot show with sound/vibration


iOS (All Versions)
──────────────────
App Start
    │
    ▼
NotificationManager.initialize()
    │
    ▼
FirebaseMessagingService.initialize()
    • Requests permission (UNUserNotificationCenter)
    • User sees dialog: "Allow notifications?"
    │
    ├─→ User taps Allow
    │   └─→ Can show notifications
    │       └─→ Sound, badge, alert
    │
    └─→ User taps Don't Allow
        └─→ Cannot show notifications
            └─→ Silently fail

Also requires:
    • capability: Push Notifications
    • capability: Remote notifications (Background)
    • certificate: APNs certificate in Firebase
```

## Error Handling Architecture

```
Try/Catch layers:

LAYER 1: App Startup (main.dart)
┌────────────────────────────────┐
│ try {                           │
│   await notificationManager     │
│       .initialize()             │
│ } catch (e) {                   │
│   debugPrint(error)             │
│   // App continues normally     │
│ }                               │
└────────────────────────────────┘
        │
        └─→ Graceful degradation
            App still works


LAYER 2: Manager Level
┌────────────────────────────────┐
│ try {                           │
│   // Initialize all services    │
│   // Handle failures per service│
│ } catch (e) {                   │
│   debugPrint(error)             │
│   rethrow // Let caller handle  │
│ }                               │
└────────────────────────────────┘
        │
        └─→ Log all errors


LAYER 3: Service Level
┌────────────────────────────────┐
│ try {                           │
│   // Firebase operation         │
│ } catch (e) {                   │
│   debugPrint(error)             │
│   return null/empty             │
│ }                               │
└────────────────────────────────┘
        │
        └─→ Return safe defaults


LAYER 4: User Level (UI)
┌────────────────────────────────┐
│ try {                           │
│   // Call manager method        │
│   // Update UI on success       │
│ } catch (e) {                   │
│   // Show error snackbar        │
│   // Suggest action to user     │
│ }                               │
└────────────────────────────────┘
        │
        └─→ User sees helpful error
```

## Integration Points in App

```
App Structure with Notifications:

MyApp (main.dart)
    │
    ├─→ Initialization
    │   └─→ NotificationManager.initialize() ✅
    │
    ├─→ Routes/Screens
    │   │
    │   ├─→ AuthScreens
    │   │   ├─→ LoginScreen
    │   │   └─→ SignupScreen
    │   │
    │   ├─→ OnboardingScreens ⏳
    │   │   ├─→ CycleSetupScreen
    │   │   │   └─→ CALL: scheduleFertileWindowReminders()
    │   │   │
    │   │   └─→ NotificationSetupScreen
    │   │       └─→ CALL: subscribeToNotifications()
    │   │
    │   ├─→ MainScreens ⏳
    │   │   ├─→ HomeScreen
    │   │   │   ├─→ PeriodLogButton
    │   │   │   │   └─→ CALL: schedulePeriodReminders()
    │   │   │   │
    │   │   │   └─→ SymptomTrackingButton
    │   │   │       └─→ CALL: scheduleSymptomReminders()
    │   │   │
    │   │   ├─→ SettingsScreen ✅
    │   │   │   └─→ NotificationPreferencesWidget
    │   │   │       └─→ Toggle, test, view preferences
    │   │   │
    │   │   ├─→ DataScreen
    │   │   │   └─→ View pending reminders
    │   │   │
    │   │   └─→ SyncScreen ⏳
    │   │       └─→ Refresh reminders
    │   │
    │   └─→ OtherScreens
    │       └─→ (None yet)
    │
    └─→ Services
        ├─→ AuthService
        ├─→ DataService
        ├─→ NotificationManager ✅
        │   ├─→ LocalNotificationService ✅
        │   ├─→ FirebaseMessagingService ✅
        │   └─→ NotificationReminderService ✅
        │
        └─→ OtherServices
```

## Testing Pyramid

```
                    /\
                   /  \
                  /Unit \
                 /       \
                /─────────\
               /           \
              / Integration \
             /               \
            /─────────────────\
           /                   \
          /     End-to-End      \
         /                       \
        /─────────────────────────\

UNIT TESTS
├─ LocalNotificationService.showNotification()
├─ FirebaseMessagingService.subscribeTopic()
└─ NotificationReminderService.schedule*()

INTEGRATION TESTS
├─ NotificationManager initializes all services
├─ Manager coordinates between services
└─ Settings persist and load correctly

END-TO-END TESTS
├─ User logs period → reminders scheduled
├─ Push notification received → displays
├─ User toggles setting → FCM updates
└─ Tapping notification → opens app
```

## Data Types

```
NotificationReminder
├─ id: String (unique identifier)
├─ title: String (notification title)
├─ message: String (notification body)
├─ scheduledTime: DateTime (when to show)
├─ type: String (fertile_window|symptom_log|period_log)
└─ isSent: bool (whether already displayed)

ReminderSettings (JSON in SharedPreferences)
├─ fertile_window: bool
├─ symptom_log: bool
└─ period_log: bool

FCMToken
└─ String (device-specific token from Firebase)

NotificationPreference
├─ enabled: bool
├─ type: String
└─ topic: String (FCM topic name)
```

---

**Architecture Version**: 1.0  
**Last Updated**: Phase 3  
**Diagram Type**: Mermaid + ASCII Art  
**Status**: Complete & Accurate
