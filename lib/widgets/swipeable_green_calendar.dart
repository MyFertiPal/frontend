import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SwipeableGreenCalendar extends StatefulWidget {
  const SwipeableGreenCalendar({
    super.key,
    required this.initialMonth,
    required this.selectedDates,
    this.onDateToggle,
    this.ovulationDates,
    this.periodDates,
    this.nextPeriodDate,
    this.nextPeriodDays,
    this.fertileWindowDates,
  });

  final DateTime initialMonth;
  final Set<DateTime> selectedDates;
  final ValueChanged<DateTime>? onDateToggle;
  final Set<DateTime>? ovulationDates;
  final Set<DateTime>? periodDates;
  final DateTime? nextPeriodDate;
  final Set<DateTime>? nextPeriodDays;
  final Set<DateTime>? fertileWindowDates;

  @override
  State<SwipeableGreenCalendar> createState() => _SwipeableGreenCalendarState();
}

class _SwipeableGreenCalendarState extends State<SwipeableGreenCalendar> {
  static const int _initialPage = 1200;
  // static const Color _accent = Color(0xFFA8D497); // Unused
  late final PageController _pageController;
  late DateTime _baseMonth;
  late DateTime _visibleMonth;
  late Set<DateTime> _localSelection;

  @override
  void initState() {
    super.initState();
    _baseMonth = _monthOnly(widget.initialMonth);
    _visibleMonth = _baseMonth;
    _pageController = PageController(initialPage: _initialPage);
    _localSelection = widget.selectedDates.map(_dayOnly).toSet();
  }

  @override
  void didUpdateWidget(covariant SwipeableGreenCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final updated = widget.selectedDates.map(_dayOnly).toSet();
    if (!setEquals(updated, _localSelection)) {
      _localSelection = updated;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_visibleMonth);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _jumpBy(-1),
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 26),
                splashRadius: 20,
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                onPressed: () => _jumpBy(1),
                icon: const Icon(Icons.chevron_right,
                    color: Colors.white, size: 26),
                splashRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildDayLabels(),
        const SizedBox(height: 6),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) =>
                setState(() => _visibleMonth = _monthForPage(page)),
            itemBuilder: (context, pageIndex) {
              final month = _monthForPage(pageIndex);
              return _MonthGrid(
                month: month,
                selectedDates: _localSelection,
                onToggle: _handleDateToggle,
                ovulationDates: widget.ovulationDates ?? {},
                periodDates: widget.periodDates ?? {},
                fertileWindowDates: widget.fertileWindowDates ?? {},
                nextPeriodDate: widget.nextPeriodDate,
                nextPeriodDays: widget.nextPeriodDays ?? {},
              );
            },
          ),
        ),
        
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _LegendItem(
              color: const Color(0xFFD32F2F),
              label: 'Period',
              hasDot: true,
              isPink: true),
          _LegendItem(
              color: const Color(0xFF1B4D2D), label: 'Ovulation', hasDot: true),
          _LegendItem(
              color: const Color(0xFF2E683D), label: 'Fertile', hasDot: true),
          _LegendItem(
              color: const Color(0xFFD32F2F),
              label: 'Predicted',
              hasBorder: true),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 0,
        ),
        itemCount: 7,
        itemBuilder: (context, index) => Center(
          child: Text(
            dayLabels[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  void _jumpBy(int delta) {
    final currentPage = _pageController.page?.round() ?? _initialPage;
    final target = currentPage + delta;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  void _handleDateToggle(DateTime date) {
    final normalized = _dayOnly(date);
    setState(() {
      if (_localSelection.any((d) => _isSameDay(d, normalized))) {
        _localSelection =
            _localSelection.where((d) => !_isSameDay(d, normalized)).toSet();
      } else {
        _localSelection = {..._localSelection, normalized};
      }
    });
    widget.onDateToggle?.call(normalized);
  }

  DateTime _monthForPage(int pageIndex) {
    final offset = pageIndex - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + offset, 1);
  }

  DateTime _monthOnly(DateTime date) => DateTime(date.year, date.month, 1);
  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDates,
    required this.onToggle,
    this.ovulationDates,
    this.periodDates,
    this.nextPeriodDate,
    this.nextPeriodDays,
    this.fertileWindowDates,
  });

  final DateTime month;
  final Set<DateTime> selectedDates;
  final ValueChanged<DateTime> onToggle;
  final Set<DateTime>? ovulationDates;
  final Set<DateTime>? periodDates;
  final DateTime? nextPeriodDate;
  final Set<DateTime>? nextPeriodDays;
  final Set<DateTime>? fertileWindowDates;

  static const Color _accent = Color(0xFFA8D497);

  @override
  Widget build(BuildContext context) {
    final firstWeekday = month.weekday % 7; // 0=Sunday ... 6=Saturday
    ;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final daysInPrevMonth =
        DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalCells = (firstWeekday + daysInMonth) <= 35 ? 35 : 42;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayInfo = _resolveDay(
            index: index,
            firstWeekday: firstWeekday,
            daysInMonth: daysInMonth,
            daysInPrevMonth: daysInPrevMonth,
            prevMonth: prevMonth,
            nextMonth: nextMonth,
          );

          final isSelected =
              selectedDates.any((d) => _isSameDay(d, dayInfo.date));

          final isPeriod =
              periodDates?.any((d) => _isSameDay(d, dayInfo.date)) ?? false;
          final isOvulation =
              ovulationDates?.any((d) => _isSameDay(d, dayInfo.date)) ?? false;
          final isNextPeriod = nextPeriodDate != null &&
              _isSameDay(nextPeriodDate!, dayInfo.date);
          final isNextPeriodWindow =
              nextPeriodDays?.any((d) => _isSameDay(d, dayInfo.date)) ?? false;
          final isFertile =
              fertileWindowDates?.any((d) => _isSameDay(d, dayInfo.date)) ??
                  false;

          Color bg = Colors.transparent;
          Color txtColor =
              dayInfo.isOutside ? Colors.white.withOpacity(0.3) : Colors.white;
          Border? border;
          Widget? indicator;

          // Priority order: Period > Next Period > Ovulation > Fertile Window
          if (isPeriod) {
            // Period days: pink background, dark pink text, pink border
            bg = const Color(0xFFF06292);
txtColor = Colors.white;

border = Border.all(
  color: const Color(0xFFD81B60),
  width: 2,
);

indicator = _buildDot(
  Colors.white,
);
            indicator = _buildDot(const Color(0xFFD32F2F));
          } else if (isNextPeriodWindow || isNextPeriod) {
            // Next period prediction: red border and red text, transparent bg
            bg = Colors.transparent;
            txtColor = const Color(0xFFD32F2F);
            border = Border.all(color: const Color(0xFFD32F2F), width: 2);
            indicator = _buildDot(const Color(0xFFD32F2F).withOpacity(0.6));
          } else if (isOvulation) {
            // Ovulation day: darker green background, white text, dark green border
            bg = const Color(0xFF1B4D2D); // Darker green
            txtColor = Colors.white;
            border = Border.all(color: const Color(0xFF1B4D2D), width: 2);
            indicator = _buildDot(const Color(0xFF1B4D2D));
          } else if (isFertile) {
            // Fertile window: light green background, dark green text, green border
            bg = const Color(0xFFC8E6C9); // Light green
            txtColor = const Color(0xFF2E683D);
            border = Border.all(color: const Color(0xFF2E683D), width: 1.2);
            indicator = _buildDot(const Color(0xFF2E683D).withOpacity(0.7));
          } else if (isSelected) {
            bg = _accent;
            txtColor = const Color(0xFF2E683D);
          }

          final boxDecoration = BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: border,
          );

          return Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: dayInfo.isOutside ? null : () => onToggle(dayInfo.date),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: boxDecoration,
                    alignment: Alignment.center,
                    child: Text(
                      '${dayInfo.date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: txtColor,
                      ),
                    ),
                  ),
                  if (indicator != null)
                    Positioned(
                      bottom: 2,
                      child: indicator,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _DayDetail _resolveDay({
    required int index,
    required int firstWeekday,
    required int daysInMonth,
    required int daysInPrevMonth,
    required DateTime prevMonth,
    required DateTime nextMonth,
  }) {
    if (index < firstWeekday) {
      final day = daysInPrevMonth - firstWeekday + index + 1;
      return _DayDetail(
          date: DateTime(prevMonth.year, prevMonth.month, day),
          isOutside: true);
    }

    if (index < firstWeekday + daysInMonth) {
      final day = index - firstWeekday + 1;
      return _DayDetail(
          date: DateTime(month.year, month.month, day), isOutside: false);
    }

    final day = index - (firstWeekday + daysInMonth) + 1;
    return _DayDetail(
        date: DateTime(nextMonth.year, nextMonth.month, day), isOutside: true);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _DayDetail {
  _DayDetail({required this.date, required this.isOutside});

  final DateTime date;
  final bool isOutside;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasDot;
  final bool hasBorder;
  final bool isPink;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasDot = false,
    this.hasBorder = false,
    this.isPink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasBorder
                ? Colors.white.withOpacity(0.2)
                : isPink
                    ? const Color(0xFFFFC0CB).withOpacity(0.6)
                    : color.withOpacity(0.4),
            border: (hasBorder || isPink)
                ? Border.all(color: isPink ? color : Colors.white, width: 2)
                : null,
          ),
          child: hasDot
              ? Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: hasBorder
              ? const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                )
              : const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
