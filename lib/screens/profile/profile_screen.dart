import 'package:flutter/material.dart';
import './profile_setup_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../providers/language_provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../onboarding/welcome_screen.dart';
import '../privacy_and_security/privacy_and_security_screen.dart';
import '../notification_settings_screen.dart';
import '../data_statistics_screen.dart';

const Color _primaryTeal = Color(0xFF0EA5A4);
const Color _darkGreenText = Color(0xFF064B23);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  User? _user;
  User? _userCard;
  bool _isDeleting = false;
  late final ApiService apiService; // Add as member variable
  bool _profileWasUpdated = false; // Track if profile was updated

  // Add missing fields for preferences
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(); // Initialize in initState
    _loadUserProfile();
    _loadUserCard();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Use member variable instead of creating local

      // Fetch profile data (contains age, cycle_length, etc.)
      final profileJson = await apiService.getProfile();
      debugPrint('Profile JSON received: ' + profileJson.toString());

      // Also fetch basic user info (contains email, name, etc.)
      final userJson = await apiService.getUser();
      debugPrint('User JSON received: ' + userJson.toString());

      // Merge both responses - profile data takes priority, fill in missing basic user info
      final mergedJson = {...userJson, ...profileJson};
      debugPrint('Merged User Data: ' + mergedJson.toString());

      final fetchedUser = User.fromJson(mergedJson);
      debugPrint('Parsed User: id=' +
          fetchedUser.id.toString() +
          ', email=' +
          (fetchedUser.email) +
          ', firstName=' +
          (fetchedUser.firstName?.toString() ?? 'null') +
          ', lastName=' +
          (fetchedUser.lastName?.toString() ?? 'null') +
          ', username=' +
          (fetchedUser.username?.toString() ?? 'null') +
          ', phoneNumber=' +
          (fetchedUser.phoneNumber?.toString() ?? 'null') +
          ', preferredLanguage=' +
          (fetchedUser.preferredLanguage?.toString() ?? 'null') +
          ', ttcHistory=' +
          fetchedUser.ttcHistory.toString() +
          ', faithPreference=' +
          (fetchedUser.faithPreference?.toString() ?? 'null') +
          ', cycleLength=' +
          (fetchedUser.cycleLength?.toString() ?? 'null') +
          ', lastPeriodDate=' +
          (fetchedUser.lastPeriodDate?.toString() ?? 'null'));

      if (mounted) {
        setState(() {
          _user = fetchedUser;
          if (_user != null) {
            selectedLanguage =
                _getLanguageDisplayName(_user!.preferredLanguage ?? 'en');
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _refreshProfile() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    try {
      await Future.wait([
        _loadUserProfile(),
        _loadUserCard(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadUserCard() async {
    try {
      final apiService = ApiService();
      final userJson = await apiService.getUser();
      debugPrint('getUser JSON received: ' + userJson.toString());
      final fetchedUser = User.fromJson(userJson);
      if (mounted) {
        setState(() {
          _userCard = fetchedUser;
        });
      }
    } catch (e) {
      debugPrint('Error loading getUser for card: $e');
    }
  }

  String _getLanguageDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'ig':
        return 'Igbo';
      case 'ha':
        return 'Hausa';
      case 'yo':
        return 'Yoruba';
      case 'pcm':
        return 'Pidgin';
      default:
        return 'English';
    }
  }

  Color _colorFromString(String input) {
    if (input.isEmpty) return _primaryTeal;
    final hash = input.codeUnits.fold<int>(0, (prev, code) => prev + code);
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1, hue, 0.45, 0.85).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    // Localization removed
    final userCard = _userCard ?? auth.currentUser;

    // Get calendar days from CalendarTabScreen (for demo, use SharedPreferences directly)
    // In production, refactor to pass calendar data via provider or callback
    final Set<DateTime> calendarDays = {};
    // Load tapped days from SharedPreferences synchronously (for demo only)
    // In production, this should be async and handled in state
    // This is a workaround for demonstration
    SharedPreferences.getInstance().then((prefs) {
      final savedDays = prefs.getStringList('tapped_days');
      if (savedDays != null && savedDays.isNotEmpty) {
        calendarDays.addAll(savedDays.map((s) => DateTime.parse(s)));
      }
    });
    // Removed local prediction. Use backend-provided next period dates only.

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_profileWasUpdated);
        return false; // We handle the pop ourselves
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _primaryTeal,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(_profileWasUpdated);
            },
          ),
          title: Text(
            AppLocalizations.of(context).profileSettings,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Stack(
          children: [
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryTeal),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      // Wrap in error boundary
                      try {
                        return RefreshIndicator(
                          onRefresh: _refreshProfile,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // User Profile Card (always use get_user)
                                _buildProfileCard(userCard, context),
                                const SizedBox(height: 16),
                                // Removed nextPeriodDates display. Use backend-driven widgets only.
                                // Goals Section
                                _buildGoalsSection(),
                                const SizedBox(height: 16),
                                // Preferences Section
                                _buildPreferencesSection(),
                                const SizedBox(height: 16),
                                // Privacy & Security Section
                                _buildPrivacySection(),
                                const SizedBox(height: 16),
                                // Delete Account Section
                                _buildDeleteAccountSection(context),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Error building profile screen: $e');
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  e.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    _loadUserProfile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryTeal,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
            if (_isRefreshing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryTeal),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ), // Scaffold
    ); // WillPopScope
  }

  Widget _buildProfileCard(user, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildInitialAvatar(user),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (() {
                          final fullName = [user?.firstName, user?.lastName]
                              .where((part) =>
                                  part != null && part!.trim().isNotEmpty)
                              .map((part) => part!.trim())
                              .join(' ');
                          if (fullName.isNotEmpty) return fullName;
                          if (user?.username != null &&
                              user!.username!.trim().isNotEmpty) {
                            return user.username!.trim();
                          }
                          if (user?.email != null &&
                              user!.email.trim().isNotEmpty) {
                            return user.email.split('@').first;
                          }
                          return 'User';
                        })(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkGreenText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (user?.email != null && user!.email.trim().isNotEmpty)
                            ? user.email
                            : 'No email',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (user?.phoneNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user!.phoneNumber!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.language,
                              size: 16, color: _primaryTeal),
                          const SizedBox(width: 6),
                          Text(
                            'Language: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _getLanguageDisplayName(
                                user?.preferredLanguage ?? 'en'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: _darkGreenText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupScreen(),
                  ),
                );
                // After returning from profile setup, reload profile to fetch new goal values
                if (result == true) {
                  setState(() {
                    _profileWasUpdated = true;
                  });
                  await _refreshProfile();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Set and update profile',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(User? user) {
    final fullName = [user?.firstName, user?.lastName]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    final fallbackName =
        (user?.username != null && user!.username!.trim().isNotEmpty)
            ? user.username!.trim()
            : ((user?.email != null && user!.email.trim().isNotEmpty)
                ? user.email.split('@').first
                : 'U');
    final displayName = fullName.isNotEmpty ? fullName : fallbackName;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final bgColor =
        _colorFromString(displayName.isNotEmpty ? displayName : initial);

    return CircleAvatar(
      radius: 35,
      backgroundColor: bgColor,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    // Dynamically display user profile data fetched from API
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: const CircularProgressIndicator(),
        ),
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    () {
                      if (_user?.ttcHistory == null ||
                          _user!.ttcHistory.isEmpty) {
                        return 'Not set';
                      }
                      return _user!.ttcHistory.join(', ');
                    }(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalRow(AppLocalizations.of(context).faithPreference,
                _user?.faithPreference ?? AppLocalizations.of(context).notSet),
            const SizedBox(height: 12),
            _buildGoalRow(
                AppLocalizations.of(context).cycleLength,
                _user?.cycleLength != null
                    ? '${_user!.cycleLength} ${AppLocalizations.of(context).days}'
                    : AppLocalizations.of(context).notSet),
            const SizedBox(height: 12),
            _buildGoalRow(
                AppLocalizations.of(context).lastPeriodDate,
                _user?.lastPeriodDate != null
                    ? _user!.lastPeriodDate.toString().split(' ')[0]
                    : AppLocalizations.of(context).notSet),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (label == 'Faith Preference')
          Text(
            () {
              final faith = _user?.faithPreference ?? 'Not set';
              if (faith.isEmpty) return 'Not set';
              return faith[0].toUpperCase() + faith.substring(1);
            }(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          )
        else
          Text(
            value.isEmpty ? 'Not set' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).preference,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageOptions = languageProvider.getAvailableLanguages();

    String selectedCode = languageProvider.locale.languageCode;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _primaryTeal.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.language, size: 22, color: _darkGreenText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context).language,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        DropdownButton<String>(
          value: selectedCode,
          underline: const SizedBox(),
          isDense: true,
          items: languageOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newCode) async {
            if (newCode == null) return;

            // Show loading indicator
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                          'Changing language to ${languageOptions[newCode]}...'),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            // Update language in provider (works immediately, even without login)
            await languageProvider.setLanguage(newCode);

            // If user is logged in, also save to backend
            bool backendSuccess = false;
            if (_user != null) {
              try {
                await apiService.updateLanguagePreference(newCode);
                backendSuccess = true;
                debugPrint('Language saved to backend: $newCode');
              } catch (e) {
                debugPrint('Failed to save language to backend: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Language changed locally. Server update failed: $e'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            }

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _user != null && backendSuccess
                              ? 'Language changed to ${languageOptions[newCode]} and saved'
                              : 'Language changed to ${languageOptions[newCode]}',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: _primaryTeal,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).privacySecurity,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shield_outlined, color: _darkGreenText),
              title: Text(AppLocalizations.of(context).dataPrivacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyAndSecurityScreen()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shield_outlined, color: _primaryTeal),
              title: Text(AppLocalizations.of(context).manageDataPermissions),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyAndSecurityScreen()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shield_outlined, color: _primaryTeal),
              title: Text(AppLocalizations.of(context).exploreMyData),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const DataStatisticsScreen()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined,
                  color: _darkGreenText),
              title: const Text('Notifications & Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).deleteAccount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).deleteAccountWarning,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () {
                        _showDeleteConfirmation(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Delete my Account',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteAccount),
          content: Text(
            AppLocalizations.of(context).deleteAccountConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performAccountDeletion();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAccountDeletion() async {
    if (!mounted) return;

    setState(() => _isDeleting = true);

    try {
      debugPrint('Starting account deletion process...');

      // Attempt backend deletion
      bool backendDeleted = false;

      try {
        await apiService.deleteUser();
        backendDeleted = true;
        debugPrint('Backend deletion successful');
      } catch (e) {
        debugPrint('Backend deletion error: $e');
        final errorStr = e.toString().toLowerCase();

        // Check for network/connectivity errors
        final isNetworkError = errorStr.contains('failed to fetch') ||
            errorStr.contains('network') ||
            errorStr.contains('timeout') ||
            errorStr.contains('client');

        // If token expired or user already gone, continue to local cleanup
        final isAuthError = errorStr.contains('401') ||
            errorStr.contains('403') ||
            errorStr.contains('404') ||
            errorStr.contains('token') ||
            errorStr.contains('unauthorized');

        if (!isAuthError && !isNetworkError) {
          // Show detailed error for non-auth/non-network errors
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to delete account: ${e.toString()}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    _performAccountDeletion();
                  },
                ),
              ),
            );
            setState(() => _isDeleting = false);
          }
          return;
        }

        // For network errors, inform user but proceed with local cleanup
        if (isNetworkError) {
          debugPrint(
              'Network error during deletion, proceeding with local cleanup: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Backend temporarily unavailable. Proceeding with local account cleanup...',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Auth error - continue with local cleanup
          debugPrint(
              'Auth error during deletion, proceeding with local cleanup: $e');
        }
      }

      // Always clear local auth state
      debugPrint('Clearing local authentication state...');
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
      debugPrint('Local auth state cleared');

      // Navigate back to welcome screen after deletion/cleanup
      if (mounted) {
        final message = backendDeleted
            ? 'Account deleted successfully'
            : 'Logged out locally (server unreachable)';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backendDeleted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Critical error during account deletion: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _performAccountDeletion();
              },
            ),
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }
}
