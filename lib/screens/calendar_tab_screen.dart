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
const Color _lightGreenBg = Color(0xFFE8FAF3);
const Color _borderGreen = Color(0xFFB6E8D3);

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

  // Derived summary values
  int? _displayPeriodLength;
  int? _displayCycleLength;
  DateTime? _displayOvulationDay;
  DateTime? _displayNextPeriod;
  DateTime? _displayFertileStart;
  DateTime? _displayFertileEnd;

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
      _updateSummaryFromLocal();
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
        _updateSummaryFromLocal();
      }
    }
  }

  /// Derives summary values from locally stored tapped days when API has not responded yet
  void _updateSummaryFromLocal() {
    final periodLen = _calculatePeriodLength();
    final cycleLen = _calculateCycleLength();
    if (_lastPeriodDate != null) {
      final lastPeriod = DateTime.parse(_lastPeriodDate!);
      final cl = cycleLen ?? 28;
      final nextPeriod = lastPeriod.add(Duration(days: cl));
      final ovulation = lastPeriod.add(Duration(days: cl - 14));
      final fertileStart = ovulation.subtract(const Duration(days: 5));
      final fertileEnd = ovulation.add(const Duration(days: 1));
      setState(() {
        _displayPeriodLength = periodLen ?? _defaultPeriodLength;
        _displayCycleLength = cl;
        _displayNextPeriod = nextPeriod;
        _displayOvulationDay = ovulation;
        _displayFertileStart = fertileStart;
        _displayFertileEnd = fertileEnd;
      });
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          _applyInsightsData(Map<dynamic, dynamic>.from(data.last));
        } else if (data is Map) {
          _applyInsightsData(data);
        } else {
          setState(() => _isSymptomsLoading = false);
        }
      } else {
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

  void _applyInsightsData(Map<dynamic, dynamic> d) async {
    if (d['fertile_period_start'] != null && d['fertile_period_end'] != null) {
      _setFertileWindow(d['fertile_period_start'], d['fertile_period_end']);
    }
    if (d['next_period'] != null && d['period_length'] != null) {
      final nextPeriodStart = DateTime.parse(d['next_period'].toString());
      final periodLength = d['period_length'] as int;
      final nextPeriodDays = List<DateTime>.generate(
          periodLength, (i) => nextPeriodStart.add(Duration(days: i)));
      setState(() {
        _nextPeriodDays = nextPeriodDays.toSet();
        _displayNextPeriod = nextPeriodStart;
        if (periodLength > 0) _displayPeriodLength = periodLength;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'tapped_days', _selectedCalendarDaysFormatted.toList());
    }
    if (d['ovulation_day'] != null) {
      _setOvulationDay(d['ovulation_day']);
    }
    if (d['cycle_length'] != null) {
      setState(() => _displayCycleLength = d['cycle_length'] as int);
    }
    if (d['symptoms'] != null) {
      setState(() {
        _loggedSymptoms = List<String>.from(d['symptoms']);
        _isSymptomsLoading = false;
      });
    } else {
      setState(() => _isSymptomsLoading = false);
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
        _displayFertileStart = s;
        _displayFertileEnd = e;
      });
    } catch (e) {
      debugPrint('Failed to parse fertile window: $e');
    }
  }

  void _setOvulationDay(dynamic dateVal) {
    try {
      final d = DateTime.parse(dateVal.toString());
      final normalized = DateTime(d.year, d.month, d.day);
      setState(() {
        _ovulationDates = {normalized};
        _displayOvulationDay = normalized;
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
      setState(() => _isCalendarCollapsed = true);
    } else if (currentOffset < 20 && _isCalendarCollapsed) {
      setState(() => _isCalendarCollapsed = false);
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

    // Only auto-generate when user taps the very first day
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

    _updateSummaryFromLocal();

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
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        consecutiveCount++;
      } else {
        break;
      }
    }
    return consecutiveCount;
  }

  int? _calculateCycleLength() {
    if (_selectedCalendarDays.length < 2) return null;
    final sortedDays = _selectedCalendarDays.toList()
      ..sort((a, b) => a.compareTo(b));
    final periodStarts = <DateTime>[sortedDays.first];
    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays > 1) {
        periodStarts.add(sortedDays[i]);
      }
    }
    if (periodStarts.length >= 2) {
      final cycleLengths = <int>[];
      for (int i = 1; i < periodStarts.length; i++) {
        final gap = periodStarts[i].difference(periodStarts[i - 1]).inDays;
        if (gap > 0) cycleLengths.add(gap);
      }
      if (cycleLengths.isNotEmpty) {
        return (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length)
            .round();
      }
    }
    return null;
  }

  void _openLogSymptomScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LogSymptomScreen(),
        settings: RouteSettings(
          name: '/log-symptoms',
          arguments: {
            'lastPeriodDate': _lastPeriodDate,
            'cycleLength': _displayCycleLength ?? 28,
            'periodLength': _displayPeriodLength ?? _defaultPeriodLength,
          },
        ),
      ),
    );
    if (result != null) {
      _fetchLoggedSymptoms();
    }
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
                            horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_remindersInitialized) ...[
                              ReminderPanel(reminderService: _reminderService),
                              const SizedBox(height: 20),
                            ],

                            // Calendar colour key
                            _buildCalendarKey(),

                            // Cycle summary stat cards
                            _buildCycleSummary(),
                            const SizedBox(height: 20),

                            // Fertile window detail card
                            if (_displayFertileStart != null &&
                                _displayFertileEnd != null) ...[
                              _buildFertileWindowCard(),
                              const SizedBox(height: 20),
                            ],

                            // Symptoms chips + see all
                            _buildSymptomsSection(),

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
                onPressed: _openLogSymptomScreen,
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Calendar colour key
  // ─────────────────────────────────────────────
  Widget _buildCalendarKey() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderGreen),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: [
          _keyItem(const Color(0xFFF06292), 'Period'),
          _keyItem(const Color(0xFF81C784), 'Fertile window'),
          _keyItem(const Color(0xFF6A1B9A), 'Ovulation'),
          _keyItem(Colors.transparent, 'Predicted period',
              border: const Color(0xFFD32F2F)),
        ],
      ),
    );
  }

  Widget _keyItem(Color color, String text, {Color? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border:
                border != null ? Border.all(color: border, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _darkGreenText,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Cycle summary 2x2 stat grid
  // ─────────────────────────────────────────────
  Widget _buildCycleSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkGreenText,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 14),
        if (_lastPeriodDate == null)
          _buildEmptyHint(
            icon: Icons.touch_app_outlined,
            text: 'Tap days on the calendar to start tracking your cycle',
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: [
              _statCard(
                icon: Icons.calendar_today_outlined,
                label: 'Period length',
                value: _displayPeriodLength != null
                    ? '${_displayPeriodLength} days'
                    : '–',
                sub: 'Based on logs',
              ),
              _statCard(
                icon: Icons.loop_outlined,
                label: 'Cycle length',
                value: _displayCycleLength != null
                    ? '${_displayCycleLength} days'
                    : '–',
                sub: 'Average',
              ),
              _statCard(
                icon: Icons.event_outlined,
                label: 'Next period',
                value: _displayNextPeriod != null
                    ? DateFormat('MMM d').format(_displayNextPeriod!)
                    : '–',
                sub: 'Predicted start',
              ),
              _statCard(
                icon: Icons.favorite_border,
                label: 'Ovulation day',
                value: _displayOvulationDay != null
                    ? DateFormat('MMM d').format(_displayOvulationDay!)
                    : '–',
                sub: 'Estimated',
              ),
            ],
          ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryTeal, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _darkGreenText,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Fertile window card
  // ─────────────────────────────────────────────
  Widget _buildFertileWindowCard() {
    final start = _displayFertileStart!;
    final end = _displayFertileEnd!;
    final cycleLen = _displayCycleLength ?? 28;
    final lastPeriod =
        _lastPeriodDate != null ? DateTime.parse(_lastPeriodDate!) : null;

    double barStart = 0.0;
    double barWidth = 0.22;
    if (lastPeriod != null) {
      final daysIn = start.difference(lastPeriod).inDays;
      final windowLen = end.difference(start).inDays + 1;
      barStart = (daysIn / cycleLen).clamp(0.0, 1.0);
      barWidth = (windowLen / cycleLen).clamp(0.0, 1.0 - barStart);
    }

    final startDayNum =
        lastPeriod != null ? start.difference(lastPeriod).inDays + 1 : '?';
    final endDayNum =
        lastPeriod != null ? end.difference(lastPeriod).inDays + 1 : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fertile window',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _darkGreenText,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _lightGreenBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderGreen),
                ),
                child: Text(
                  '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d').format(end)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkGreenText,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: totalWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Positioned(
                    left: totalWidth * barStart,
                    child: Container(
                      height: 8,
                      width: totalWidth * barWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Days $startDayNum–$endDayNum of your ${cycleLen}-day cycle',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _borderGreen),
          const SizedBox(height: 14),
          Text(
            'Conception timing & baby sex probability',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _conceptionPill(
                  icon: Icons.female,
                  label: 'Girl',
                  desc: 'Days before\novulation',
                  bgColor: const Color(0xFFFFF0F5),
                  borderColor: const Color(0xFFF9A8C9),
                  iconColor: const Color(0xFFBE185D),
                  textColor: const Color(0xFFBE185D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _conceptionPill(
                  icon: Icons.male,
                  label: 'Boy',
                  desc: 'On or after\novulation',
                  bgColor: const Color(0xFFE8F4FD),
                  borderColor: const Color(0xFF93C5FD),
                  iconColor: const Color(0xFF1E40AF),
                  textColor: const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conceptionPill({
    required IconData icon,
    required String label,
    required String desc,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Symptoms section (chips)
  // ─────────────────────────────────────────────
  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Logged symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _darkGreenText,
                fontFamily: 'Poppins',
              ),
            ),
            Row(
              children: [
                if (_loggedSymptoms.isNotEmpty) ...[
                  GestureDetector(
                    onTap: _openLogSymptomScreen,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        color: _primaryTeal,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  onTap: _clearCalendarDays,
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline,
                          color: _darkGreenText, size: 17),
                      SizedBox(width: 3),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 13,
                          color: _darkGreenText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_isSymptomsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _primaryTeal),
            ),
          )
        else if (_loggedSymptoms.isEmpty)
          _buildEmptyHint(
            icon: Icons.add_circle_outline,
            text: 'No symptoms logged yet. Tap to log how you\'re feeling.',
            onTap: _openLogSymptomScreen,
            showChevron: true,
          )
        else
          _buildSymptomChips(),
      ],
    );
  }

  Widget _buildSymptomChips() {
    final preview = _loggedSymptoms.take(4).toList();
    final extra = _loggedSymptoms.length - preview.length;

    final chipColors = [
      const Color(0xFFF06292),
      _primaryTeal,
      const Color(0xFF81C784),
      const Color(0xFF6A1B9A),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...preview.asMap().entries.map((entry) {
          final i = entry.key;
          final symptom = entry.value;
          String display = symptom;
          if (symptom.contains(':')) {
            final p = symptom.split(':');
            if (p.length == 2) display = '${p[0].trim()} · ${p[1].trim()}';
          } else if (symptom.contains('-')) {
            final p = symptom.split('-');
            if (p.length == 2) display = '${p[0].trim()} · ${p[1].trim()}';
          }
          return GestureDetector(
            onTap: _openLogSymptomScreen,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _borderGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: chipColors[i % chipColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    display,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _darkGreenText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (extra > 0)
          GestureDetector(
            onTap: _openLogSymptomScreen,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _lightGreenBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _borderGreen),
              ),
              child: Text(
                '+$extra more',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _darkGreenText,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Shared empty-state hint tile
  // ─────────────────────────────────────────────
  Widget _buildEmptyHint({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _lightGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderGreen),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryTeal, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: _darkGreenText,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: _primaryTeal, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Clear calendar
  // ─────────────────────────────────────────────
  Future<void> _clearCalendarDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tapped_days');
      setState(() {
        _selectedCalendarDays = {};
        _selectedCalendarDaysFormatted = {};
        _nextPeriodDays = {};
        _ovulationDates = {};
        _fertileWindowDays = {};
        _lastPeriodDate = null;
        _displayPeriodLength = null;
        _displayCycleLength = null;
        _displayNextPeriod = null;
        _displayOvulationDay = null;
        _displayFertileStart = null;
        _displayFertileEnd = null;
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