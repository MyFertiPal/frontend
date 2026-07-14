import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyAndSecurityScreen extends StatelessWidget {
  static const routeName = '/privacy-and-security';

  const PrivacyAndSecurityScreen({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF0EA5A4);

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://myfertipal.com/privacy-policy',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Permissions',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Shield Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.08),
                border: Border.all(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.security_outlined,
                size: 60,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Privacy & Permissions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Manage your privacy settings and app permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 30),

            _buildActionTile(
              icon: Icons.policy_outlined,
              title: 'Privacy Policy',
              subtitle:
                  'Read how MyFertiPal collects, uses and protects your information.',
              onTap: _openPrivacyPolicy,
            ),

            const SizedBox(height: 14),

            _buildActionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification permissions.',
              onTap: _openSettings,
            ),

            const SizedBox(height: 30),

            Text(
              'Permissions can be changed at any time from your device settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}