import 'package:flutter/material.dart';
 
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
 
import '../generated/l10n/app_localizations.dart';
import '../widgets/swipeable_green_calendar.dart';
import '../widgets/reminder_panel.dart';
import 'tracking/log_symptom_screen.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../services/notification_reminder_service.dart';
 
const Color _primaryTeal = Color(0xFF0EA5A4);
const Color _darkGreenText = Color(0xFF064B23);
 
// Default period length constant (replace with profile value when available)
const int _defaultPeriodLength = 5;
 
class CalendarTabScreen extends StatefulWidget {
  final ValueNotifier<bool>? refreshNotifier;
  const CalendarTabScreen({Key? key, this.refreshNotifier}) : super(key: key);
 
  @override
  State<CalendarTabScreen> createState() => _CalendarTabScreenState();
}
 
class _CalendarTabScreenState extends State<CalendarTabScreen> {
  Set<DateTime> _ovulationDates = {};
  Set<DateTime> _fertileWindowDays = {};
  final ScrollController _calendarScrollController = ScrollController();
  bool _isCalendarCollapsed = false;
  Set<DateTime> _selectedCalendarDays = {};
  Set<DateTime> _nextPeriodDays = {};
  Set<String> _selectedCalendarDaysFormatted = {};
  String? _lastPeriodDate;
  List<String> _loggedSymptoms = [];
  bool _isSymptomsLoading = false;
  late NotificationReminderService _reminderService;
  bool _remindersInitialized = false;
 
  @override
  void initState() {
    super.initState();
    _calendarScrollController.addListener(_onCalendarScroll);
    _loadTappedDays();
    _fetchLoggedSymptoms();
    _initializeReminders();
    widget.refreshNotifier?.addListener(_handleRefreshRequest);
  }
 
  Future<void> _initializeReminders() async {
    _reminderService = NotificationReminderService();
    await _reminderService.initialize();
    if (!mounted) return;
    setState(() {
      _remindersInitialized = true;
    });
  }
 
  void _handleRefreshRequest() {
    if (widget.refreshNotifier?.value == true) {
      _fetchLoggedSymptoms();
      widget.refreshNotifier?.value = false;
    }
  }
 
  Future<void> _loadTappedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDays = prefs.getStringList('tapped_days');
    if (savedDays != null && savedDays.isNotEmpty) {
      setState(() {
        _selectedCalendarDaysFormatted = savedDays.toSet();
        _selectedCalendarDays = savedDays.map((s) => DateTime.parse(s)).toSet();
        if (_selectedCalendarDays.isNotEmpty) {
          final latest =
              _selectedCalendarDays.reduce((a, b) => a.isAfter(b) ? a : b);
          _lastPeriodDate = DateFormat('yyyy-MM-dd').format(latest);
        } else {
          _lastPeriodDate = null;
        }
      });
    } else {
      if (_lastPeriodDate != null) {
        final lastPeriod = DateTime.parse(_lastPeriodDate!);
        final periodDays = List<DateTime>.generate(
          _defaultPeriodLength,
          (i) =>
              DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day + i),
        );
        setState(() {
          _selectedCalendarDays = periodDays.toSet();
          _selectedCalendarDaysFormatted =
              periodDays.map((d) => DateFormat('yyyy-MM-dd').format(d)).toSet();
        });
        await prefs.setStringList(
            'tapped_days', _selectedCalendarDaysFormatted.toList());
      }
    }
  }
 
  Future<void> _fetchLoggedSymptoms() async {
    setState(() {
      _isSymptomsLoading = true;
    });
    try {
      final api = ApiService();
      final headers = await api.getHeaders(includeAuth: true);
      final url = Uri.parse('${ApiService.baseUrl}/insights/insights');
      final response = await http.get(url, headers: headers);
      debugPrint('GET /insights/insights response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final latestCycle = data.last;
          debugPrint('Latest cycle: $latestCycle');
          if (latestCycle['fertile_period_start'] != null &&
              latestCycle['fertile_period_end'] != null) {
            _setFertileWindow(latestCycle['fertile_period_start'],
                latestCycle['fertile_period_end']);
          }
          if (latestCycle['next_period'] != null &&
              latestCycle['period_length'] != null) {
            final nextPeriodStart = DateTime.parse(latestCycle['next_period']);
            final periodLength = latestCycle['period_length'];
            final nextPeriodDays = List<DateTime>.generate(
                periodLength, (i) => nextPeriodStart.add(Duration(days: i)));
            setState(() {
              _nextPeriodDays = nextPeriodDays.toSet();
              _selectedCalendarDays = {..._selectedCalendarDays};
              _selectedCalendarDaysFormatted = _selectedCalendarDays
                  .map((d) => DateFormat('yyyy-MM-dd').format(d))
                  .toSet();
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList(
                'tapped_days', _selectedCalendarDaysFormatted.toList());
          }
          if (latestCycle['symptoms'] != null) {
            debugPrint('Symptoms found: ${latestCycle['symptoms']}');
            setState(() {
              _loggedSymptoms = List<String>.from(latestCycle['symptoms']);
              _isSymptomsLoading = false;
            });
          } else {
            debugPrint('No symptoms found in latest cycle.');
            if (latestCycle['ovulation_day'] != null) {
              _setOvulationDay(latestCycle['ovulation_day']);
            }
            setState(() {
              _isSymptomsLoading = false;
            });
          }
        } else if (data is Map) {
          debugPrint('Data is a Map: $data');
          if (data['fertile_period_start'] != null &&
              data['fertile_period_end'] != null) {
            _setFertileWindow(
                data['fertile_period_start'], data['fertile_period_end']);
          }
          if (data['next_period'] != null && data['period_length'] != null) {
            final nextPeriodStart = DateTime.parse(data['next_period']);
            final periodLength = data['period_length'];
            final nextPeriodDays = List<DateTime>.generate(
                periodLength, (i) => nextPeriodStart.add(Duration(days: i)));
            setState(() {
              _nextPeriodDays = nextPeriodDays.toSet();
              _selectedCalendarDays = {..._selectedCalendarDays};
              _selectedCalendarDaysFormatted = _selectedCalendarDays
                  .map((d) => DateFormat('yyyy-MM-dd').format(d))
                  .toSet();
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList(
                'tapped_days', _selectedCalendarDaysFormatted.toList());
          }
          if (data['symptoms'] != null) {
            debugPrint('Symptoms found: ${data['symptoms']}');
            setState(() {
              _loggedSymptoms = List<String>.from(data['symptoms']);
              _isSymptomsLoading = false;
            });
          } else {
            debugPrint('No symptoms found in data map.');
            setState(() {
              _isSymptomsLoading = false;
            });
          }
          if (data['ovulation_day'] != null) {
            _setOvulationDay(data['ovulation_day']);
          }
        } else {
          debugPrint('Data is neither List nor Map: $data');
          setState(() {
            _isSymptomsLoading = false;
          });
        }
      } else {
        debugPrint('Non-200 response, setting _loggedSymptoms to empty.');
        setState(() {
          _loggedSymptoms = [];
          _isSymptomsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exception in _fetchLoggedSymptoms: $e');
      if (!mounted) return;
      setState(() {
        _loggedSymptoms = [];
        _isSymptomsLoading = false;
      });
    }
  }
 
  void _setFertileWindow(dynamic start, dynamic end) {
    try {
      final s = DateTime.parse(start.toString());
      final e = DateTime.parse(end.toString());
      final days = <DateTime>{};
      for (int i = 0; i <= e.difference(s).inDays; i++) {
        days.add(DateTime(s.year, s.month, s.day + i));
      }
      setState(() {
        _fertileWindowDays = days;
      });
    } catch (e) {
      debugPrint('Failed to parse fertile window: $e');
    }
  }
 
  void _setOvulationDay(dynamic dateVal) {
    try {
      final d = DateTime.parse(dateVal.toString());
      setState(() {
        _ovulationDates = {DateTime(d.year, d.month, d.day)};
      });
    } catch (e) {
      debugPrint('Failed to parse ovulation day: $e');
    }
  }
 
  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_handleRefreshRequest);
    _calendarScrollController.removeListener(_onCalendarScroll);
    _calendarScrollController.dispose();
    super.dispose();
  }
 
  void _onCalendarScroll() {
    final currentOffset = _calendarScrollController.offset;
    if (currentOffset > 60 && !_isCalendarCollapsed) {
      setState(() {
        _isCalendarCollapsed = true;
      });
    } else if (currentOffset < 20 && _isCalendarCollapsed) {
      setState(() {
        _isCalendarCollapsed = false;
      });
    }
  }
 
  void _toggleCalendarDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final isAdding =
        !_selectedCalendarDays.any((d) => _isSameDay(d, normalized));
 
    setState(() {
      if (!isAdding) {
        _selectedCalendarDays = _selectedCalendarDays
            .where((d) => !_isSameDay(d, normalized))
            .toSet();
      } else {
        _selectedCalendarDays = {..._selectedCalendarDays, normalized};
      }
      _selectedCalendarDaysFormatted = _selectedCalendarDays
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toSet();
      if (_selectedCalendarDays.isNotEmpty) {
        final latest =
            _selectedCalendarDays.reduce((a, b) => a.isAfter(b) ? a : b);
        _lastPeriodDate = DateFormat('yyyy-MM-dd').format(latest);
      } else {
        _lastPeriodDate = null;
      }
    });
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'tapped_days', _selectedCalendarDaysFormatted.toList());
 
    // Only auto-generate period days when the user taps the very first day
    if (isAdding && _selectedCalendarDays.length == 1 && _lastPeriodDate != null) {
      final lastPeriod = DateTime.parse(_lastPeriodDate!);
      final periodDays = List<DateTime>.generate(
        _defaultPeriodLength,
        (i) =>
            DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day + i),
      );
      setState(() {
        _selectedCalendarDays = periodDays.toSet();
        _selectedCalendarDaysFormatted =
            periodDays.map((d) => DateFormat('yyyy-MM-dd').format(d)).toSet();
      });
      await prefs.setStringList(
          'tapped_days', _selectedCalendarDaysFormatted.toList());
    }
 
    final calculatedPeriodLength = _calculatePeriodLength();
    final calculatedCycleLength = _calculateCycleLength();
 
    if (_selectedCalendarDays.isNotEmpty) {
      try {
        final api = ApiService();
        final profileJson = await api.getProfile();
        final userData = profileJson['data'] ?? profileJson;
        final int? age = userData['age'];
        final String? ttcHistory =
            userData['ttc_history'] ?? userData['ttcHistory'];
        final String? faithPreference =
            userData['faith_preference'] ?? userData['faithPreference'];
        final bool? audioPreference = userData['audio_preference'];
 
        final finalPeriodLength =
            calculatedPeriodLength ?? userData['period_length'] ?? _defaultPeriodLength;
        final finalCycleLength =
            calculatedCycleLength ?? userData['cycle_length'] ?? 28;
 
        if (_lastPeriodDate != null) {
          final lastPeriod = DateTime.parse(_lastPeriodDate!);
          final nextPeriodStart =
              lastPeriod.add(Duration(days: finalCycleLength));
          final nextPeriodDaysList = List<DateTime>.generate(
            finalPeriodLength,
            (i) => DateTime(nextPeriodStart.year, nextPeriodStart.month,
                nextPeriodStart.day + i),
          );
          setState(() {
            _nextPeriodDays = nextPeriodDaysList.toSet();
          });
          debugPrint(
              'Calculated next period: ${_nextPeriodDays.map((d) => DateFormat('yyyy-MM-dd').format(d)).join(', ')}');
        }
 
        await api.updateProfile(
          age: age,
          cycleLength: finalCycleLength,
          periodLength: finalPeriodLength,
          lastPeriodDate: _lastPeriodDate,
          ttcHistory: ttcHistory,
          faithPreference: faithPreference,
          audioPreference: audioPreference,
        );
 
        debugPrint(
            'Profile updated with cycleLength: $finalCycleLength, periodLength: $finalPeriodLength');
 
        await AnalyticsService.logPeriodLogged(
          periodLength: finalPeriodLength,
          cycleLength: finalCycleLength,
          source: 'calendar_tab',
        );
      } catch (e) {
        debugPrint('Failed to sync last period date to profile: ${e.toString()}');
      }
    }
  }
 
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
 
  int? _calculatePeriodLength() {
    if (_selectedCalendarDays.isEmpty) return null;
    final sortedDays = _selectedCalendarDays.toList()
      ..sort((a, b) => a.compareTo(b));
    int consecutiveCount = 1;
    for (int i = 1; i < sortedDays.length; i++) {
      final dayDifference = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (dayDifference == 1) {
        consecutiveCount++;
      } else {
        break;
      }
    }
    debugPrint('Calculated period length: $consecutiveCount days');
    return consecutiveCount;
  }
 
  int? _calculateCycleLength() {
    if (_selectedCalendarDays.length < 2) return null;
    final sortedDays = _selectedCalendarDays.toList()
      ..sort((a, b) => a.compareTo(b));
 
    final periodStarts = <DateTime>[];
    periodStarts.add(sortedDays.first);
 
    for (int i = 1; i < sortedDays.length; i++) {
      final dayDifference = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (dayDifference > 1) {
        periodStarts.add(sortedDays[i]);
      }
    }
 
    if (periodStarts.length >= 2) {
      final cycleLengths = <int>[];
      for (int i = 1; i < periodStarts.length; i++) {
        final gap = periodStarts[i].difference(periodStarts[i - 1]).inDays;
        if (gap > 0) {
          cycleLengths.add(gap);
        }
      }
      if (cycleLengths.isNotEmpty) {
        final averageCycleLength =
            (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length)
                .round();
        debugPrint(
            'Calculated cycle length: $averageCycleLength days (from ${cycleLengths.length} cycle(s))');
        return averageCycleLength;
      }
    }
    return null;
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryTeal,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isCalendarCollapsed ? 80 : null,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isCalendarCollapsed) ...[
                            const SizedBox(height: 10),
                            // FIX: added missing comma above
                            SwipeableGreenCalendar(
                              initialMonth: DateTime.now(),
                              selectedDates: _selectedCalendarDays,
                              nextPeriodDays: _nextPeriodDays,
                              periodDates: _selectedCalendarDays,
                              ovulationDates: _ovulationDates,
                              fertileWindowDates: _fertileWindowDays,
                              onDateToggle: _toggleCalendarDate,
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isCalendarCollapsed = false),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy')
                                        .format(DateTime.now()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.expand_more,
                                      color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: RefreshIndicator(
                      onRefresh: _fetchLoggedSymptoms,
                      child: SingleChildScrollView(
                        controller: _calendarScrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_remindersInitialized)
                              ReminderPanel(reminderService: _reminderService),
                            const SizedBox(height: 16),
                            _buildCalendarKey(),
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context).loggedSymptoms,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: _clearCalendarDays,
                                  icon: const Icon(Icons.delete_outline,
                                      color: _darkGreenText),
                                  label: Text(
                                    AppLocalizations.of(context).clear,
                                    style: const TextStyle(
                                      color: _darkGreenText,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (_isSymptomsLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else ...[
                              if (_loggedSymptoms.isEmpty)
                                Text(
                                    AppLocalizations.of(context)
                                        .noSymptomsLogged,
                                    style: const TextStyle(color: Colors.grey)),
                              if (_loggedSymptoms.isNotEmpty)
                                ..._loggedSymptoms.map(
                                  (symptom) => _buildLoggedSymptomItem(
                                    symptom,
                                    Icons.check_circle,
                                    _primaryTeal,
                                  ),
                                ),
                            ],
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton(
                backgroundColor: _darkGreenText,
                elevation: 6,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LogSymptomScreen(),
                      settings: RouteSettings(
                        name: '/log-symptoms',
                        arguments: {
                          'lastPeriodDate': _lastPeriodDate,
                          'cycleLength': _selectedCalendarDays.length,
                          'periodLength': _selectedCalendarDays.length,
                        },
                      ),
                    ),
                  );
                  if (result != null) {
                    if (result is Map && result['symptoms'] != null) {
                      debugPrint(
                          'Received logged symptoms: ${result['symptoms']}');
                    }
                    _fetchLoggedSymptoms();
                  }
                },
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // FIX: single definition of _buildCalendarKey (duplicate removed)
  Widget _buildCalendarKey() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: [
          _keyItem(const Color(0xFFF06292), 'Period'),
          _keyItem(const Color(0xFF81C784), 'Fertile Window'),
          _keyItem(const Color(0xFF6A1B9A), 'Ovulation'),
          _keyItem(
            Colors.transparent,
            'Predicted Period',
            border: const Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }
 
  // FIX: single definition of _keyItem (duplicate removed)
  Widget _keyItem(Color color, String text, {Color? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border:
                border != null ? Border.all(color: border, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
 
  Widget _buildLoggedSymptomItem(
      String symptom, IconData icon, Color iconColor) {
    String displaySymptom = symptom;
    String sendSymptom = symptom;
    if (symptom.contains(':')) {
      final parts = symptom.split(':');
      if (parts.length == 2) {
        displaySymptom = '${parts[0].trim()} - ${parts[1].trim()}';
        sendSymptom = displaySymptom;
      }
    } else if (symptom.contains('-')) {
      final parts = symptom.split('-');
      if (parts.length == 2) {
        displaySymptom = '${parts[0].trim()} - ${parts[1].trim()}';
        sendSymptom = displaySymptom;
      }
    }
 
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => debugPrint('Symptom sent: $sendSymptom'),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displaySymptom,
                style: const TextStyle(
                  fontSize: 16,
                  color: _darkGreenText,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Future<void> _clearCalendarDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tapped_days');
      // FIX: use reassignment instead of .clear() for consistency
      setState(() {
        _selectedCalendarDays = {};
        _selectedCalendarDaysFormatted = {};
        _nextPeriodDays = {};
        _ovulationDates = {};
        _fertileWindowDays = {};
        _lastPeriodDate = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).calendarCleared),
            backgroundColor: _primaryTeal,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing calendar days: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context).failedToClearCalendar}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}