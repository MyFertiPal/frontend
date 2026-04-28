import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';

class LogSymptomScreen extends StatefulWidget {
  const LogSymptomScreen({super.key});

  @override
  State<LogSymptomScreen> createState() => _LogSymptomScreenState();
}

class _LogSymptomScreenState extends State<LogSymptomScreen> {
  String? _expandedSymptom;
  Map<String, String?> _selectedOptions = {};
  // Change Mood to allow multiple selections
  Map<String, List<String>> _multiSelectedOptions = {'Mood': []};
  bool _isSaving = false;

  List<String> get _selectedSymptoms {
    // For multi-select symptoms, add all selected values with container name
    List<String> symptoms = [];
    // Always add selected Mood values first
    for (var mood in _multiSelectedOptions['Mood'] ?? []) {
      symptoms.add('Mood -$mood');
    }
    // Add other selected symptoms
    _selectedOptions.forEach((key, value) {
      if (key != 'Mood' && value != null) {
        symptoms.add('$key -$value');
      }
    });
    return symptoms;
  }

  Map<String, List<String>> get _symptomOptions {
    final l10n = AppLocalizations.of(context);
    return {
      l10n.mood: [l10n.fatigue, l10n.anxiety, l10n.moodSwings, l10n.sadness],
      l10n.bleeding: [l10n.light, l10n.medium, l10n.heavy, l10n.spotting],
      l10n.cervicalMucus: [
        l10n.dry,
        l10n.sticky,
        l10n.creamy,
        l10n.watery,
        l10n.eggWhite
      ],
      l10n.sexualActivity: [l10n.protected, l10n.unprotected, l10n.none],
      l10n.pain: [l10n.mild, l10n.moderate, l10n.severe],
      l10n.abdominalCramps: [l10n.mild, l10n.moderate, l10n.severe],
    };
  }

  List<String> get _symptomCategories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.mood,
      l10n.bleeding,
      l10n.cervicalMucus,
      l10n.sexualActivity,
      l10n.pain,
      l10n.abdominalCramps,
    ];
  }

  Future<void> _saveSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectAtLeastOneSymptom),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final api = ApiService();

      // Fetch user profile for cycleLength and periodLength
      final profileJson = await api.getProfile();

      // Defensive: handle both direct and nested user fields
      final userData = profileJson['data'] ?? profileJson;
      String? lastPeriodDate =
          userData['last_period_date'] ?? userData['lastPeriodDate'];
      int? cycleLength = userData['cycle_length'] ?? userData['cycleLength'];
      int? periodLength = userData['period_length'] ?? userData['periodLength'];

      // Fallback: if lastPeriodDate is null, set to today
      if (lastPeriodDate == null) {
        lastPeriodDate = DateTime.now().toIso8601String().split('T')[0];
      }

      final payload = {
        "last_period_date": lastPeriodDate,
        "cycle_length": cycleLength,
        "period_length": periodLength,
        "symptoms": _selectedSymptoms,
      };

      debugPrint('Sending log payload: ${jsonEncode(payload)}');

      final headers = await api.getHeaders(includeAuth: true);
      final url = Uri.parse('${ApiService.baseUrl}/insights/insights');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('Log API response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).symptomsLoggedSuccessfully),
              backgroundColor: Color(0xFF0EA5A4),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop({
            'symptoms': _selectedSymptoms,
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context).failedToSaveSymptoms}: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving symptoms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              color: Color(0xFF0EA5A4),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0EA5A4),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.logSymptoms,
                  style: const TextStyle(
                    color: Color(0xFF0EA5A4),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Symptom list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  ..._symptomCategories.map((symptom) {
                    return Column(
                      children: [
                        _buildSymptomContainer(symptom),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                  if (_selectedSymptoms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Text(
                        l10n.noSymptomsSelected,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF0EA5A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xFF0EA5A4),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSymptoms,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF0EA5A4),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.save,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomContainer(String symptomName) {
    final l10n = AppLocalizations.of(context);
    final moodKey = l10n.mood;
    final options = _symptomOptions[symptomName] ?? [];
    final isExpanded = _expandedSymptom == symptomName;
    return Container(
      // ...existing code...
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedSymptom = isExpanded ? null : symptomName;
              });
            },
            child: Container(
              height: 83,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0EA5A4),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.water_drop,
                        color: Color(0xFF0EA5A4),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    symptomName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  bool isSelected;
                  if (symptomName == moodKey) {
                    isSelected =
                        _multiSelectedOptions['Mood']?.contains(option) ??
                            false;
                  } else {
                    isSelected = _selectedOptions[symptomName] == option;
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (symptomName == moodKey) {
                          final current = _multiSelectedOptions['Mood'] ?? [];
                          if (isSelected) {
                            _multiSelectedOptions['Mood'] = List.from(current)
                              ..remove(option);
                          } else {
                            _multiSelectedOptions['Mood'] = List.from(current)
                              ..add(option);
                          }
                        } else {
                          _selectedOptions[symptomName] = option;
                          // Do NOT collapse after selection
                          // _expandedSymptom = null; // Remove this line
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0EA5A4)
                            : const Color(0xFF0EA5A4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
