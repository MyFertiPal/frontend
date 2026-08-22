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
/// SUMMARY STAT
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
/// CALENDAR SCREEN
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

/// ============================================================
/// CALENDAR STATE
/// ============================================================

class CalendarTabScreenState extends State<CalendarTabScreen> {
  final LocalPeriodService _periodService =
      LocalPeriodService();

  final ApiService _api = ApiService();

  List<dynamic> _loggedSymptoms = [];

  DateTime? _selectedDate;

  DateTime? _lastPeriod;

  DateTime? _activePeriodStart;

  bool _isLoading = false;

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

  /// ==========================================================
  /// LOCALIZATION
  /// ==========================================================

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

  int _daysBetween(
    DateTime from,
    DateTime to,
  ) {
    final a = _normalize(from);
    final b = _normalize(to);

    return b.difference(a).inDays;
  }

  String _formatDateForApi(DateTime date) {
    final normalized = _normalize(date);

    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
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
      return _normalize(
        DateTime.parse(text),
      );
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

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  /// ==========================================================
  /// LOCALIZED MONTH NAMES
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

  List<String> get _shortWeekdayNames => [
        _l10n.monday.substring(0, 1),
        _l10n.tuesday.substring(0, 1),
        _l10n.wednesday.substring(0, 1),
        _l10n.thursday.substring(0, 1),
        _l10n.friday.substring(0, 1),
        _l10n.saturday.substring(0, 1),
        _l10n.sunday.substring(0, 1),
      ];

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

    return '${_shortMonth(start.month)} ${start.day} – '
        '${_shortMonth(end.month)} ${end.day}';
  }

  String _shortMonth(int month) {
    return _monthNames[month - 1];
  }

  /// ==========================================================
  /// LIFECYCLE
  /// ==========================================================

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(
      screenName: 'CalendarTabScreen',
    );

    AnalyticsService.logCalendarViewed();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    unawaited(
      _refreshCalendar(),
    );
  }

  /// ==========================================================
  /// PUBLIC REFRESH
  /// ==========================================================

  Future<void> refresh() async {
    await _refreshCalendar();
  }

  Future<void> _refreshCalendar() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    try {
      await _loadCycle();

      if (mounted) {
        await _loadSymptomsForVisibleMonth();
      }
    } catch (e) {
      debugPrint(
        'Calendar refresh error: $e',
      );
    } finally {
      _isLoading = false;
    }
  }

  /// ==========================================================
  /// LOAD PROFILE + INSIGHTS
  /// ==========================================================

  Future<void> _loadCycle() async {
    Map<String, dynamic>? profile;

    List<dynamic> insights = [];

    // Clear previous predictions.
    _nextPeriod = null;
    _ovulationDay = null;
    _fertileStart = null;
    _fertileEnd = null;

    try {
      profile = await _api.getProfile();

      debugPrint(
        'CALENDAR PROFILE: $profile',
      );
    } catch (e) {
      debugPrint(
        'Calendar getProfile error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    /// ----------------------------------------------------------
    /// PROFILE = SOURCE OF TRUTH
    /// ----------------------------------------------------------

    if (profile != null) {
      _cycleLength =
          _toInt(profile['cycle_length']);

      _periodLength =
          _toInt(profile['period_length']);

      _lastPeriod =
          _parseDate(
        profile['last_period_date'],
      );

      debugPrint(
        'CURRENT LAST PERIOD: $_lastPeriod',
      );

      debugPrint(
        'CURRENT CYCLE LENGTH: $_cycleLength',
      );

      debugPrint(
        'CURRENT PERIOD LENGTH: $_periodLength',
      );
    }

    /// ----------------------------------------------------------
    /// LOAD INSIGHTS
    /// ----------------------------------------------------------

    try {
      insights =
          await _api.getInsights();

      debugPrint(
        'CALENDAR INSIGHTS: $insights',
      );
    } catch (e) {
      debugPrint(
        'Calendar getInsights error: $e',
      );
    }

    /// ----------------------------------------------------------
    /// FIND INSIGHT FOR CURRENT CYCLE
    /// ----------------------------------------------------------

    Map<String, dynamic>? currentInsight;

    final currentLastPeriod =
        _lastPeriod == null
            ? null
            : _formatDateForApi(
                _lastPeriod!,
              );

    for (final item in insights) {
      if (item is! Map) {
        continue;
      }

      final insight =
          Map<String, dynamic>.from(item);

      final insightLastPeriod =
          _stringValue(
        insight['last_period_date'] ??
            insight['period_start_date'] ??
            insight['cycle_start_date'],
      );

      if (currentLastPeriod != null &&
          insightLastPeriod ==
              currentLastPeriod) {
        currentInsight = insight;
        break;
      }
    }

    /// ----------------------------------------------------------
    /// ONLY FALL BACK TO AN UNDATED INSIGHT
    /// ----------------------------------------------------------

    if (currentInsight == null) {
      for (final item in insights) {
        if (item is! Map) {
          continue;
        }

        final insight =
            Map<String, dynamic>.from(item);

        final hasCycleDate =
            insight.containsKey(
                  'last_period_date',
                ) ||
                insight.containsKey(
                  'period_start_date',
                ) ||
                insight.containsKey(
                  'cycle_start_date',
                );

        if (!hasCycleDate) {
          currentInsight = insight;
          break;
        }
      }
    }

    if (currentInsight != null) {
      debugPrint(
        'CURRENT CYCLE INSIGHT: '
        '$currentInsight',
      );

      _nextPeriod =
          _stringValue(
        currentInsight[
              'next_period_date'] ??
            currentInsight[
              'next_period'],
      );

      _ovulationDay =
          _stringValue(
        currentInsight[
          'ovulation_day'],
      );

      _fertileStart =
          _stringValue(
        currentInsight[
          'fertile_period_start'],
      );

      _fertileEnd =
          _stringValue(
        currentInsight[
          'fertile_period_end'],
      );
    }

    /// ----------------------------------------------------------
    /// VALIDATE PREDICTIONS
    /// ----------------------------------------------------------

    _validateAndRepairPredictions();

    if (_fertileStart != null &&
        _fertileEnd != null) {
      AnalyticsService
          .logFertileWindowViewed();
    }

    /// ----------------------------------------------------------
    /// LOCAL PERIODS
    /// ----------------------------------------------------------

    await _loadLocalPeriods();

    /// ----------------------------------------------------------
    /// MARKERS
    /// ----------------------------------------------------------

    _buildBackendMarkers();

    _rebuildMergedMarkers();

    if (!mounted) {
      return;
    }

    setState(() {});
  }
    /// ==========================================================
  /// VALIDATE / REPAIR PREDICTIONS
  /// ==========================================================

  void _validateAndRepairPredictions() {
    if (_lastPeriod == null ||
        _cycleLength <= 0) {
      return;
    }

    final lastPeriod = _lastPeriod!;

    /// ----------------------------------------------------------
    /// NEXT PERIOD
    ///
    /// Cycle length means:
    ///
    /// last period start + cycle length
    /// ----------------------------------------------------------

    final expectedNextPeriod =
        _normalize(
      lastPeriod.add(
        Duration(
          days: _cycleLength,
        ),
      ),
    );

    final backendNextPeriod =
        _parseDate(
      _nextPeriod,
    );

    if (backendNextPeriod == null ||
        backendNextPeriod.isBefore(
          lastPeriod,
        )) {
      _nextPeriod =
          _formatDateForApi(
        expectedNextPeriod,
      );
    }

    /// ----------------------------------------------------------
    /// OVULATION
    ///
    /// Approximation:
    /// next period - 14 days
    /// ----------------------------------------------------------

    final expectedOvulation =
        _normalize(
      expectedNextPeriod.subtract(
        const Duration(
          days: 14,
        ),
      ),
    );

    final backendOvulation =
        _parseDate(
      _ovulationDay,
    );

    if (backendOvulation == null ||
        backendOvulation.isBefore(
          lastPeriod,
        ) ||
        backendOvulation.isAfter(
          expectedNextPeriod,
        )) {
      _ovulationDay =
          _formatDateForApi(
        expectedOvulation,
      );
    }

    /// ----------------------------------------------------------
    /// FERTILE WINDOW
    ///
    /// 5 days before ovulation
    /// through 1 day after ovulation.
    /// ----------------------------------------------------------

    final expectedFertileStart =
        _normalize(
      expectedOvulation.subtract(
        const Duration(
          days: 5,
        ),
      ),
    );

    final expectedFertileEnd =
        _normalize(
      expectedOvulation.add(
        const Duration(
          days: 1,
        ),
      ),
    );

    final backendFertileStart =
        _parseDate(
      _fertileStart,
    );

    final backendFertileEnd =
        _parseDate(
      _fertileEnd,
    );

    final fertileIsInvalid =
        backendFertileStart == null ||
            backendFertileEnd == null ||
            backendFertileStart
                .isBefore(lastPeriod) ||
            backendFertileEnd
                .isBefore(
              backendFertileStart,
            ) ||
            backendFertileEnd
                .isAfter(
              expectedNextPeriod,
            );

    if (fertileIsInvalid) {
      _fertileStart =
          _formatDateForApi(
        expectedFertileStart,
      );

      _fertileEnd =
          _formatDateForApi(
        expectedFertileEnd,
      );
    }

    debugPrint(
      'VALIDATED PREDICTIONS: '
      'next=$_nextPeriod, '
      'ovulation=$_ovulationDay, '
      'fertile=$_fertileStart → $_fertileEnd',
    );
  }

  /// ==========================================================
  /// LOCAL PERIODS
  /// ==========================================================

  Future<void> _loadLocalPeriods() async {
    try {
      final logs =
          await _periodService.getPeriodLogs();

      _localPeriodDays = logs
          .map(_normalize)
          .toSet();

      if (_localPeriodDays.isEmpty) {
        _activePeriodStart = null;
        return;
      }

      final sorted =
          _localPeriodDays.toList()
            ..sort();

      /// Find the latest continuous period block.
      DateTime start =
          sorted.last;

      while (_localPeriodDays.contains(
        start.subtract(
          const Duration(
            days: 1,
          ),
        ),
      )) {
        start = start.subtract(
          const Duration(
            days: 1,
          ),
        );
      }

      _activePeriodStart = start;

      debugPrint(
        'ACTIVE PERIOD START: '
        '$_activePeriodStart',
      );
    } catch (e) {
      debugPrint(
        'Local period load error: $e',
      );
    }
  }

  /// ==========================================================
  /// BACKEND MARKERS
  /// ==========================================================

  void _buildBackendMarkers() {
    final markers =
        <DateTime, DayType>{};

    /// ----------------------------------------------------------
    /// CURRENT PERIOD
    /// ----------------------------------------------------------

    if (_lastPeriod != null &&
        _periodLength > 0) {
      for (
        int i = 0;
        i < _periodLength;
        i++
      ) {
        final date =
            _normalize(
          _lastPeriod!.add(
            Duration(
              days: i,
            ),
          ),
        );

        markers[date] =
            DayType.period;
      }
    }

    /// ----------------------------------------------------------
    /// FERTILE WINDOW
    /// ----------------------------------------------------------

    final fertileStart =
        _parseDate(
      _fertileStart,
    );

    final fertileEnd =
        _parseDate(
      _fertileEnd,
    );

    if (fertileStart != null &&
        fertileEnd != null &&
        !fertileEnd.isBefore(
          fertileStart,
        )) {
      var current =
          fertileStart;

      while (!current.isAfter(
        fertileEnd,
      )) {
        if (markers[current] == null) {
          markers[current] =
              DayType.fertile;
        }

        current = current.add(
          const Duration(
            days: 1,
          ),
        );
      }
    }

    /// ----------------------------------------------------------
    /// OVULATION
    /// ----------------------------------------------------------

    final ovulation =
        _parseDate(
      _ovulationDay,
    );

    if (ovulation != null) {
      if (markers[ovulation] !=
          DayType.period) {
        markers[ovulation] =
            DayType.ovulation;
      }
    }

    /// ----------------------------------------------------------
    /// NEXT PREDICTED PERIOD
    /// ----------------------------------------------------------

    final nextPeriod =
        _parseDate(
      _nextPeriod,
    );

    if (nextPeriod != null &&
        _periodLength > 0) {
      for (
        int i = 0;
        i < _periodLength;
        i++
      ) {
        final date =
            _normalize(
          nextPeriod.add(
            Duration(
              days: i,
            ),
          ),
        );

        /// Never overwrite an actual/current period.
        if (markers[date] == null ||
            markers[date] ==
                DayType.fertile ||
            markers[date] ==
                DayType.ovulation) {
          markers[date] =
              DayType.predicted;
        }
      }
    }

    _backendMarkers = markers;
  }

  /// ==========================================================
  /// MERGE BACKEND + LOCALLY LOGGED PERIODS
  /// ==========================================================

  void _rebuildMergedMarkers() {
    final merged =
        Map<DateTime, DayType>.from(
      _backendMarkers,
    );

    for (final date
        in _localPeriodDays) {
      merged[_normalize(date)] =
          DayType.period;
    }

    _dayMarkers = merged;
  }

  /// ==========================================================
  /// OPEN ADD PERIOD
  /// ==========================================================

  Future<void> _openAddPeriod() async {
    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddPeriodScreen(
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

    if (result != true ||
        !mounted) {
      return;
    }

    await _refreshCalendar();
  }

  /// ==========================================================
  /// PREVIOUS MONTH
  /// ==========================================================

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth =
          DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
        1,
      );
    });

    unawaited(
      _loadSymptomsForVisibleMonth(),
    );
  }

  /// ==========================================================
  /// NEXT MONTH
  /// ==========================================================

  void _goToNextMonth() {
    setState(() {
      _visibleMonth =
          DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        1,
      );
    });

    unawaited(
      _loadSymptomsForVisibleMonth(),
    );
  }

  /// ==========================================================
  /// SYMPTOMS
  /// ==========================================================

  Future<void>
      _loadSymptomsForVisibleMonth() async {
    final start =
        DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final end =
        DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      _daysInMonth(
        _visibleMonth,
      ),
    );

    List<dynamic> symptoms = [];

    try {
      symptoms =
          await _api.getSymptoms(
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      debugPrint(
        'getSymptoms error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loggedSymptoms =
          symptoms;
    });
  }

  /// ==========================================================
  /// BUILD
  /// ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color:
          _TrackingColors.bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              _refreshCalendar,
          child:
              SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                _buildHero(),

                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),
                  child:
                      _buildCalendarCard(),
                ),

                _buildLegend(),

                const SizedBox(
                  height: 8,
                ),

                _buildSummaryRow(),

                const SizedBox(
                  height: 24,
                ),

                _buildLoggedSymptoms(),

                const SizedBox(
                  height: 20,
                ),
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
        _normalize(
      widget.today,
    );

    final todayLabel =
        '${_fullWeekday(today.weekday)}, '
        '${_monthNames[today.month - 1]} '
        '${today.day}';

    final days =
        List.generate(
      5,
      (index) => today.add(
        Duration(
          days: index - 2,
        ),
      ),
    );

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ),
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          22,
          22,
          22,
          26,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            28,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(.05),
              blurRadius: 18,
              offset:
                  const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              _l10n.today,
              style:
                  const TextStyle(
                fontSize: 16,
                color:
                    Color(0xFF0B5D4D),
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              todayLabel,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF0B5D4D),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children:
                  days.map(
                (date) {
                  final isToday =
                      _sameDate(
                    date,
                    today,
                  );

                  return _WeekDateItem(
                    weekday:
                        _shortWeekday(
                      date.weekday,
                    ),
                    day: date.day,
                    isToday:
                        isToday,
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _fullWeekday(
    int weekday,
  ) {
    return _fullWeekdayNames[
        weekday - 1];
  }

  String _shortWeekday(
    int weekday,
  ) {
    return _shortWeekdayNames[
        weekday - 1];
  }

  /// ==========================================================
  /// MAIN CALENDAR
  /// ==========================================================

  Widget _buildCalendarCard() {
    final daysInMonth =
        _daysInMonth(
      _visibleMonth,
    );

    /// IMPORTANT:
    ///
    /// Our headers are:
    /// Monday Tuesday Wednesday Thursday Friday Saturday Sunday
    ///
    /// Therefore:
    ///
    /// Monday = 0
    /// Tuesday = 1
    /// ...
    /// Sunday = 6
    ///
    /// This fixes the August alignment issue.
    final firstWeekdayOffset =
        _visibleMonth.weekday - 1;

    final cells = <int?>[
      ...List.filled(
        firstWeekdayOffset,
        null,
      ),
      for (
        int day = 1;
        day <= daysInMonth;
        day++
      )
        day,
    ];

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      padding:
          const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              IconButton(
                onPressed:
                    _goToPreviousMonth,
                icon:
                    const Icon(
                  Icons.chevron_left,
                ),
                color:
                    _TrackingColors
                        .textMuted,
              ),

              Text(
                '${_monthNames[_visibleMonth.month - 1]} '
                '${_visibleMonth.year}',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              IconButton(
                onPressed:
                    _goToNextMonth,
                icon:
                    const Icon(
                  Icons.chevron_right,
                ),
                color:
                    _TrackingColors
                        .textMuted,
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          /// WEEKDAY HEADERS
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            children:
                _shortWeekdayNames
                    .map(
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

          const SizedBox(
            height: 4,
          ),

          /// DATES
          GridView.builder(
            shrinkWrap: true,
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
                return const SizedBox
                    .shrink();
              }

              final date =
                  DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );

              final normalized =
                  _normalize(
                date,
              );

              final type =
                  _dayMarkers[
                    normalized
                  ];

              /// IMPORTANT:
              ///
              /// There is NO GestureDetector.
              ///
              /// Main calendar is display-only.
              return _CalendarDayCell(
                day: day,
                type: type,
                isSelected:
                    _sameDate(
                  _selectedDate,
                  date,
                ),
              );
            },
          ),

          const SizedBox(
            height: 16,
          ),

          /// ADD PERIOD
          SizedBox(
            width:
                double.infinity,
            child:
                ElevatedButton.icon(
              onPressed:
                  _openAddPeriod,
              icon:
                  const Icon(
                Icons.add,
              ),
              label:
                  const Text(
                'Add period',
              ),
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
                  vertical: 14,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
    /// ==========================================================
  /// LEGEND
  /// ==========================================================

  Widget _buildLegend() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
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
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors
                    .textMuted,
          ),
        ),
      ],
    );
  }

  Widget _legendOutlineItem(
    String label,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,
            border:
                Border.all(
              color:
                  _TrackingColors
                      .predictedBorder,
              width: 2,
            ),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors
                    .textMuted,
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
      child:
          ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 20,
        ),
        itemCount:
            summaryStats.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 12,
        ),
        itemBuilder:
            (context, index) {
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
  /// LOGGED SYMPTOMS
  /// ==========================================================

  Widget _buildLoggedSymptoms() {
    return Padding(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            _l10n.loggedSymptoms,
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          if (_loggedSymptoms
              .isEmpty)
            Center(
              child: Text(
                _l10n
                    .noSymptomsLogged,
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              final symptoms =
                  item['symptoms'];

              return Card(
                child:
                    ListTile(
                  title:
                      Text(
                    symptoms
                            is List
                        ? symptoms
                            .join(
                            ', ',
                          )
                        : symptoms
                            .toString(),
                  ),
                  subtitle:
                      Text(
                    item[
                              'created_at']
                            ?.toString() ??
                        '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// GRID DELEGATE
/// ============================================================================

class SliceGridDelegate
    extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliceGridDelegate({
    required super.crossAxisCount,
  }) : super(
          childAspectRatio: 1,
        );
}

/// ============================================================================
/// WEEK DATE ITEM
/// ============================================================================

class _WeekDateItem
    extends StatelessWidget {
  final String weekday;
  final int day;
  final bool isToday;

  const _WeekDateItem({
    required this.weekday,
    required this.day,
    required this.isToday,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (isToday) {
      return Container(
        width: 64,
        height: 64,
        decoration:
            const BoxDecoration(
          color:
              Color(0xFF18B7B3),
          shape:
              BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Text(
              weekday,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              '$day',
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
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
          const SizedBox(
            height: 6,
          ),
          Text(
            '$day',
            style:
                const TextStyle(
              color:
                  Color(0xFF0B5D4D),
              fontSize: 26,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// CALENDAR DAY CELL
/// ============================================================================

class _CalendarDayCell
    extends StatelessWidget {
  final int day;

  final DayType? type;

  final bool isSelected;

  const _CalendarDayCell({
    required this.day,
    required this.type,
    this.isSelected = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Color? backgroundColor;

    Color textColor =
        Colors.black87;

    Border? border;

    FontWeight fontWeight =
        FontWeight.normal;

    if (type ==
        DayType.period) {
      backgroundColor =
          _TrackingColors.period;

      textColor =
          Colors.white;

      fontWeight =
          FontWeight.w600;
    } else if (type ==
        DayType.ovulation) {
      backgroundColor =
          _TrackingColors
              .tealDark;

      textColor =
          Colors.white;

      fontWeight =
          FontWeight.w600;
    } else if (type ==
        DayType.fertile) {
      backgroundColor =
          _TrackingColors.fertile;

      textColor =
          _TrackingColors
              .fertileText;
    } else if (type ==
        DayType.predicted) {
      border = Border.all(
        color:
            _TrackingColors
                .predictedBorder,
        width: 2,
      );

      textColor =
          _TrackingColors.period;
    }

    if (isSelected &&
        type !=
            DayType.period) {
      border = Border.all(
        color:
            _TrackingColors
                .tealDark,
        width: 2,
      );
    }

    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color:
              backgroundColor,
          shape:
              BoxShape.circle,
          border:
              border,
        ),
        child: Text(
          '$day',
          style:
              TextStyle(
            fontSize: 13,
            color:
                textColor,
            fontWeight:
                fontWeight,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// SUMMARY CARD
/// ============================================================================

class _SummaryCard
    extends StatelessWidget {
  final String value;

  final String label;

  const _SummaryCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 148,
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              _TrackingColors
                  .cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  _TrackingColors
                      .textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// ADD PERIOD SCREEN
///
/// This is intentionally in the same file for now so you can copy/paste
/// everything without creating another file.
///
/// The months swipe VERTICALLY.
/// ============================================================================

class AddPeriodScreen
    extends StatefulWidget {
  final Set<DateTime>
      initialPeriodDays;

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
  final LocalPeriodService
      _periodService =
      LocalPeriodService();

  final ApiService _api =
      ApiService();

  late Set<DateTime>
      _selectedDays;

  late Set<DateTime>
      _originalDays;

  late PageController
      _pageController;

  late DateTime
      _initialMonth;

  bool _saving = false;

  /// Number of months available before/after
  /// the initial month.
  static const int _monthRange = 60;

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

    _initialMonth =
        DateTime(
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
  /// DATE HELPERS
  /// ==========================================================

  static DateTime _normalize(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _sameDate(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  int _daysInMonth(
    DateTime month,
  ) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  DateTime _monthForPage(
    int page,
  ) {
    return DateTime(
      _initialMonth.year,
      _initialMonth.month +
          (page - _monthRange),
      1,
    );
  }

  /// ==========================================================
  /// TOGGLE DAY
  /// ==========================================================

  void _toggleDate(
    DateTime date,
  ) {
    final normalized =
        _normalize(date);

    setState(() {
      if (_selectedDays
          .contains(normalized)) {
        _selectedDays
            .remove(normalized);
      } else {
        _selectedDays
            .add(normalized);
      }
    });
  }

  /// ==========================================================
  /// SAVE PERIOD
  /// ==========================================================

  Future<void> _savePeriod() async {
    if (_saving) {
      return;
    }

    if (_selectedDays.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      /// --------------------------------------------------------
      /// DAYS ADDED
      /// --------------------------------------------------------

      final addedDays =
          _selectedDays
              .difference(
        _originalDays,
      );

      /// --------------------------------------------------------
      /// DAYS REMOVED
      /// --------------------------------------------------------

      final removedDays =
          _originalDays
              .difference(
        _selectedDays,
      );

      /// --------------------------------------------------------
      /// SAVE NEW DAYS
      /// --------------------------------------------------------

      for (final date
          in addedDays) {
        await _periodService
            .savePeriod(
          date,
        );
      }

      /// --------------------------------------------------------
      /// DELETE REMOVED DAYS
      /// --------------------------------------------------------

      for (final date
          in removedDays) {
        await _periodService
            .deletePeriod(
          date,
        );
      }

      /// --------------------------------------------------------
      /// FIND THE LATEST PERIOD BLOCK
      /// --------------------------------------------------------

      final sorted =
          _selectedDays.toList()
            ..sort();

      DateTime latestStart =
          sorted.last;

      while (_selectedDays
          .contains(
        latestStart.subtract(
          const Duration(
            days: 1,
          ),
        ),
      )) {
        latestStart =
            latestStart.subtract(
          const Duration(
            days: 1,
          ),
        );
      }

      debugPrint(
        'ADD PERIOD: '
        'LATEST PERIOD START = '
        '$latestStart',
      );

      /// --------------------------------------------------------
      /// DETERMINE WHETHER THIS IS A NEW CYCLE
      /// --------------------------------------------------------
      ///
      /// If a newly added period is separated from the
      /// previous period by more than one day, it is treated
      /// as a new period start.
      ///
      bool isNewCycle = false;

      if (addedDays.isNotEmpty) {
        final previousSorted =
            _originalDays.toList()
              ..sort();

        if (previousSorted.isEmpty) {
          isNewCycle = true;
        } else {
          final previousLatest =
              previousSorted.last;

          for (final added
              in addedDays) {
            final gap =
                added
                    .difference(
                      previousLatest,
                    )
                    .inDays;

            if (gap > 1) {
              isNewCycle = true;
              break;
            }
          }
        }
      }

      /// --------------------------------------------------------
      /// GENERATE NEW PREDICTIONS
      /// --------------------------------------------------------

      if (isNewCycle) {
        debugPrint(
          'ADD PERIOD: '
          'NEW CYCLE DETECTED',
        );

        final result =
            await _api.generateInsights(
          cycleLength:
              widget.cycleLength,
          lastPeriodDate:
              _formatDateForApi(
            latestStart,
          ),
          periodLength:
              widget.periodLength,
          symptoms: const [
            'none',
          ],
        );

        debugPrint(
          'ADD PERIOD: '
          'GENERATE INSIGHTS RESULT '
          '$result',
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pop(true);
    } catch (e) {
      debugPrint(
        'ADD PERIOD SAVE ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save period: $e',
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

  String _formatDateForApi(
    DateTime date,
  ) {
    final normalized =
        _normalize(date);

    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  /// ==========================================================
  /// BUILD
  /// ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _TrackingColors.bg,

      appBar: AppBar(
        title:
            const Text(
          'Add period',
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            _TrackingColors
                .tealDark,
        elevation: 0,
      ),

      body: Column(
        children: [
          const Padding(
            padding:
                EdgeInsets.fromLTRB(
              20,
              16,
              20,
              10,
            ),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Select the days of your period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF0B4A40),
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
                'Swipe up or down to move between months. Tap a date to add or remove it.',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Expanded(
            child:
                PageView.builder(
              controller:
                  _pageController,
              scrollDirection:
                  Axis.vertical,
              itemCount:
                  (_monthRange * 2) +
                      1,
              itemBuilder:
                  (
                context,
                page,
              ) {
                final month =
                    _monthForPage(
                  page,
                );

                return
                    _buildMonth(
                  month,
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

  Widget _buildMonth(
    DateTime month,
  ) {
    final days =
        _daysInMonth(month);

    /// Monday-first calendar.
    final offset =
        month.weekday - 1;

    final cells = <int?>[
      ...List.filled(
        offset,
        null,
      ),
      for (
        int day = 1;
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
              BorderRadius.circular(
            24,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
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
                      Color(0xFF0B4A40),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              /// WEEKDAYS
              Row(
                children: const [
                  _AddPeriodWeekday(
                    'M',
                  ),
                  _AddPeriodWeekday(
                    'T',
                  ),
                  _AddPeriodWeekday(
                    'W',
                  ),
                  _AddPeriodWeekday(
                    'T',
                  ),
                  _AddPeriodWeekday(
                    'F',
                  ),
                  _AddPeriodWeekday(
                    'S',
                  ),
                  _AddPeriodWeekday(
                    'S',
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              /// DATES
              Expanded(
                child:
                    GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      cells.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        7,
                    childAspectRatio:
                        1,
                  ),
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final day =
                        cells[index];

                    if (day ==
                        null) {
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
                            .contains(
                      date,
                    );

                    return GestureDetector(
                      behavior:
                          HitTestBehavior
                              .opaque,
                      onTap: () =>
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
                          width: 40,
                          height: 40,
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
                              fontWeight: selected
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

  String _monthName(
    int month,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  /// ==========================================================
  /// BOTTOM SAVE BAR
  /// ==========================================================

  Widget _buildBottomBar() {
    final selectedCount =
        _selectedDays.length;

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
                selectedCount == 0
                    ? 'No period days selected'
                    : '$selectedCount period '
                      '${selectedCount == 1 ? 'day' : 'days'} selected',
                style:
                    const TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    _selectedDays
                                .isEmpty ||
                            _saving
                        ? null
                        : _savePeriod,
                style:
                    ElevatedButton
                        .styleFrom(
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
                        BorderRadius
                            .circular(
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
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Save period',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .w600,
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
    _pageController
        .dispose();

    super.dispose();
  }
}

/// ============================================================================
/// ADD PERIOD WEEKDAY
/// ============================================================================

class _AddPeriodWeekday
    extends StatelessWidget {
  final String label;

  const _AddPeriodWeekday(
    this.label,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
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