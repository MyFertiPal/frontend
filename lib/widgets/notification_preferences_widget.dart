/// Notification preferences screen widget
/// Can be integrated into the profile/settings area
///
/// Usage in a settings screen:
/// ```dart
/// // In your settings screen
/// NotificationPreferencesWidget()
/// ```

import 'package:flutter/material.dart';
import '../services/notification_manager.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  final NotificationManager _notificationManager = NotificationManager();
  late Map<String, dynamic> _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _notificationManager.getReminderSettings();
      setState(() {
        _settings = settings;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      setState(() {
        _loading = false;
        _settings = {
          'fertile_window': true,
          'symptom_log': true,
          'period_log': true,
        };
      });
    }
  }

  Future<void> _toggleNotificationType(String type, bool value) async {
    try {
      await _notificationManager.setReminderEnabled(type, value);
      setState(() {
        _settings[type] = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Notifications enabled for $type'
                  : 'Notifications disabled for $type',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update notification settings'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationManager.sendTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send test notification'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildNotificationToggle(
                  title: 'Fertile Window Reminders',
                  subtitle: 'Get reminded during your fertile window',
                  type: 'fertile_window',
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                _buildNotificationToggle(
                  title: 'Symptom Logging Reminders',
                  subtitle: 'Daily reminders to log your symptoms',
                  type: 'symptom_log',
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                _buildNotificationToggle(
                  title: 'Period Logging Reminders',
                  subtitle: 'Get reminded to log your period',
                  type: 'period_log',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E683D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notification Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Enable notifications to stay on top of your cycle\n'
                  '• Push notifications require allowing app notifications in device settings\n'
                  '• You can customize notification times in your cycle data',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required String type,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _settings[type] ?? true,
            onChanged: (value) => _toggleNotificationType(type, value),
            activeColor: const Color(0xFF2E683D),
          ),
        ],
      ),
    );
  }
}
