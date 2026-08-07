import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/period_service.dart';


/// Calendar marker types
enum DayType {
  period,
  fertile,
  ovulation,
  predicted,
}


/// Theme colors
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

      List<String> _extractSymptomNames() {
  final names = <String>[];

  for (final item in _loggedSymptoms) {
    if (item is! Map) continue;

    final symptoms = item["symptoms"];

    if (symptoms is List) {
      for (final symptom in symptoms) {
        if (symptom != null) {
          final value = symptom.toString().trim();

          if (value.isNotEmpty && !names.contains(value)) {
            names.add(value);
          }
        }
      }
    } else if (symptoms != null) {
      final value = symptoms.toString().trim();

      if (value.isNotEmpty && !names.contains(value)) {
        names.add(value);
      }
    }
  }

  return names;
}
Future<void> _refreshInsights() async {
  try {
    final profile = await _api.getProfile();
    final symptoms = await _api.getSymptoms();

    if (!mounted) return;

    _loggedSymptoms = symptoms;

    final cycleLength =
        (profile["cycle_length"] as num?)?.toInt() ?? 28;

    final periodLength =
        (profile["period_length"] as num?)?.toInt() ?? 5;

    final lastPeriodDate =
        profile["last_period_date"]?.toString();

    if (lastPeriodDate == null || lastPeriodDate.isEmpty) {
      debugPrint(
        "Cannot generate insights: last_period_date is missing",
      );
      return;
    }

    _cycleLength = cycleLength;
    _periodLength = periodLength;

    _lastPeriod = DateTime.tryParse(lastPeriodDate);

    final symptomNames = _extractSymptomNames();

    debugPrint(
      "Generating insights with:"
      "\ncycle_length: $cycleLength"
      "\nlast_period_date: $lastPeriodDate"
      "\nperiod_length: $periodLength"
      "\nsymptoms: $symptomNames",
    );

    final insights = await _api.generateInsights(
      cycleLength: cycleLength,
      lastPeriodDate: lastPeriodDate,
      periodLength: periodLength,
      symptoms: symptomNames,
    );

    debugPrint("GENERATE INSIGHTS RESPONSE: $insights");

    if (!mounted) return;

    if (insights.isNotEmpty) {
      final data = insights.first;

      if (data is Map) {
        _nextPeriod =
            data["next_period"]?.toString();

        _ovulationDay =
            data["ovulation_day"]?.toString();

        _fertileStart =
            data["fertile_period_start"]?.toString();

        _fertileEnd =
            data["fertile_period_end"]?.toString();
      }
    }

    // Rebuild calculated calendar markers.
    _buildBackendMarkers();

    setState(() {});
  } catch (e) {
    debugPrint("Refresh insights error: $e");
  }
}
void _buildBackendMarkers() {
  // Remove only calculated markers.
  // Keep locally logged period days.
  _dayMarkers.removeWhere(
    (_, type) =>
        type == DayType.fertile ||
        type == DayType.ovulation ||
        type == DayType.predicted,
  );

  // -------------------------
  // Ovulation
  // -------------------------
  if (_ovulationDay != null) {
    final date = DateTime.tryParse(_ovulationDay!);

    if (date != null) {
      _dayMarkers[_normalize(date)] = DayType.ovulation;
    }
  }

  // -------------------------
  // Fertile window
  // -------------------------
  if (_fertileStart != null && _fertileEnd != null) {
    final start = DateTime.tryParse(_fertileStart!);
    final end = DateTime.tryParse(_fertileEnd!);

    if (start != null && end != null) {
      var current = _normalize(start);
      final last = _normalize(end);

      while (!current.isAfter(last)) {
        // Don't overwrite an actual period day.
        if (_dayMarkers[_normalize(current)] != DayType.period) {
          _dayMarkers[_normalize(current)] = DayType.fertile;
        }

        current = current.add(
          const Duration(days: 1),
        );
      }
    }
  }

  // -------------------------
  // Predicted next period
  // -------------------------
  if (_nextPeriod != null) {
    final date = DateTime.tryParse(_nextPeriod!);

    if (date != null) {
      for (int i = 0; i < _periodLength; i++) {
        final predictedDate = date.add(
          Duration(days: i),
        );

        final key = _normalize(predictedDate);

        // Don't overwrite actual period days.
        if (_dayMarkers[key] != DayType.period) {
          _dayMarkers[key] = DayType.predicted;
        }
      }
    }
  }
}


  bool _isSyncingPeriod = false;



  List<dynamic> _loggedSymptoms = [];



  DateTime? _selectedDate;



  DateTime? _lastPeriod;



  int _cycleLength = 28;


  int _periodLength = 5;




  String? _nextPeriod;


  String? _ovulationDay;


  String? _fertileStart;


  String? _fertileEnd;





  late DateTime _visibleMonth;



  Map<DateTime, DayType> _dayMarkers = {};





  static DateTime _normalize(DateTime date) {

    return DateTime(
      date.year,
      date.month,
      date.day,
    );

  }





  @override
  void initState() {

    super.initState();


    _visibleMonth = DateTime(
      widget.today.year,
      widget.today.month,
      1,
    );


    if(widget.dayMarkers != null){

      _dayMarkers =
          Map.from(widget.dayMarkers!);

    }


    _loadCycle();

  }






  Future<void> _loadCycle() async {


    try {


      final periods =
          await _localPeriod.getPeriodLogs();



      _dayMarkers.clear();



      for(final date in periods){

        _dayMarkers[
          _normalize(date)
        ] = DayType.period;

      }



      await _refreshCycleData();



    }catch(e){

      debugPrint(
        "Calendar load error: $e",
      );

    }


  }






  /// Generates fertility insight from backend.
  ///
  /// POST:
  /// /insights/insights
  ///
  /// Payload:
  /// {
  /// cycle_length,
  /// last_period_date,
  /// period_length,
  /// symptoms
  /// }


  Future<void> _refreshCycleData() async {


    try {


      final profile =
          await _api.getProfile();



      final symptoms =
          await _api.getSymptoms();




      _cycleLength =
          profile["cycle_length"] ?? 28;



      _periodLength =
          profile["period_length"] ?? 5;




      if(profile["last_period_date"] != null){

        _lastPeriod =
            DateTime.parse(
              profile["last_period_date"],
            );

      }





      final symptomList = <String>[];



      for(final item in symptoms){

        if(item["symptoms"] != null){

          symptomList.addAll(
            List<String>.from(
              item["symptoms"],
            ),
          );

        }

      }




      final insights =
          await _api.generateInsights(


            cycleLength:
                _cycleLength,


            lastPeriodDate:
                _lastPeriod != null
                    ? _lastPeriod!
                        .toIso8601String()
                        .substring(0,10)

                    : DateTime.now()
                        .toIso8601String()
                        .substring(0,10),



            periodLength:
                _periodLength,


            symptoms:
                symptomList,


          );






      _loggedSymptoms =
          symptoms;






      if(insights.isNotEmpty){


        final prediction =
            insights.first;



        _nextPeriod =
            prediction["next_period"];



        _ovulationDay =
            prediction["ovulation_day"];



        _fertileStart =
            prediction["fertile_period_start"];



        _fertileEnd =
            prediction["fertile_period_end"];



      }






      _rebuildMarkers();




      if(!mounted)return;



      setState((){});




    }catch(e){


      debugPrint(
        "Refresh cycle error: $e",
      );


    }


  }







  void _rebuildMarkers(){



    _dayMarkers.removeWhere(
      (_, type) =>
          type != DayType.period,
    );




    // Logged periods

    if(_lastPeriod != null){


      for(int i=0;
          i<_periodLength;
          i++){


        final date =
            _lastPeriod!
                .add(
                  Duration(
                    days:i,
                  ),
                );



        _dayMarkers[
          _normalize(date)
        ] = DayType.period;


      }


    }





    // Ovulation

    if(_ovulationDay != null){


      final date =
          DateTime.parse(
            _ovulationDay!,
          );



      _dayMarkers[
        _normalize(date)
      ] = DayType.ovulation;


    }







    // Fertile window

    if(_fertileStart != null &&
       _fertileEnd != null){



      DateTime start =
          DateTime.parse(
            _fertileStart!,
          );



      final end =
          DateTime.parse(
            _fertileEnd!,
          );




      while(
        start.isBefore(end) ||
        start.isAtSameMomentAs(end)

      ){


        _dayMarkers[
          _normalize(start)
        ] = DayType.fertile;



        start =
            start.add(
              const Duration(
                days:1,
              ),
            );


      }


    }





    // Predicted period

    if(_nextPeriod != null){


      final date =
          DateTime.parse(
            _nextPeriod!,
          );



      for(int i=0;
          i<_periodLength;
          i++){


        _dayMarkers[
          _normalize(
            date.add(
              Duration(days:i),
            ),
          )
        ] = DayType.predicted;


      }


    }


  }

  Future<void> _togglePeriodDay(DateTime date) async {
  if (_isSyncingPeriod) return;

  final key = _normalize(date);
  final wasPeriod = _dayMarkers[key] == DayType.period;

  setState(() {
    _isSyncingPeriod = true;

    if (wasPeriod) {
      _dayMarkers.remove(key);
    } else {
      _dayMarkers[key] = DayType.period;
    }
  });

  try {
    if (wasPeriod) {
      // Local storage only
      await _localPeriod.deletePeriod(key);
    } else {
      // Local storage only
      await _localPeriod.savePeriod(key);
    }

    // Re-read the locally stored period dates
    final periods = await _localPeriod.getPeriodLogs();

    if (periods.isEmpty) {
      throw Exception("No period date available for insight generation");
    }

    // Use the latest/most recent logged period
    periods.sort((a, b) => a.compareTo(b));

    final latestPeriod = _normalize(periods.last);

    // Generate fresh backend insights/predictions
    await _api.generateInsights(
      cycleLength: _cycleLength,
      lastPeriodDate:
          latestPeriod.toIso8601String().split('T').first,
      periodLength: _periodLength,
      symptoms: _extractSymptomNames(),
    );

    // GET the newly generated prediction/insight data
    
  } catch (e) {
    debugPrint("Period update error: $e");

    // Roll back local UI if something failed
    if (mounted) {
      setState(() {
        if (wasPeriod) {
          _dayMarkers[key] = DayType.period;
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




  void _goPreviousMonth(){

    setState((){


      _visibleMonth =
          DateTime(
            _visibleMonth.year,
            _visibleMonth.month - 1,
            1,
          );


    });

  }






  void _goNextMonth(){


    setState((){


      _visibleMonth =
          DateTime(
            _visibleMonth.year,
            _visibleMonth.month + 1,
            1,
          );


    });


  }





  int _daysInMonth(DateTime month){


    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;


  }







  @override
  Widget build(BuildContext context) {


    return Container(


      color:_TrackingColors.bg,


      child:SafeArea(


        child:SingleChildScrollView(


          child:Column(


            crossAxisAlignment:
                CrossAxisAlignment.stretch,


            children:[



              _buildHero(),



              Padding(

                padding:
                    const EdgeInsets.symmetric(
                      horizontal:16,
                    ),


                child:
                    _buildCalendarCard(),


              ),




              _buildLegend(),




              const SizedBox(height:10),



              _buildSummaryRow(),




              const SizedBox(height:25),




              _buildLoggedSymptoms(),



            ],


          ),


        ),


      ),


    );


  }








  Widget _buildHero(){



    final todayLabel =

        '${_fullWeekday(widget.today.weekday)}, '

        '${_monthNames[widget.today.month-1]} '

        '${widget.today.day}';




    final days =
        List.generate(
          5,
          (i)=>
              widget.today.add(
                Duration(
                  days:i-2,
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



      child:Container(


        padding:
            const EdgeInsets.all(22),



        decoration:
            BoxDecoration(


              color:Colors.white,



              borderRadius:
                  BorderRadius.circular(
                    28,
                  ),



              boxShadow:[

                BoxShadow(

                  color:
                      Colors.black
                      .withOpacity(.05),

                  blurRadius:18,

                  offset:
                      const Offset(
                        0,
                        6,
                      ),

                ),

              ],


            ),



        child:Column(


          crossAxisAlignment:
              CrossAxisAlignment.start,



          children:[


            const Text(

              "Today",

              style:TextStyle(

                fontSize:16,

                color:
                    _TrackingColors.tealDark,

                fontWeight:
                    FontWeight.w500,

              ),

            ),




            const SizedBox(height:5),




            Text(

              todayLabel,

              style:const TextStyle(

                fontSize:18,

                fontWeight:
                    FontWeight.w800,

                color:
                    _TrackingColors.tealDark,

              ),

            ),




            const SizedBox(height:24),





            Row(


              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,



              children:

              days.map((date){



                final today =
                    _normalize(date)
                    ==
                    _normalize(
                      widget.today,
                    );



                return _WeekDateItem(

                  weekday:
                      _shortWeekday(
                        date.weekday,
                      ),


                  day:
                      date.day,


                  isToday:
                      today,

                );


              }).toList(),


            ),


          ],


        ),


      ),


    );


  }







  Widget _buildCalendarCard(){



    final days =
        _daysInMonth(
          _visibleMonth,
        );



    final offset =
        _visibleMonth.weekday % 7;



    final cells=<int?>[

      ...List.filled(
        offset,
        null,
      ),


      for(int i=1;i<=days;i++)
        i,


    ];





    return Container(


      padding:
          const EdgeInsets.all(16),



      decoration:
          BoxDecoration(


            color:Colors.white,


            borderRadius:
                BorderRadius.circular(
                  24,
                ),


          ),



      child:Column(


        children:[



          Row(


            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,



            children:[



              IconButton(

                onPressed:
                    _goPreviousMonth,


                icon:
                    const Icon(
                      Icons.chevron_left,
                    ),

              ),





              Text(


                "${_monthNames[_visibleMonth.month-1]} ${_visibleMonth.year}",


                style:
                    const TextStyle(

                      fontWeight:
                          FontWeight.w600,

                    ),

              ),





              IconButton(

                onPressed:
                    _goNextMonth,


                icon:
                    const Icon(
                      Icons.chevron_right,
                    ),

              ),



            ],


          ),




          GridView.count(


            crossAxisCount:7,


            shrinkWrap:true,


            physics:
                const NeverScrollableScrollPhysics(),



            children:

            _weekdayShort.map((e)=>Center(

              child:Text(

                e,

                style:
                    const TextStyle(

                      color:
                          _TrackingColors.textMuted,

                    ),

              ),

            )).toList(),



          ),






          GridView.builder(


            shrinkWrap:true,


            physics:
                const NeverScrollableScrollPhysics(),



            itemCount:
                cells.length,



            gridDelegate:
                const SliceGridDelegate(

                  crossAxisCount:7,

                ),




            itemBuilder:(context,index){



              final day =
                  cells[index];



              if(day==null){

                return const SizedBox();

              }




              final date =
                  DateTime(

                    _visibleMonth.year,

                    _visibleMonth.month,

                    day,

                  );





              return GestureDetector(


                onTap:
                  _isSyncingPeriod
                  ? null
                  :
                  ()=>_togglePeriodDay(
                    date,
                  ),



                child:
                    _CalendarDayCell(

                      day:day,


                      isToday:
                          DateUtils.isSameDay(
                            widget.today,
                            date,
                          ),


                      type:
                          _dayMarkers[
                            _normalize(date)
                          ],


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
  // LEGEND
  // ---------------------------------------------------------------------------

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
            color: _TrackingColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _legendOutlineItem(
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _TrackingColors.predictedBorder,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _TrackingColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

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
          value: _fertileStart == null ||
                  _fertileEnd == null
              ? "--"
              : "${_fertileStart!.substring(5)} - "
                  "${_fertileEnd!.substring(5)}",
          label: "Fertile Window",
        ),
      ];

  Widget _buildSummaryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
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

  // ---------------------------------------------------------------------------
  // LOGGED SYMPTOMS
  // ---------------------------------------------------------------------------

  Widget _buildLoggedSymptoms() {
    return Padding(
      padding: const EdgeInsets.symmetric(
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
              fontWeight: FontWeight.bold,
              color: _TrackingColors.tealDark,
            ),
          ),

          const SizedBox(height: 16),

          if (_loggedSymptoms.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Center(
                child: Text(
                  "No symptoms logged yet",
                  style: TextStyle(
                    color:
                        _TrackingColors.textMuted,
                  ),
                ),
              ),
            ),

          ..._loggedSymptoms.map(
            (item) {
              final rawSymptoms =
                  item["symptoms"];

              final symptoms =
                  rawSymptoms is List
                      ? rawSymptoms
                          .map(
                            (e) => e.toString(),
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
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        _TrackingColors.cardBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      symptoms.isEmpty
                          ? "Symptoms logged"
                          : symptoms,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            _TrackingColors.tealDark,
                      ),
                    ),

                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                              _TrackingColors.textMuted,
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

  // ---------------------------------------------------------------------------
  // DATE HELPERS
  // ---------------------------------------------------------------------------

  static const List<String> _monthNames = [
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

  static const List<String> _weekdayShort = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

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
}


// -----------------------------------------------------------------------------
// GRID DELEGATE
// -----------------------------------------------------------------------------

class SliceGridDelegate
    extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliceGridDelegate({
    required super.crossAxisCount,
  }) : super(
          childAspectRatio: 1,
        );
}


// -----------------------------------------------------------------------------
// WEEK DATE ITEM
// -----------------------------------------------------------------------------

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
          mainAxisAlignment:
              MainAxisAlignment.center,
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
              color: _TrackingColors.tealDark,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// CALENDAR DAY CELL
// -----------------------------------------------------------------------------

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
  Widget build(BuildContext context) {
    Color? background;
    Color textColor = Colors.black87;

    Border? border;

    FontWeight weight =
        FontWeight.normal;


    // Actual period
    if (type == DayType.period) {
      background =
          _TrackingColors.period;

      textColor = Colors.white;

      weight = FontWeight.w600;
    }

    // Ovulation
    else if (
      type == DayType.ovulation
    ) {
      background =
          _TrackingColors.tealDark;

      textColor = Colors.white;

      weight = FontWeight.w600;
    }

    // Today
    else if (isToday) {
      background =
          _TrackingColors.tealDark;

      textColor = Colors.white;

      weight = FontWeight.w600;
    }

    // Fertile window
    else if (
      type == DayType.fertile
    ) {
      background =
          _TrackingColors.fertile;

      textColor =
          _TrackingColors.fertileText;
    }

    // Predicted period
    else if (
      type == DayType.predicted
    ) {
      border = Border.all(
        color:
            _TrackingColors.predictedBorder,
        width: 2,
      );

      textColor =
          _TrackingColors.period;
    }


    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: weight,
          ),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// SUMMARY CARD
// -----------------------------------------------------------------------------

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