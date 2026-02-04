import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/notification_reminder_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  static const routeName = '/notification-settings';
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationReminderService _notificationService;

  bool _enableNotifications = true;
  bool _enableFertileWindowReminder = true;
  bool _enablePeriodReminder = true;
  bool _enableSymptomLogReminder = true;
  bool _enableInsightNotifications = true;
  void initState() {
    super.initState();
    _notificationService = NotificationReminderService();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _enableNotifications = prefs.getBool('notifications_enabled') ?? true;
        _enableFertileWindowReminder =
            prefs.getBool('fertile_window_reminder') ?? true;
        _enablePeriodReminder = prefs.getBool('period_reminder') ?? true;
        _enableSymptomLogReminder =
            prefs.getBool('symptom_log_reminder') ?? true;
        _enableInsightNotifications =
            prefs.getBool('insight_notifications') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<void> _saveNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _enableNotifications);
      await prefs.setBool(
          'fertile_window_reminder', _enableFertileWindowReminder);
      await prefs.setBool('period_reminder', _enablePeriodReminder);
      await prefs.setBool('symptom_log_reminder', _enableSymptomLogReminder);
      await prefs.setBool('insight_notifications', _enableInsightNotifications);

      // Sync to backend if user is logged in
      final auth = Provider.of<AuthService>(context, listen: false);
      if (auth.currentUser != null) {
        // Note: updateProfile has specific named parameters
        // For now, these settings are stored locally in SharedPreferences
        // You can extend updateProfile in api_service.dart to support these parameters
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated'),
            backgroundColor: Color(0xFF2E683D),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E683D),
        elevation: 0,
        title: const Text('Notifications & Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master Notifications Toggle
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 12),
            _buildNotificationTile(
              title: 'Enable All Notifications',
              subtitle: 'Turn on/off all notification types',
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                  if (!value) {
                    _enableFertileWindowReminder = false;
                    _enablePeriodReminder = false;
                    _enableSymptomLogReminder = false;
                    _enableInsightNotifications = false;
                  }
                });
                _saveNotificationPreferences();
              },
              icon: Icons.notifications_active,
              accentColor: const Color(0xFF2E683D),
            ),
            const SizedBox(height: 24),

            // Notification Types
            if (_enableNotifications) ...[
              _buildSectionHeader('Notification Types'),
              const SizedBox(height: 12),
              _buildNotificationTile(
                title: 'Fertile Window Reminders',
                subtitle: 'Get reminded about your fertile window',
                value: _enableFertileWindowReminder,
                onChanged: (value) {
                  setState(() => _enableFertileWindowReminder = value);
                  _saveNotificationPreferences();
                },
                icon: Icons.favorite,
                accentColor: const Color(0xFFC8E6C9),
              ),
              const SizedBox(height: 12),
              _buildNotificationTile(
                title: 'Period Reminders',
                subtitle: 'Get reminded when your period is coming',
                value: _enablePeriodReminder,
                onChanged: (value) {
                  setState(() => _enablePeriodReminder = value);
                  _saveNotificationPreferences();
                },
                icon: Icons.calendar_today,
                accentColor: const Color(0xFFFFB3BA),
              ),
              const SizedBox(height: 12),
              _buildNotificationTile(
                title: 'Symptom Log Reminders',
                subtitle: 'Reminders to log your daily symptoms',
                value: _enableSymptomLogReminder,
                onChanged: (value) {
                  setState(() => _enableSymptomLogReminder = value);
                  _saveNotificationPreferences();
                },
                icon: Icons.assignment,
                accentColor: const Color(0xFFA8D497),
              ),
              const SizedBox(height: 12),
              _buildNotificationTile(
                title: 'Insight Notifications',
                subtitle: 'Receive personalized fertility insights',
                value: _enableInsightNotifications,
                onChanged: (value) {
                  setState(() => _enableInsightNotifications = value);
                  _saveNotificationPreferences();
                },
                icon: Icons.lightbulb,
                accentColor: const Color(0xFFFFD700),
              ),
            ],
            const SizedBox(height: 32),

            // Notification History
            _buildSectionHeader('Notification History'),
            const SizedBox(height: 12),
            FutureBuilder<List<NotificationReminder>>(
              future: _notificationService.getPendingReminders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reminders = snapshot.data ?? [];
                if (reminders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No pending notifications',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reminders.length > 5 ? 5 : reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return _buildReminderCard(reminder);
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Permission Settings
            _buildSectionHeader('Permissions'),
            const SizedBox(height: 12),
            _buildPermissionCard(
              title: 'Calendar Access',
              description: 'Allow access to view your calendar',
              icon: Icons.calendar_month,
              isGranted: true,
            ),
            const SizedBox(height: 12),
            _buildPermissionCard(
              title: 'Location Access',
              description: 'Optional: For health facility recommendations',
              icon: Icons.location_on,
              isGranted: false,
            ),
            const SizedBox(height: 12),
            _buildPermissionCard(
              title: 'Contacts Access',
              description:
                  'Optional: To share cycle data with trusted contacts',
              icon: Icons.contacts,
              isGranted: false,
            ),
            const SizedBox(height: 32),

            // Data Sharing Settings
            _buildSectionHeader('Data Sharing'),
            const SizedBox(height: 12),
            _buildDataSharingTile(
              title: 'Share with Healthcare Providers',
              subtitle: 'Allow healthcare providers to view your data',
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 12),
            _buildDataSharingTile(
              title: 'Anonymous Research Participation',
              subtitle: 'Contribute anonymized data to fertility research',
              icon: Icons.science,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E683D),
            fontFamily: 'Poppins',
          ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: accentColor.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E683D),
            activeTrackColor: const Color(0xFFA8D497),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(NotificationReminder reminder) {
    final typeLabel = reminder.type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reminder.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8D497).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E683D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reminder.message,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isGranted,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E683D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isGranted ? 'Granted' : 'Denied',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isGranted ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSharingTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E683D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
