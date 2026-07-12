import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import 'home_screen.dart';

class GenderPredictionScreen extends StatefulWidget {
  const GenderPredictionScreen({Key? key}) : super(key: key);

  @override
  State<GenderPredictionScreen> createState() => _GenderPredictionScreenState();
}

class _GenderPredictionScreenState extends State<GenderPredictionScreen> {
  String? _selectedGender;
  DateTime? _ovulationDay;
  DateTime? _fertileStart;
  DateTime? _fertileEnd;
  bool _loading = true;
 final AudioPlayer _audioPlayer = AudioPlayer();

bool _isLoadingAudio = false;
bool _isPlayingAudio = false;
String? _audioUrl;

  List<String> get _genderOptions {
    final l10n = AppLocalizations.of(context);
    return [l10n.male, l10n.female, l10n.noPreference];
  }

  @override
  void initState() {
    super.initState();
     AnalyticsService.logScreenView(
      screenName: "Gender",
    );
  _fetchOvulationDay();

_audioPlayer.onPlayerStateChanged.listen((state) {
  if (mounted) {
    setState(() {
      _isPlayingAudio = state == PlayerState.playing;
    });
  }
});
  }



 
     Future<void> _speakInstructions() async {
  try {
    final l10n = AppLocalizations.of(context);

    final text =
        '${l10n.genderPredictionDisclaimer} ${l10n.selectGenderExpectation}';

    setState(() {
      _isLoadingAudio = true;
    });


    final response = await ApiService().post(
      '/user/api/v1/audio/generate-tts',
      {
        "text": text,
        "voice": "Idera",
        "language": "en",
      },
    );


    final audioUrl = response['audio_url'];


    if (audioUrl == null) {
      throw Exception("No audio URL returned");
    }


    await _audioPlayer.play(
      UrlSource(
        audioUrl.toString(),
        mimeType: "audio/mpeg",
      ),
    );


  } catch(e) {

    debugPrint("Gender audio error: $e");

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).failedPlayAudio,
          ),
        ),
      );
    }

  } finally {

    if(mounted){
      setState(() {
        _isLoadingAudio = false;
      });
    }

  }
}
  }

  Future<void> _fetchOvulationDay() async {
    setState(() => _loading = true);
    try {
      final api = ApiService();
      final headers = await api.getHeaders(includeAuth: true);
      final url = Uri.parse('${ApiService.baseUrl}/insights/insights');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = response.body;
        final decoded = data.isNotEmpty
            ? (data.startsWith('[')
                ? List<Map<String, dynamic>>.from(
                    jsonDecode(data).map((e) => Map<String, dynamic>.from(e)))
                : Map<String, dynamic>.from(jsonDecode(data)))
            : null;
        Map<String, dynamic>? latestCycle;
        if (decoded is List && decoded.isNotEmpty) {
          latestCycle = decoded.last;
        } else if (decoded is Map) {
          latestCycle = Map<String, dynamic>.from(decoded);
        }
        if (latestCycle != null) {
          if (latestCycle['ovulation_day'] != null) {
            _ovulationDay = DateTime.tryParse(latestCycle['ovulation_day']);
          }
          if (latestCycle['fertile_period_start'] != null &&
              latestCycle['fertile_period_end'] != null) {
            _fertileStart =
                DateTime.tryParse(latestCycle['fertile_period_start']);
            _fertileEnd = DateTime.tryParse(latestCycle['fertile_period_end']);
          }
        }
      }
    } catch (e) {
      // Handle error
    }
    setState(() => _loading = false);
  }

  List<Map<String, String>> _getAdvice() {
    final l10n = AppLocalizations.of(context);
    if (_ovulationDay == null || _selectedGender == null) return [];
    final List<Map<String, String>> advice = [];
    final maleLabel = l10n.male;
    final femaleLabel = l10n.female;
    for (int i = -3; i <= 1; i++) {
      final day = _ovulationDay!.add(Duration(days: i));
      String tip;
      if (_selectedGender == maleLabel) {
        tip = i == 0 ? l10n.bestChanceForMale : l10n.lowerChanceForMale;
      } else if (_selectedGender == femaleLabel) {
        tip = i < 0 ? l10n.bestChanceForFemale : l10n.lowerChanceForFemale;
      } else {
        tip = l10n.generalAdviceForConception;
      }
      advice.add({
        'date': DateFormat('d MMM').format(day),
        'tip': tip,
      });
    }
    return advice;
  }

  String? getFertileWindowText() {
    if (_fertileStart != null && _fertileEnd != null) {
      final formatter = DateFormat('d MMM');
      return '${formatter.format(_fertileStart!)}–${formatter.format(_fertileEnd!)}';
    }
    return null;
  }

  String? getOvulationDayText() {
    if (_ovulationDay != null) {
      return DateFormat('d MMM').format(_ovulationDay!);
    }
    return null;
  }

  // Update GenderPredictionScreen to look like a chat box
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.genderPredictionTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
                settings: const RouteSettings(name: '/home'),
              ),
            );
          },
        ),
        backgroundColor: const Color(0xFF0EA5A4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speakInstructions,
            tooltip: l10n.readAffirmationAloud,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFFF5F5F0),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Disclaimer message before bubble section
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFD32F2F), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFFD32F2F)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.genderPredictionDisclaimer,
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFFD32F2F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _chatBubble(
                    child: Text(l10n.selectGenderExpectation,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    isBot: true,
                  ),
                  const SizedBox(height: 12),
                  _chatBubble(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _genderOptions.map((option) {
                          final isSelected = _selectedGender == option;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedGender = option);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0EA5A4)
                                      : const Color(0xFF0EA5A4),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    isBot: false,
                  ),
                  const SizedBox(height: 24),
                  if (_selectedGender != null &&
                      (_ovulationDay != null ||
                          (_fertileStart != null && _fertileEnd != null)))
                    _chatBubble(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (getFertileWindowText() != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  '${l10n.fertileWindowLabel}: ${getFertileWindowText()!}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          if (getOvulationDayText() != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  '${l10n.ovulationDayLabel}: ${getOvulationDayText()!}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          Text(l10n.adviceForTiming,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          ..._getAdvice().map((item) => Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(item['date']!),
                                  subtitle: Text(item['tip']!),
                                ),
                              )),
                        ],
                      ),
                      isBot: true,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
                      child: Text(
                        l10n.noPredictionDataAvailable,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _chatBubble({required Widget child, required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBot ? const Color(0xFFE6F4EA) : const Color(0xFF0EA5A4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
