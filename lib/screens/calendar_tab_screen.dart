import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/period_service.dart';
import '../services/analytics_service.dart';
import '../generated/l10n/app_localizations.dart';

/// ============================================================
/// DAY TYPES
/// ============================================================

enum DayType {
  period,
  fertile,
  ovulation,
  predicted,
}

/// ============================================================
/// COLORS
/// ============================================================

class _TrackingColors {
  static const header = Color(0xFFF98080);

  static const teal = Color(0xFF0F6B5C);
  static const tealDark = Color(0xFF0B4A40);

  static const period = Color(0xFFF98080);

  static const fertile = Color(0xFFD9F2E6);
  static const fertileText = Color(0xFF1F7A5C);

  static const predictedBorder = Color(0xFFF6B4B4);

  static const cardBorder = Color(0xFFF6C9C9);

  static const bg = Color(0xFFFAFAFA);

  static const textMuted = Color(0xFF8A8F98);
}

/// ============================================================
/// SUMMARY
/// ============================================================

class SummaryStat {
  final String value;
  final String label;

  const SummaryStat({
    required this.value,
    required this.label,
  });
}

/// ============================================================
/// CALENDAR
/// ============================================================

class CalendarTabScreen extends StatefulWidget {
  final DateTime today;
  final Map<DateTime, DayType>? dayMarkers;

  CalendarTabScreen({
    super.key,
    DateTime? today,
    this.dayMarkers,
  }) : today = today ?? DateTime.now();

  @override
  State<CalendarTabScreen> createState() =>
      CalendarTabScreenState();
}

class CalendarTabScreenState extends State<CalendarTabScreen>
    with WidgetsBindingObserver {
  final LocalPeriodService _periodService =
      LocalPeriodService();

  final ApiService _api = ApiService();

  List<dynamic> _loggedSymptoms = [];

  DateTime? _selectedDate;
  DateTime? _lastPeriod;
  DateTime? _activePeriodStart;

  bool _isLoading = false;
  bool _hasCalendarError = false;

  int _cycleLength = 0;
  int _periodLength = 0;

  String? _nextPeriod;
  String? _ovulationDay;
  String? _fertileStart;
  String? _fertileEnd;

  late DateTime _visibleMonth;

  Map<DateTime, DayType> _backendMarkers = {};
  Set<DateTime> _localPeriodDays = {};
  Map<DateTime, DayType> _dayMarkers = {};

  int _calendarRequestId = 0;
  int _symptomsRequestId = 0;

  AppLocalizations get _l10n =>
      AppLocalizations.of(context);

  /// ==========================================================
  /// DATE HELPERS
  /// ==========================================================

  static DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  int _daysBetween(DateTime from, DateTime to) {
    return _normalize(to)
        .difference(_normalize(from))
        .inDays;
  }

  String _formatDateForApi(DateTime date) {
    final d = _normalize(date);

    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    try {
      return _normalize(DateTime.parse(text));
    } catch (_) {
      return null;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    return valueString.isEmpty ? null : valueString;
  }

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  /// ==========================================================
  /// LOCALIZED MONTHS
  /// ==========================================================

  List<String> get _monthNames => [
        _l10n.jan,
        _l10n.feb,
        _l10n.mar,
        _l10n.apr,
        _l10n.may,
        _l10n.jun,
        _l10n.jul,
        _l10n.aug,
        _l10n.sep,
        _l10n.oct,
        _l10n.nov,
        _l10n.dec,
      ];

  List<String> get _fullWeekdayNames => [
        _l10n.monday,
        _l10n.tuesday,
        _l10n.wednesday,
        _l10n.thursday,
        _l10n.friday,
        _l10n.saturday,
        _l10n.sunday,
      ];

  List<String> get _shortWeekdayNames {
    return _fullWeekdayNames.map((day) {
      final trimmed = day.trim();
      return trimmed.isEmpty
          ? ''
          : trimmed.characters.first.toUpperCase();
    }).toList();
  }

  /// ==========================================================
  /// SUMMARY
  /// ==========================================================

  List<SummaryStat> get summaryStats {
    return [
      SummaryStat(
        value: _cycleLength > 0
            ? _l10n.days(_cycleLength)
            : '--',
        label: _l10n.cycleLength,
      ),
      SummaryStat(
        value: _periodLength > 0
            ? _l10n.days(_periodLength)
            : '--',
        label: _l10n.periodLength,
      ),
      SummaryStat(
        value: _formatFertileWindow(),
        label: _l10n.fertileWindow,
      ),
    ];
  }

  String _formatFertileWindow() {
    if (_fertileStart == null ||
        _fertileEnd == null) {
      return '--';
    }

    final start = _parseDate(_fertileStart);
    final end = _parseDate(_fertileEnd);

    if (start == null || end == null) {
      return '--';
    }

    return '${_monthNames[start.month - 1]} ${start.day} – '
        '${_monthNames[end.month - 1]} ${end.day}';
  }

  /// ==========================================================
  /// LIFECYCLE
  /// ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    AnalyticsService.logScreenView(
      screenName: 'CalendarTabScreen',
    );

    AnalyticsService.logCalendarViewed();

    final today = _normalize(DateTime.now());

    _visibleMonth = DateTime(
      today.year,
      today.month,
      1,
    );

    unawaited(_refreshCalendar());
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed &&
        mounted) {
      unawaited(_refreshCalendar(force: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ==========================================================
  /// REFRESH
  /// ==========================================================

  Future<void> refresh() async {
    await _refreshCalendar(force: true);
  }

  Future<void> _refreshCalendar({
    bool force = false,
  }) async {
    if (_isLoading && !force) {
      return;
    }

    final requestId = ++_calendarRequestId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasCalendarError = false;
      });
    }

    try {
      await _loadCycle(requestId);

      if (!mounted ||
          requestId != _calendarRequestId) {
        return;
      }

      await _loadSymptomsForVisibleMonth();
    } catch (e) {
      debugPrint('Calendar refresh error: $e');

      if (mounted &&
          requestId == _calendarRequestId) {
        setState(() {
          _hasCalendarError = true;
        });
      }
    } finally {
      if (mounted &&
          requestId == _calendarRequestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ==========================================================
  /// LOAD CYCLE
  /// ==========================================================

  Future<void> _loadCycle(int requestId) async {
    Map<String, dynamic>? profile;
    List<dynamic> insights = [];

    _nextPeriod = null;
    _ovulationDay = null;
    _fertileStart = null;
    _fertileEnd = null;

    try {
      profile = await _api.getProfile();
    } catch (e) {
      debugPrint('getProfile error: $e');
    }

    if (!mounted ||
        requestId != _calendarRequestId) {
      return;
    }

    if (profile != null) {
      _cycleLength =
          _toInt(profile['cycle_length']);

      _periodLength =
          _toInt(profile['period_length']);

      _lastPeriod =
          _parseDate(profile['last_period_date']);
    }

    try {
      insights = await _api.getInsights();
    } catch (e) {
      debugPrint('getInsights error: $e');
    }

    if (!mounted ||
        requestId != _calendarRequestId) {
      return;
    }

    final currentInsight =
        _findCurrentCycleInsight(insights);

    if (currentInsight != null) {
      _nextPeriod = _stringValue(
        currentInsight['next_period_date'] ??
            currentInsight['next_period'],
      );

      _ovulationDay = _stringValue(
        currentInsight['ovulation_day'],
      );

      _fertileStart = _stringValue(
        currentInsight['fertile_period_start'],
      );

      _fertileEnd = _stringValue(
        currentInsight['fertile_period_end'],
      );
    }

    _ensurePredictionFallback();

    if (_fertileStart != null &&
        _fertileEnd != null) {
      AnalyticsService.logFertileWindowViewed();
    }

    await _loadLocalPeriods();

    if (!mounted ||
        requestId != _calendarRequestId) {
      return;
    }

    _buildBackendMarkers();
    _rebuildMergedMarkers();

    setState(() {});
  }

  /// ==========================================================
  /// FIND CURRENT INSIGHT
  /// ==========================================================

  Map<String, dynamic>? _findCurrentCycleInsight(
    List<dynamic> insights,
  ) {
    final currentLastPeriod =
        _lastPeriod == null
            ? null
            : _formatDateForApi(_lastPeriod!);

    if (currentLastPeriod != null) {
      for (final item in insights) {
        if (item is! Map) {
          continue;
        }

        final insight =
            Map<String, dynamic>.from(item);

        final start =
            _extractInsightStartDate(insight);

        if (start == currentLastPeriod) {
          return insight;
        }
      }
    }

    // Only use an undated insight if the backend
    // did not associate it with another cycle.
    for (final item in insights) {
      if (item is! Map) {
        continue;
      }

      final insight =
          Map<String, dynamic>.from(item);

      final hasCycleDate =
          insight.containsKey('last_period_date') ||
              insight.containsKey('period_start_date') ||
              insight.containsKey('cycle_start_date');

      if (!hasCycleDate) {
        return insight;
      }
    }

    return null;
  }

  String? _extractInsightStartDate(
    Map<String, dynamic> insight,
  ) {
    final raw =
        insight['last_period_date'] ??
            insight['period_start_date'] ??
            insight['cycle_start_date'];

    final parsed = _parseDate(raw);

    return parsed == null
        ? null
        : _formatDateForApi(parsed);
  }

  /// ==========================================================
  /// PREDICTION FALLBACK
  /// ==========================================================

  void _ensurePredictionFallback() {
    if (_lastPeriod == null ||
        _cycleLength <= 0) {
      return;
    }

    final lastPeriod = _lastPeriod!;

    final expectedNext =
        _normalize(
      lastPeriod.add(
        Duration(days: _cycleLength),
      ),
    );

    final backendNext =
        _parseDate(_nextPeriod);

    if (backendNext == null ||
        backendNext.isBefore(lastPeriod)) {
      _nextPeriod =
          _formatDateForApi(expectedNext);
    }

    final next =
        _parseDate(_nextPeriod) ??
            expectedNext;

    final backendOvulation =
        _parseDate(_ovulationDay);

    if (backendOvulation == null ||
        backendOvulation.isBefore(lastPeriod) ||
        backendOvulation.isAfter(next)) {
      final fallback =
          _normalize(
        next.subtract(
          const Duration(days: 14),
        ),
      );

      _ovulationDay =
          _formatDateForApi(fallback);
    }

    final ovulation =
        _parseDate(_ovulationDay) ??
            _normalize(
              next.subtract(
                const Duration(days: 14),
              ),
            );

    final fertileStart =
        _parseDate(_fertileStart);

    final fertileEnd =
        _parseDate(_fertileEnd);

    final validFertile =
        fertileStart != null &&
            fertileEnd != null &&
            !fertileEnd.isBefore(fertileStart) &&
            !fertileStart.isBefore(lastPeriod) &&
            !fertileEnd.isAfter(next);

    if (!validFertile) {
      _fertileStart = _formatDateForApi(
        _normalize(
          ovulation.subtract(
            const Duration(days: 5),
          ),
        ),
      );

      _fertileEnd = _formatDateForApi(
        _normalize(
          ovulation.add(
            const Duration(days: 1),
          ),
        ),
      );
    }
  }

  /// ==========================================================
  /// LOCAL PERIOD DATA
  /// ==========================================================

  Future<void> _loadLocalPeriods() async {
    try {
      final logs =
          await _periodService.getPeriodLogs();

      _localPeriodDays =
          logs.map(_normalize).toSet();

      _activePeriodStart =
          _findLatestPeriodStart(
        _localPeriodDays,
      );
    } catch (e) {
      debugPrint(
        'Local period load error: $e',
      );

      _localPeriodDays = {};
      _activePeriodStart = null;
    }
  }

  DateTime? _findLatestPeriodStart(
    Set<DateTime> dates,
  ) {
    if (dates.isEmpty) {
      return null;
    }

    final sorted = dates.toList()..sort();

    DateTime start = sorted.last;

    while (dates.contains(
      start.subtract(
        const Duration(days: 1),
      ),
    )) {
      start = start.subtract(
        const Duration(days: 1),
      );
    }

    return start;
  }

  /// ==========================================================
  /// MARKERS
  /// ==========================================================

  void _buildBackendMarkers() {
    final markers = <DateTime, DayType>{};

    // Actual current period.
    if (_lastPeriod != null &&
        _periodLength > 0) {
      for (var i = 0; i < _periodLength; i++) {
        final date = _normalize(
          _lastPeriod!.add(
            Duration(days: i),
          ),
        );

        markers[date] = DayType.period;
      }
    }

    // Fertile window.
    final fertileStart =
        _parseDate(_fertileStart);

    final fertileEnd =
        _parseDate(_fertileEnd);

    if (fertileStart != null &&
        fertileEnd != null &&
        !fertileEnd.isBefore(fertileStart)) {
      var date = fertileStart;

      while (!date.isAfter(fertileEnd)) {
        if (!markers.containsKey(date)) {
          markers[date] = DayType.fertile;
        }

        date = date.add(
          const Duration(days: 1),
        );
      }
    }

    // Ovulation.
    final ovulation =
        _parseDate(_ovulationDay);

    if (ovulation != null &&
        markers[ovulation] != DayType.period) {
      markers[ovulation] =
          DayType.ovulation;
    }

    // Predicted next period.
    final nextPeriod =
        _parseDate(_nextPeriod);

    if (nextPeriod != null &&
        _periodLength > 0) {
      for (var i = 0; i < _periodLength; i++) {
        final date = _normalize(
          nextPeriod.add(
            Duration(days: i),
          ),
        );

        // Never overwrite actual/fertility/ovulation data.
        if (!markers.containsKey(date)) {
          markers[date] =
              DayType.predicted;
        }
      }
    }

    _backendMarkers = markers;
  }

  void _rebuildMergedMarkers() {
    final merged =
        Map<DateTime, DayType>.from(
      _backendMarkers,
    );

    // User-entered periods always override predictions.
    for (final date in _localPeriodDays) {
      merged[_normalize(date)] =
          DayType.period;
    }

    _dayMarkers = merged;
  }

  /// ==========================================================
  /// SYMPTOMS
  /// ==========================================================

  Future<void>
      _loadSymptomsForVisibleMonth() async {
    final requestId = ++_symptomsRequestId;

    final month = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final end = DateTime(
      month.year,
      month.month,
      _daysInMonth(month),
    );

    try {
      final symptoms =
          await _api.getSymptoms(
        startDate: month,
        endDate: end,
      );

      if (!mounted ||
          requestId != _symptomsRequestId) {
        return;
      }

      setState(() {
        _loggedSymptoms =
            symptoms;
      });
    } catch (e) {
      debugPrint(
        'getSymptoms error: $e',
      );

      if (!mounted ||
          requestId != _symptomsRequestId) {
        return;
      }

      setState(() {
        _loggedSymptoms = [];
      });
    }
  }

  /// ==========================================================
  /// NAVIGATION
  /// ==========================================================

  void _goToPreviousMonth() {
    ++_symptomsRequestId;

    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
        1,
      );
    });

    unawaited(
      _loadSymptomsForVisibleMonth(),
    );
  }

  void _goToNextMonth() {
    ++_symptomsRequestId;

    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        1,
      );
    });

    unawaited(
      _loadSymptomsForVisibleMonth(),
    );
  }

  void _goToToday() {
    final today =
        _normalize(DateTime.now());

    setState(() {
      _visibleMonth = DateTime(
        today.year,
        today.month,
        1,
      );
    });

    unawaited(
      _loadSymptomsForVisibleMonth(),
    );
  }

  /// ==========================================================
  /// ADD PERIOD
  /// ==========================================================

  Future<void> _openAddPeriod() async {
    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddPeriodScreen(
          initialPeriodDays:
              Set<DateTime>.from(
            _localPeriodDays,
          ),
          periodLength:
              _periodLength,
          initialMonth:
              _visibleMonth,
          cycleLength:
              _cycleLength,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshCalendar(force: true);
    }
  }
    /// ==========================================================
  /// BUILD
  /// ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _TrackingColors.bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              _refreshCalendar(force: true),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildHero(),
                _buildCalendarSection(),
                _buildLegend(),
                const SizedBox(height: 8),
                _buildSummaryRow(),
                const SizedBox(height: 24),
                _buildLoggedSymptoms(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ==========================================================
  /// HERO
  /// ==========================================================

  Widget _buildHero() {
    final today =
        _normalize(DateTime.now());

    final todayLabel =
        '${_fullWeekday(today.weekday)}, '
        '${_monthNames[today.month - 1]} '
        '${today.day}';

    final days = List.generate(
      5,
      (index) => today.add(
        Duration(days: index - 2),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          22,
          22,
          22,
          26,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.today,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0B5D4D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              todayLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B5D4D),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: days.map((date) {
                return _WeekDateItem(
                  weekday:
                      _shortWeekday(date.weekday),
                  day: date.day,
                  isToday:
                      _sameDate(date, today),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _fullWeekday(int weekday) {
    return _fullWeekdayNames[weekday - 1];
  }

  String _shortWeekday(int weekday) {
    return _shortWeekdayNames[weekday - 1];
  }

  /// ==========================================================
  /// CALENDAR SECTION
  /// ==========================================================

  Widget _buildCalendarSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: _buildCalendarCard(),
    );
  }

  Widget _buildCalendarCard() {
    final daysInMonth =
        _daysInMonth(_visibleMonth);

    final firstWeekdayOffset =
        _visibleMonth.weekday - 1;

    final cells = <int?>[
      ...List.filled(
        firstWeekdayOffset,
        null,
      ),
      for (
        var day = 1;
        day <= daysInMonth;
        day++
      )
        day,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed:
                    _goToPreviousMonth,
                icon: const Icon(
                  Icons.chevron_left,
                ),
                color:
                    _TrackingColors.textMuted,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthNames[_visibleMonth.month - 1]} '
                    '${_visibleMonth.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed:
                    _goToNextMonth,
                icon: const Icon(
                  Icons.chevron_right,
                ),
                color:
                    _TrackingColors.textMuted,
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToToday,
              child: Text(_l10n.today),
            ),
          ),

          const SizedBox(height: 4),

          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            children:
                _shortWeekdayNames.map(
              (weekday) {
                return Center(
                  child: Text(
                    weekday,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w500,
                      color:
                          _TrackingColors
                              .textMuted,
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 4),

          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder:
                (context, index) {
              final day = cells[index];

              if (day == null) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );

              final normalized =
                  _normalize(date);

              return _CalendarDayCell(
                day: day,
                type:
                    _dayMarkers[normalized],
                isToday:
                    _sameDate(
                  normalized,
                  DateTime.now(),
                ),
                isSelected:
                    _sameDate(
                  _selectedDate,
                  normalized,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : _openAddPeriod,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add / edit period',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _TrackingColors.tealDark,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (_isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              minHeight: 2,
            ),
          ],

          if (_hasCalendarError) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  _refreshCalendar(force: true),
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Unable to refresh cycle data. Try again.',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ==========================================================
  /// LEGEND
  /// ==========================================================

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        0,
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          _legendItem(
            _TrackingColors.period,
            _l10n.period,
          ),
          _legendItem(
            _TrackingColors.fertile,
            _l10n.fertileWindow,
          ),
          _legendItem(
            _TrackingColors.tealDark,
            _l10n.ovulation,
          ),
          _legendOutlineItem(
            _l10n.predicted,
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    Color color,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _legendOutlineItem(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  _TrackingColors.predictedBorder,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors.textMuted,
          ),
        ),
      ],
    );
  }

  /// ==========================================================
  /// SUMMARY
  /// ==========================================================

  Widget _buildSummaryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount: summaryStats.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat =
              summaryStats[index];

          return _SummaryCard(
            value: stat.value,
            label: stat.label,
          );
        },
      ),
    );
  }

  /// ==========================================================
  /// SYMPTOMS
  /// ==========================================================

  Widget _buildLoggedSymptoms() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.loggedSymptoms,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (_loggedSymptoms.isEmpty)
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Text(
                  _l10n.noSymptomsLogged,
                  style: const TextStyle(
                    color:
                        _TrackingColors.textMuted,
                  ),
                ),
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              if (item is! Map) {
                return const SizedBox.shrink();
              }

              final symptoms =
                  item['symptoms'];

              final symptomText =
                  symptoms is List
                      ? symptoms
                          .where(
                            (e) =>
                                e != null &&
                                e.toString()
                                    .trim()
                                    .isNotEmpty,
                          )
                          .join(', ')
                      : (symptoms
                                  ?.toString()
                                  .trim() ??
                              '');

              if (symptomText.isEmpty) {
                return const SizedBox.shrink();
              }

              final createdAt =
                  item['created_at']
                          ?.toString()
                          .trim() ??
                      '';

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite_outline,
                    color:
                        _TrackingColors.tealDark,
                  ),
                  title:
                      Text(symptomText),
                  subtitle:
                      createdAt.isEmpty
                          ? null
                          : Text(createdAt),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// WEEK DATE ITEM
/// ============================================================

class _WeekDateItem extends StatelessWidget {
  final String weekday;
  final int day;
  final bool isToday;

  const _WeekDateItem({
    required this.weekday,
    required this.day,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Semantics(
        label: 'Today, $weekday $day',
        child: Container(
          width: 64,
          height: 64,
          decoration:
              const BoxDecoration(
            color: Color(0xFF18B7B3),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style:
                    const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$day',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Text(
            weekday,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$day',
            style:
                const TextStyle(
              color: Color(0xFF0B5D4D),
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// CALENDAR DAY CELL
/// ============================================================

class _CalendarDayCell extends StatelessWidget {
  final int day;
  final DayType? type;
  final bool isToday;
  final bool isSelected;

  const _CalendarDayCell({
    required this.day,
    required this.type,
    required this.isToday,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color textColor = Colors.black87;

    Border? border;

    if (type == DayType.period) {
      backgroundColor =
          _TrackingColors.period;
      textColor = Colors.white;
    } else if (type == DayType.ovulation) {
      backgroundColor =
          _TrackingColors.tealDark;
      textColor = Colors.white;
    } else if (type == DayType.fertile) {
      backgroundColor =
          _TrackingColors.fertile;
      textColor =
          _TrackingColors.fertileText;
    } else if (type == DayType.predicted) {
      border = Border.all(
        color:
            _TrackingColors.predictedBorder,
        width: 2,
      );
      textColor =
          _TrackingColors.period;
    }

    if (isToday &&
        type != DayType.period &&
        type != DayType.ovulation) {
      border = Border.all(
        color: _TrackingColors.teal,
        width: 2,
      );
    }

    if (isSelected) {
      border = Border.all(
        color: _TrackingColors.tealDark,
        width: 2.5,
      );
    }

    return Semantics(
      label: type == DayType.period
          ? '$day, period'
          : type == DayType.ovulation
              ? '$day, estimated ovulation'
              : type == DayType.fertile
                  ? '$day, estimated fertile window'
                  : type == DayType.predicted
                      ? '$day, predicted period'
                      : '$day',
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight:
                  type == DayType.period ||
                          type == DayType.ovulation
                      ? FontWeight.w600
                      : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// SUMMARY CARD
/// ============================================================

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              _TrackingColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color:
                  _TrackingColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
/// ============================================================
/// ADD / EDIT PERIOD SCREEN
/// ============================================================

class AddPeriodScreen extends StatefulWidget {
  final Set<DateTime> initialPeriodDays;
  final int periodLength;
  final DateTime initialMonth;
  final int cycleLength;

  const AddPeriodScreen({
    super.key,
    required this.initialPeriodDays,
    required this.periodLength,
    required this.initialMonth,
    required this.cycleLength,
  });

  @override
  State<AddPeriodScreen> createState() =>
      _AddPeriodScreenState();
}

class _AddPeriodScreenState
    extends State<AddPeriodScreen> {
  final LocalPeriodService _periodService =
      LocalPeriodService();

  final ApiService _api = ApiService();

  late Set<DateTime> _selectedDays;
  late Set<DateTime> _originalDays;

  late PageController _pageController;
  late DateTime _initialMonth;

  bool _saving = false;

  static const int _monthRange = 60;

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedDays =
        widget.initialPeriodDays
            .map(_normalize)
            .toSet();

    _originalDays =
        Set<DateTime>.from(
      _selectedDays,
    );

    _initialMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );

    _pageController =
        PageController(
      initialPage: _monthRange,
    );
  }

  /// ==========================================================
  /// MONTH
  /// ==========================================================

  DateTime _monthForPage(int page) {
    return DateTime(
      _initialMonth.year,
      _initialMonth.month +
          (page - _monthRange),
      1,
    );
  }

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  /// ==========================================================
  /// SELECTED PERIOD EPISODES
  /// ==========================================================

  List<Set<DateTime>> _findEpisodes(
    Set<DateTime> dates,
  ) {
    if (dates.isEmpty) {
      return [];
    }

    final sorted = dates.toList()..sort();

    final episodes = <Set<DateTime>>[];
    var current = <DateTime>{sorted.first};

    for (var i = 1; i < sorted.length; i++) {
      final previous = sorted[i - 1];
      final currentDate = sorted[i];

      final gap =
          currentDate
              .difference(previous)
              .inDays;

      if (gap == 1) {
        current.add(currentDate);
      } else {
        episodes.add(current);
        current = <DateTime>{currentDate};
      }
    }

    episodes.add(current);

    return episodes;
  }

  /// ==========================================================
  /// CURRENT EDITABLE EPISODE
  /// ==========================================================

  Set<DateTime> _currentEpisode() {
    final episodes =
        _findEpisodes(_originalDays);

    if (episodes.isEmpty) {
      return {};
    }

    episodes.sort((a, b) {
      final aLast = a.toList()..sort();
      final bLast = b.toList()..sort();

      return aLast.last.compareTo(
        bLast.last,
      );
    });

    return Set<DateTime>.from(
      episodes.last,
    );
  }

  /// ==========================================================
  /// TOGGLE
  /// ==========================================================

  void _toggleDate(DateTime date) {
    if (_saving) {
      return;
    }

    final normalized =
        _normalize(date);

    setState(() {
      if (_selectedDays.contains(normalized)) {
        _selectedDays.remove(normalized);
        return;
      }

      /// If there is no period yet, the first selected
      /// date becomes the anchor.
      if (_selectedDays.isEmpty) {
        _selectedDays.add(normalized);
        return;
      }

      /// Keep the selected period continuous.
      final sorted =
          _selectedDays.toList()..sort();

      final first = sorted.first;
      final last = sorted.last;

      final before =
          normalized.difference(first).inDays;

      final after =
          normalized.difference(last).inDays;

      if (before == -1 ||
          after == 1) {
        _selectedDays.add(normalized);
        return;
      }

      /// Allow tapping inside the current range.
      if (!normalized.isBefore(first) &&
          !normalized.isAfter(last)) {
        _selectedDays.add(normalized);
        return;
      }

      /// Don't silently create a disconnected period.
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Period days should be consecutive. '
            'Add days next to the selected period.',
          ),
        ),
      );
    });
  }

  /// ==========================================================
  /// SAVE
  /// ==========================================================

  Future<void> _savePeriod() async {
    if (_saving) {
      return;
    }

    final selected =
        Set<DateTime>.from(_selectedDays);

    final original =
        Set<DateTime>.from(_originalDays);

    /// Allow deletion only when editing an existing
    /// period episode.
    final editingExisting =
        original.isNotEmpty;

    if (selected.isEmpty &&
        !editingExisting) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one period day.',
          ),
        ),
      );

      return;
    }

    /// Don't allow accidental multiple episodes
    /// to be created from this screen.
    final episodes =
        _findEpisodes(selected);

    if (episodes.length > 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select consecutive period days.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final added =
          selected.difference(original);

      final removed =
          original.difference(selected);

      /// --------------------------------------------------------
      /// SAVE LOCAL DATA
      /// --------------------------------------------------------

      if (added.isNotEmpty) {
        await _periodService.savePeriods(
          added,
        );
      }

      if (removed.isNotEmpty) {
        await _periodService.deletePeriods(
          removed,
        );
      }

      /// --------------------------------------------------------
      /// DETERMINE PERIOD START
      /// --------------------------------------------------------

      DateTime? periodStart;

      if (selected.isNotEmpty) {
        final sorted =
            selected.toList()..sort();

        periodStart = sorted.first;
      }

      /// --------------------------------------------------------
      /// DETERMINE WHETHER THE PERIOD START CHANGED
      /// --------------------------------------------------------

      DateTime? originalStart;

      if (original.isNotEmpty) {
        final sorted =
            original.toList()..sort();

        originalStart = sorted.first;
      }

      final cycleChanged =
          periodStart != null &&
          !_sameDate(
            periodStart,
            originalStart,
          );

      /// --------------------------------------------------------
      /// GENERATE INSIGHTS ONLY WHEN NECESSARY
      /// --------------------------------------------------------

      if (cycleChanged &&
          widget.cycleLength > 0 &&
          widget.periodLength > 0) {
        try {
          await _api.generateInsights(
            cycleLength:
                widget.cycleLength,
            lastPeriodDate:
                _formatDateForApi(
              periodStart!,
            ),
            periodLength:
                widget.periodLength,
            symptoms: const ['none'],
          );
        } catch (e) {
          /// Period saving already succeeded.
          ///
          /// Prediction generation failure must not
          /// cause the user's period entry to be lost.
          debugPrint(
            'Prediction generation failed: $e',
          );
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint(
        'Save period error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'We could not save your period. '
            'Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  bool _sameDate(
    DateTime? a,
    DateTime? b,
  ) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatDateForApi(DateTime date) {
    final d = _normalize(date);

    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// ==========================================================
  /// BUILD
  /// ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _TrackingColors.bg,
      appBar: AppBar(
        title: const Text(
          'Add / edit period',
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            _TrackingColors.tealDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              8,
            ),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                _selectedDays.isEmpty
                    ? 'Select the first day of your period'
                    : 'Select the consecutive days of your period',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      _TrackingColors.tealDark,
                ),
              ),
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Swipe vertically between months. Tap a date to add or remove it.',
                style:
                    TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: PageView.builder(
              controller:
                  _pageController,
              scrollDirection:
                  Axis.vertical,
              itemCount:
                  (_monthRange * 2) + 1,
              itemBuilder:
                  (context, page) {
                return _buildMonth(
                  _monthForPage(page),
                );
              },
            ),
          ),

          _buildBottomBar(),
        ],
      ),
    );
  }

  /// ==========================================================
  /// MONTH
  /// ==========================================================

  Widget _buildMonth(DateTime month) {
    final days =
        _daysInMonth(month);

    final offset =
        month.weekday - 1;

    final cells = <int?>[
      ...List.filled(
        offset,
        null,
      ),
      for (
        var day = 1;
        day <= days;
        day++
      )
        day,
    ];

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '${_monthName(month.month)} '
                '${month.year}',
                style:
                    const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      _TrackingColors.tealDark,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  _AddPeriodWeekday('M'),
                  _AddPeriodWeekday('T'),
                  _AddPeriodWeekday('W'),
                  _AddPeriodWeekday('T'),
                  _AddPeriodWeekday('F'),
                  _AddPeriodWeekday('S'),
                  _AddPeriodWeekday('S'),
                ],
              ),

              const SizedBox(height: 8),

              Expanded(
                child:
                    GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      cells.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemBuilder:
                      (context, index) {
                    final day =
                        cells[index];

                    if (day == null) {
                      return const SizedBox();
                    }

                    final date =
                        DateTime(
                      month.year,
                      month.month,
                      day,
                    );

                    final selected =
                        _selectedDays
                            .contains(date);

                    return Semantics(
                      button: true,
                      label: selected
                          ? '$day, selected period day'
                          : '$day, period day',
                      child:
                          GestureDetector(
                        behavior:
                            HitTestBehavior
                                .opaque,
                        onTap: _saving
                            ? null
                            : () =>
                                _toggleDate(
                                  date,
                                ),
                        child:
                            Center(
                          child:
                              AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds:
                                  150,
                            ),
                            width: 42,
                            height: 42,
                            alignment:
                                Alignment
                                    .center,
                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? _TrackingColors
                                      .period
                                  : Colors
                                      .transparent,
                              shape:
                                  BoxShape
                                      .circle,
                              border:
                                  selected
                                      ? null
                                      : Border.all(
                                          color: Colors
                                              .transparent,
                                        ),
                            ),
                            child:
                                Text(
                              '$day',
                              style:
                                  TextStyle(
                                color: selected
                                    ? Colors
                                        .white
                                    : Colors
                                        .black87,
                                fontWeight:
                                    selected
                                        ? FontWeight
                                            .w600
                                        : FontWeight
                                            .normal,
                                fontSize:
                                    14,
                              ),
                            ),
                          ),
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
    );
  }

 String _monthName(int month) {
  final months = [
    AppLocalizations.of(context).jan,
    AppLocalizations.of(context).feb,
    AppLocalizations.of(context).mar,
    AppLocalizations.of(context).apr,
    AppLocalizations.of(context).may,
    AppLocalizations.of(context).jun,
    AppLocalizations.of(context).jul,
    AppLocalizations.of(context).aug,
    AppLocalizations.of(context).sep,
    AppLocalizations.of(context).oct,
    AppLocalizations.of(context).nov,
    AppLocalizations.of(context).dec,
  ];

  return months[month - 1];
}
  /// ==========================================================
  /// SAVE BAR
  /// ==========================================================

  Widget _buildBottomBar() {
    final count =
        _selectedDays.length;

    final editingExisting =
        _originalDays.isNotEmpty;

    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16,
        ),
        decoration:
            const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                count == 0
                    ? editingExisting
                        ? 'All period days will be removed'
                        : 'No period days selected'
                    : '$count period '
                      '${count == 1 ? 'day' : 'days'} selected',
                style:
                    const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _saving ||
                            (count == 0 &&
                                !editingExisting)
                        ? null
                        : _savePeriod,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _TrackingColors
                          .tealDark,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : Text(
                        count == 0 &&
                                editingExisting
                            ? 'Remove period'
                            : 'Save period',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// ============================================================
/// WEEKDAY
/// ============================================================

class _AddPeriodWeekday
    extends StatelessWidget {
  final String label;

  const _AddPeriodWeekday(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                _TrackingColors
                    .textMuted,
          ),
        ),
      ),
    );
  }
}