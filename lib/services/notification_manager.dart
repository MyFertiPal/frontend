import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';
import 'firebase_messaging_service_stub.dart'
    if (dart.library.io) 'firebase_messaging_service.dart';
import 'notification_reminder_service.dart';

/// Unified notification manager that integrates local and FCM notifications
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();
  final NotificationReminderService _reminderService =
      NotificationReminderService();

  bool _isInitialized = false;

  /// Initialize the notification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _localNotificationService.initialize();
      debugPrint('Local notifications initialized');

      // Initialize Firebase messaging (uses stub on web platform)
      await _fcmService.initialize();
      debugPrint('Firebase messaging initialized');

      // Initialize reminder service
      await _reminderService.initialize();
      debugPrint('Reminder service initialized');

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notification manager: $e');
      rethrow;
    }
  }

  /// Send a test notification
  Future<void> sendTestNotification() async {
    await _localNotificationService.showNotification(
      id: 999,
      title: 'Fertipath Test',
      body: 'This is a test notification',
    );
  }

  /// Schedule a fertility window reminder
  Future<void> scheduleFertileWindowReminders(
    DateTime cycleStartDate,
    int cycleLength,
  ) async {
    await _reminderService.scheduleFertileWindowReminders(
      cycleStartDate,
      cycleLength,
    );

    // Also schedule local notifications for these reminders
    final reminders =
        await _reminderService.getRemindersByType('fertile_window');
    for (final reminder in reminders) {
      await _localNotificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.message,
        scheduledTime: reminder.scheduledTime,
        payload: 'type:fertile_window,id:${reminder.id}',
      );
    }
  }

  /// Schedule symptom logging reminders
  Future<void> scheduleSymptomReminders(
    DateTime lastSymptomDate,
  ) async {
    await _reminderService.scheduleSymptomLoggingReminders(
      lastSymptomDate,
      28,
    );

    // Also schedule local notifications for these reminders
    final reminders = await _reminderService.getRemindersByType('symptom_log');
    for (final reminder in reminders) {
      await _localNotificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.message,
        scheduledTime: reminder.scheduledTime,
        payload: 'type:symptom_log,id:${reminder.id}',
      );
    }
  }

  /// Schedule period logging reminders
  Future<void> schedulePeriodReminders(
    DateTime lastPeriodDate,
    int cycleLength,
  ) async {
    await _reminderService.schedulePeriodLoggingReminders(
      lastPeriodDate,
      cycleLength,
    );

    // Also schedule local notifications for these reminders
    final reminders = await _reminderService.getRemindersByType('period_log');
    for (final reminder in reminders) {
      await _localNotificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.message,
        scheduledTime: reminder.scheduledTime,
        payload: 'type:period_log,id:${reminder.id}',
      );
    }
  }

  /// Get all pending notifications
  Future<List<NotificationReminder>> getPendingReminders() async {
    return await _reminderService.getPendingReminders();
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(String reminderId) async {
    await _reminderService.deleteReminder(reminderId);
    await _localNotificationService.cancelNotification(reminderId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _reminderService.clearAllReminders();
    await _localNotificationService.cancelAllNotifications();
  }

  /// Subscribe to notification types via FCM
  Future<void> subscribeToNotifications({
    bool fertileWindow = true,
    bool symptomLog = true,
    bool periodLog = true,
  }) async {
    await _fcmService.subscribeToNotificationTypes(
      fertileWindow: fertileWindow,
      symptomLog: symptomLog,
      periodLog: periodLog,
    );
  }

  /// Unsubscribe from all notifications
  Future<void> unsubscribeFromAllNotifications() async {
    await _fcmService.unsubscribeFromAllNotifications();
  }

  /// Get FCM token for backend registration
  Future<String?> getFcmToken() async {
    return await _fcmService.getFcmToken();
  }

  /// Enable/disable notification types
  Future<void> setReminderEnabled(String type, bool enabled) async {
    await _reminderService.setReminderEnabled(type, enabled);

    if (enabled) {
      // Subscribe to FCM topic if enabling
      switch (type) {
        case 'fertile_window':
          await _fcmService.subscribeTopic('fertile_window_reminders');
          break;
        case 'symptom_log':
          await _fcmService.subscribeTopic('symptom_log_reminders');
          break;
        case 'period_log':
          await _fcmService.subscribeTopic('period_log_reminders');
          break;
      }
    } else {
      // Unsubscribe from FCM topic if disabling
      switch (type) {
        case 'fertile_window':
          await _fcmService.unsubscribeTopic('fertile_window_reminders');
          break;
        case 'symptom_log':
          await _fcmService.unsubscribeTopic('symptom_log_reminders');
          break;
        case 'period_log':
          await _fcmService.unsubscribeTopic('period_log_reminders');
          break;
      }
    }
  }

  /// Get reminder settings
  Future<Map<String, dynamic>> getReminderSettings() async {
    return await _reminderService.getReminderSettings();
  }
}
