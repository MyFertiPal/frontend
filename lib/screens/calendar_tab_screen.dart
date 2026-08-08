import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/period_service.dart';

/// Types of calendar-day markers shown on the calendar grid.
enum DayType {
  period,
  fertile,
  ovulation,
  predicted,
}

/// Colors used across the screen.
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

/// A single stat shown in the horizontally-scrollable summary row.
class SummaryStat {
  final String value;
  final String label;

  const SummaryStat({
    required this.value,
    required this.label,
  });
}

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
      _CalendarTabScreenState();
}

class _CalendarTabScreenState extends State<CalendarTabScreen> {
  final LocalPeriodService _periodService =
      LocalPeriodService();

  List<dynamic> _loggedSymptoms = [];

  DateTime? _selectedDate;
  DateTime? _lastPeriod;

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

  bool _isLoading = false;

  static DateTime _normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  List<SummaryStat> get summaryStats {
    return [
      SummaryStat(
        value: _cycleLength > 0
            ? "$_cycleLength days"
            : "--",
        label: "Cycle Length",
      ),
      SummaryStat(
        value: _periodLength > 0
            ? "$_periodLength days"
            : "--",
        label: "Period Length",
      ),
      SummaryStat(
        value: _formatFertileWindow(),
        label: "Fertile Window",
      ),
    ];
  }

  String _formatFertileWindow() {
    if (_fertileStart == null || _fertileEnd == null) {
      return "--";
    }

    try {
      final start = DateTime.parse(_fertileStart!);
      final end = DateTime.parse(_fertileEnd!);

      return "${_shortMonth(start.month)} ${start.day} – "
          "${_shortMonth(end.month)} ${end.day}";
    } catch (_) {
      return "--";
    }
  }

  String _shortMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    _refreshCalendar();
  }

  /// Call this whenever the calendar tab becomes visible.
  ///
  /// This method is intentionally public so the parent screen can call:
  ///
  /// calendarKey.currentState?.refresh();
  ///
  /// when the Calendar tab is selected.
  Future<void> refresh() async {
    await _refreshCalendar();
  }

  Future<void> _refreshCalendar() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      await _loadCycle();

      if (mounted) {
        await _loadSymptomsForVisibleMonth();
      }
    } finally {
      _isLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Month navigation
  // ---------------------------------------------------------------------------

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

  static const _monthNames = [
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

  static const _weekdayShort = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _TrackingColors.bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCalendar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildHero(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCalendarCard(),
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

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadCycle() async {
    final api = ApiService();

    Map<String, dynamic>? profile;
    List<dynamic> insights = [];

    try {
      profile = await api.getProfile();
    } catch (e) {
      debugPrint(
        "Calendar getProfile error: $e",
      );
    }

    try {
      insights = await api.getInsights();
    } catch (e) {
      debugPrint(
        "Calendar getInsights error: $e",
      );
    }

    if (!mounted) return;

    // -------------------------------------------------------
    // Profile
    // -------------------------------------------------------

    if (profile != null) {
      _cycleLength =
          _toInt(profile["cycle_length"]);

      _periodLength =
          _toInt(profile["period_length"]);

      final lastPeriod =
          profile["last_period_date"];

      if (lastPeriod != null &&
          lastPeriod.toString().isNotEmpty) {
        try {
          _lastPeriod =
              DateTime.parse(lastPeriod.toString());
        } catch (_) {
          _lastPeriod = null;
        }
      }
    }

    // -------------------------------------------------------
    // Insights
    // -------------------------------------------------------

    if (insights.isNotEmpty) {
      final latestInsight =
          Map<String, dynamic>.from(
        insights.first as Map,
      );

      _nextPeriod =
          _stringValue(
        latestInsight["next_period_date"] ??
            latestInsight["next_period"],
      );

      _ovulationDay =
          _stringValue(
        latestInsight["ovulation_day"],
      );

      _fertileStart =
          _stringValue(
        latestInsight["fertile_period_start"],
      );

      _fertileEnd =
          _stringValue(
        latestInsight["fertile_period_end"],
      );
    }

    // -------------------------------------------------------
    // Local period logs
    // -------------------------------------------------------

    await _loadLocalPeriods();

    // -------------------------------------------------------
    // Rebuild markers
    // -------------------------------------------------------

    _buildBackendMarkers();

    _rebuildMergedMarkers();

    if (!mounted) return;

    setState(() {});
  }

  int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;

    final stringValue =
        value.toString().trim();

    return stringValue.isEmpty
        ? null
        : stringValue;
  }

  Future<void> _loadLocalPeriods() async {
    try {
      final logs =
          await _periodService.getPeriodLogs();

      _localPeriodDays = logs
          .map(_normalize)
          .toSet();
    } catch (e) {
      debugPrint(
        "Local period load error: $e",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Backend marker generation
  // ---------------------------------------------------------------------------

  void _buildBackendMarkers() {
    final markers = <DateTime, DayType>{};

    // -------------------------------------------------------
    // Actual last period
    // -------------------------------------------------------

    if (_lastPeriod != null &&
        _periodLength > 0) {
      for (int i = 0;
          i < _periodLength;
          i++) {
        final date =
            _lastPeriod!.add(
          Duration(days: i),
        );

        markers[_normalize(date)] =
            DayType.period;
      }
    }

    // -------------------------------------------------------
    // Fertile window
    // -------------------------------------------------------

    if (_fertileStart != null &&
        _fertileEnd != null) {
      try {
        var day =
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

        while (!day.isAfter(end)) {
          // Don't overwrite an actual period.
          if (markers[day] == null) {
            markers[day] =
                DayType.fertile;
          }

          day = day.add(
            const Duration(days: 1),
          );
        }
      } catch (e) {
        debugPrint(
          "Fertile date parsing error: $e",
        );
      }
    }

    // -------------------------------------------------------
    // Ovulation
    // -------------------------------------------------------

    if (_ovulationDay != null) {
      try {
        final date =
            _normalize(
          DateTime.parse(
            _ovulationDay!,
          ),
        );

        // Period takes priority.
        if (markers[date] != DayType.period) {
          markers[date] =
              DayType.ovulation;
        }
      } catch (_) {}
    }

    // -------------------------------------------------------
    // Predicted period
    // -------------------------------------------------------

    if (_nextPeriod != null &&
        _periodLength > 0) {
      try {
        final start =
            _normalize(
          DateTime.parse(
            _nextPeriod!,
          ),
        );

        for (int i = 0;
            i < _periodLength;
            i++) {
          final date =
              start.add(
            Duration(days: i),
          );

          // Actual period always wins.
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
          "Predicted date parsing error: $e",
        );
      }
    }

    _backendMarkers = markers;
  }

  // ---------------------------------------------------------------------------
  // Merge local actual periods over backend predictions
  // ---------------------------------------------------------------------------

  void _rebuildMergedMarkers() {
    final merged =
        Map<DateTime, DayType>.from(
      _backendMarkers,
    );

    // A user-entered actual period ALWAYS wins.
    for (final date in _localPeriodDays) {
      merged[date] =
          DayType.period;
    }

    _dayMarkers = merged;
  }

  // ---------------------------------------------------------------------------
  // Tapping / logging periods
  // ---------------------------------------------------------------------------

  bool _isTappable(DayType? type) {
    // IMPORTANT:
    //
    // Predicted days MUST be tappable.
    //
    // If today was predicted to be the period start and
    // the user's period actually started, they need to
    // be able to tap that day and convert it to an actual
    // period day.
    //
    // We also allow fertile and ovulation days to be tapped
    // because the user may discover that their actual period
    // started on a day the prediction was wrong about.
    //
    return true;
  }

  Future<void> _onDayTapped(
    DateTime date,
  ) async {
    final normalized =
        _normalize(date);

    final currentType =
        _dayMarkers[normalized];

    if (!_isTappable(currentType)) {
      return;
    }

    final alreadyLogged =
        _localPeriodDays.contains(
      normalized,
    );

    // -------------------------------------------------------
    // Optimistic UI update
    // -------------------------------------------------------

    setState(() {
      _selectedDate = normalized;

      if (alreadyLogged) {
        _localPeriodDays.remove(
          normalized,
        );
      } else {
        _localPeriodDays.add(
          normalized,
        );
      }

      _rebuildMergedMarkers();
    });

    // -------------------------------------------------------
    // Persist locally
    // -------------------------------------------------------

    try {
      if (alreadyLogged) {
        await _periodService
            .deletePeriod(normalized);
      } else {
        await _periodService
            .savePeriod(normalized);
      }
    } catch (e) {
      debugPrint(
        "Period save/delete error: $e",
      );

      // Roll back UI if storage failed.
      if (!mounted) return;

      setState(() {
        if (alreadyLogged) {
          _localPeriodDays.add(
            normalized,
          );
        } else {
          _localPeriodDays.remove(
            normalized,
          );
        }

        _rebuildMergedMarkers();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Symptoms
  // ---------------------------------------------------------------------------

  Future<void> _loadSymptomsForVisibleMonth() async {
    final api = ApiService();

    final start = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final end = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      _daysInMonth(_visibleMonth),
    );

    List<dynamic> symptoms = [];

    try {
      symptoms = await api.getSymptoms(
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      debugPrint(
        "getSymptoms error: $e",
      );
    }

    if (!mounted) return;

    setState(() {
      _loggedSymptoms = symptoms;
    });
  }

  Widget _buildLoggedSymptoms() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Logged Symptoms",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (_loggedSymptoms.isEmpty)
            const Center(
              child: Text(
                "No symptoms logged yet",
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              final symptoms =
                  item["symptoms"];

              return Card(
                child: ListTile(
                  title: Text(
                    symptoms is List
                        ? symptoms.join(", ")
                        : symptoms.toString(),
                  ),
                  subtitle: Text(
                    item["created_at"]
                        ?.toString() ??
                        "",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------------

  Widget _buildHero() {
    final todayLabel =
        '${_fullWeekday(widget.today.weekday)}, '
        '${_monthNames[widget.today.month - 1]} '
        '${widget.today.day}';

    final days = List.generate(
      5,
      (i) => widget.today.add(
        Duration(days: i - 2),
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
        decoration: BoxDecoration(
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
            const Text(
              "Today",
              style: TextStyle(
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
              style: const TextStyle(
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

  String _fullWeekday(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[weekday - 1];
  }

  String _shortWeekday(int weekday) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return names[weekday - 1];
  }

  // ---------------------------------------------------------------------------
  // Calendar
  // ---------------------------------------------------------------------------

  Widget _buildCalendarCard() {
    final daysInMonth =
        _daysInMonth(_visibleMonth);

    final firstWeekdayOffset =
        _visibleMonth.weekday % 7;

    final cells = <int?>[
      ...List.filled(
        firstWeekdayOffset,
        null,
      ),
      for (
        var d = 1;
        d <= daysInMonth;
        d++
      )
        d,
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
                _weekdayShort.map(
              (w) {
                return Center(
                  child: Text(
                    w,
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
            itemCount: cells.length,
            gridDelegate:
                const SliceGridDelegate(
              crossAxisCount: 7,
            ),
            itemBuilder:
                (context, i) {
              final day = cells[i];

              if (day == null) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );

              final type =
                  _dayMarkers[
                    _normalize(date)
                  ];

              return GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onTap: () =>
                    _onDayTapped(date),
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

  // ---------------------------------------------------------------------------
  // Legend
  // ---------------------------------------------------------------------------

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
            'Period',
          ),

          _legendItem(
            _TrackingColors.fertile,
            'Fertile Window',
          ),

          _legendItem(
            _TrackingColors.tealDark,
            'Ovulation',
          ),

          _legendOutlineItem(
            'Predicted',
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

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

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
                const SizedBox(width: 12),
        itemBuilder:
            (context, i) {
          final stat =
              summaryStats[i];

          return _SummaryCard(
            value: stat.value,
            label: stat.label,
          );
        },
      ),
    );
  }
}

// ============================================================================
// Grid delegate
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
// Week item
// ============================================================================

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
              "$day",
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
            "$day",
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
// Calendar day
// ============================================================================

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
    Color? bg;

    Color textColor =
        Colors.black87;

    Border? border;

    FontWeight weight =
        FontWeight.normal;

    // -------------------------------------------------------
    // Actual period
    // -------------------------------------------------------

    if (type == DayType.period) {
      bg = _TrackingColors.period;
      textColor = Colors.white;
      weight = FontWeight.w600;
    }

    // -------------------------------------------------------
    // Ovulation
    // -------------------------------------------------------

    else if (type ==
        DayType.ovulation) {
      bg = _TrackingColors.tealDark;
      textColor = Colors.white;
      weight = FontWeight.w600;
    }

    // -------------------------------------------------------
    // Fertile
    // -------------------------------------------------------

    else if (type ==
        DayType.fertile) {
      bg = _TrackingColors.fertile;
      textColor =
          _TrackingColors.fertileText;
    }

    // -------------------------------------------------------
    // Predicted
    // -------------------------------------------------------

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

    // -------------------------------------------------------
    // Selection
    // -------------------------------------------------------
    //
    // Don't replace a period's pink styling with
    // a green border. The actual period should remain
    // clearly solid pink.
    //
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
          color: bg,
          shape:
              BoxShape.circle,
          border: border,
        ),
        child: Text(
          '$day',
          style:
              TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: weight,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Summary card
// ============================================================================

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
