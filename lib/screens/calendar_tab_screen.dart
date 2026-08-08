import 'package:flutter/material.dart';

/// ============================================================
/// CALENDAR MARKER TYPES
/// ============================================================

enum DayType {
  period,
  fertile,
  ovulation,
  predicted,
}

/// ============================================================
/// CALENDAR COLORS
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

  static const text = Color(0xFF20242A);
  static const textMuted = Color(0xFF8A8F98);
}

/// ============================================================
/// SUMMARY MODEL
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
  /// The date used as "today" by the UI.
  final DateTime today;

  /// Markers supplied by the parent/business logic.
  ///
  /// Example:
  ///
  /// {
  ///   DateTime(2026, 8, 18): DayType.period,
  ///   DateTime(2026, 8, 19): DayType.period,
  ///   DateTime(2026, 8, 22): DayType.fertile,
  ///   DateTime(2026, 8, 25): DayType.ovulation,
  ///   DateTime(2026, 9, 15): DayType.predicted,
  /// }
  final Map<DateTime, DayType>? dayMarkers;

  /// Optional summary values.
  final String cycleLength;
  final String periodLength;
  final String fertileWindow;

   CalendarTabScreen({
    super.key,
    DateTime? today,
    this.dayMarkers,
    this.cycleLength = '--',
    this.periodLength = '--',
    this.fertileWindow = '--',
  }) : today = today ?? DateTime.now();

  @override
  State<CalendarTabScreen> createState() =>
      _CalendarTabScreenState();
}

/// ============================================================
/// STATE
/// ============================================================

class _CalendarTabScreenState
    extends State<CalendarTabScreen> {
  late DateTime _visibleMonth;

  DateTime? _selectedDate;

  late Map<DateTime, DayType> _dayMarkers;

  @override
  void initState() {
    super.initState();

    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );

    _dayMarkers = _normalizeMarkers(
      widget.dayMarkers ?? {},
    );
  }

  @override
  void didUpdateWidget(
    covariant CalendarTabScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dayMarkers != widget.dayMarkers) {
      setState(() {
        _dayMarkers = _normalizeMarkers(
          widget.dayMarkers ?? {},
        );
      });
    }
  }

  /// ==========================================================
  /// DATE NORMALIZATION
  /// ==========================================================

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Map<DateTime, DayType> _normalizeMarkers(
    Map<DateTime, DayType> markers,
  ) {
    final result = <DateTime, DayType>{};

    for (final entry in markers.entries) {
      result[_normalize(entry.key)] = entry.value;
    }

    return result;
  }

  /// ==========================================================
  /// MONTH NAVIGATION
  /// ==========================================================

  void _previousMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        1,
      );
    });
  }

  void _goToToday() {
    setState(() {
      _visibleMonth = DateTime(
        widget.today.year,
        widget.today.month,
        1,
      );
    });
  }

  /// ==========================================================
  /// DATE SELECTION
  /// ==========================================================

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _normalize(date);
    });
  }

  /// ==========================================================
  /// MONTH INFORMATION
  /// ==========================================================

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  int _firstWeekdayOffset(DateTime month) {
    return DateTime(
      month.year,
      month.month,
      1,
    ).weekday %
        7;
  }

  /// ==========================================================
  /// BUILD
  /// ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TrackingColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildHero(),

              const SizedBox(height: 4),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: _buildCalendarCard(),
              ),

              const SizedBox(height: 12),

              _buildLegend(),

              const SizedBox(height: 18),

              _buildSummaryRow(),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  /// ==========================================================
  /// HERO
  /// ==========================================================

  Widget _buildHero() {
    final today = _normalize(widget.today);

    final dates = List.generate(
      5,
      (index) {
        return today.add(
          Duration(days: index - 2),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
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
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w500,
                color:
                    _TrackingColors.tealDark,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              _formatFullDate(today),
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
              children: dates.map(
                (date) {
                  return _WeekDateItem(
                    weekday:
                        _shortWeekday(
                      date.weekday,
                    ),
                    day: date.day,
                    isToday:
                        DateUtils.isSameDay(
                      date,
                      today,
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================================================
  /// CALENDAR CARD
  /// ==========================================================

  Widget _buildCalendarCard() {
    final days =
        _daysInMonth(_visibleMonth);

    final offset =
        _firstWeekdayOffset(
      _visibleMonth,
    );

    final cells = <int?>[
      ...List<int?>.filled(
        offset,
        null,
      ),
      for (int day = 1;
          day <= days;
          day++)
        day,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              _TrackingColors.cardBorder
                  .withOpacity(.35),
        ),
      ),
      child: Column(
        children: [
          _buildMonthHeader(),

          const SizedBox(height: 8),

          _buildWeekdayHeader(),

          const SizedBox(height: 8),

          _buildCalendarGrid(cells),
        ],
      ),
    );
  }

  /// ==========================================================
  /// MONTH HEADER
  /// ==========================================================

  Widget _buildMonthHeader() {
    final isCurrentMonth =
        _visibleMonth.year ==
                widget.today.year &&
            _visibleMonth.month ==
                widget.today.month;

    return Row(
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(
            Icons.chevron_left,
            size: 26,
          ),
        ),

        Expanded(
          child: Center(
            child: Text(
              '${_monthNames[_visibleMonth.month - 1]} '
              '${_visibleMonth.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                color:
                    _TrackingColors.text,
              ),
            ),
          ),
        ),

        if (!isCurrentMonth)
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(
                color:
                    _TrackingColors.teal,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(width: 48),

        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(
            Icons.chevron_right,
            size: 26,
          ),
        ),
      ],
    );
  }

  /// ==========================================================
  /// WEEKDAY HEADER
  /// ==========================================================

  Widget _buildWeekdayHeader() {
    return Row(
      children:
          _weekdayLabels.map(
        (label) {
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      _TrackingColors.textMuted,
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  /// ==========================================================
  /// CALENDAR GRID
  /// ==========================================================

  Widget _buildCalendarGrid(
    List<int?> cells,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 7,
        crossAxisSpacing: 3,
        childAspectRatio: 0.88,
      ),
      itemBuilder:
          (context, index) {
        final day = cells[index];

        if (day == null) {
          return const SizedBox();
        }

        final date = DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
          day,
        );

        final normalizedDate =
            _normalize(date);

        final marker =
            _dayMarkers[
                normalizedDate];

        final isToday =
            DateUtils.isSameDay(
          normalizedDate,
          widget.today,
        );

        final isSelected =
            DateUtils.isSameDay(
          normalizedDate,
          _selectedDate,
        );

        return _CalendarDayCell(
          day: day,
          type: marker,
          isToday: isToday,
          isSelected: isSelected,
          onTap: () {
            _selectDate(date);
          },
        );
      },
    );
  }

  /// ==========================================================
  /// LEGEND
  /// ==========================================================

  Widget _buildLegend() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          _LegendItem(
            color:
                _TrackingColors.period,
            label: 'Period',
          ),

          _LegendItem(
            color:
                _TrackingColors.fertile,
            label: 'Fertile Window',
            textColor:
                _TrackingColors.fertileText,
          ),

          _LegendItem(
            color:
                _TrackingColors.tealDark,
            label: 'Ovulation',
          ),

          const _PredictedLegendItem(),
        ],
      ),
    );
  }

  /// ==========================================================
  /// SUMMARY
  /// ==========================================================

  Widget _buildSummaryRow() {
    final stats = [
      SummaryStat(
        value:
            widget.cycleLength,
        label: 'Cycle Length',
      ),
      SummaryStat(
        value:
            widget.periodLength,
        label: 'Period Length',
      ),
      SummaryStat(
        value:
            widget.fertileWindow,
        label: 'Fertile Window',
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount: stats.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 12,
        ),
        itemBuilder:
            (context, index) {
          final stat = stats[index];

          return _SummaryCard(
            value: stat.value,
            label: stat.label,
          );
        },
      ),
    );
  }

  /// ==========================================================
  /// DATE FORMATTING
  /// ==========================================================

  String _formatFullDate(
    DateTime date,
  ) {
    return '${_fullWeekday(date.weekday)}, '
        '${_monthNames[date.month - 1]} '
        '${date.day}';
  }

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
      _weekdayLabels = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];
}

/// ============================================================
/// CALENDAR DAY CELL
///
/// THIS IS PURE UI.
///
/// It does NOT calculate anything.
/// It simply receives DayType and paints the day.
/// ============================================================

class _CalendarDayCell
    extends StatelessWidget {
  final int day;
  final DayType? type;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.type,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appearance =
        _appearanceForType(type);

    Border? border;

    if (isSelected) {
      border = Border.all(
        color:
            _TrackingColors.teal,
        width: 2,
      );
    } else if (appearance.borderColor !=
        null) {
      border = Border.all(
        color:
            appearance.borderColor!,
        width: 1.8,
      );
    }

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                appearance.backgroundColor,
            border: border,
          ),
          alignment:
              Alignment.center,
          child: Stack(
            alignment:
                Alignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      type != null ||
                              isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                  color:
                      appearance.textColor,
                ),
              ),

              if (isToday)
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      color:
                          appearance
                              .todayDotColor,
                      shape:
                          BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _DayAppearance _appearanceForType(
    DayType? type,
  ) {
    switch (type) {
      case DayType.period:
        return const _DayAppearance(
          backgroundColor:
              _TrackingColors.period,
          textColor:
              Colors.white,
          todayDotColor:
              Colors.white,
        );

      case DayType.fertile:
        return const _DayAppearance(
          backgroundColor:
              _TrackingColors.fertile,
          textColor:
              _TrackingColors.fertileText,
          todayDotColor:
              _TrackingColors.fertileText,
        );

      case DayType.ovulation:
        return const _DayAppearance(
          backgroundColor:
              _TrackingColors.tealDark,
          textColor:
              Colors.white,
          todayDotColor:
              Colors.white,
        );

      case DayType.predicted:
        return const _DayAppearance(
          backgroundColor:
              Colors.transparent,
          textColor:
              _TrackingColors.tealDark,
          borderColor:
              _TrackingColors.predictedBorder,
          todayDotColor:
              _TrackingColors.tealDark,
        );

      case null:
        return const _DayAppearance(
          backgroundColor:
              Colors.transparent,
          textColor:
              _TrackingColors.text,
          todayDotColor:
              _TrackingColors.teal,
        );
    }
  }
}

/// ============================================================
/// DAY APPEARANCE
/// ============================================================

class _DayAppearance {
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color todayDotColor;

  const _DayAppearance({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.todayDotColor,
  });
}

/// ============================================================
/// WEEK DATE ITEM
/// ============================================================

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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          weekday,
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
            color: isToday
                ? _TrackingColors
                    .teal
                : _TrackingColors
                    .textMuted,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isToday
                ? _TrackingColors
                    .teal
                : Colors.transparent,
            shape:
                BoxShape.circle,
          ),
          alignment:
              Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
              color: isToday
                  ? Colors.white
                  : _TrackingColors
                      .text,
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// LEGEND ITEM
/// ============================================================

class _LegendItem
    extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            fontSize: 12,
            color: textColor ??
                _TrackingColors
                    .textMuted,
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// PREDICTED LEGEND
/// ============================================================

class _PredictedLegendItem
    extends StatelessWidget {
  const _PredictedLegendItem();

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(
              color:
                  _TrackingColors
                      .predictedBorder,
              width: 2,
            ),
          ),
        ),

        const SizedBox(width: 6),

        const Text(
          'Predicted',
          style: TextStyle(
            fontSize: 12,
            color:
                _TrackingColors
                    .textMuted,
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// SUMMARY CARD
/// ============================================================

class _SummaryCard
    extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              _TrackingColors.cardBorder
                  .withOpacity(.45),
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
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  _TrackingColors
                      .tealDark,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
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