import 'package:flutter/material.dart';
import "../../theme/app_colors.dart";
import "../../services/api_service.dart";
import '../../services/analytics_service.dart';
import '../../generated/l10n/app_localizations.dart';


enum GenderExpectation {
  girl,
  boy,
  noPreference
}


class GenderPredictionScreen extends StatefulWidget {

  const GenderPredictionScreen({
    super.key,
  });


  @override
  State<GenderPredictionScreen> createState() =>
      _GenderPredictionScreenState();
}



class _GenderPredictionScreenState
    extends State<GenderPredictionScreen> {


  GenderExpectation? _selected;



  void _selectOption(
      GenderExpectation option
      ) {

    AnalyticsService.logGenderPredictionSelected(option.name);

    setState(() {
      _selected = option;
    });


    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GenderPredictionResultScreen(
              selection: option,
            ),
      ),
    );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6FBF8),


      body: SafeArea(

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.stretch,


          children: [


            Padding(

              padding:
              const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  20
              ),


              child: Row(

                children: [


                  InkWell(

                    onTap: () {

                      if(
                      Navigator.canPop(context)
                      ){

                        Navigator.pop(context);

                      }

                    },


                    child: Container(

                      width:44,

                      height:44,


                      decoration:
                      const BoxDecoration(

                        color:Colors.white,

                        shape:BoxShape.circle,

                      ),


                      child:
                      const Icon(
                        Icons.arrow_back,
                        color:AppColors.primaryDark,
                      ),

                    ),

                  ),


                  const SizedBox(width:16),


                   Text(

                    AppLocalizations.of(context).genderPrediction,

                    style:TextStyle(

                      fontSize:24,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      AppColors.textPrimary,

                    ),

                  )

                ],

              ),

            ),



            Expanded(

              child: SingleChildScrollView(

                padding:
                const EdgeInsets.symmetric(
                    horizontal:16
                ),


                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,


                  children: [



                   Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF5F5),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.red,
      width: 1,
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(
        Icons.info_outline,
        color: Colors.red,
        size: 24,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).importantDisclaimer,
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).genderPredictionDisclaimer,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),


                    const SizedBox(height:24),



                     Text(

                      AppLocalizations.of(context).selectGenderExpectation,

                      style:TextStyle(

                        fontSize:18,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                    const SizedBox(height:16),



                    _OptionCard(

                      title:AppLocalizations.of(context).girl,

                      subtitle:
                      AppLocalizations.of(context).hopingForGirl,

                      emoji:"👧",

                      accentColor:
                      AppColors.pinkAccent,

                      selected:
                      _selected ==
                          GenderExpectation.girl,


                      onTap:(){

                        _selectOption(
                            GenderExpectation.girl
                        );

                      },

                    ),



                    const SizedBox(height:12),



                    _OptionCard(

                      title:AppLocalizations.of(context).boy,

                      subtitle:
                      AppLocalizations.of(context).hopingForBoy,

                      emoji:"👦",

                      accentColor:
                      AppColors.teal,

                      selected:
                      _selected ==
                          GenderExpectation.boy,


                      onTap:(){

                        _selectOption(
                            GenderExpectation.boy
                        );

                      },

                    ),



                    const SizedBox(height:12),



                    _OptionCard(

                      title:AppLocalizations.of(context).noPreference,

                      subtitle:
                      AppLocalizations.of(context).openToEither,

                      emoji:"💚",

                      accentColor:
                      AppColors.primaryDark,

                      selected:
                      _selected ==
                          GenderExpectation.noPreference,


                      onTap:(){

                        _selectOption(
                            GenderExpectation.noPreference
                        );

                      },

                    ),



                  ],

                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}
class _OptionCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;


  const _OptionCard({

    required this.title,

    required this.subtitle,

    required this.emoji,

    required this.accentColor,

    required this.selected,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius:
      BorderRadius.circular(18),


      child: Container(

        padding:
        const EdgeInsets.all(14),


        decoration:
        BoxDecoration(

          color:
          Colors.white,


          borderRadius:
          BorderRadius.circular(18),


          border:
          Border.all(

            color:
            selected
                ? accentColor
                : Colors.transparent,


            width:2,

          ),

          boxShadow:[

            const BoxShadow(

              color:
              Colors.black12,

              blurRadius:4,

              offset:
              Offset(0,2),

            )

          ],

        ),



        child:Row(

          children:[


            Container(

              width:52,

              height:52,


              decoration:
              BoxDecoration(

                color:
                accentColor.withOpacity(
                    0.15
                ),

                shape:
                BoxShape.circle,

              ),


              child:
              Center(

                child:
                Text(

                  emoji,

                  style:
                  const TextStyle(
                      fontSize:26
                  ),

                ),

              ),

            ),



            const SizedBox(width:14),



            Expanded(

              child:Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  Text(

                    title,

                    style:
                    TextStyle(

                      fontSize:17,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      accentColor,

                    ),

                  ),



                  const SizedBox(height:3),



                  Text(

                    subtitle,

                    style:
                    TextStyle(

                      fontSize:13,

                      color:
                      Colors.grey[700],

                    ),

                  ),


                ],

              ),

            ),




            Container(

              width:24,

              height:24,


              decoration:
              BoxDecoration(

                shape:
                BoxShape.circle,


                border:
                Border.all(

                  color:
                  accentColor,

                  width:2,

                ),


                color:
                selected
                    ? accentColor
                    : Colors.transparent,

              ),


              child:
              selected

                  ?

              const Icon(

                Icons.check,

                color:
                Colors.white,

                size:16,

              )


                  :

              null,


            )


          ],

        ),

      ),

    );

  }

}




// ================================
// RESULT SCREEN
// ================================



class GenderPredictionResultScreen
    extends StatefulWidget {


  final GenderExpectation selection;



  const GenderPredictionResultScreen({

    super.key,

    required this.selection,

  });



  @override
  State<GenderPredictionResultScreen>
  createState() =>
      _GenderPredictionResultScreenState();

}




class _GenderPredictionResultScreenState
    extends State<GenderPredictionResultScreen> {


  Map<String,dynamic>? insight;


  bool loading = true;



  @override
  void initState(){

    super.initState();

    loadInsight();

  }




  Future<void> loadInsight() async {


    try{


      final result =
      await ApiService()
          .getInsights();



      if(result.isNotEmpty){


        setState((){


          insight =
              Map<String,dynamic>
                  .from(
                  result.first
              );


          loading=false;


        });


      }


    }

    catch(e){


      debugPrint(
          "Gender insight error: $e"
      );


      setState((){

        loading=false;

      });


    }


  }





 String get selectedLabel {
  final l10n = AppLocalizations.of(context);

  switch (widget.selection) {
    case GenderExpectation.boy:
      return l10n.boy;

    case GenderExpectation.girl:
      return l10n.girl;

    case GenderExpectation.noPreference:
      return l10n.noPreference;
  }
}



List<DateTime> get suggestedDates {
  if (insight == null) return [];

  final ovulation = DateTime.parse(
    insight!["ovulation_day"],
  );

  switch (widget.selection) {
    case GenderExpectation.boy:
      // closer to ovulation
      return [
        ovulation.subtract(const Duration(days: 1)),
        ovulation,
      ];

    case GenderExpectation.girl:
      // a few days before ovulation
      return [
        ovulation.subtract(const Duration(days: 4)),
        ovulation.subtract(const Duration(days: 3)),
        ovulation.subtract(const Duration(days: 2)),
      ];

    case GenderExpectation.noPreference:
      return [
        ovulation.subtract(const Duration(days: 2)),
        ovulation.subtract(const Duration(days: 1)),
        ovulation,
      ];
  }
}
String formatDate(DateTime date) {
  final l10n = AppLocalizations.of(context);

  final months = [
    l10n.jan,
    l10n.feb,
    l10n.mar,
    l10n.apr,
    l10n.may,
    l10n.jun,
    l10n.jul,
    l10n.aug,
    l10n.sep,
    l10n.oct,
    l10n.nov,
    l10n.dec,
  ];

  final days = [
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday,
  ];

  return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
}


  @override
  Widget build(BuildContext context){
    final l10n = AppLocalizations.of(context);

final ovulation =
    insight?["ovulation_day"]?.toString() ?? l10n.notAvailable;

final fertileStart =
    insight?["fertile_period_start"]?.toString() ?? l10n.notAvailable;

final fertileEnd =
    insight?["fertile_period_end"]?.toString() ?? l10n.notAvailable;

final fertileWindow = "$fertileStart - $fertileEnd";

    return Scaffold(


      backgroundColor:
      const Color(0xFFF6FBF8),



      appBar:
      AppBar(


        backgroundColor:
        const Color(0xFFF6FBF8),


        elevation:0,


        iconTheme:
        const IconThemeData(

          color:
          AppColors.primaryDark,

        ),


      ),





      body:


      loading


          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )



          :


      SingleChildScrollView(


        padding:
        const EdgeInsets.all(24),


        child:
        Column(


          children:[



            Container(
  width: 90,
  height: 90,
  decoration: BoxDecoration(
    color: widget.selection == GenderExpectation.girl
        ? Colors.pink.shade50
        : widget.selection == GenderExpectation.boy
            ? Colors.blue.shade50
            : Colors.green.shade50,
    shape: BoxShape.circle,
  ),
  child: Center(
    child: Text(
      widget.selection == GenderExpectation.girl
          ? "👧"
          : widget.selection == GenderExpectation.boy
              ? "👦"
              : "💚",
      style: const TextStyle(fontSize: 42),
    ),
  ),
),



            const SizedBox(height:16),




            Text(

             AppLocalizations.of(context).predictionFor(selectedLabel),


              textAlign:
              TextAlign.center,


              style:
              const TextStyle(

                fontSize:21,

                fontWeight:
                FontWeight.bold,

                color:
                AppColors.primaryDark,

              ),

            ),




            const SizedBox(height:20),



// Fertile Window Container
            
            Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.green.shade50,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      const Icon(
        Icons.calendar_today,
        color: Colors.green,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              AppLocalizations.of(context).fertileWindow,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(fertileWindow),
          ],
        ),
      ),
    ],
  ),
),
const SizedBox(height: 14),
// Ovulation Day Container
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.orange.shade50,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      const Icon(
        Icons.track_changes,
        color: Colors.orange,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              AppLocalizations.of(context).estimatedOvulation,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(ovulation),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 14),
// Suggested Timing Container
const SizedBox(height:20),
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0,3),
      )
    ],
  ),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

     Text(
        AppLocalizations.of(context).suggestedTiming,
        style: TextStyle(
          fontSize:18,
          fontWeight:FontWeight.bold,
          color:AppColors.primaryDark,
        ),
      ),

      const SizedBox(height:12),

      Text(
        widget.selection == GenderExpectation.boy
            ? AppLocalizations.of(context).tryCloserToOvulation
            : widget.selection == GenderExpectation.girl
                ? AppLocalizations.of(context).tryBeforeOvulation
                : AppLocalizations.of(context).yourFertileDays,
        style: TextStyle(
          color: Colors.grey[700],
        ),
      ),

      const SizedBox(height:12),

      ...suggestedDates.map(
        (date) => Container(
          margin: const EdgeInsets.only(bottom:8),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color:
              widget.selection == GenderExpectation.boy
                  ? Colors.blue.shade50
                  : widget.selection == GenderExpectation.girl
                      ? Colors.pink.shade50
                      : Colors.green.shade50,

            borderRadius:
              BorderRadius.circular(12),
          ),

          child: Row(
            children: [

              Icon(
                Icons.favorite,
                color:
                  widget.selection == GenderExpectation.boy
                      ? Colors.blue
                      : widget.selection == GenderExpectation.girl
                          ? Colors.pink
                          : Colors.green,
              ),

              const SizedBox(width:12),

              Text(
                formatDate(date),
                style: const TextStyle(
                  fontWeight:FontWeight.w600,
                  fontSize:15,
                ),
              ),

            ],
          ),
        ),
      ),

    ],
  ),
),
            const SizedBox(height:20),

          ],

        ),


      ),


    );


  }


}