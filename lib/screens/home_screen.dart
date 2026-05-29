import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../services/api_key_config.dart';
import '../services/yarngpt_tts_service.dart';
import '../models/user.dart';
import '../utils/responsive_utils.dart';
import 'profile/profile_screen.dart';
import 'support/support_screen.dart';
import 'onboarding/welcome_screen.dart';
import 'educational/educational_hub_screen.dart';
import 'calendar_tab_screen.dart';
import 'gender_prediction_screen.dart';
import 'user_guide_screen.dart';
import 'specialists/specialist_search_screen.dart';
import 'specialists/specialist_chat_screen.dart';
import 'tracking/log_symptom_screen.dart';
import 'payment/payment_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryTeal = Color(0xFF0EA5A4);
  static const Color _darkGreenText = Color(0xFF064B23);
  static const Color _ctaGreen = _darkGreenText;

  Future<void> _openLogSymptomScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogSymptomScreen(),
      ),
    );
    if (result != null && result is Map && result['symptoms'] is List<String>) {
      setState(() {
        _lastLoggedSymptoms = List<String>.from(result['symptoms']);
      });
      _sendInsightsPost();
    }
  }

  Map<String, dynamic>? _insightData;
  String? _insightText;
  String? _insightAudioUrl;
  bool _audioEnabled = true;
  late YarnGptTtsService _yarngptService;

  Locale? _lastLocale;

  // Default fallback data
  static const Map<String, dynamic> _defaultCycleSummary = {
    'fertile_period_start': 'N/A',
    'fertile_period_end': 'N/A',
    'ovulation_day': 'N/A',
  };
  static const String _defaultInsightText =
      'Track your cycle and get personalized insights here. Once you log your symptoms and cycle data, helpful tips and predictions will appear!';

  int _selectedIndex = 0;
  bool _showSideMenu = false;

  // Store last logged symptoms
  List<String> _lastLoggedSymptoms = [];

  @override
  void initState() {
    super.initState();
    // Initialize with default values immediately
    _insightData = Map<String, dynamic>.from(_defaultCycleSummary);
    _insightText = _defaultInsightText;

    // Initialize TTS service - gracefully handle if API key is not configured
    try {
      final testKey = ApiKeyConfig.getTestApiKey();
      String? apiKey;

      if (testKey != null) {
        apiKey = testKey;
      } else {
        try {
          apiKey = ApiKeyConfig.getYarnGptApiKey();
        } catch (e) {
          debugPrint('YarnGPT API key not configured: $e');
          apiKey = null;
        }
      }

      if (apiKey != null && apiKey.isNotEmpty) {
        _yarngptService = YarnGptTtsService(apiKey: apiKey);
      } else {
        // Disable audio functionality if API key is not available
        _audioEnabled = false;
        debugPrint('Audio features disabled - API key not configured');
        // Create a dummy service with a placeholder key to avoid crashes
        _yarngptService = YarnGptTtsService(apiKey: 'disabled');
      }
    } catch (e) {
      debugPrint('Failed to initialize YarnGPT TTS service: $e');
      _audioEnabled = false;
      // Create a dummy service as fallback
      _yarngptService = YarnGptTtsService(apiKey: 'disabled');
    }

    _loadAudioPreference();
    _sendInsightsPost();
  }

  Future<void> _loadAudioPreference() async {
    try {
      final api = ApiService();
      final profile = await api.getProfile();
      final audioPreference = profile['audio_preference'] ?? true;
      setState(() {
        _audioEnabled = audioPreference;
      });
    } catch (e) {
      debugPrint('Error loading audio preference: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;
    if (_lastLocale == null || _lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      _sendInsightsPost();
    }
  }

  Future<void> _sendInsightsPost() async {
    try {
      final api = ApiService();
      final headers = await api.getHeaders(includeAuth: true);

      // Fetch user profile to get period_length, cycle_length, last_period_date
      Map<String, dynamic>? profile;
      try {
        profile = await api.getProfile();
      } catch (e) {
        // If fetching profile fails, show fallback data
        setState(() {
          _insightData = Map<String, dynamic>.from(_defaultCycleSummary);
          _insightText = _defaultInsightText;
        });
        return;
      }

      int? cycleLength;
      int? periodLength;
      String? lastPeriodDate;

      cycleLength = profile['cycle_length'] is int
          ? profile['cycle_length']
          : int.tryParse(profile['cycle_length']?.toString() ?? '');
      periodLength = profile['period_length'] is int
          ? profile['period_length']
          : int.tryParse(profile['period_length']?.toString() ?? '');
      lastPeriodDate = profile['last_period_date']?.toString();

      final url = Uri.parse('${ApiService.baseUrl}/insights/insights');
      final body = {
        'cycle_length': cycleLength ?? 0,
        'last_period_date': lastPeriodDate ?? '',
        'period_length': periodLength ?? 0,
        'symptoms':
            _lastLoggedSymptoms.isNotEmpty ? _lastLoggedSymptoms : ['none'],
      };

      debugPrint('Sending POST to /insights/insights with body: $body');
      final postResponse = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('POST response status: ${postResponse.statusCode}');

      // Now GET insights/insights
      final getResponse = await http.get(url, headers: headers);
      debugPrint('GET /insights/insights status: ${getResponse.statusCode}');
      debugPrint('GET /insights/insights response: ${getResponse.body}');

      if (getResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(getResponse.body);
        debugPrint('Parsed insights data: $data');

        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          final insights = data[0] as Map<String, dynamic>;
          debugPrint('First insight object keys: ${insights.keys.toList()}');

          setState(() {
            _insightData = insights;
            // Try to get insight_text, or generate one from available data
            _insightText = insights['insight_text']?.toString() ??
                insights['prediction']?.toString() ??
                insights['recommendation']?.toString() ??
                _defaultInsightText;
            // Get audio URL if available
            _insightAudioUrl = insights['audio_url']?.toString();
            debugPrint('Set _insightText to: $_insightText');
            debugPrint('Audio URL: $_insightAudioUrl');
          });
          // Auto-play insights with YarnGPT TTS
          if (_audioEnabled &&
              _insightText != null &&
              _insightText!.isNotEmpty) {
            _playInsightAudioWithTTS();
          }
          return;
        }
      }

      // If no data or bad response, show fallback
      debugPrint('No valid insights data, using fallback');
      setState(() {
        _insightData = Map<String, dynamic>.from(_defaultCycleSummary);
        _insightText = _defaultInsightText;
      });
    } catch (e) {
      debugPrint('Failed to send/get insights: $e');
      setState(() {
        _insightData = Map<String, dynamic>.from(_defaultCycleSummary);
        _insightText = _defaultInsightText;
      });
    }
  }

  Future<void> _playInsightAudioWithTTS() async {
    if (_insightText == null || _insightText!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No insight text to read'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Use YarnGPT to convert text to speech and play
      await _yarngptService.speakText(_insightText!);
    } catch (e) {
      debugPrint('Error playing insight audio with YarnGPT: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopInsightAudio() async {
    await _yarngptService.pause();
  }

  void _toggleInsightAudio() async {
    if (_yarngptService.isPlaying) {
      _stopInsightAudio();
    } else {
      await _playInsightAudioWithTTS();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(),
              const EducationalHubScreen(),
              const CalendarTabScreen(),
              const SupportScreen(),
            ],
          ),
          if (_showSideMenu)
            GestureDetector(
              onTap: _toggleSideMenu,
              child: Container(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          if (_showSideMenu)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 30, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: _darkGreenText,
                                  size: 28,
                                ),
                                onPressed: _toggleSideMenu,
                              ),
                              _buildAvatar(user),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProfileCard(user),
                          const SizedBox(height: 20),
                          _buildMenuItem(
                            label: AppLocalizations.of(context).profile,
                            icon: Icons.person_outline,
                            onTap: () async {
                              _toggleSideMenu();
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                              // Refresh home page data if profile was updated
                              if (result == true) {
                                _sendInsightsPost();
                              }
                            },
                          ),
                          _buildMenuItem(
                            label: AppLocalizations.of(context).support,
                            icon: Icons.help_outline,
                            onTap: () {
                              _toggleSideMenu();
                              _showSupportDialog();
                            },
                          ),
                          _buildMenuItem(
                            label: AppLocalizations.of(context).help,
                            icon: Icons.menu_book_outlined,
                            onTap: () {
                              _toggleSideMenu();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UserGuideScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            label: 'Payment',
                            icon: Icons.payments_outlined,
                            onTap: () {
                              _toggleSideMenu();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PaymentScreen(),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          _buildMenuItem(
                            label: AppLocalizations.of(context).logOut,
                            icon: Icons.logout,
                            iconColor: Colors.grey.shade600,
                            textColor: Colors.grey.shade700,
                            onTap: () async {
                              _toggleSideMenu();
                              await auth.signOut();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const WelcomeScreen()),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryTeal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _selectedIndex == 0 ? AppLocalizations.of(context).home : '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: _selectedIndex == 1
                ? AppLocalizations.of(context).educational
                : '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline),
            label: _selectedIndex == 2
                ? AppLocalizations.of(context).trackCycle
                : '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.support_agent),
            label:
                _selectedIndex == 3 ? AppLocalizations.of(context).support : '',
          ),
        ],
      ),
    );
  }

  void _toggleSideMenu() {
    setState(() {
      _showSideMenu = !_showSideMenu;
    });
  }

  Widget _buildProfileCard(User? user) {
    final fullName = [user?.firstName, user?.lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
    final fallbackName =
        (user?.username != null && user!.username!.trim().isNotEmpty)
            ? user.username!.trim()
            : ((user?.email != null && user!.email.trim().isNotEmpty)
                ? user.email.split('@').first
                : 'User');
    final displayName = fullName.isNotEmpty ? fullName : fallbackName;
    final email = (user?.email != null && user!.email.trim().isNotEmpty)
        ? user.email
        : 'No email';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildAvatar(user, radius: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkGreenText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? _darkGreenText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: textColor ?? _darkGreenText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, {double radius = 18}) {
    final fullName = [user?.firstName, user?.lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
    final fallbackName =
        (user?.username != null && user!.username!.trim().isNotEmpty)
            ? user.username!.trim()
            : ((user?.email != null && user!.email.trim().isNotEmpty)
                ? user.email.split('@').first
                : 'U');
    final nameForInitial = fullName.isNotEmpty ? fullName : fallbackName;
    final initial =
        nameForInitial.isNotEmpty ? nameForInitial[0].toUpperCase() : 'U';
    final color =
    _darkGreenText;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  int? _calculateDaysUntilFertile() {
    if (_insightData == null || _insightData!['fertile_period_start'] == null) {
      debugPrint(
          'Fertile calculation: No insight data or fertile_period_start is null');
      return null;
    }

    final fertileStartStr =
        _insightData!['fertile_period_start'].toString().trim();
    if (fertileStartStr.isEmpty ||
        fertileStartStr == 'N/A' ||
        fertileStartStr == 'null') {
      debugPrint(
          'Fertile calculation: Invalid fertile_period_start value: $fertileStartStr');
      return null;
    }

    try {
      final fertileStart = DateTime.parse(fertileStartStr);
      final today = DateTime.now();
      // Reset time part to compare only dates
      final fertileStartDate =
          DateTime(fertileStart.year, fertileStart.month, fertileStart.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      final difference = fertileStartDate.difference(todayDate).inDays;

      debugPrint(
          'Fertile calculation: Today=$todayDate, FertileStart=$fertileStartDate, Days=$difference');

      return difference >= 0
          ? difference
          : null; // Return null if already passed
    } catch (e) {
      debugPrint('Fertile calculation: Error parsing date: $e');
      return null;
    }
  }

  bool _isInFertileWindow() {
    if (_insightData == null ||
        _insightData!['fertile_period_start'] == null ||
        _insightData!['fertile_period_end'] == null) {
      return false;
    }

    final fertileStartStr =
        _insightData!['fertile_period_start'].toString().trim();
    final fertileEndStr = _insightData!['fertile_period_end'].toString().trim();

    if (fertileStartStr.isEmpty ||
        fertileStartStr == 'N/A' ||
        fertileStartStr == 'null' ||
        fertileEndStr.isEmpty ||
        fertileEndStr == 'N/A' ||
        fertileEndStr == 'null') {
      return false;
    }

    try {
      final fertileStart = DateTime.parse(fertileStartStr);
      final fertileEnd = DateTime.parse(fertileEndStr);
      final today = DateTime.now();

      // Reset time part to compare only dates
      final fertileStartDate =
          DateTime(fertileStart.year, fertileStart.month, fertileStart.day);
      final fertileEndDate =
          DateTime(fertileEnd.year, fertileEnd.month, fertileEnd.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      final isInWindow = !todayDate.isBefore(fertileStartDate) &&
          !todayDate.isAfter(fertileEndDate);
      debugPrint(
          'In fertile window check: $isInWindow (Start: $fertileStartDate, End: $fertileEndDate, Today: $todayDate)');

      return isInWindow;
    } catch (e) {
      debugPrint('Error checking fertile window: $e');
      return false;
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _darkGreenText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkGreenText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(builder: (context) {
        final cardWidth = ResponsiveUtils.getResponsiveCardWidth(context);
        final cardHeight = ResponsiveUtils.getResponsiveCardHeight(context);
        final iconSize = ResponsiveUtils.isSmallScreen(context) ? 20.0 : 24.0;
        final fontSize =
            ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14);

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: _ctaGreen,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: _darkGreenText, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHomeTab() {
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.5;
    const buttonHeight = 64.0;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: heroHeight + (buttonHeight / 2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: heroHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _primaryTeal,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Stack(
                      children: [
                        // Hamburger menu icon
                        Positioned(
                          top: 30,
                          left: 0,
                          child: GestureDetector(
                            onTap: _toggleSideMenu,
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        // Background pregnant woman shadow image
                        Positioned.fill(
                          child: IgnorePointer(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Transform.translate(
                                    offset: const Offset(5, 0),
                                    child: Opacity(
                                      opacity: 0.08,
                                      child: Image.asset(
                                        'assets/images/pregnant.png',
                                        color: Colors.white,
                                        colorBlendMode: BlendMode.srcIn,
                                        // Make image height match the available shape height
                                        // while preserving aspect ratio
                                        height: constraints.maxHeight,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Insight text
                        if (_insightText != null && _insightText!.isNotEmpty)
                          Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).fertileWindow,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _insightText!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_audioEnabled && _insightText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: ListenableBuilder(
                                        listenable: _yarngptService,
                                        builder: (context, _) {
                                          return GestureDetector(
                                            onTap: _toggleInsightAudio,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: _darkGreenText,
                                                border: Border.all(
                                                  color: _darkGreenText,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (_yarngptService.isLoading)
                                                    const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    Icon(
                                                      _yarngptService.isPlaying
                                                          ? Icons.pause_circle
                                                          : Icons.play_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _yarngptService.isLoading
                                                        ? 'Loading...'
                                                        : _yarngptService
                                                                .isPlaying
                                                            ? 'Pause'
                                                            : 'Listen',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: heroHeight - (buttonHeight / 2),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _openLogSymptomScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _darkGreenText,
                          elevation: 4,
                          side: const BorderSide(color: _darkGreenText, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop, color: _darkGreenText),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context).logSymptoms,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: _darkGreenText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cycle summary table (below hero section)
          if (_insightData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryTeal.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).cycleInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _darkGreenText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Fertility Countdown
                    if (_isInFertileWindow())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primaryTeal.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _primaryTeal,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: _primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .fertileWindow,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _darkGreenText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)
                                          .inFertileWindow,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _darkGreenText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_calculateDaysUntilFertile() != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primaryTeal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _primaryTeal,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.hourglass_bottom,
                                color: _primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .fertileWindow,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _darkGreenText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _calculateDaysUntilFertile() == 1
                                          ? AppLocalizations.of(context)
                                              .dayUntilFertile(
                                              _calculateDaysUntilFertile()
                                                  .toString(),
                                            )
                                          : AppLocalizations.of(context)
                                              .daysUntilFertile(
                                              _calculateDaysUntilFertile()
                                                  .toString(),
                                            ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _darkGreenText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .fertilityCountdown,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context).logCycleSee,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    _buildSummaryRow(
                      AppLocalizations.of(context).fertileWindow,
                      _insightData!['fertile_period_start'] != null &&
                              _insightData!['fertile_period_end'] != null
                          ? '${_insightData!['fertile_period_start']} - ${_insightData!['fertile_period_end']}'
                          : 'N/A',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      AppLocalizations.of(context).ovulationDay,
                      _insightData!['ovulation_day']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    ResponsiveUtils.getResponsiveHorizontalPadding(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context).calendar,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ),
                SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.child_care,
                    label: AppLocalizations.of(context).genderPredictions,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const GenderPredictionScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    ResponsiveUtils.getResponsiveHorizontalPadding(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.medical_services_outlined,
                    label: AppLocalizations.of(context).findSpecialist,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpecialistSearchScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.chat_bubble_outline,
                    label: AppLocalizations.of(context).chatWithSpecialist,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpecialistChatScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              Icon(
                Icons.support_agent,
                color: _darkGreenText,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Support',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: _darkGreenText,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help or have feedback?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please reach out to us at:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _primaryTeal,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: _primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '+234-813-202-7445',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _darkGreenText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _primaryTeal,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: _primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'contact@myfertipal.com',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _darkGreenText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ll get back to you as soon as possible!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _darkGreenText,
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _yarngptService.dispose();
    super.dispose();
  }
}


