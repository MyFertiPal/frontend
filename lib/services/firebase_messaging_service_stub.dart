/// Stub implementation of FirebaseMessagingService for web platform
/// This prevents firebase_messaging_web compilation errors on web
class FirebaseMessagingService {
  Future<void> initialize() async {
    // No-op on web platform
  }

  Future<String?> getToken() async {
    return null;
  }

  Future<String?> getFcmToken() async {
    return null;
  }

  Future<void> subscribeToTopic(String topic) async {
    // No-op on web platform
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // No-op on web platform
  }

  Future<void> subscribeTopic(String topic) async {
    // No-op on web platform
  }

  Future<void> unsubscribeTopic(String topic) async {
    // No-op on web platform
  }

  Future<void> subscribeToNotificationTypes({
    bool fertileWindow = true,
    bool symptomLog = true,
    bool periodLog = true,
  }) async {
    // No-op on web platform
  }

  Future<void> unsubscribeFromAllNotifications() async {
    // No-op on web platform
  }
}
