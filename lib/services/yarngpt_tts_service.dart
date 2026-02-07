import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// YarnGPT Text-to-Speech Service
/// Converts text to speech using the YarnGPT API
class YarnGptTtsService extends ChangeNotifier {
  static const String apiUrl = 'https://yarngpt.ai/api/v1/tts';

  final String apiKey;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get duration => _duration;
  Duration get position => _position;

  /// Initialize YarnGptTtsService with API key
  /// API key should be passed from a secure configuration source
  YarnGptTtsService({required this.apiKey}) {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  /// Convert text to speech and play it
  Future<void> speakText(String text, {String? voice}) async {
    if (text.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!kIsWeb) {
        final cachedBytes = await _tryLoadCachedAudio(text, voice: voice);
        if (cachedBytes != null && cachedBytes.isNotEmpty) {
          await _audioPlayer.play(BytesSource(cachedBytes));
          return;
        }
      }

      // Prepare request body
      final Map<String, dynamic> body = {
        'text': text,
      };

      // Only add voice if explicitly provided
      if (voice != null && voice.isNotEmpty) {
        body['voice'] = voice;
      }

      debugPrint('YarnGPT TTS: Sending request to $apiUrl');
      debugPrint('YarnGPT TTS: Request body: $body');

      // Call YarnGPT API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('YarnGPT TTS: Response status: ${response.statusCode}');
      debugPrint('YarnGPT TTS: Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Response is binary MP3 data
        final audioBytes = response.bodyBytes;
        debugPrint(
            'YarnGPT TTS: Received ${audioBytes.length} bytes of audio data');
        if (!kIsWeb) {
          await _cacheAudioBytes(text, audioBytes, voice: voice);
        }
        // Play audio from memory so it works on web and mobile.
        await _audioPlayer.play(BytesSource(audioBytes));
      } else if (response.statusCode == 401) {
        throw Exception(
            'YarnGPT Authentication Failed (401): Invalid or expired API key. '
            'Response: ${response.body}');
      } else if (response.statusCode == 403) {
        throw Exception(
            'YarnGPT Access Denied (403): API key does not have required permissions. '
            'Response: ${response.body}');
      } else {
        throw Exception(
            'YarnGPT API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('YarnGPT TTS Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> _tryLoadCachedAudio(String text, {String? voice}) async {
    try {
      final file = await _getCacheFile(text, voice: voice);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          return bytes;
        }
      }
    } catch (e) {
      debugPrint('YarnGPT TTS: Cache read failed: $e');
    }

    return null;
  }

  Future<void> _cacheAudioBytes(
    String text,
    Uint8List bytes, {
    String? voice,
  }) async {
    try {
      final file = await _getCacheFile(text, voice: voice);
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('YarnGPT TTS: Cache write failed: $e');
    }
  }

  Future<File> _getCacheFile(String text, {String? voice}) async {
    final hash = _buildCacheKey(text, voice: voice);
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/yarngpt_$hash.mp3');
  }

  String _buildCacheKey(String text, {String? voice}) {
    final payload = '${voice ?? ''}::$text';
    return sha1.convert(utf8.encode(payload)).toString();
  }

  /// Pause audio playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume audio playback
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// Stop audio playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
