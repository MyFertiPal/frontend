import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/period_service.dart';

/// Types of calendar-day markers shown on the calendar grid.
enum DayType { period, fertile, ovulation, predicted }

/// Colors used across the screen. Pulled out so they're easy to retheme.
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
  const SummaryStat({required this.value, required this.label});
}

/// Cycle tracking screen: hero week strip, a month calendar with markers, and a summary row of stats.
class CalendarTabScreen extends StatefulWidget {
  final DateTime today;

  final Map<DateTime, DayType>? dayMarkers;

  CalendarTabScreen({
    super.key,
    DateTime? today,
    this.dayMarkers,
  }) : today = today ?? DateTime.now();

  @override
  State<CalendarTabScreen> createState() => _CalendarTabScreenState();
}

class _CalendarTabScreenState extends State<CalendarTabScreen> {
  final LocalPeriodService _periodService = LocalPeriodService();

  List<dynamic> _loggedSymptoms = [];

  DateTime? _selectedDate;
  DateTime? _lastPeriod;
  int _cycleLength = 0;
  int _periodLength = 0;

  // Only a single day comes back from the backend for last/next period -
  // the rest of the period/prediction range is derived locally using
  // _periodLength. Ovulation is a single day; fertile window is an
  // explicit start/end range, both returned as-is from insights.
  String? _nextPeriod;
  String? _ovulationDay;
  String? _fertileStart;
  String? _fertileEnd;

  late DateTime _visibleMonth; // first day of the currently shown month

  // Markers computed from the backend (profile + insights).
  Map<DateTime, DayType> _backendMarkers = {};

  // Days the user has tapped/logged locally (persisted via shared_preferences).
  Set<DateTime> _localPeriodDays = {};

  // Merged view actually rendered on the calendar (backend + local).
  Map<DateTime, DayType> _dayMarkers = {};

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<SummaryStat> get summaryStats => [
        SummaryStat(
          value: "$_cycleLength days",
          label: "Cycle Length",
        ),
        SummaryStat(
          value: "$_periodLength days",
          label: "Period Length",
        ),
        SummaryStat(
          value: _fertileStart == null
              ? "--"
              : "${_fertileStart!.substring(5)} - ${_fertileEnd!.substring(5)}",
          label: "Fertile Window",
        ),
      ];

  @override
  void initState() {
    super.initState();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    _loadCycle();
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekdayShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _TrackingColors.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  // ---- Data loading ---------------------------------------------------------

  Future<void> _loadCycle() async {
    try {
      final api = ApiService();

      final profile = await api.getProfile();
      final insights = await api.getInsights();
      final symptoms = await api.getSymptoms();

      if (!mounted) return;

      _loggedSymptoms = symptoms;

      _cycleLength = profile["cycle_length"] ?? 0;
      _periodLength = profile["period_length"] ?? 0;

      if (profile["last_period_date"] != null) {
        _lastPeriod = DateTime.parse(profile["last_period_date"]);
      }

      if (insights.isNotEmpty) {
        final latestInsight = insights.first as Map<String, dynamic>;
        // NOTE: adjust this key if your backend's insights payload uses a
        // different field name for the predicted next period date.
        _nextPeriod =
            latestInsight["next_period_date"] ?? latestInsight["next_period"];
        _ovulationDay = latestInsight["ovulation_day"];
        _fertileStart = latestInsight["fertile_period_start"];
        _fertileEnd = latestInsight["fertile_period_end"];
      }

      await _loadLocalPeriods();
      _buildBackendMarkers();
      _rebuildMergedMarkers();

      setState(() {});
    } catch (e) {
      debugPrint("Calendar error: $e");
    }
  }

  Future<void> _loadLocalPeriods() async {
    final logs = await _periodService.getPeriodLogs();
    // Merge (don't overwrite) - if the user taps a day while this load is
    // still in flight (e.g. slow network for profile/insights), we must
    // not wipe out that optimistic in-memory addition when this resolves.
    _localPeriodDays.addAll(logs.map(_normalize));
  }

  /// Expands the single last-period-date / next-period-date the backend
  /// returns into full period-length ranges.
  void _buildBackendMarkers() {
    final markers = <DateTime, DayType>{};

    // Period days: last period date + period length.
    if (_lastPeriod != null && _periodLength > 0) {
      for (int i = 0; i < _periodLength; i++) {
        final date = _lastPeriod!.add(Duration(days: i));
        markers[_normalize(date)] = DayType.period;
      }
    }

    // Fertile window: explicit start/end range from insights.
    if (_fertileStart != null && _fertileEnd != null) {
      var day = DateTime.parse(_fertileStart!);
      final end = DateTime.parse(_fertileEnd!);

      while (day.isBefore(end) || day.isAtSameMomentAs(end)) {
        markers[_normalize(day)] = DayType.fertile;
        day = day.add(const Duration(days: 1));
      }
    }

    // Ovulation: single day, takes priority over the fertile window it
    // falls inside.
    if (_ovulationDay != null) {
      final date = DateTime.parse(_ovulationDay!);
      markers[_normalize(date)] = DayType.ovulation;
    }

    // Predicted period days: next period date + period length. Takes
    // priority over fertile/ovulation if they happen to overlap.
    if (_nextPeriod != null && _periodLength > 0) {
      final date = DateTime.parse(_nextPeriod!);
      for (int i = 0; i < _periodLength; i++) {
        final predictedDate = date.add(Duration(days: i));
        markers[_normalize(predictedDate)] = DayType.predicted;
      }
    }

    _backendMarkers = markers;
  }

  /// Combines backend-derived markers with locally-logged period days.
  /// A locally-logged day always renders as an actual period day, even if
  /// the backend had it marked as merely "predicted".
  void _rebuildMergedMarkers() {
    final merged = Map<DateTime, DayType>.from(_backendMarkers);

    for (final date in _localPeriodDays) {
      merged[date] = DayType.period;
    }

    _dayMarkers = merged;
  }

  // ---- Tap-to-log period days -------------------------------------------

  bool _isTappable(DayType? type) {
    // Only unmarked days and existing period days can be tapped.
    // Predicted days aren't editable directly - log the actual period
    // once it starts instead.
    return type == null || type == DayType.period;
  }

  Future<void> _onDayTapped(DateTime date) async {
    final normalized = _normalize(date);
    final currentType = _dayMarkers[normalized];

    if (!_isTappable(currentType)) return;

    final isLogged = _localPeriodDays.contains(normalized);

    setState(() {
      _selectedDate = normalized;
      if (isLogged) {
        _localPeriodDays.remove(normalized);
      } else {
        _localPeriodDays.add(normalized);
      }
      _rebuildMergedMarkers();
    });

    if (isLogged) {
      await _periodService.deletePeriod(normalized);
    } else {
      await _periodService.savePeriod(normalized);
    }
  }

  // ---- Logged symptoms --------------------------------------------------

  Widget _buildLoggedSymptoms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Text("No symptoms logged yet"),
            ),
          ..._loggedSymptoms.map((item) {
            return Card(
              child: ListTile(
                title: Text(
                  item["symptoms"].join(", "),
                ),
                subtitle: Text(item["created_at"]),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---- Hero header + week strip ------------------------------------------

  Widget _buildHero() {
    final todayLabel =
        '${_fullWeekday(widget.today.weekday)}, '
        '${_monthNames[widget.today.month - 1]} ${widget.today.day}';

    final days = List.generate(
      5,
      (i) => widget.today.add(Duration(days: i - 2)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today",
              style: TextStyle(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((date) {
                final isToday =
                    _normalize(date) == _normalize(widget.today);

                return _WeekDateItem(
                  weekday: _shortWeekday(date.weekday),
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

  String _fullWeekday(int weekday) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return names[weekday - 1];
  }

  String _shortWeekday(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  // ---- Calendar card -------------------------------------------------------

  Widget _buildCalendarCard() {
    final daysInMonth = _daysInMonth(_visibleMonth);
    // Dart weekday: Mon=1..Sun=7. We want a Sun-first grid (S M T W T F S).
    final firstWeekdayOffset = _visibleMonth.weekday % 7; // Sun=0..Sat=6

    final cells = <int?>[
      ...List.filled(firstWeekdayOffset, null),
      for (var d = 1; d <= daysInMonth; d++) d,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left),
                color: _TrackingColors.textMuted,
                tooltip: 'Previous month',
              ),
              Text(
                '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right),
                color: _TrackingColors.textMuted,
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _weekdayShort
                .map((w) => Center(
                      child: Text(
                        w,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _TrackingColors.textMuted,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliceGridDelegate(crossAxisCount: 7),
            itemBuilder: (context, i) {
              final day = cells[i];
              if (day == null) return const SizedBox.shrink();
              final date =
                  DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final type = _dayMarkers[_normalize(date)];

              return GestureDetector(
                onTap: () => _onDayTapped(date),
                child: _CalendarDayCell(
                  day: day,
                  type: type,
                  isSelected: DateUtils.isSameDay(
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

  // ---- Legend ---------------------------------------------------------------

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          _legendItem(_TrackingColors.period, 'Period'),
          _legendItem(_TrackingColors.fertile, 'Fertile Window'),
          _legendItem(_TrackingColors.tealDark, 'Ovulation'),
          _legendOutlineItem('Predicted'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: _TrackingColors.textMuted)),
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
            border: Border.all(color: _TrackingColors.predictedBorder, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: _TrackingColors.textMuted)),
      ],
    );
  }

  // ---- Summary cards (horizontally scrollable) ------------------------------

  Widget _buildSummaryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: summaryStats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final stat = summaryStats[i];
          return _SummaryCard(value: stat.value, label: stat.label);
        },
      ),
    );
  }
}

/// Simple 7-column grid delegate with a fixed 1:1 cell aspect ratio.
class SliceGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliceGridDelegate({required super.crossAxisCount})
      : super(childAspectRatio: 1);
}

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
      return Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF18B7B3),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$day",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$day",
            style: const TextStyle(
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

/// A single day cell on the calendar grid.
///
/// Note: "today" is intentionally NOT given special styling here - it's
/// already called out in the hero card above the calendar.
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
  Widget build(BuildContext context) {
    Color? bg;
    Color textColor = Colors.black87;
    Border? border;
    FontWeight weight = FontWeight.normal;

    if (type == DayType.period) {
      bg = _TrackingColors.period;
      textColor = Colors.white;
      weight = FontWeight.w600;
    } else if (type == DayType.ovulation) {
      bg = _TrackingColors.tealDark;
      textColor = Colors.white;
      weight = FontWeight.w600;
    } else if (type == DayType.fertile) {
      bg = _TrackingColors.fertile;
      textColor = _TrackingColors.fertileText;
    } else if (type == DayType.predicted) {
      border = Border.all(
        color: _TrackingColors.predictedBorder,
        width: 2,
      );
      textColor = _TrackingColors.period;
    }

    if (isSelected) {
      border = Border.all(
        color: _TrackingColors.tealDark,
        width: 2,
      );
    }

    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text(
          '$day',
          style: TextStyle(fontSize: 13, color: textColor, fontWeight: weight),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _TrackingColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _TrackingColors.textMuted),
          ),
        ],
      ),
    );
  }
}