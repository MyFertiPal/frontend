import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  State<CalendarTabScreen> createState() =>
      _CalendarTabScreenState();
}

class _CalendarTabScreenState extends State<CalendarTabScreen> {
  List<dynamic> _loggedSymptoms = [];
  void _buildBackendMarkers(){

  _dayMarkers.clear();


  // Period
  if(_lastPeriod != null){

    for(int i=0;i<_periodLength;i++){

      final date =
      _lastPeriod!.add(
        Duration(days:i)
      );

      _dayMarkers[
        _normalize(date)
      ] = DayType.period;

    }

  }


  // Ovulation

  if(_ovulationDay != null){

    final date =
    DateTime.parse(_ovulationDay!);


    _dayMarkers[
      _normalize(date)
    ] = DayType.ovulation;

  }



  // Fertile window

  if(
  _fertileStart != null &&
  _fertileEnd != null
  ){

    DateTime start =
    DateTime.parse(_fertileStart!);

    DateTime end =
    DateTime.parse(_fertileEnd!);


    while(
      start.isBefore(end) ||
      start.isAtSameMomentAs(end)
    ){

      _dayMarkers[
        _normalize(start)
      ] = DayType.fertile;


      start =
      start.add(
        const Duration(days:1)
      );

    }

  }



  // Next period

  if(_nextPeriod != null){

    final date =
    DateTime.parse(_nextPeriod!);


    for(int i=0;i<_periodLength;i++){

      _dayMarkers[
      _normalize(
        date.add(Duration(days:i))
      )
      ] = DayType.predicted;

    }

  }

}
  DateTime? _selectedDate;
  DateTime? _lastPeriod;
int _cycleLength = 0;
int _periodLength = 0;

String? _nextPeriod;
String? _ovulationDay;
String? _fertileStart;
String? _fertileEnd;

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
 value:
 _fertileStart == null
 ? "--"
 : "${_fertileStart!.substring(5)} - ${_fertileEnd!.substring(5)}",
 label: "Fertile Window",
),

];

  late DateTime _visibleMonth; // first day of the currently shown month
  Map<DateTime, DayType> _dayMarkers = {};

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);


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

  // Sample marker set, only used when the caller doesn't supply real data.
  

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
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCalendarCard(),
                ),
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

  // ---- Hero header + week strip ------------------------------------------

Future<void> _loadCycle() async {

try {

final api = ApiService();

final profile =
await api.getProfile();


final predictions =
await api.getCyclePrediction();

final symptoms =
await api.getSymptoms();


if (predictions.isEmpty) return;

final prediction = predictions.first;

if(!mounted) return;


setState(() {
_loggedSymptoms = symptoms;

_cycleLength =
profile["cycle_length"] ?? 0;


_periodLength =
profile["period_length"] ?? 0;



if(profile["last_period_date"] != null){

_lastPeriod =
DateTime.parse(
profile["last_period_date"]
);

}



_nextPeriod =
prediction["next_period"];


_ovulationDay =
prediction["ovulation_day"];


_fertileStart =
prediction["fertile_period_start"];


_fertileEnd =
prediction["fertile_period_end"];



_buildBackendMarkers();


});


}
catch(e){

debugPrint(
"Calendar error: $e"
);

}

}
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
  Widget _buildHero() {
    final todayLabel =
        '${_fullWeekday(widget.today.weekday)}, '
        '${_monthNames[widget.today.month - 1]} ${widget.today.day}';

    return Container(
      color: _TrackingColors.header,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            todayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                // shift so "today" lands in the middle-ish, like the spec
                final date = widget.today.add(Duration(days: i - 2));
                final isToday = _normalize(date) == _normalize(widget.today);
                return _DayPill(
                  label: _shortWeekday(date.weekday),
                  number: date.day,
                  isToday: isToday,
                );
              },
            ),
          ),
        ],
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
              final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final isToday = _normalize(date) == _normalize(widget.today);
              final type = _dayMarkers[_normalize(date)];
    
             return GestureDetector(
  onTap: () {
    setState(() {
      _selectedDate = date;
    });
  },
  child: _CalendarDayCell(
    day: day,
    isToday: isToday,
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

class _DayPill extends StatelessWidget {
  final String label;
  final int number;
  final bool isToday;

  const _DayPill({
    required this.label,
    required this.number,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 76,
      decoration: BoxDecoration(
        color: isToday ? _TrackingColors.teal : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isToday ? Colors.white70 : _TrackingColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$number',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Color? bg;
    Color textColor = Colors.black87;
    Border? border;
    FontWeight weight = FontWeight.normal;

    if (type == DayType.period) {
  bg = _TrackingColors.period;
  textColor = Colors.white;
} else if (isToday || type == DayType.ovulation) {
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