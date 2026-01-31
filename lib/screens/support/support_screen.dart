import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../community/community_groups_screen.dart';
import '../community/create_group_screen.dart';
import 'cultural_guidance_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int _selectedIndex = 3;
  String _currentAffirmation = "";
  List<String> _affirmations = [];
  String _faith = 'neutral';
  bool _loadingAffirmations = true;

  // Audio player properties
  late AudioPlayer _audioPlayer;
  bool _isPlayingAudio = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

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
    _initializeAudioPlayer();
    _fetchFaithPreference();
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
        _faith = faith;
        _affirmations = _faithAffirmations[faith]!;
        _currentAffirmation = _affirmations[0];
        _loadingAffirmations = false;
      });
    } catch (e) {
      setState(() {
        _faith = 'neutral';
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
        // Set streaming mode for responsive playback
        await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
        await _audioPlayer.play(AssetSource('audio/encouragement.wav'));
      } catch (e) {
        debugPrint('Audio play failed: $e');
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
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
              color: Color(0xFF2E683D),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.supportHub,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.supportHubSubtitle,
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
                      color: const Color(0xFFA8D497).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF2E683D),
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
                                    color: Color(0xFF2E683D),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .dailyAffirmation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E683D),
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
                                          color: Colors.black,
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
                                      color: Color(0xFF2E683D),
                                      fontFamily: 'Poppins',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
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
                              color: Color(0xFFA8D497),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.audioEncouragement,
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
                            // Play/Pause button
                            IconButton(
                              icon: Icon(
                                _isPlayingAudio
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: const Color(0xFFA8D497),
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
                                    AppLocalizations.of(context)!.audioTitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
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
                                      activeColor: const Color(0xFF2E683D),
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
                    AppLocalizations.of(context)!.culturalGuidance,
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
                              AppLocalizations.of(context)!
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
                        color: Color(0xFF2E683D),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.communityGroups,
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
                            color: const Color(0xFFA8D497),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Color(0xFF2E683D),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.create,
                                style: const TextStyle(
                                  color: Color(0xFF2E683D),
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
                                AppLocalizations.of(context)!.fertilityCircle,
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
                                      color: const Color(0xFFA8D497),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .generalSupport,
                                      style: const TextStyle(
                                        color: Color(0xFF2E683D),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '24 ${AppLocalizations.of(context)!.members}',
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
                                AppLocalizations.of(context)!.latestMessage,
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
                                  content: Text(AppLocalizations.of(context)!
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
                          AppLocalizations.of(context)!.exploreCommunityGroups),
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
