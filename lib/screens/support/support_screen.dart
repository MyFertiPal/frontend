import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "../../theme/app_colors.dart";
import '../../generated/l10n/app_localizations.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double hPad = constraints.maxWidth * 0.055; // ~16 on 360
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 20),
                  const _PodcastCard(),
                  const SizedBox(height: 32),
                  _ConnectWithOthersSection(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      
    );
  }
}

// ---------------- Header ----------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).connect,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

      ],
    );
  }
}

// ---------------- Live Session ----------------

class _PodcastCard extends StatelessWidget {
  const _PodcastCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Background image
            Image.asset(
  "assets/splash/logo.png",
  fit: BoxFit.cover,
),

            /// Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.15),
                    Colors.black.withOpacity(.45),
                    Colors.black.withOpacity(.85),
                  ],
                ),
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFF1DB954), // Spotify green
    borderRadius: BorderRadius.circular(30),
  ),
  child:  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.headphones,
        color: Colors.white,
        size: 14,
      ),
      SizedBox(width: 6),
      Text(
        AppLocalizations.of(context).podcast,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 11,
        ),
      ),
    ],
  ),
),

                  const Spacer(),

                  Text(
  AppLocalizations.of(context).fertiTalks,
  style: TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    height: 1.2,
  ),
),

                  const SizedBox(height: 12),

                  Row(
  children: [
    Icon(
      Icons.music_note,
      color: Colors.white70,
      size: 18,
    ),
    SizedBox(width: 8),
    Text(
      AppLocalizations.of(context).newEpisodesAvailable,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 15,
      ),
    ),
  ],
),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                    onPressed: () async {
  await _openPodcast();
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.headphones),
    SizedBox(width: 8),
    Text(
      AppLocalizations.of(context).listenOnSpotify,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ],
),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ---------------- Connect with others ----------------

class _ConnectWithOthersSection extends StatelessWidget {
  const _ConnectWithOthersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
             Expanded(
              child: Text(
              
  AppLocalizations.of(context).connectWithOthers,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ConnectCard(
  emoji: '👥',
  iconBg: const Color(0xFFDDEEE5),
 title: AppLocalizations.of(context).whatsAppCommunity,
subtitle: AppLocalizations.of(context).whatsAppCommunityDescription,
linkText: AppLocalizations.of(context).joinCommunity,
  linkColor: AppColors.textPrimary,
  onTap: _openWhatsAppCommunity,
),
        const SizedBox(height: 12),
        _ConnectCard(
          emoji: '💜',
          iconBg: const Color(0xFFEAE1F7),
         title: AppLocalizations.of(context).successStories,
subtitle: AppLocalizations.of(context).successStoriesDescription,
linkText: AppLocalizations.of(context).beInspired,
          linkColor: const Color(0xFF8E5FD1),
          onTap: (){},
        ),
        const SizedBox(height: 12),
        _ConnectCard(
          emoji: '🙏',
          iconBg: const Color(0xFFFBEAD2),
         title: AppLocalizations.of(context).faithEncouragement,
subtitle: AppLocalizations.of(context).faithEncouragementDescription,
linkText: AppLocalizations.of(context).getEncouraged,
          linkColor: const Color(0xFFCB8A2C),
          onTap: (){},
        ),
      ],
    );
  }
}
Future<void> _openPodcast() async {
  final uri = Uri.parse(
    "https://open.spotify.com/show/033Zg8LRmNhoSs58enrdGi?si=xe4U0RoVR3WXw1yLyZtzxA",
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
        
  
Future<void> _openWhatsAppCommunity() async {
  final uri = Uri.parse(
    "https://chat.whatsapp.com/G5bwLptRQXEAIRlfORKOmT",
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

class _ConnectCard extends StatelessWidget {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String linkText;
  final Color linkColor;
  final VoidCallback onTap;

  const _ConnectCard({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.linkText,
    required this.linkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          linkText,
                          style: TextStyle(
                            color: linkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 15, color: linkColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
