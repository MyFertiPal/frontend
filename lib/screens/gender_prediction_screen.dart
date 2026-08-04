import 'package:flutter/material.dart';
import "../../theme/app_colors.dart";
import "../../services/api_service.dart";


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


                  const Text(

                    "Gender Prediction",

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

                      padding:
                      const EdgeInsets.all(16),


                      decoration:
                      BoxDecoration(

                        color:
                        const Color(
                            0xFFFDECE3
                        ),

                        borderRadius:
                        BorderRadius.circular(
                            16
                        ),

                      ),


                      child:
                      const Text(

                        "Important Disclaimer\n\n"
                            "This feature uses fertility timing "
                            "information to provide gender "
                            "prediction guidance. It is not "
                            "scientifically guaranteed and should "
                            "not replace medical advice.",


                        style:TextStyle(

                          fontSize:14,

                          height:1.4,

                        ),

                      ),

                    ),



                    const SizedBox(height:24),



                    const Text(

                      "Select your gender expectation",

                      style:TextStyle(

                        fontSize:18,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                    const SizedBox(height:16),



                    _OptionCard(

                      title:"Girl",

                      subtitle:
                      "I'm hoping for a baby girl",

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

                      title:"Boy",

                      subtitle:
                      "I'm hoping for a baby boy",

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

                      title:"No Preference",

                      subtitle:
                      "I'm open to either",

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
  String get genderAdvice {


    final ovulation =
        insight?["ovulation_day"]
            ?.toString()
            ??
            "Not available";


    final fertileStart =
        insight?["fertile_period_start"]
            ?.toString()
            ??
            "Not available";


    final fertileEnd =
        insight?["fertile_period_end"]
            ?.toString()
            ??
            "Not available";



    final fertileWindow =
        "$fertileStart to $fertileEnd";



    switch(widget.selection){



      case GenderExpectation.boy:


        return """

Your fertile window:

$fertileWindow


Estimated ovulation day:

$ovulation


For a baby boy preference 👦

The Shettles method suggests timing intercourse as close as possible to ovulation.

Suggested timing:

• Ovulation day
• One day before ovulation


Remember: This method is not scientifically guaranteed.

""";




      case GenderExpectation.girl:


        return """

Your fertile window:

$fertileWindow


Estimated ovulation day:

$ovulation


For a baby girl preference 👧

The Shettles method suggests timing intercourse a few days before ovulation.

Suggested timing:

• 2–4 days before ovulation


Remember: This method is not scientifically guaranteed.

""";





      case GenderExpectation.noPreference:


        return """

Your fertile window:

$fertileWindow


Estimated ovulation day:

$ovulation


Your body is most fertile during this window.

Tracking ovulation and timing intercourse during the fertile period may improve your chances of conception.


""";

    }

  }




  String get selectedLabel {


    switch(widget.selection){


      case GenderExpectation.boy:

        return "Boy";


      case GenderExpectation.girl:

        return "Girl";


      case GenderExpectation.noPreference:

        return "No Preference";


    }

  }






  @override
  Widget build(BuildContext context){


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



        title:
        const Text(

          "Your Results",

          style:
          TextStyle(

            color:
            AppColors.primaryDark,

            fontWeight:
            FontWeight.bold,

          ),

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



            const Icon(

              Icons.favorite,

              size:60,

              color:
              Colors.pink,

            ),



            const SizedBox(height:16),




            Text(

              "Prediction for: $selectedLabel",


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




            Container(

              padding:
              const EdgeInsets.all(18),


              decoration:
              BoxDecoration(

                color:
                Colors.white,


                borderRadius:
                BorderRadius.circular(18),


                boxShadow:[


                  const BoxShadow(

                    color:
                    Colors.black12,

                    blurRadius:5,

                    offset:
                    Offset(0,3),

                  )

                ],

              ),



              child:
              Text(


                genderAdvice,


                style:
                TextStyle(

                  fontSize:15,

                  height:1.6,

                  color:
                  Colors.grey[800],

                ),


              ),


            ),




            const SizedBox(height:20),




            Container(

              padding:
              const EdgeInsets.all(14),


              decoration:
              BoxDecoration(

                color:
                const Color(
                    0xFFFDECE3
                ),


                borderRadius:
                BorderRadius.circular(14),

              ),


              child:
              const Text(


                "Note: Gender timing methods are not proven methods for choosing a baby's sex. They are only based on timing theories and should not replace medical guidance.",


                style:
                TextStyle(

                  fontSize:13,

                  height:1.4,

                ),


              ),


            )


          ],

        ),


      ),


    );


  }


}