import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatelessWidget {
  static const routeName = '/delete-account';

  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0EA5A4),
        elevation: 0,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      size: 38,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete your MyFertiPal account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF064B23),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can delete your account directly inside the app from Profile > Delete Account. This page exists for app store review and support requests.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'How deletion works',
              icon: Icons.verified_user_outlined,
              items: const [
                'Sign in to the app with the account you want deleted.',
                'Open Profile and choose Delete Account.',
                'Confirm the deletion prompt to remove your account.',
                'Your local session is cleared after deletion completes.',
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'What is removed',
              icon: Icons.inventory_2_outlined,
              items: const [
                'Your account access and authentication session.',
                'Saved profile data associated with the account.',
                'Deletion requests are sent to the backend at account removal.',
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Need help?',
              icon: Icons.support_agent_outlined,
              items: const [
                'If you cannot access the app, contact support at support@nexusfertility.com.',
                'Use the email address tied to your account when requesting deletion.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0EA5A4)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064B23),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Color(0xFF0EA5A4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
