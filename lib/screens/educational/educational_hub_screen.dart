import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../services/api_key_config.dart';
import '../../services/yarngpt_tts_service.dart';
import '../../theme.dart';
import 'article_reading_screen.dart';

const Color _primaryTeal = Color(0xFF0EA5A4);
const Color _darkGreenText = Color(0xFF064B23);

class EducationalHubScreen extends StatefulWidget {
  const EducationalHubScreen({super.key});

  @override
  State<EducationalHubScreen> createState() => _EducationalHubScreenState();
}

class _EducationalHubScreenState extends State<EducationalHubScreen> {
  String selectedCategory = '';
  late AudioPlayer _audioPlayer;

  List<Map<String, String>> get allArticles {
    final l10n = AppLocalizations.of(context);
    return [
      {
        'category': l10n.fertilityBasics,
        'title': l10n.article1Title,
        'excerpt': l10n.article1Excerpt,
        'image': 'assets/images/article_1.jpeg',
        'audioUrl': 'audio/article_1.mp3',
        'content': l10n.article1Content,
      },
      {
        'category': l10n.fertilityBasics,
        'title': l10n.article2Title,
        'excerpt': l10n.article2Excerpt,
        'image': 'assets/images/article_2.jpeg',
        'audioUrl': 'audio/article_2.mp3',
        'content': l10n.article2Content,
      },
      {
        'category': l10n.mythsFacts,
        'title': l10n.article3Title,
        'excerpt': l10n.article3Excerpt,
        'image': 'assets/images/article_3.jpeg',
        'audioUrl': 'audio/article_3.mp3',
        'content': l10n.article3Content,
      },
    ];
  }

  List<String> get categories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.fertilityBasics,
      l10n.mythsFacts,
    ];
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedCategories = categories;
    if (updatedCategories.isNotEmpty &&
        (selectedCategory.isEmpty ||
            !updatedCategories.contains(selectedCategory))) {
      selectedCategory = updatedCategories.first;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showAudioModal(BuildContext context, Map<String, String> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AudioPlayerModal(
        audioPlayer: _audioPlayer,
        article: article,
      ),
    ).then((_) {
      // Stop audio when modal is dismissed
      _audioPlayer.stop();
    });
  }

  Widget _buildArticleCard(Map<String, String> article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleReadingScreen(
                imageUrl: article['image'] ?? '',
                title: article['title'] ?? '',
                articleText: article['content'] ?? article['excerpt'] ?? '',
                audioUrl: article['audioUrl'], // Pass audio URL
              ),
            ),
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  article['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            article['category'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context).minsRead,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkGreenText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article['excerpt'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showAudioModal(context, article),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              color: _primaryTeal,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.play_arrow,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context).listen,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            color: _primaryTeal,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).english,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final effectiveCategory = selectedCategory.isEmpty && categories.isNotEmpty
        ? categories.first
        : selectedCategory;
    final filteredArticles = allArticles
        .where((article) => article['category'] == effectiveCategory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).educationalHub,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: effectiveCategory.isEmpty ? null : effectiveCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: _darkGreenText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
            ),
          ),
          // Articles list
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: filteredArticles
                    .map((article) => _buildArticleCard(article))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerModal extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Map<String, String> article;

  const AudioPlayerModal({
    Key? key,
    required this.audioPlayer,
    required this.article,
  }) : super(key: key);

  @override
  State<AudioPlayerModal> createState() => _AudioPlayerModalState();
}

class _AudioPlayerModalState extends State<AudioPlayerModal> {
  late YarnGptTtsService _ttsService;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
        _ttsService = YarnGptTtsService(apiKey: apiKey);
      } else {
        debugPrint('Audio features disabled - API key not configured');
        _ttsService = YarnGptTtsService(apiKey: 'disabled');
      }
    } catch (e) {
      debugPrint('Failed to initialize TTS service: $e');
      _ttsService = YarnGptTtsService(apiKey: 'disabled');
    }
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _ttsService.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _ttsService.isPlaying;
          _duration = _ttsService.duration;
          _position = _ttsService.position;
          _isLoading = _ttsService.isLoading;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        // Pause functionality not yet supported in YarnGptTtsService
        setState(() {
          _errorMessage = 'Pause feature coming soon. Please reload to stop.';
        });
      } else {
        // Get the article content and speak it using YarnGPT TTS
        final articleContent = widget.article['content'] ?? '';
        if (articleContent.isEmpty) {
          setState(() {
            _errorMessage = 'No article content available.';
          });
          return;
        }

        // Speak the article text using YarnGPT TTS
        await _ttsService.speakText(articleContent);
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Playback error. Please try again.';
        });
      }
    }
  }

  Future<void> _setSpeed(double speed) async {
    // Note: YarnGPT TTS API doesn't support playback speed control
    // This is just a UI representation for now
    if (mounted) {
      setState(() => _playbackSpeed = speed);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.article['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _darkGreenText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          activeColor: _primaryTeal,
                          inactiveColor: Colors.grey.shade300,
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          value: _position.inSeconds
                              .toDouble()
                              .clamp(0, _duration.inSeconds.toDouble()),
                          onChanged: (value) {
                            // Seeking not supported with YarnGPT TTS
                            // This is a visual-only slider for now
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed:
                            null, // Disabled: seeking not supported with YarnGPT TTS
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryTeal,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 56,
                                height: 56,
                                child: Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.7),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                                onPressed: _togglePlayPause,
                              ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed:
                            null, // Disabled: seeking not supported with YarnGPT TTS
                      ),
                    ],
                  ),
                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Speed controls
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playback Speed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _playbackSpeed == speed
                                    ? _primaryTeal
                                    : Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => _setSpeed(speed),
                              child: Text(
                                speed == 1.0 ? '1x' : '${speed}x',
                                style: TextStyle(
                                  color: _playbackSpeed == speed
                                      ? Colors.white
                                      : _darkGreenText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
