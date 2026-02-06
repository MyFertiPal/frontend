/// Example: How to trigger notifications when user updates cycle information
///
/// This file demonstrates how to integrate NotificationManager into screens
/// where users log their cycle data.

import 'package:flutter/material.dart';
import '../services/notification_manager.dart';

/// Example: Period Data Entry Screen
/// This shows how to schedule notifications when user logs their period
class PeriodDataEntryExample extends StatefulWidget {
  const PeriodDataEntryExample({super.key});

  @override
  State<PeriodDataEntryExample> createState() => _PeriodDataEntryExampleState();
}

class _PeriodDataEntryExampleState extends State<PeriodDataEntryExample> {
  final NotificationManager _notificationManager = NotificationManager();
  late DateTime _selectedDate;
  late int _cycleLength;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _cycleLength = 28; // Default cycle length
  }

  /// Call this when user confirms their period date
  Future<void> _onPeriodLogged() async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setting up reminders...')),
      );

      // Schedule period reminders
      await _notificationManager.schedulePeriodReminders(
        _selectedDate,
        _cycleLength,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Period logged! Reminders scheduled.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting reminders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Period')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected Date:'),
            Text('${_selectedDate.toLocal()}'.split('.')[0]),
            const SizedBox(height: 16),
            const Text('Cycle Length (days):'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _cycleLength = int.tryParse(value) ?? 28;
              },
              decoration: InputDecoration(
                hintText: '$_cycleLength',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPeriodLogged,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E683D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log Period & Set Reminders'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example: Fertility Window Notification Trigger
/// This shows how to schedule notifications when user syncs their cycle data
class FertilityWindowNotificationExample {
  static final NotificationManager _notificationManager = NotificationManager();

  /// Call this when user provides cycle information
  /// Typically in a cycle setup or sync screen
  static Future<void> scheduleFertilityNotifications({
    required DateTime cycleStartDate,
    required int cycleLength,
  }) async {
    try {
      await _notificationManager.scheduleFertileWindowReminders(
        cycleStartDate,
        cycleLength,
      );
      debugPrint(
        'Fertility window notifications scheduled for cycle starting $cycleStartDate',
      );
    } catch (e) {
      debugPrint('Error scheduling fertility notifications: $e');
      rethrow;
    }
  }
}

/// Example: Symptom Logging Reminder Setup
/// Demonstrates how to trigger symptom reminders when user starts tracking
class SymptomLoggingSetupExample {
  static final NotificationManager _notificationManager = NotificationManager();

  /// Call this when user enables symptom tracking
  static Future<void> startSymptomReminders(
    DateTime firstSymptomDate,
  ) async {
    try {
      await _notificationManager.scheduleSymptomReminders(firstSymptomDate);
      debugPrint('Symptom reminders started from $firstSymptomDate');
    } catch (e) {
      debugPrint('Error starting symptom reminders: $e');
      rethrow;
    }
  }

  /// Call this when user disables symptom tracking
  static Future<void> stopSymptomReminders() async {
    try {
      final reminders = await _notificationManager.getPendingReminders();
      final symptomReminders = reminders.where((r) => r.type == 'symptom_log');

      for (final reminder in symptomReminders) {
        await _notificationManager.cancelNotification(reminder.id);
      }

      debugPrint('Symptom reminders stopped');
    } catch (e) {
      debugPrint('Error stopping symptom reminders: $e');
      rethrow;
    }
  }
}

/// Example: Comprehensive Cycle Setup Screen
/// Shows how to enable all notification types when user completes onboarding
class CycleSetupNotificationsExample extends StatefulWidget {
  const CycleSetupNotificationsExample({super.key});

  @override
  State<CycleSetupNotificationsExample> createState() =>
      _CycleSetupNotificationsExampleState();
}

class _CycleSetupNotificationsExampleState
    extends State<CycleSetupNotificationsExample> {
  final NotificationManager _notificationManager = NotificationManager();
  bool _notificationsEnabled = true;

  /// Complete cycle setup and schedule all notification types
  Future<void> _completeSetup({
    required DateTime periodStartDate,
    required int cycleLength,
  }) async {
    try {
      if (!_notificationsEnabled) {
        debugPrint('Notifications disabled by user, skipping setup');
        return;
      }

      // Enable all notification types
      await _notificationManager.subscribeToNotifications(
        fertileWindow: true,
        symptomLog: true,
        periodLog: true,
      );

      // Schedule all reminders
      await Future.wait([
        _notificationManager.scheduleFertileWindowReminders(
          periodStartDate,
          cycleLength,
        ),
        _notificationManager.scheduleSymptomReminders(periodStartDate),
        _notificationManager.schedulePeriodReminders(
          periodStartDate,
          cycleLength,
        ),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup complete! You\'ll receive reminders.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      debugPrint('All notifications scheduled successfully');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up notifications: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Error in cycle setup: $e');
    }
  }

  Future<void> _skipNotifications() async {
    try {
      await _notificationManager.unsubscribeFromAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications disabled')),
        );
      }
    } catch (e) {
      debugPrint('Error disabling notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Timely Reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBenefit(
                      icon: Icons.favorite,
                      title: 'Fertile Window Alerts',
                      description: 'Know when you\'re most fertile',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit(
                      icon: Icons.health_and_safety,
                      title: 'Daily Symptom Reminders',
                      description: 'Track your symptoms consistently',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit(
                      icon: Icons.calendar_today,
                      title: 'Period Logging Reminders',
                      description: 'Never forget to log your period',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive reminders for your cycle'),
              activeColor: const Color(0xFF2E683D),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _notificationsEnabled
                    ? () => _completeSetup(
                          periodStartDate: DateTime.now(),
                          cycleLength: 28,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E683D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enable All Reminders'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _skipNotifications,
                child: const Text('Skip for Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E683D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Usage Examples
void exampleUsages() {
  // Example 1: When user logs their period
  // _onPeriodLogged(); // Calls schedulePeriodReminders()

  // Example 2: When user starts tracking symptoms
  // SymptomLoggingSetupExample.startSymptomReminders(DateTime.now());

  // Example 3: When user enters their cycle info
  // FertilityWindowNotificationExample.scheduleFertilityNotifications(
  //   cycleStartDate: DateTime.now(),
  //   cycleLength: 28,
  // );

  // Example 4: Complete setup after onboarding
  // _completeSetup(periodStartDate: DateTime.now(), cycleLength: 28);
}

/// Simple helper function to check notification status
Future<void> logNotificationStatus() async {
  final notificationManager = NotificationManager();
  try {
    final pending = await notificationManager.getPendingReminders();
    final settings = await notificationManager.getReminderSettings();
    final fcmToken = await notificationManager.getFcmToken();

    debugPrint('=== Notification Status ===');
    debugPrint('Pending reminders: ${pending.length}');
    debugPrint('Settings: $settings');
    debugPrint('FCM Token: ${fcmToken?.substring(0, 20)}...');
  } catch (e) {
    debugPrint('Error checking notification status: $e');
  }
}
