import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'api_service.dart';


class AudioService with ChangeNotifier {

  final AudioPlayer _player = AudioPlayer();
  final ApiService _api = ApiService();
  String? _currentArticleId;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  String? get currentArticleId => _currentArticleId;
  bool get isPlaying => _isPlaying;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  AudioService() {
    _initAudio();
  }

  Future<void> _initAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> playArticle(String articleId, String audioUrl, {String? languageCode}) async {
    try {
      if (_currentArticleId != articleId) {
        await _player.setUrl(audioUrl);
        _currentArticleId = articleId;
      }
      
      await _player.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> playTTS({
  required String text,
  required String languageCode,
}) async {

  try {

    final response = await _api.generateTTS(
      text: text,
      voice: "Idera",
      language: languageCode,
    );


    final audioUrl = response["audio_url"];


    if(audioUrl != null){

      await _player.setUrl(audioUrl);

      await _player.play();

      _isPlaying = true;

      notifyListeners();

    }


  } catch(e){

    if(kDebugMode){
      print("TTS playback error: $e");
    }

  }

}

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentArticleId = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
    _playbackSpeed = speed;
    notifyListeners();
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
