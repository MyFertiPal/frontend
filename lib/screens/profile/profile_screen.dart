import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import "../../services/api_service.dart";
import '../../services/analytics_service.dart';
import "../profile/profile_setup_screen.dart";
import '../../generated/l10n/app_localizations.dart';

import "../../screens/web/web_view_screen.dart";
import "../subscription/subscription_screen.dart";
import '../../providers/language_provider.dart';

/// Colors used across the screen.
class _ProfileColors {
  static const headerBg = Color(0xFF163B30);
  static const premiumBg = Color(0xFF2F5C4A);
  static const gold = Color(0xFFE9B44C);
  static const bg = Color(0xFFF7F7F5);
  static const cardBorder = Color(0xFFECECE8);
  static const textMuted = Color(0xFF8A8F88);
  static const heading = Color(0xFF163B30);
  static const danger = Color(0xFFE8756A);
  static const dangerBorder = Color(0xFFF3C3BD);
}

/// One row in the Settings list.
class _SettingsItemData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? trailingText;
  final bool isToggle;
  final VoidCallback? onTap;

  const _SettingsItemData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.trailingText,
    this.isToggle = false,
    this.onTap,
  });
}

/// A single stat shown in the summary row under the header.
/// A single stat shown in the summary row under the header.
class ProfileStat {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const ProfileStat({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });
}

/// Profile screen
class ProfileScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isPremiumMember;
  final List<ProfileStat>? stats;

  /// URL opened when "Privacy & Security" is tapped.
  final String privacyPolicyUrl;

  final String language;

  final VoidCallback? onPersonalInformationTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onLogOut;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onBack;

  ProfileScreen({
    super.key,
    required this.name,
    required this.privacyPolicyUrl,
    this.isPremiumMember = true,
    this.avatarUrl =
        "assets/images/profile_placeholder.png",
    this.stats,
    this.language = 'en',
    this.onPersonalInformationTap,
    this.onLanguageTap,
    this.onHelpSupportTap,
    this.onAboutTap,
    this.onLogOut,
    this.onDeleteAccount,
    this.onBack,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 
  final List<String> _languages = const [
  'English',
  'Yoruba',
  'Igbo',
  'Pidgin',
  'Hausa',
];
List<ProfileStat> _localizedStats(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    ProfileStat(
      icon: Icons.donut_large,
      iconColor: const Color(0xFF1F9E75),
      iconBg: const Color(0xFFDCF3E8),
      value: '14',
      label: l10n.cyclesTracked,
    ),

    ProfileStat(
      icon: Icons.event_note,
      iconColor: const Color(0xFFE8756A),
      iconBg: const Color(0xFFFBE1DE),
      value: '86',
      label: l10n.symptomsLogged,
    ),

    ProfileStat(
      icon: Icons.videocam,
      iconColor: const Color(0xFF3B8AD8),
      iconBg: const Color(0xFFDCEBFB),
      value: '5',
      label: l10n.consultations,
    ),
  ];
}
final ApiService _apiService = ApiService();
XFile? _selectedImage;
String _name = "";
String _avatarUrl = "";
String _selectedLanguage = "English";

late bool _isPremium;
bool _notificationsEnabled = true;
bool _isProfileImageLoading = true;

int _cyclesTracked = 0;
int _symptomsLogged = 0;
int _consultations = 0;

bool _isLoading = true;


Future<void> _loadProfile() async {
  try {
    final user = await _apiService.getUser();
    final profile = await _apiService.getProfile();

    debugPrint("USER: $user");
    debugPrint("PROFILE: $profile");

    final userId = profile["user_id"] ?? user["user_id"];

    String avatarUrl = "";

    if (userId != null) {
      try {
        final pictureResponse =
            await _apiService.getProfilePicture(
          userId: userId.toString(),
        );

        debugPrint(
          "PROFILE PICTURE RESPONSE: $pictureResponse",
        );

        final data =
            pictureResponse["data"] as Map<String, dynamic>?;

        avatarUrl = data?["url"]?.toString() ?? "";

        debugPrint(
          "PROFILE PICTURE URL: $avatarUrl",
        );
      } catch (e) {
        debugPrint(
          "Profile picture could not be loaded: $e",
        );
      }
    }

    if (!mounted) return;

    setState(() {
  _name =
      "${user["first_name"] ?? ""} ${user["last_name"] ?? ""}"
          .trim();

  _avatarUrl = avatarUrl;

  _selectedLanguage = _convertLanguageCode(
    user["language_preference"] ?? "en",
  );

  _isLoading = false;
  _isProfileImageLoading = false;
});
  } catch (e) {
    debugPrint("Profile loading error: $e");

    if (!mounted) return;

   setState(() {
  _name = widget.name;
  _selectedLanguage = widget.language;
  _avatarUrl = "";

  _isLoading = false;
  _isProfileImageLoading = false;
});
  }
}
String _convertLanguageCode(String code) {
  switch (code.toLowerCase()) {
    case "en":
      return "English";
    case "yo":
      return "Yoruba";
    case "ig":
      return "Igbo";
    case "ha":
      return "Hausa";
    case "pcm":
      return "Pidgin";
    default:
      return "English";
  }
}
String _languageCode(String language) {
  switch (language) {
    case "English":
      return "en";
    case "Yoruba":
      return "yo";
    case "Igbo":
      return "ig";
    case "Hausa":
      return "ha";
    case "Pidgin":
      return "pcm";
    default:
      return "en";
  }
}


@override
void initState() {
  super.initState();

  AnalyticsService.logScreenView(screenName: 'ProfileScreen');

  _isPremium = widget.isPremiumMember;

  _loadProfile();

}

Widget _buildLanguageRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFDCEBFB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.translate,
            size: 18,
            color: Color(0xFF3B8AD8),
          ),
        ),
        const SizedBox(width: 14),

         Expanded(
          child: Text(
            AppLocalizations.of(context).language,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ProfileColors.heading,
            ),
          ),
        ),

        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLanguage,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: _languages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (value) async {
  if (value == null) return;

  final previous = _selectedLanguage;

  setState(() {
    _selectedLanguage = value;
  });

  try {
    final code = _languageCode(value);

    await _apiService.updateLanguagePreference(code);

    if (mounted) {
      // THIS IS THE IMPORTANT LINE
      await context.read<LanguageProvider>().setLanguage(code);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).languageUpdated,
          ),
        ),
      );
    }
  } catch (e) {
    setState(() {
      _selectedLanguage = previous;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).languageUpdateFailed,
          ),
        ),
      );
    }
  }
},
          ),
        ),
      ],
    ),
  );
}


Future<void> _pickAndUploadProfilePicture() async {
  try {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final profile = await _apiService.getProfile();
    final userId = profile["user_id"];

    debugPrint("PROFILE USER ID: $userId");

    if (userId == null) {
      throw Exception(
        "Unable to determine user ID from profile.",
      );
    }

    if (!mounted) return;

    setState(() {
      _selectedImage = image;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Uploading profile picture..."),
      ),
    );

    // Upload the image
    final uploadResponse =
        await _apiService.uploadProfilePicture(
      userId: userId.toString(),
      file: image,
    );

    debugPrint(
      "PROFILE IMAGE UPLOAD RESPONSE: $uploadResponse",
    );

    // Now fetch the official/current URL from the backend
    final pictureResponse =
        await _apiService.getProfilePicture(
      userId: userId.toString(),
    );

    debugPrint(
      "PROFILE IMAGE GET RESPONSE: $pictureResponse",
    );

    final data =
        pictureResponse["data"] as Map<String, dynamic>?;

    final url = data?["url"]?.toString();

    if (url == null || url.isEmpty) {
      throw Exception(
        "Profile picture URL was not returned.",
      );
    }

    debugPrint(
      "CURRENT PROFILE IMAGE URL: $url",
    );

    if (!mounted) return;

    await AnalyticsService.logProfilePictureUpdated();

    setState(() {
      _avatarUrl = url;
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Profile picture updated successfully.",
        ),
      ),
    );
  } catch (e) {
    debugPrint(
      "Profile picture error: $e",
    );

    if (!mounted) return;

    setState(() {
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to update profile picture: $e",
        ),
      ),
    );
  }
}

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteAccount),
        content: Text(
          AppLocalizations.of(context).deleteAccountMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text( AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: _ProfileColors.danger),
            child:  Text( AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AnalyticsService.logAccountDeleted();
      await _apiService.deleteUser();

if(mounted){

Navigator.pushNamedAndRemoveUntil(
context,
"/login",
(route)=>false,
);

}
    }
  }

  List<_SettingsItemData> _settingsItems(BuildContext context) => [
        _SettingsItemData(
          icon: Icons.person_outline,
          iconColor: const Color(0xFF1F9E75),
          iconBg: const Color(0xFFDCF3E8),
          label: AppLocalizations.of(context).personalInformation,
           onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
  },
        ),
        _SettingsItemData(
          icon: Icons.notifications_none,
          iconColor: const Color(0xFFCB9A2C),
          iconBg: const Color(0xFFFBEDD2),
        label: AppLocalizations.of(context).notifications,
          isToggle: true,
        ),
        
        _SettingsItemData(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF7C6FD6),
          iconBg: const Color(0xFFE8E4FA),
          label: AppLocalizations.of(context).privacySecurity,
          onTap: () {
  _openWebPage(
    AppLocalizations.of(context).privacySecurity,
    widget.privacyPolicyUrl,
  );
},
        ),
        _SettingsItemData(
          icon: Icons.info_outline,
          iconColor: const Color(0xFFCB9A2C),
          iconBg: const Color(0xFFFBEDD2),
          label: AppLocalizations.of(context).aboutMyFertiPal,
         onTap: () {
  _openWebPage(
    "About MyFertiPal",
    "https://myfertipal.com/about-us",
  );
},
        ),
      ];

void _openWebPage(
String title,
String url,
) {

Navigator.push(
 context,
 MaterialPageRoute(
  builder: (_) => WebViewScreen(
    title: title,
    url: url,
  ),
 ),
);

}
Widget _buildUpgradeMembershipCard() {
  final l10n = AppLocalizations.of(context);

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AnalyticsService.logCustomEvent(
          'membership_opened',
          parameters: {'source': 'profile'},
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF163B30),
              Color(0xFF2F5C4A),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE9B44C).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFFE9B44C),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.upgradeMembership,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    l10n.upgradeMembershipDescription,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _ProfileColors.bg,

    body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildStatsRow(),
            ),
            _buildUpgradeMembershipCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                AppLocalizations.of(context).settings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _ProfileColors.heading,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSettingsCard(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildLogOutButton(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildDeleteAccountButton(),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ---- Header ---------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _ProfileColors.headerBg,
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 4),
          Stack(
  clipBehavior: Clip.none,
  children: [
    // Profile image
   Container(
  width: 104,
  height: 104,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: const Color(0xFF3FA98A),
      width: 3,
    ),
  ),
  padding: const EdgeInsets.all(3),
  child: ClipOval(
    child: _selectedImage != null
        ? FutureBuilder<Uint8List>(
            future: _selectedImage!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              }

              return const _ProfileImageSkeleton();
            },
          )
        : _isProfileImageLoading
            ? const _ProfileImageSkeleton()
            : _avatarUrl.isNotEmpty
                ? Image.network(
                    _avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const _ProfileImageSkeleton();
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Image.asset(
                        "assets/images/profile_placeholder.webp",
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/images/profile_placeholder.webp",
                    fit: BoxFit.cover,
                  ),
  ),
),

    // Camera button
    Positioned(
      right: -2,
      bottom: -2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickAndUploadProfilePicture,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F9E75),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 19,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  ],
),
const SizedBox(height: 14),
Text(
  _name.isNotEmpty ? _name : widget.name,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
          
          if (_isPremium) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _ProfileColors.premiumBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, size: 16, color: _ProfileColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).basicMember,
                    style: TextStyle(
                      color: _ProfileColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Stats row --------------------------------------------------------------

 Widget _buildStatsRow() {
  final stats =
      widget.stats ?? _localizedStats(context);

  return Row(
    children: [
      for (var i = 0; i < stats.length; i++) ...[
        if (i > 0)
          const SizedBox(width: 12),

        Expanded(
          child: _StatCard(
            stat: stats[i],
          ),
        ),
      ],
    ],
  );
}
  // ---- Settings card ------------------------------------------------------------

  Widget _buildSettingsCard() {
  final items = _settingsItems(context);

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _ProfileColors.cardBorder),
    ),
    child: Column(
      children: [
        _SettingsRow(
          data: items[0],
          notificationsEnabled: _notificationsEnabled,
          onToggleChanged: (v) =>
              setState(() => _notificationsEnabled = v),
        ),
        const Divider(height: 1),

        _SettingsRow(
          data: items[1],
          notificationsEnabled: _notificationsEnabled,
          onToggleChanged: (v) =>
              setState(() => _notificationsEnabled = v),
        ),
        const Divider(height: 1),

        _buildLanguageRow(),
        const Divider(height: 1),

        _SettingsRow(
          data: items[2],
          notificationsEnabled: _notificationsEnabled,
          onToggleChanged: (v) =>
              setState(() => _notificationsEnabled = v),
        ),
        const Divider(height: 1),

        _SettingsRow(
          data: items[3],
          notificationsEnabled: _notificationsEnabled,
          onToggleChanged: (v) =>
              setState(() => _notificationsEnabled = v),
        ),
      ],
    ),
  );
}

  // ---- Actions ------------------------------------------------------------------

  Widget _buildLogOutButton() {
    return OutlinedButton.icon(
      onPressed: () async {

await _apiService.logout();

if(mounted){
Navigator.pushNamedAndRemoveUntil(
context,
"/login",
(route)=>false,
);
}

},
      icon: const Icon(Icons.logout, size: 18, color: Colors.black87),
      label:  Text(AppLocalizations.of(context).logOut,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: _ProfileColors.cardBorder),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return OutlinedButton(
      onPressed: _confirmDeleteAccount,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: _ProfileColors.dangerBorder),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        AppLocalizations.of(context).deleteAccount,
        style: TextStyle(color: _ProfileColors.danger, fontWeight: FontWeight.w600),
      ),
    );
  }
}
class _ProfileImageSkeleton extends StatefulWidget {
  const _ProfileImageSkeleton();

  @override
  State<_ProfileImageSkeleton> createState() =>
      _ProfileImageSkeletonState();
}

class _ProfileImageSkeletonState
    extends State<_ProfileImageSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final position = _controller.value * 2 - 1;

            return LinearGradient(
              begin: Alignment(-1.0 + position, 0),
              end: Alignment(position + 1.0, 0),
              colors: const [
                Color(0xFFBDBDBD),
                Color(0xFFE0E0E0),
                Color(0xFFBDBDBD),
              ],
              stops: const [
                0.25,
                0.5,
                0.75,
              ],
            ).createShader(bounds);
          },
          child: Container(
            color: const Color(0xFFBDBDBD),
          ),
        );
      },
    );
  }
}
class _StatCard extends StatelessWidget {
  final ProfileStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ProfileColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: stat.iconBg, shape: BoxShape.circle),
            child: Icon(stat.icon, size: 20, color: stat.iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            stat.value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _ProfileColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItemData data;
  final bool notificationsEnabled;
  final ValueChanged<bool> onToggleChanged;

  const _SettingsRow({
    required this.data,
    required this.notificationsEnabled,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.isToggle ? null : data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: data.iconBg, shape: BoxShape.circle),
              child: Icon(data.icon, size: 18, color: data.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _ProfileColors.heading,
                ),
              ),
            ),
            if (data.isToggle)
              Switch(
                value: notificationsEnabled,
                onChanged: onToggleChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF1F9E75),
              )
            else if (data.trailingText != null) ...[
              Text(
                data.trailingText!,
                style: const TextStyle(fontSize: 14, color: _ProfileColors.textMuted),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: _ProfileColors.textMuted),
            ] else
              const Icon(Icons.chevron_right, size: 20, color: _ProfileColors.textMuted),
          ],
        ),
      ),
    );
  }
}