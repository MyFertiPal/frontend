
import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/period_service.dart';
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

  // ============================================================
  // LOCALIZATION
  // ============================================================

  AppLocalizations get _l10n =>
      AppLocalizations.of(context);

  // ============================================================
  // DATE HELPERS
  // ============================================================

  static DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  String _formatDateForApi(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
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

  // ============================================================
  // LOCALIZED MONTH NAMES
  // ============================================================

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

  // ============================================================
  // SUMMARY
  // ============================================================

  List<SummaryStat> get summaryStats {
    return [
      SummaryStat(
        value: _cycleLength > 0
            ? '$_cycleLength ${_l10n.days}'
            : '--',
        label: _l10n.cycleLength,
      ),
      SummaryStat(
        value: _periodLength > 0
            ? '$_periodLength ${_l10n.days}'
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

    try {
      final start =
          DateTime.parse(_fertileStart!);

      final end =
          DateTime.parse(_fertileEnd!);

      return '${_shortMonth(start.month)} ${start.day} – '
          '${_shortMonth(end.month)} ${end.day}';
    } catch (_) {
      return '--';
    }
  }

  String _shortMonth(int month) {
    return _monthNames[month - 1];
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    unawaited(
      _refreshCalendar(),
    );
  }

  // ============================================================
  // PUBLIC REFRESH
  // ============================================================

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

  // ============================================================
  // LOAD PROFILE + INSIGHTS
  // ============================================================

  Future<void> _loadCycle() async {
    Map<String, dynamic>? profile;

    List<dynamic> insights = [];

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

    try {
      insights = await _api.getInsights();

      debugPrint(
        'CALENDAR INSIGHTS: $insights',
      );
    } catch (e) {
      debugPrint(
        'Calendar getInsights error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    if (profile != null) {
      _cycleLength =
          _toInt(profile['cycle_length']);

      _periodLength =
          _toInt(profile['period_length']);

      final lastPeriod =
          profile['last_period_date'];

      if (lastPeriod != null &&
          lastPeriod.toString().trim().isNotEmpty) {
        try {
          _lastPeriod =
              _normalize(
            DateTime.parse(
              lastPeriod.toString(),
            ),
          );
        } catch (e) {
          debugPrint(
            'Last period parsing error: $e',
          );

          _lastPeriod = null;
        }
      }
    }

    if (insights.isNotEmpty) {
      try {
        final latest =
            Map<String, dynamic>.from(
          insights.first as Map,
        );

        _nextPeriod =
            _stringValue(
          latest['next_period_date'] ??
              latest['next_period'],
        );

        _ovulationDay =
            _stringValue(
          latest['ovulation_day'],
        );

        _fertileStart =
            _stringValue(
          latest['fertile_period_start'],
        );

        _fertileEnd =
            _stringValue(
          latest['fertile_period_end'],
        );
      } catch (e) {
        debugPrint(
          'Insight parsing error: $e',
        );
      }
    }

    await _loadLocalPeriods();

    _buildBackendMarkers();

    _rebuildMergedMarkers();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // LOCAL PERIODS
  // ============================================================

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
          _localPeriodDays.toList()..sort();

      DateTime start = sorted.last;

      while (_localPeriodDays.contains(
        start.subtract(
          const Duration(days: 1),
        ),
      )) {
        start = start.subtract(
          const Duration(days: 1),
        );
      }

      _activePeriodStart = start;

      debugPrint(
        'ACTIVE PERIOD START: $_activePeriodStart',
      );
    } catch (e) {
      debugPrint(
        'Local period load error: $e',
      );
    }
  }

  // ============================================================
  // BACKEND MARKERS
  // ============================================================

  void _buildBackendMarkers() {
    final markers =
        <DateTime, DayType>{};

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
            Duration(days: i),
          ),
        );

        markers[date] =
            DayType.period;
      }
    }

    if (_fertileStart != null &&
        _fertileEnd != null) {
      try {
        var current =
            _normalize(
          DateTime.parse(
            _fertileStart!,
          ),
        );

        final end =
            _normalize(
          DateTime.parse(
            _fertileEnd!,
          ),
        );

        while (!current.isAfter(end)) {
          if (markers[current] == null) {
            markers[current] =
                DayType.fertile;
          }

          current = current.add(
            const Duration(days: 1),
          );
        }
      } catch (e) {
        debugPrint(
          'Fertile date parsing error: $e',
        );
      }
    }

    if (_ovulationDay != null) {
      try {
        final date =
            _normalize(
          DateTime.parse(
            _ovulationDay!,
          ),
        );

        if (markers[date] !=
            DayType.period) {
          markers[date] =
              DayType.ovulation;
        }
      } catch (e) {
        debugPrint(
          'Ovulation parsing error: $e',
        );
      }
    }

    if (_nextPeriod != null &&
        _periodLength > 0) {
      try {
        final start =
            _normalize(
          DateTime.parse(
            _nextPeriod!,
          ),
        );

        for (
          int i = 0;
          i < _periodLength;
          i++
        ) {
          final date =
              _normalize(
            start.add(
              Duration(days: i),
            ),
          );

          if (markers[date] == null ||
              markers[date] ==
                  DayType.fertile ||
              markers[date] ==
                  DayType.ovulation) {
            markers[date] =
                DayType.predicted;
          }
        }
      } catch (e) {
        debugPrint(
          'Predicted date parsing error: $e',
        );
      }
    }

    _backendMarkers = markers;
  }

  // ============================================================
  // MERGE MARKERS
  // ============================================================

  void _rebuildMergedMarkers() {
    final merged =
        Map<DateTime, DayType>.from(
      _backendMarkers,
    );

    for (final date in _localPeriodDays) {
      merged[_normalize(date)] =
          DayType.period;
    }

    _dayMarkers = merged;
  }

  // ============================================================
  // PERIOD DETECTION
  // ============================================================

  bool _isNewPeriodStart(DateTime date) {
    final normalized =
        _normalize(date);

    if (_localPeriodDays.isEmpty) {
      return true;
    }

    final sorted =
        _localPeriodDays.toList()..sort();

    final latest = sorted.last;

    final difference =
        normalized.difference(latest).inDays;

    if (difference <= 1) {
      return false;
    }

    return true;
  }

  // ============================================================
  // TAPPABLE
  // ============================================================

  bool _isTappable(DayType? type) {
    return true;
  }

  // ============================================================
  // TAP DAY
  // ============================================================

  Future<void> _onDayTapped(
    DateTime date,
  ) async {
    final normalized =
        _normalize(date);

    final alreadyLogged =
        _localPeriodDays.contains(
      normalized,
    );

    debugPrint(
      'CALENDAR TAP: '
      '${_formatDateForApi(normalized)}',
    );

    if (alreadyLogged) {
      setState(() {
        _selectedDate = normalized;

        _localPeriodDays.remove(
          normalized,
        );

        _rebuildMergedMarkers();
      });

      try {
        await _periodService.deletePeriod(
          normalized,
        );

        debugPrint(
          'Deleted period: '
          '${_formatDateForApi(normalized)}',
        );
      } catch (e) {
        debugPrint(
          'Delete period error: $e',
        );
      }

      await _loadLocalPeriods();

      if (mounted) {
        setState(() {
          _rebuildMergedMarkers();
        });
      }

      return;
    }

    final isNewPeriod =
        _isNewPeriodStart(normalized);

    debugPrint(
      'IS NEW PERIOD: $isNewPeriod',
    );

    setState(() {
      _selectedDate = normalized;

      _localPeriodDays.add(
        normalized,
      );

      if (isNewPeriod) {
        _activePeriodStart =
            normalized;
      }

      _rebuildMergedMarkers();
    });

    try {
      await _periodService.savePeriod(
        normalized,
      );

      debugPrint(
        'Saved period: '
        '${_formatDateForApi(normalized)}',
      );
    } catch (e) {
      debugPrint(
        'Save period error: $e',
      );

      return;
    }

    if (!isNewPeriod) {
      debugPrint(
        'Continuation day.'
        ' generateInsights() skipped.',
      );

      return;
    }

    try {
      final result =
          await _api.generateInsights(
        cycleLength: _cycleLength,
        lastPeriodDate:
            _formatDateForApi(normalized),
        periodLength: _periodLength,
        symptoms: const [
          'none',
        ],
      );

      debugPrint(
        'GENERATE INSIGHTS RESULT: $result',
      );

      await _refreshCalendar();
    } catch (e) {
      debugPrint(
        'Generate insights error: $e',
      );
    }
  }

  // ============================================================
  // PREVIOUS MONTH
  // ============================================================

  void _goToPreviousMonth() {
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

  // ============================================================
  // NEXT MONTH
  // ============================================================

  void _goToNextMonth() {
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

  // ============================================================
  // SYMPTOMS
  // ============================================================

  Future<void> _loadSymptomsForVisibleMonth() async {
    final start = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final end = DateTime(
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
      _loggedSymptoms = symptoms;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _TrackingColors.bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCalendar,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildHero(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child:
                      _buildCalendarCard(),
                ),

                _buildLegend(),

                const SizedBox(height: 8),

                _buildSummaryRow(),

                const SizedBox(height: 24),

                _buildLoggedSymptoms(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    final todayLabel =
        '${_fullWeekday(widget.today.weekday)}, '
        '${_monthNames[widget.today.month - 1]} '
        '${widget.today.day}';

    final days = List.generate(
      5,
      (index) => widget.today.add(
        Duration(days: index - 2),
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
              BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset:
                  const Offset(0, 6),
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
                color:
                    Color(0xFF0B5D4D),
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

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

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children:
                  days.map(
                (date) {
                  final isToday =
                      _normalize(date) ==
                          _normalize(
                            widget.today,
                          );

                  return _WeekDateItem(
                    weekday:
                        _shortWeekday(
                      date.weekday,
                    ),
                    day: date.day,
                    isToday: isToday,
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
    return _fullWeekdayNames[weekday - 1];
  }

  String _shortWeekday(
    int weekday,
  ) {
    return _shortWeekdayNames[weekday - 1];
  }

  // ============================================================
  // CALENDAR CARD
  // ============================================================

  Widget _buildCalendarCard() {
    final daysInMonth =
        _daysInMonth(
      _visibleMonth,
    );

    final firstWeekdayOffset =
        _visibleMonth.weekday % 7;

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
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.05),
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
                MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed:
                    _goToPreviousMonth,
                icon: const Icon(
                  Icons.chevron_left,
                ),
                color:
                    _TrackingColors.textMuted,
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
                icon: const Icon(
                  Icons.chevron_right,
                ),
                color:
                    _TrackingColors.textMuted,
              ),
            ],
          ),

          const SizedBox(height: 8),

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
                          _TrackingColors.textMuted,
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
            itemCount:
                cells.length,
            gridDelegate:
                const SliceGridDelegate(
              crossAxisCount: 7,
            ),
            itemBuilder:
                (context, index) {
              final day =
                  cells[index];

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

              final type =
                  _dayMarkers[
                    normalized
                  ];

              return GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onTap:
                    _isTappable(type)
                        ? () =>
                            _onDayTapped(
                              date,
                            )
                        : null,
                child:
                    _CalendarDayCell(
                  day: day,
                  type: type,
                  isSelected:
                      DateUtils.isSameDay(
                    _selectedDate,
                    date,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

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

        const SizedBox(width: 6),

        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors.textMuted,
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

        const SizedBox(width: 6),

        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                _TrackingColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
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

  // ============================================================
  // LOGGED SYMPTOMS
  // ============================================================

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
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (_loggedSymptoms.isEmpty)
            Center(
              child: Text(
                _l10n.noSymptomsLogged,
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              final symptoms =
                  item['symptoms'];

              return Card(
                child: ListTile(
                  title: Text(
                    symptoms is List
                        ? symptoms.join(', ')
                        : symptoms.toString(),
                  ),
                  subtitle: Text(
                    item['created_at']
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

// ============================================================================
// GRID DELEGATE
// ============================================================================

class SliceGridDelegate
    extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliceGridDelegate({
    required super.crossAxisCount,
  }) : super(
          childAspectRatio: 1,
        );
}

// ============================================================================
// WEEK DATE ITEM
// ============================================================================

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
              MainAxisAlignment.center,
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

            const SizedBox(height: 2),

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

          const SizedBox(height: 6),

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

// ============================================================================
// CALENDAR DAY CELL
// ============================================================================

class _CalendarDayCell extends StatelessWidget {
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

    if (type == DayType.period) {
      backgroundColor =
          _TrackingColors.period;

      textColor =
          Colors.white;

      fontWeight =
          FontWeight.w600;
    }

    else if (type ==
        DayType.ovulation) {
      backgroundColor =
          _TrackingColors.tealDark;

      textColor =
          Colors.white;

      fontWeight =
          FontWeight.w600;
    }

    else if (type ==
        DayType.fertile) {
      backgroundColor =
          _TrackingColors.fertile;

      textColor =
          _TrackingColors.fertileText;
    }

    else if (type ==
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
        type != DayType.period) {
      border = Border.all(
        color:
            _TrackingColors.tealDark,
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

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard extends StatelessWidget {
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
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border:
            Border.all(
          color:
              _TrackingColors
                  .cardBorder,
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
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

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

