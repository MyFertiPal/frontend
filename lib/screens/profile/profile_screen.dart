import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import "../../services/api_service.dart";
import "../profile/profile_setup_screen.dart";
import "../../services/profile_image_picker.dart";
import "../../screens/web/web_view_screen.dart";

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
  final List<ProfileStat> stats;

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
     this.avatarUrl = "assets/images/profile_placeholder.png",
    this.stats = const [
      ProfileStat(
        icon: Icons.donut_large,
        iconColor: Color(0xFF1F9E75),
        iconBg: Color(0xFFDCF3E8),
        value: '14',
        label: 'Cycles Tracked',
      ),
      ProfileStat(
        icon: Icons.event_note,
        iconColor: Color(0xFFE8756A),
        iconBg: Color(0xFFFBE1DE),
        value: '86',
        label: 'Symptoms Logged',
      ),
      ProfileStat(
        icon: Icons.videocam,
        iconColor: Color(0xFF3B8AD8),
        iconBg: Color(0xFFDCEBFB),
        value: '5',
        label: 'Consultations',
      ),
    ],
    this.language = 'English',
    this.onPersonalInformationTap,
    this.onLanguageTap,
    this.onHelpSupportTap,
    this.onAboutTap,
    this.onLogOut,
    this.onDeleteAccount,
    this.onBack,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _languages = const [
  'English',
  'Yoruba',
  'Igbo',
  'Pidgin',
  'Hausa',
];
final ApiService _apiService = ApiService();
String? _imagePath;
String _name = "";
String _avatarUrl = "";
String _selectedLanguage = "English";

bool _isPremium = false;
bool _notificationsEnabled = true;

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

    setState(() {

      // Account data
      _name =
          "${user["first_name"] ?? ""} ${user["last_name"] ?? ""}".trim();
      _avatarUrl = user["profile_image"] ?? "";

      _selectedLanguage =
          _convertLanguageCode(
              user["language_preference"] ?? "en"
          );


      // Fertility profile data
      // available for Personal Information screen later

      _isLoading = false;

    });


  } catch(e){

    debugPrint("Profile loading error: $e");

    setState(() {
      _name = widget.name;
      _selectedLanguage = widget.language;
      _isLoading = false;
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
  _loadProfile();
   _loadImage();
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

        const Expanded(
          child: Text(
            "Language",
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
  await _apiService.updateLanguagePreference(
    _languageCode(value),
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Language updated successfully."),
      ),
    );
  }
} catch (e) {
  setState(() {
    _selectedLanguage = previous;
  });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to update language."),
      ),
    );
  }
}

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Language updated successfully."),
      ),
    );
  }

  widget.onLanguageTap?.call();
},
          ),
        ),
      ],
    ),
  );
}

Future<void> _loadImage() async {
  _imagePath =
      await ProfileImageService.getImagePath();

  if (mounted) {
    setState(() {});
  }
}


  

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          "This permanently deletes your account and all tracked data. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: _ProfileColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
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

  List<_SettingsItemData> get _settingsItems => [
        _SettingsItemData(
          icon: Icons.person_outline,
          iconColor: const Color(0xFF1F9E75),
          iconBg: const Color(0xFFDCF3E8),
          label: 'Personal Information',
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
          label: 'Notifications',
          isToggle: true,
        ),
        
        _SettingsItemData(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF7C6FD6),
          iconBg: const Color(0xFFE8E4FA),
          label: 'Privacy & Security',
          onTap: () {
  _openWebPage(
    "Privacy Policy",
    widget.privacyPolicyUrl,
  );
},
        ),
        _SettingsItemData(
          icon: Icons.info_outline,
          iconColor: const Color(0xFFCB9A2C),
          iconBg: const Color(0xFFFBEDD2),
          label: 'About MyFertiPal',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Settings',
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
          InkWell(
  onTap: () async {
  final image = await ProfileImageService.pickFromGallery();

  if (image != null) {
    setState(() {
      _imagePath = image.path;
    });
  }
},
  borderRadius: BorderRadius.circular(60),
  child: Container(
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
      child: _imagePath != null && File(_imagePath!).existsSync()
          ? Image.file(
              File(_imagePath!),
              fit: BoxFit.cover,
            )
          : _avatarUrl.isNotEmpty
              ? Image.network(
                  _avatarUrl,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/images/profile_placeholder.webp",
                  fit: BoxFit.cover,
                ),
    ),
  ),
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
                    'Premium Member',
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
    return Row(
      children: [
        for (var i = 0; i < widget.stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _StatCard(stat: widget.stats[i])),
        ],
      ],
    );
  }

  // ---- Settings card ------------------------------------------------------------

  Widget _buildSettingsCard() {
  final items = _settingsItems;

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
      label: const Text('Log Out',
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
      child: const Text(
        'Delete Account',
        style: TextStyle(color: _ProfileColors.danger, fontWeight: FontWeight.w600),
      ),
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