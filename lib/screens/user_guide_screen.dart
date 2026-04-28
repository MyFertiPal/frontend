import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0EA5A4),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).howToUseFertipath,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).welcomeToFertipath,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color(0xFF0EA5A4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).guideIntro,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildGuideSection(
              context: context,
              number: '1',
              title: AppLocalizations.of(context).step1Title,
              description: AppLocalizations.of(context).step1Description,
              icon: Icons.person_outline,
            ),
            _buildGuideSection(
              context: context,
              number: '2',
              title: AppLocalizations.of(context).step2Title,
              description: AppLocalizations.of(context).step2Description,
              icon: Icons.calendar_today,
            ),
            _buildGuideSection(
              context: context,
              number: '3',
              title: AppLocalizations.of(context).step3Title,
              description: AppLocalizations.of(context).step3Description,
              icon: Icons.edit_note,
            ),
            _buildGuideSection(
              context: context,
              number: '4',
              title: AppLocalizations.of(context).step4Title,
              description: AppLocalizations.of(context).step4Description,
              icon: Icons.insights,
            ),
            _buildGuideSection(
              context: context,
              number: '5',
              title: AppLocalizations.of(context).step5Title,
              description: AppLocalizations.of(context).step5Description,
              icon: Icons.headphones,
            ),
            _buildGuideSection(
              context: context,
              number: '6',
              title: AppLocalizations.of(context).step6Title,
              description: AppLocalizations.of(context).step6Description,
              icon: Icons.support_agent,
            ),
            _buildGuideSection(
              context: context,
              number: '7',
              title: AppLocalizations.of(context).step7Title,
              description: AppLocalizations.of(context).step7Description,
              icon: Icons.timeline,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5A4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0EA5A4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF0EA5A4),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        AppLocalizations.of(context).proTips,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF0EA5A4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).proTipsContent,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Color(0xFF0EA5A4),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        AppLocalizations.of(context).needHelp,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF0EA5A4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).needHelpContent,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection({
    required BuildContext context,
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5A4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF0EA5A4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF0EA5A4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
