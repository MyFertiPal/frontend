import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/period_service.dart';

/// Calendar marker types.
enum DayType {
  period,
  fertile,
  ovulation,
  predicted,
}

/// Theme colors.
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

class _CalendarTabScreenState
    extends State<CalendarTabScreen> {
  final ApiService _api = ApiService();

  final LocalPeriodService _localPeriod =
      LocalPeriodService();

  // ------------------------------------------------------------
  // CALENDAR STATE
  // ------------------------------------------------------------

  late DateTime _visibleMonth;

  Map<DateTime, DayType> _dayMarkers = {};

  DateTime? _selectedDate;

  bool _isSyncingPeriod = false;

  // ------------------------------------------------------------
  // CYCLE DATA
  // ------------------------------------------------------------

  DateTime? _lastPeriod;

  int _cycleLength = 28;

  int _periodLength = 5;

  String? _nextPeriod;

  String? _ovulationDay;

  String? _fertileStart;

  String? _fertileEnd;

  // ------------------------------------------------------------
  // SYMPTOMS
  // ------------------------------------------------------------

  List<dynamic> _loggedSymptoms = [];

  // ------------------------------------------------------------
  // DATE NORMALIZATION
  // ------------------------------------------------------------

  static DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ------------------------------------------------------------
  // EXTRACT SYMPTOM NAMES
  // ------------------------------------------------------------

  List<String> _extractSymptomNames() {
    final names = <String>[];

    for (final item in _loggedSymptoms) {
      if (item is! Map) continue;

      final symptoms = item["symptoms"];

      if (symptoms is List) {
        for (final symptom in symptoms) {
          if (symptom == null) continue;

          final value =
              symptom.toString().trim();

          if (value.isNotEmpty &&
              !names.contains(value)) {
            names.add(value);
          }
        }
      } else if (symptoms != null) {
        final value =
            symptoms.toString().trim();

        if (value.isNotEmpty &&
            !names.contains(value)) {
          names.add(value);
        }
      }
    }

    return names;
  }

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    if (widget.dayMarkers != null) {
      _dayMarkers =
          Map<DateTime, DayType>.from(
        widget.dayMarkers!,
      );
    }

    _loadCycle();
  }

  // ------------------------------------------------------------
  // INITIAL CALENDAR LOAD
  // ------------------------------------------------------------

 Future<void> _loadCycle() async {
  try {
    // ----------------------------------------------------------
    // 1. LOAD PROFILE FIRST
    // ----------------------------------------------------------

    final profile = await _api.getProfile();

    final cycleLength =
        (profile["cycle_length"] as num?)?.toInt() ?? 28;

    final periodLength =
        (profile["period_length"] as num?)?.toInt() ?? 5;

    final lastPeriodString =
        profile["last_period_date"]?.toString();

    _cycleLength = cycleLength;
    _periodLength = periodLength;

    if (lastPeriodString != null &&
        lastPeriodString.isNotEmpty) {
      _lastPeriod = DateTime.tryParse(
        lastPeriodString,
      );

      if (_lastPeriod != null) {
        _lastPeriod = _normalize(_lastPeriod!);
      }
    }

    // ----------------------------------------------------------
    // 2. LOAD SYMPTOMS
    // ----------------------------------------------------------

    final symptoms = await _api.getSymptoms();

    _loggedSymptoms = symptoms;

    // ----------------------------------------------------------
    // 3. LOAD LOCALLY TAPPED ACTUAL PERIOD DAYS
    // ----------------------------------------------------------

    final periods =
        await _localPeriod.getPeriodLogs();

    // ----------------------------------------------------------
    // 4. IF PROFILE HAS LAST PERIOD, USE IT
    // ----------------------------------------------------------

    if (_lastPeriod != null) {
      _rebuildMarkers();
    }

    // ----------------------------------------------------------
    // 5. ADD LOCALLY TAPPED ACTUAL DAYS
    // ----------------------------------------------------------

    for (final date in periods) {
      _dayMarkers[_normalize(date)] =
          DayType.period;
    }

    if (!mounted) return;

    setState(() {});

    // ----------------------------------------------------------
    // 6. GENERATE FRESH INSIGHTS
    // ----------------------------------------------------------

    if (_lastPeriod != null) {
      await _generateFreshInsights();
    }
  } catch (e, stackTrace) {
    debugPrint(
      "Calendar load error: $e",
    );

    debugPrint(
      "$stackTrace",
    );
  }
}
Future<void> _generateFreshInsights() async {
  if (_lastPeriod == null) return;

  try {
    final lastPeriodDate =
        _normalize(_lastPeriod!)
            .toIso8601String()
            .split('T')
            .first;

    final insights =
        await _api.generateInsights(
      cycleLength: _cycleLength,
      lastPeriodDate: lastPeriodDate,
      periodLength: _periodLength,
      symptoms: _extractSymptomNames(),
    );

    if (!mounted) return;

    debugPrint(
      "CALENDAR INSIGHTS RESPONSE: $insights",
    );

    if (insights.isNotEmpty &&
        insights.first is Map) {
      final data =
          Map<String, dynamic>.from(
        insights.first as Map,
      );

      _nextPeriod =
          data["next_period"]?.toString();

      _ovulationDay =
          data["ovulation_day"]?.toString();

      _fertileStart =
          data["fertile_period_start"]?.toString();

      _fertileEnd =
          data["fertile_period_end"]?.toString();
    }

    // IMPORTANT:
    // Rebuild colors AFTER insights arrive.
    _rebuildMarkers();

    if (mounted) {
      setState(() {});
    }
  } catch (e, stackTrace) {
    debugPrint(
      "Insight generation error: $e",
    );

    debugPrint(
      "$stackTrace",
    );
  }
}
  // ------------------------------------------------------------
  // REFRESH PROFILE + SYMPTOMS + INSIGHTS
  // ------------------------------------------------------------

  Future<void> _refreshCycleData() async {
    try {
      final profile =
          await _api.getProfile();

      final symptoms =
          await _api.getSymptoms();

      if (!mounted) return;

      final cycleLength =
          (profile["cycle_length"] as num?)
                  ?.toInt() ??
              28;

      final periodLength =
          (profile["period_length"] as num?)
                  ?.toInt() ??
              5;

      final lastPeriodString =
          profile["last_period_date"]
              ?.toString();

      _cycleLength = cycleLength;
      _periodLength = periodLength;

      _loggedSymptoms = symptoms;

      if (lastPeriodString != null &&
          lastPeriodString.isNotEmpty) {
        _lastPeriod =
            DateTime.tryParse(
          lastPeriodString,
        );
      }

      // --------------------------------------------------------
      // If there is no last period, don't generate predictions.
      // --------------------------------------------------------

      if (_lastPeriod == null) {
        _nextPeriod = null;
        _ovulationDay = null;
        _fertileStart = null;
        _fertileEnd = null;

        _rebuildMarkers();

        if (mounted) {
          setState(() {});
        }

        return;
      }

      final lastPeriodDate =
          _normalize(_lastPeriod!)
              .toIso8601String()
              .split('T')
              .first;

      final symptomNames =
          _extractSymptomNames();

      debugPrint(
        '''
CALENDAR INSIGHT REQUEST

cycle_length: $cycleLength
period_length: $periodLength
last_period_date: $lastPeriodDate
symptoms: $symptomNames
''',
      );

      // --------------------------------------------------------
      // Generate fresh backend prediction.
      // --------------------------------------------------------

      final insights =
          await _api.generateInsights(
        cycleLength: cycleLength,
        lastPeriodDate: lastPeriodDate,
        periodLength: periodLength,
        symptoms: symptomNames,
      );

      if (!mounted) return;

      debugPrint(
        "CALENDAR INSIGHTS RESPONSE: $insights",
      );

      // --------------------------------------------------------
      // APPLY BACKEND RESPONSE
      // --------------------------------------------------------

      if (insights.isNotEmpty &&
          insights.first is Map) {
        final data =
            Map<String, dynamic>.from(
          insights.first as Map,
        );

        _nextPeriod =
            data["next_period"]?.toString();

        _ovulationDay =
            data["ovulation_day"]?.toString();

        _fertileStart =
            data["fertile_period_start"]
                ?.toString();

        _fertileEnd =
            data["fertile_period_end"]
                ?.toString();
      }

      // --------------------------------------------------------
      // Rebuild calendar markers.
      // --------------------------------------------------------

      _rebuildMarkers();

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Refresh cycle error: $e",
      );

      debugPrint(
        "$stackTrace",
      );
    }
  }

  // ------------------------------------------------------------
  // REBUILD ALL CALENDAR MARKERS
  // ------------------------------------------------------------

 void _rebuildMarkers() {
  final markers = <DateTime, DayType>{};

  // ============================================================
  // ACTUAL PERIOD
  // ============================================================

  if (_lastPeriod != null) {
    final start = _normalize(_lastPeriod!);

    for (int i = 0; i < _periodLength; i++) {
      final date = _normalize(
        start.add(
          Duration(days: i),
        ),
      );

      markers[date] = DayType.period;
    }
  }

  // ============================================================
  // FERTILE WINDOW
  // ============================================================

  if (_fertileStart != null &&
      _fertileEnd != null) {
    final start = DateTime.tryParse(
      _fertileStart!,
    );

    final end = DateTime.tryParse(
      _fertileEnd!,
    );

    if (start != null && end != null) {
      var current = _normalize(start);
      final last = _normalize(end);

      while (!current.isAfter(last)) {
        if (markers[current] != DayType.period) {
          markers[current] = DayType.fertile;
        }

        current = current.add(
          const Duration(days: 1),
        );
      }
    }
  }

  // ============================================================
  // OVULATION
  // ============================================================

  if (_ovulationDay != null) {
    final date = DateTime.tryParse(
      _ovulationDay!,
    );

    if (date != null) {
      final key = _normalize(date);

      if (markers[key] != DayType.period) {
        markers[key] = DayType.ovulation;
      }
    }
  }

  // ============================================================
  // NEXT PREDICTED PERIOD
  // ============================================================

  if (_nextPeriod != null) {
    final date = DateTime.tryParse(
      _nextPeriod!,
    );

    if (date != null) {
      final start = _normalize(date);

      for (int i = 0; i < _periodLength; i++) {
        final key = _normalize(
          start.add(
            Duration(days: i),
          ),
        );

        if (markers[key] != DayType.period &&
            markers[key] != DayType.ovulation) {
          markers[key] = DayType.predicted;
        }
      }
    }
  }

  // ============================================================
  // APPLY
  // ============================================================

  _dayMarkers = markers;

  debugPrint(
    "CALENDAR MARKERS: $_dayMarkers",
  );
}

  // ------------------------------------------------------------
  // TOGGLE PERIOD DAY
  // ------------------------------------------------------------

  Future<void> _togglePeriodDay(
    DateTime date,
  ) async {
    if (_isSyncingPeriod) return;

    final key =
        _normalize(date);

    final wasPeriod =
        _dayMarkers[key] ==
            DayType.period;

    // ----------------------------------------------------------
    // UPDATE UI IMMEDIATELY
    // ----------------------------------------------------------

    setState(() {
      _isSyncingPeriod = true;

      if (wasPeriod) {
        _dayMarkers.remove(key);
      } else {
        _dayMarkers[key] =
            DayType.period;
      }
    });

    try {
      // --------------------------------------------------------
      // SAVE LOCALLY FIRST
      // --------------------------------------------------------

      if (wasPeriod) {
        await _localPeriod
            .deletePeriod(key);
      } else {
        await _localPeriod
            .savePeriod(key);
      }

      // --------------------------------------------------------
      // READ LOCAL PERIODS
      // --------------------------------------------------------

      final periods =
          await _localPeriod
              .getPeriodLogs();

      periods.sort(
        (a, b) => a.compareTo(b),
      );

      // --------------------------------------------------------
      // NOTHING LEFT
      // --------------------------------------------------------

      if (periods.isEmpty) {
        if (!mounted) return;

        setState(() {
          _dayMarkers.clear();

          _lastPeriod = null;

          _nextPeriod = null;
          _ovulationDay = null;
          _fertileStart = null;
          _fertileEnd = null;
        });

        return;
      }

      // --------------------------------------------------------
      // MOST RECENT LOGGED PERIOD
      // --------------------------------------------------------

      final latestPeriod =
          _normalize(
        periods.last,
      );

      _lastPeriod =
          latestPeriod;

      // --------------------------------------------------------
      // REBUILD LOCAL PERIOD MARKERS
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        for (final period in periods) {
          _dayMarkers[
            _normalize(period)
          ] = DayType.period;
        }
      });

      // --------------------------------------------------------
      // GENERATE FRESH INSIGHTS
      // --------------------------------------------------------

      final insights =
          await _api.generateInsights(
        cycleLength: _cycleLength,
        lastPeriodDate:
            latestPeriod
                .toIso8601String()
                .split('T')
                .first,
        periodLength: _periodLength,
        symptoms:
            _extractSymptomNames(),
      );

      if (!mounted) return;

      debugPrint(
        "UPDATED CALENDAR INSIGHTS: $insights",
      );

      // --------------------------------------------------------
      // APPLY NEW PREDICTIONS
      // --------------------------------------------------------

      if (insights.isNotEmpty &&
          insights.first is Map) {
        final data =
            Map<String, dynamic>.from(
          insights.first as Map,
        );

        _nextPeriod =
            data["next_period"]
                ?.toString();

        _ovulationDay =
            data["ovulation_day"]
                ?.toString();

        _fertileStart =
            data["fertile_period_start"]
                ?.toString();

        _fertileEnd =
            data["fertile_period_end"]
                ?.toString();
      }

      // --------------------------------------------------------
      // REBUILD MARKERS
      // --------------------------------------------------------

      _rebuildMarkers();

      setState(() {});
    } catch (e, stackTrace) {
      debugPrint(
        "Period update error: $e",
      );

      debugPrint(
        "$stackTrace",
      );

      // --------------------------------------------------------
      // ROLLBACK UI
      // --------------------------------------------------------

      if (mounted) {
        setState(() {
          if (wasPeriod) {
            _dayMarkers[key] =
                DayType.period;
          } else {
            _dayMarkers.remove(key);
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingPeriod = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // MONTH NAVIGATION
  // ------------------------------------------------------------

  void _goPreviousMonth() {
    setState(() {
      _visibleMonth =
          DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
        1,
      );
    });
  }

  void _goNextMonth() {
    setState(() {
      _visibleMonth =
          DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        1,
      );
    });
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
    // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color: _TrackingColors.bg,
      child: SafeArea(
        child: SingleChildScrollView(
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

              const SizedBox(height: 10),

              _buildSummaryRow(),

              const SizedBox(height: 25),

              _buildLoggedSymptoms(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _buildHero() {
    final todayLabel =
        '${_fullWeekday(widget.today.weekday)}, '
        '${_monthNames[widget.today.month - 1]} '
        '${widget.today.day}';

    final days =
        List.generate(
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
            const EdgeInsets.all(22),
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
                    _TrackingColors.tealDark,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              todayLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    _TrackingColors.tealDark,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children:
                  days.map((date) {
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
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CALENDAR CARD
  // ------------------------------------------------------------

  Widget _buildCalendarCard() {
    final days =
        _daysInMonth(
      _visibleMonth,
    );

    final offset =
        _visibleMonth.weekday % 7;

    final cells =
        <int?>[
      ...List.filled(
        offset,
        null,
      ),
      for (int i = 1;
          i <= days;
          i++)
        i,
    ];

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // ----------------------------------------------------
          // MONTH HEADER
          // ----------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed:
                    _isSyncingPeriod
                        ? null
                        : _goPreviousMonth,
                icon:
                    const Icon(
                  Icons.chevron_left,
                ),
              ),

              Text(
                "${_monthNames[_visibleMonth.month - 1]} "
                "${_visibleMonth.year}",
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              IconButton(
                onPressed:
                    _isSyncingPeriod
                        ? null
                        : _goNextMonth,
                icon:
                    const Icon(
                  Icons.chevron_right,
                ),
              ),
            ],
          ),

          // ----------------------------------------------------
          // WEEKDAY HEADER
          // ----------------------------------------------------

          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            children:
                _weekdayShort.map(
              (day) {
                return Center(
                  child: Text(
                    day,
                    style:
                        const TextStyle(
                      color:
                          _TrackingColors
                              .textMuted,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 6),

          // ----------------------------------------------------
          // CALENDAR DAYS
          // ----------------------------------------------------

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
                return const SizedBox();
              }

              final date =
                  DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );

              final key =
                  _normalize(date);

              final type =
                  _dayMarkers[key];

              return GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onTap:
                    _isSyncingPeriod
                        ? null
                        : () =>
                            _togglePeriodDay(
                              date,
                            ),
                child:
                    _CalendarDayCell(
                  day: day,
                  isToday:
                      DateUtils.isSameDay(
                    widget.today,
                    date,
                  ),
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

          // ----------------------------------------------------
          // SMALL SYNC INDICATOR
          // ----------------------------------------------------

          if (_isSyncingPeriod) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        _TrackingColors.teal,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Updating predictions...",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _TrackingColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LEGEND
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // SUMMARY DATA
  // ------------------------------------------------------------

  List<SummaryStat>
      get summaryStats => [
    SummaryStat(
      value:
          "$_cycleLength days",
      label:
          "Cycle Length",
    ),
    SummaryStat(
      value:
          "$_periodLength days",
      label:
          "Period Length",
    ),
    SummaryStat(
      value:
          _fertileStart == null ||
                  _fertileEnd == null
              ? "--"
              : "${_formatMonthDay(_fertileStart!)} - "
                  "${_formatMonthDay(_fertileEnd!)}",
      label:
          "Fertile Window",
    ),
  ];

  String _formatMonthDay(
    String value,
  ) {
    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return "${_monthNames[date.month - 1].substring(0, 3)} "
        "${date.day}";
  }

  // ------------------------------------------------------------
  // SUMMARY ROW
  // ------------------------------------------------------------

  Widget _buildSummaryRow() {
    return SizedBox(
      height: 96,
      child:
          ListView.separated(
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

  // ------------------------------------------------------------
  // LOGGED SYMPTOMS
  // ------------------------------------------------------------

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
          const Text(
            "Logged Symptoms",
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  _TrackingColors
                      .tealDark,
            ),
          ),

          const SizedBox(height: 16),

          if (_loggedSymptoms.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Center(
                child: Text(
                  "No symptoms logged yet",
                  style: TextStyle(
                    color:
                        _TrackingColors
                            .textMuted,
                  ),
                ),
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              if (item is! Map) {
                return const SizedBox();
              }

              final rawSymptoms =
                  item["symptoms"];

              final symptoms =
                  rawSymptoms is List
                      ? rawSymptoms
                          .map(
                            (e) =>
                                e.toString(),
                          )
                          .join(", ")
                      : rawSymptoms
                              ?.toString() ??
                          "";

              final createdAt =
                  item["created_at"]
                          ?.toString() ??
                      "";

              return Container(
                width:
                    double.infinity,
                margin:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
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
                  children: [
                    Text(
                      symptoms.isEmpty
                          ? "Symptoms logged"
                          : symptoms,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            _TrackingColors
                                .tealDark,
                      ),
                    ),

                    if (createdAt
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        createdAt,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              _TrackingColors
                                  .textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
    // ------------------------------------------------------------
  // DATE HELPERS
  // ------------------------------------------------------------

  static const List<String>
      _monthNames = [
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

  static const List<String>
      _weekdayShort = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  String _fullWeekday(
    int weekday,
  ) {
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

  String _shortWeekday(
    int weekday,
  ) {
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
              color:
                  Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$day",
            style:
                const TextStyle(
              color:
                  _TrackingColors
                      .tealDark,
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

class _CalendarDayCell
    extends StatelessWidget {
  final int day;
  final bool isToday;
  final DayType? type;
  final bool isSelected;

  const _CalendarDayCell({
    required this.day,
    required this.isToday,
    required this.type,
    this.isSelected = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Color? background;
    Color textColor =
        Colors.black87;

    Border? border;

    FontWeight weight =
        FontWeight.normal;

    // ----------------------------------------------------------
    // ACTUAL PERIOD
    // ----------------------------------------------------------

    if (type ==
        DayType.period) {
      background =
          _TrackingColors.period;

      textColor =
          Colors.white;

      weight =
          FontWeight.w600;
    }

    // ----------------------------------------------------------
    // OVULATION
    // ----------------------------------------------------------

    else if (type ==
        DayType.ovulation) {
      background =
          _TrackingColors
              .tealDark;

      textColor =
          Colors.white;

      weight =
          FontWeight.w600;
    }

    // ----------------------------------------------------------
    // TODAY
    // ----------------------------------------------------------

    else if (isToday) {
      background =
          _TrackingColors
              .tealDark;

      textColor =
          Colors.white;

      weight =
          FontWeight.w600;
    }

    // ----------------------------------------------------------
    // FERTILE WINDOW
    // ----------------------------------------------------------

    else if (type ==
        DayType.fertile) {
      background =
          _TrackingColors.fertile;

      textColor =
          _TrackingColors
              .fertileText;
    }

    // ----------------------------------------------------------
    // PREDICTED PERIOD
    // ----------------------------------------------------------

    else if (type ==
        DayType.predicted) {
      border =
          Border.all(
        color:
            _TrackingColors
                .predictedBorder,
        width: 2,
      );

      textColor =
          _TrackingColors.period;
    }

    // ----------------------------------------------------------
    // SELECTED DATE
    // ----------------------------------------------------------

    if (isSelected &&
        type == null) {
      border =
          Border.all(
        color:
            _TrackingColors
                .teal,
        width: 2,
      );
    }

    return Center(
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 150,
        ),
        width: 38,
        height: 38,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color: background,
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
// SUMMARY CARD
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