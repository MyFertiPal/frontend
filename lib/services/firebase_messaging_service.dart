import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'local_notification_service.dart';

/// Service for handling Firebase Cloud Messaging (FCM) / Push Notifications
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  bool _isInitialized = false;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase (if not already done)
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Firebase already initialized: $e');
      }

      // Request permissions for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle message when app is opened from notification
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // Save new token to backend
        _saveFcmTokenToBackend(newToken);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  /// Get the current FCM token
  Future<String?> getFcmToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');

    // Show local notification
    if (message.notification != null) {
      _localNotificationService.showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'MyFertiPal',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle background messages (static method - cannot use instance)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');

    // Initialize local notification service for background
    final localNotifications = LocalNotificationService();
    await localNotifications.initialize();

    // Show local notification
    if (message.notification != null) {
      await localNotifications.showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'MyFertiPal',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Save FCM token to backend for push notifications
  Future<void> _saveFcmTokenToBackend(String token) async {
    try {
      // TODO: Implement backend API call to save FCM token
      debugPrint('FCM token saved to backend: $token');
    } catch (e) {
      debugPrint('Error saving FCM token to backend: $e');
    }
  }

  /// Subscribe to a notification topic
  Future<void> subscribeTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to notification types
  Future<void> subscribeToNotificationTypes({
    bool fertileWindow = true,
    bool symptomLog = true,
    bool periodLog = true,
  }) async {
    if (fertileWindow) {
      await subscribeTopic('fertile_window_reminders');
    }
    if (symptomLog) {
      await subscribeTopic('symptom_log_reminders');
    }
    if (periodLog) {
      await subscribeTopic('period_log_reminders');
    }
  }

  /// Unsubscribe from all notification types
  Future<void> unsubscribeFromAllNotifications() async {
    await unsubscribeTopic('fertile_window_reminders');
    await unsubscribeTopic('symptom_log_reminders');
    await unsubscribeTopic('period_log_reminders');
  }
}
