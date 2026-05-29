import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/api_key_config.dart';
import '../../services/yarngpt_tts_service.dart';
import '../community/community_groups_screen.dart';
import '../community/create_group_screen.dart';
import 'cultural_guidance_screen.dart';

const Color _primaryTeal = Color(0xFF0EA5A4);
const Color _darkGreenText = Color(0xFF064B23);

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _currentAffirmation = "";
  List<String> _affirmations = [];
  bool _loadingAffirmations = true;
  String _currentFaith = 'neutral'; // Track current faith preference
  bool _audioEnabled = true; // Track if audio guidance is enabled

  // Audio player properties
  late AudioPlayer _audioPlayer;
  bool _isPlayingAudio = false;
  bool _isAudioLoading = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // TTS service for affirmations
  late YarnGptTtsService _affirmationTtsService;
  bool _affirmationTtsLoading = false;

  Map<String, List<String>> get _faithAffirmations {
    final l10n = AppLocalizations.of(context);
    return {
      'christian': [
        l10n.christianAffirmation1,
        l10n.christianAffirmation2,
        l10n.christianAffirmation3,
      ],
      'muslim': [
        l10n.muslimAffirmation1,
        l10n.muslimAffirmation2,
        l10n.muslimAffirmation3,
      ],
      'traditionalist': [
        l10n.traditionalistAffirmation1,
        l10n.traditionalistAffirmation2,
        l10n.traditionalistAffirmation3,
        l10n.traditionalistAffirmation4,
        l10n.traditionalistAffirmation5,
      ],
      'neutral': [
        l10n.neutralAffirmation1,
        l10n.neutralAffirmation2,
        l10n.neutralAffirmation3,
      ],
    };
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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
        _affirmationTtsService = YarnGptTtsService(apiKey: apiKey);
      } else {
        debugPrint('Audio features disabled - API key not configured');
        _affirmationTtsService = YarnGptTtsService(apiKey: 'disabled');
      }
    } catch (e) {
      debugPrint('Failed to initialize affirmation TTS service: $e');
      _affirmationTtsService = YarnGptTtsService(apiKey: 'disabled');
    }
    _initializeAudioPlayer();
    _initializeAffirmationTts();
    _fetchFaithPreference();
    _loadAudioPreference();
  }

  Future<void> _loadAudioPreference() async {
    try {
      final api = ApiService();
      final profile = await api.getProfile();
      final audioPreference = profile['audio_preference'] ?? true;
      if (mounted) {
        setState(() {
          _audioEnabled = audioPreference;
        });
      }
    } catch (e) {
      debugPrint('Error loading audio preference: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh affirmations when locale changes to ensure translations are updated
    _refreshAffirmations();
  }

  void _refreshAffirmations() {
    if (_affirmations.isNotEmpty && mounted) {
      // Reload affirmations from the new language using stored faith preference
      setState(() {
        _affirmations = _faithAffirmations[_currentFaith]!;
        // Keep the current affirmation index if possible, otherwise reset to first
        final currentIndex = _currentAffirmation.isEmpty
            ? 0
            : _affirmations.indexWhere((a) => a == _currentAffirmation);
        _currentAffirmation =
            currentIndex >= 0 && currentIndex < _affirmations.length
                ? _affirmations[currentIndex]
                : _affirmations[0];
      });
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _audioDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _audioPosition = position;
        });
      }
    });
  }

  void _initializeAffirmationTts() {
    _affirmationTtsService.addListener(() {
      if (mounted) {
        setState(() {
          _affirmationTtsLoading = _affirmationTtsService.isLoading;
        });
      }
    });
  }

  Future<void> _playAffirmationTts() async {
    if (_currentAffirmation.isEmpty) return;

    try {
      setState(() {
        _affirmationTtsLoading = true;
      });

      try {
        // Attempt a specific voice first for a calmer tone.
        await _affirmationTtsService.speakText(
          _currentAffirmation,
          voice: 'Aria',
        );
      } catch (e) {
        debugPrint('Affirmation TTS voice failed, retrying default: $e');
        await _affirmationTtsService.speakText(_currentAffirmation);
      }
    } catch (e) {
      debugPrint('Error playing affirmation TTS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedPlayAffirmation),
            backgroundColor: Colors.red.shade400,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _fetchFaithPreference() async {
    setState(() {
      _loadingAffirmations = true;
    });
    try {
      final api = ApiService();
      final profile = await api.getProfile();
      final userData = profile['data'] ?? profile;
      final String? faithPref =
          userData['faith_preference'] ?? userData['faithPreference'];
      String faith = 'neutral';
      if (faithPref != null) {
        final f = faithPref.toLowerCase();
        if (f.contains('christian'))
          faith = 'christian';
        else if (f.contains('muslim'))
          faith = 'muslim';
        else if (f.contains('traditionalist')) faith = 'traditionalist';
      }
      setState(() {
        _currentFaith = faith; // Store the current faith preference
        _affirmations = _faithAffirmations[faith]!;
        _currentAffirmation = _affirmations[0];
        _loadingAffirmations = false;
      });
    } catch (e) {
      setState(() {
        _currentFaith = 'neutral'; // Store the current faith preference
        _affirmations = _faithAffirmations['neutral']!;
        _currentAffirmation = _affirmations[0];
        _loadingAffirmations = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
    } else {
      // Load and play audio - using encouragement audio from assets
      try {
        setState(() {
          _isAudioLoading = true;
        });
        // Set the audio source and play based on the current language
        final locale = Localizations.localeOf(context);
        final assetPath = _audioAssetForLocale(locale);
        await _audioPlayer.setSource(AssetSource(assetPath));
        await _audioPlayer.resume();
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Audio play failed: $e');
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).failedPlayAudio),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  String _audioAssetForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ha':
        return 'audio/ha.mp3';
      case 'pcm':
        return 'audio/pcm.mp3';
      case 'yo':
        return 'audio/yo.mp3';
      case 'ig':
        return 'audio/ig.mp3';
      case 'en':
      default:
        return 'audio/en.mp3';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _affirmationTtsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Localization removed

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Green appbar
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 20),
            decoration: const BoxDecoration(
              color: _primaryTeal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).supportHub,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).supportHubSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Body with daily affirmation and other content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily affirmation card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 130,
                      maxHeight: 200,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _primaryTeal,
                        width: 1,
                      ),
                    ),
                    child: _loadingAffirmations
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              // Top row: spark icon, text, refresh button
                              Row(
                                children: [
                                  const Icon(
                                    Icons.flash_on,
                                    color: _primaryTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)
                                        .dailyAffirmation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _darkGreenText,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Cycle to next affirmation
                                        final currentIdx = _affirmations
                                            .indexOf(_currentAffirmation);
                                        final nextIdx = (currentIdx + 1) %
                                            _affirmations.length;
                                        _currentAffirmation =
                                            _affirmations[nextIdx];
                                      });
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.refresh,
                                          size: 16,
                                          color: _darkGreenText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Affirmation text (expandable)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _currentAffirmation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _darkGreenText,
                                      fontFamily: 'Poppins',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Play button for affirmation TTS (only show if audio enabled)
                              if (_audioEnabled)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _affirmationTtsLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                _primaryTeal.withOpacity(0.6),
                                              ),
                                            ),
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.volume_up_rounded,
                                              color: _primaryTeal,
                                              size: 24,
                                            ),
                                            onPressed: _playAffirmationTts,
                                            tooltip:
                                                AppLocalizations.of(context)
                                                    .readAffirmationAloud,
                                          ),
                                  ],
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Audio encouragement card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
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
                        // Title row with audio icon
                        Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: _primaryTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).audioEncouragement,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Play/Pause button, Title and Progress bar, Duration
                        Row(
                          children: [
                            // Play/Pause button with loading state
                            _isAudioLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          _primaryTeal,
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      _isPlayingAudio
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: _primaryTeal,
                                      size: 40,
                                    ),
                                    onPressed: _togglePlayPause,
                                  ),
                            const SizedBox(width: 12),
                            // Title and Progress bar
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).audioTitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _darkGreenText,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Progress bar with actual duration and position
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 5),
                                      trackHeight: 3,
                                    ),
                                    child: Slider(
                                      value:
                                          _audioPosition.inSeconds.toDouble(),
                                      max: _audioDuration.inSeconds.toDouble() >
                                              0
                                          ? _audioDuration.inSeconds.toDouble()
                                          : 1.0,
                                      activeColor: _primaryTeal,
                                      inactiveColor: Colors.grey.shade300,
                                      onChanged: (value) async {
                                        final position =
                                            Duration(seconds: value.toInt());
                                        await _audioPlayer.seek(position);
                                      },
                                    ),
                                  ),
                                  // Show progress time
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${_formatDuration(_audioPosition)} / ${_formatDuration(_audioDuration)}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Duration display removed (now shown with progress)
                            Text(
                              _formatDuration(_audioDuration),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).culturalGuidance,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CulturalGuidanceScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)
                                  .culturalGuidanceDescription,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Community groups section
                  Row(
                    children: [
                      const Icon(
                        Icons.group,
                        color: _primaryTeal,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).communityGroups,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateGroupScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _darkGreenText,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).create,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Community group card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Group info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group name
                              Text(
                                AppLocalizations.of(context).fertilityCircle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Category badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _primaryTeal,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .generalSupport,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '24 ${AppLocalizations.of(context).members}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Latest message
                              Text(
                                AppLocalizations.of(context).latestMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Right arrow
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)
                                      .groupChatComingSoon)),
                            );
                          },
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CommunityGroupsScreen(),
                          ),
                        );
                      },
                      child: Text(
                          AppLocalizations.of(context).exploreCommunityGroups),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contact Support section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _primaryTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: _primaryTeal,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).contactSupport,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _darkGreenText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context).contactSupportMessage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _darkGreenText,
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _primaryTeal,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: _primaryTeal,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+234-813-202-7445',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _darkGreenText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _primaryTeal,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email,
                                color: _primaryTeal,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'contact@myfertipal.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _darkGreenText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
