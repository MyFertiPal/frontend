import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

import '../screens/specialists/specialist_search_screen.dart';
import "../screens/root_screen.dart";
import '../screens/gender_prediction_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tracking/log_symptom_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  final ApiService _apiService = ApiService();


  String _insightText = "";

  String? _currentLanguage;


  String _name = "User";
  String _firstName = "User";
  String _avatarUrl = "";


  int _cycleLength = 28;
  int _periodLength = 5;


  DateTime? _lastPeriodDate;

  DateTime? _fertileStart;
  DateTime? _fertileEnd;
  DateTime? _ovulationDate;
  DateTime? _nextPeriod;


  bool _isLoading = true;



  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _currentLanguage =
          Localizations.localeOf(context).languageCode;

      _loadHomeData();

    });
  }



  @override
  void didChangeDependencies() {

    super.didChangeDependencies();


    final language =
        Localizations.localeOf(context).languageCode;


    if (_currentLanguage == null) {

      _currentLanguage = language;

    } 
    else if (_currentLanguage != language) {

      _currentLanguage = language;

      _reloadInsights();

    }

  }




  String _greeting(BuildContext context) {

    final hour = DateTime.now().hour;


    if (hour < 12) {

      return AppLocalizations.of(context).goodMorning;

    } 
    else if (hour < 17) {

      return AppLocalizations.of(context).goodAfternoon;

    } 
    else {

      return AppLocalizations.of(context).goodEvening;

    }

  }

Future<void> _loadProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Read the profile image URL saved after upload
    final savedAvatarUrl =
        prefs.getString('profile_image_url') ?? '';

    final user = await _apiService.getUser();

    if (!mounted) return;

    final backendAvatarUrl =
        user["profile_image"]?.toString() ?? "";

    // LocalStorage takes priority
    final avatarUrl = savedAvatarUrl.isNotEmpty
        ? savedAvatarUrl
        : backendAvatarUrl;

    setState(() {
      _firstName =
          user["first_name"]?.toString() ?? "User";

      _name =
          "${user["first_name"] ?? ""} "
          "${user["last_name"] ?? ""}".trim();

      _avatarUrl = avatarUrl;
    });

    // If local storage was empty but backend has an image,
    // save it locally for future use.
    if (savedAvatarUrl.isEmpty && backendAvatarUrl.isNotEmpty) {
      await prefs.setString(
        'profile_image_url',
        backendAvatarUrl,
      );
    }

    debugPrint(
      "HOME PROFILE IMAGE FROM LOCAL STORAGE: $_avatarUrl",
    );
  } catch (e) {
    debugPrint(
      "HOME PROFILE ERROR: $e",
    );
  }
}

  Future<void> _reloadInsights() async {

    try {


      final insights =
          await _apiService.getInsights();


      if (!mounted) return;


      setState(() {

        if (insights.isNotEmpty) {

          _insightText =
              insights.first["insight_text"] ??
              AppLocalizations.of(context)
                  .defaultInsight;

        }

      });


    } catch(e) {

      debugPrint(
        "INSIGHT RELOAD ERROR: $e",
      );

    }

  }





  Future<void> _loadHomeData() async {
  try {
    final prefs = await SharedPreferences.getInstance();

final savedAvatarUrl =
    prefs.getString('profile_image_url') ?? '';
    final user = await _apiService.getUser();

    final profile = await _apiService.getProfile();

    final predictions = await _apiService.getInsights();

    if (predictions.isEmpty) {
      if (!mounted) return;

      setState(() {
        _firstName = user["first_name"]?.toString() ?? "User";

        _name =
            "${user["first_name"] ?? ""} "
            "${user["last_name"] ?? ""}"
                .trim();

     _avatarUrl = savedAvatarUrl.isNotEmpty
    ? savedAvatarUrl
    : user["profile_image"]?.toString() ?? "";

        _cycleLength =
            profile["cycle_length"] ?? 28;

        _periodLength =
            profile["period_length"] ?? 5;

        if (profile["last_period_date"] != null) {
          _lastPeriodDate = DateTime.parse(
            profile["last_period_date"].toString(),
          );
        }

        _isLoading = false;
      });

      return;
    }

    final prediction = predictions.first;

    if (!mounted) return;

    setState(() {
      // -----------------------------
      // USER
      // -----------------------------

      _firstName =
          user["first_name"]?.toString() ?? "User";

      _name =
          "${user["first_name"] ?? ""} "
          "${user["last_name"] ?? ""}"
              .trim();

      // IMPORTANT:
      // This is the URL returned by the backend.
     _avatarUrl = savedAvatarUrl.isNotEmpty
    ? savedAvatarUrl
    : user["profile_image"]?.toString() ?? "";

      // -----------------------------
      // PROFILE
      // -----------------------------

      _cycleLength =
          profile["cycle_length"] ?? 28;

      _periodLength =
          profile["period_length"] ?? 5;

      if (profile["last_period_date"] != null) {
        _lastPeriodDate = DateTime.parse(
          profile["last_period_date"].toString(),
        );
      }

      // -----------------------------
      // PREDICTIONS
      // -----------------------------

      if (prediction["fertile_period_start"] != null) {
        _fertileStart = DateTime.parse(
          prediction["fertile_period_start"].toString(),
        );
      }

      if (prediction["fertile_period_end"] != null) {
        _fertileEnd = DateTime.parse(
          prediction["fertile_period_end"].toString(),
        );
      }

      if (prediction["ovulation_day"] != null) {
        _ovulationDate = DateTime.parse(
          prediction["ovulation_day"].toString(),
        );
      }

      if (prediction["next_period"] != null) {
        _nextPeriod = DateTime.parse(
          prediction["next_period"].toString(),
        );
      }

      _isLoading = false;
    });

    // Load insight separately.
    await _reloadInsights();

    debugPrint("HOME PROFILE IMAGE URL: $_avatarUrl");
  } catch (e) {
    debugPrint("HOME ERROR: $e");

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



  String _currentPhase(BuildContext context) {

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );



    bool sameDay(DateTime? date){

      if(date == null) return false;


      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

    }



    if(
      _fertileStart != null &&
      _fertileEnd != null &&
      !today.isBefore(_fertileStart!) &&
      !today.isAfter(_fertileEnd!)
    ){

      return AppLocalizations.of(context)
          .fertileWindow;

    }




    if(sameDay(_ovulationDate)){

      return AppLocalizations.of(context)
          .ovulation;

    }





    if(
      _nextPeriod != null &&
      !today.isBefore(_nextPeriod!) &&
      today.isBefore(
        _nextPeriod!
            .add(
              Duration(days: _periodLength),
            ),
      )
    ){

      return AppLocalizations.of(context)
          .period;

    }



    return AppLocalizations.of(context)
        .cycle;

  }





  @override
  Widget build(BuildContext context) {


    if(_isLoading){

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }



    return Scaffold(

      backgroundColor:
          AppColors.cardBackground,


      body: SafeArea(

        bottom: false,


        child:
        SingleChildScrollView(

          padding:
              const EdgeInsets.only(
                bottom: 24,
              ),


          child:
          Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,


            children: [

              const SizedBox(height:30),


              _buildHeader(context),


              const SizedBox(height:16),


              _buildTrackingCard(context),


              const SizedBox(height:28),


              _buildQuickActions(context),


              const SizedBox(height:20),


              _buildInsightCard(context),


              const SizedBox(height:28),


              _buildBookSpecialistSection(context),

            ],

          ),

        ),

      ),

    );

  }
  // ---------- Header ----------

Widget _buildHeader(BuildContext context) {

  return Padding(

    padding:
        const EdgeInsets.fromLTRB(20, 8, 20, 0),


    child: Row(

      children: [


     ClipOval(
  child: SizedBox(
    width: 56,
    height: 56,
    child: _avatarUrl.isNotEmpty
        ? Image.network(
            _avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/images/profile_placeholder.webp",
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            "assets/images/profile_placeholder.webp",
            fit: BoxFit.cover,
          ),
  ),
),


        const SizedBox(width:12),



        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,


            children: [


              Text(

                _greeting(context),


                style: const TextStyle(

                  color:
                      AppColors.textPrimary,

                  fontSize:15,

                ),

              ),



              Text(

                _name.split(" ").first,


                style: const TextStyle(

                  color:
                      AppColors.textPrimary,

                  fontSize:24,

                  fontWeight:
                      FontWeight.w800,

                ),

              ),


            ],

          ),

        ),




        InkWell(

          borderRadius:
              BorderRadius.circular(24),


         onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileScreen(
        name: _name,
        privacyPolicyUrl:
            'https://myfertipal.com/privacy-policy',
      ),
    ),
  );

  // Reload profile after returning.
  await _loadProfile();
},


          child: Container(

            width:48,

            height:48,


            decoration: BoxDecoration(

              color:Colors.white,


              borderRadius:
                  BorderRadius.circular(24),


              boxShadow: const [

                BoxShadow(

                  color:Colors.black12,

                  blurRadius:8,

                  offset:
                      Offset(0,2),

                ),

              ],

            ),


            child: const Icon(

              Icons.person,

              color:
                  AppColors.textPrimary,

            ),

          ),

        ),


      ],

    ),

  );

}





// ---------- Tracking Card ----------


Widget _buildTrackingCard(BuildContext context) {


  int cycleDay = 1;



  if(_lastPeriodDate != null){


    cycleDay =
        (DateTime.now()
                    .difference(
                      _lastPeriodDate!,
                    )
                    .inDays %
                _cycleLength) +
            1;



    if(cycleDay <= 0){

      cycleDay += _cycleLength;

    }

  }



  return Padding(

    padding:
        const EdgeInsets.symmetric(
          horizontal:20,
        ),



    child: ClipRRect(

      borderRadius:
          BorderRadius.circular(28),



      child: Container(

        height:300,



        decoration:
            const BoxDecoration(

          gradient:
              LinearGradient(

            begin:
                Alignment.topCenter,


            end:
                Alignment.bottomCenter,


            colors:[

              AppColors.teal,

              AppColors.primaryDark,

            ],

          ),

        ),




        child: Stack(

          children:[



            Center(

              child:Opacity(

                opacity:.50,


                child:Image.asset(

                  "assets/images/flower.png",

                  width:280,

                  fit:BoxFit.contain,

                ),

              ),

            ),





            Padding(

              padding:
                  const EdgeInsets.all(26),



              child:Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,



                children:[



                  Text(

                    AppLocalizations.of(context)
                        .day(cycleDay),


                    style:
                        const TextStyle(

                      color:
                          Colors.white,

                      fontSize:18,

                    ),

                  ),





                  const Spacer(),





                  Center(

                    child:Text(

                      _currentPhase(context),


                      textAlign:
                          TextAlign.center,


                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize:46,

                        fontWeight:
                            FontWeight.w300,

                      ),

                    ),

                  ),




                  const Spacer(),


                ],

              ),

            ),

          ],

        ),

      ),

    ),

  );

}







// ---------- Quick Actions ----------


Widget _buildQuickActions(BuildContext context){


  return Padding(

    padding:
        const EdgeInsets.symmetric(
          horizontal:20,
        ),



    child:Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,



      children:[



        Text(

          AppLocalizations.of(context)
              .quickActions,


          style:
              const TextStyle(

            color:
                AppColors.textPrimary,

            fontSize:24,

            fontWeight:
                FontWeight.w800,

          ),

        ),



        const SizedBox(height:16),





        Row(

          children:[



            Expanded(

              child:_quickActionCard(

                icon:
                    Icons.add,


                iconBg:
                    AppColors.pinkAccent,


                label:
                    AppLocalizations.of(context)
                        .logSymptoms,


                onTap:(){

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>
                          const LogSymptomsScreen(),

                    ),

                  );

                },

              ),

            ),




            const SizedBox(width:14),




            Expanded(

              child:_quickActionCard(

                icon:
                    Icons.male,


                iconBg:
                    AppColors.teal,


                label:
                    AppLocalizations.of(context)
                        .genderPrediction,



                onTap:(){

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>
                          const GenderPredictionScreen(),

                    ),

                  );

                },

              ),

            ),





            const SizedBox(width:14),





            Expanded(

              child:_quickActionCard(

                icon:
                    Icons.calendar_today_outlined,


                iconBg:
                    const Color(0XFFA8E4B7),


                iconColor:
                    AppColors.primaryDark,



                label:
                    AppLocalizations.of(context)
                        .calendar,



                onTap:(){

                  RootScreen.of(context)
                      ?.changeTab(1);

                },

              ),

            ),



          ],

        ),

      ],

    ),

  );

}







Widget _quickActionCard({

  required IconData icon,

  required Color iconBg,

  required String label,

  required VoidCallback onTap,

  Color iconColor = Colors.white,

}){


  return Material(

    color:
        Colors.white,



    borderRadius:
        BorderRadius.circular(20),



    child:InkWell(

      borderRadius:
          BorderRadius.circular(20),


      onTap:onTap,



      child:Container(

        padding:
            const EdgeInsets.symmetric(
              vertical:20,
              horizontal:8,
            ),



        decoration:
            BoxDecoration(

          borderRadius:
              BorderRadius.circular(20),



          boxShadow:[

            BoxShadow(

              color:
                  Colors.black.withOpacity(.06),


              blurRadius:10,


              offset:
                  const Offset(0,4),

            ),

          ],

        ),



        child:Column(

          children:[



            Container(

              width:48,

              height:48,


              decoration:
                  BoxDecoration(

                color:
                    iconBg,


                borderRadius:
                    BorderRadius.circular(14),

              ),



              child:Icon(

                icon,

                color:
                    iconColor,

                size:26,

              ),

            ),





            const SizedBox(height:10),





            Text(

              label,


              textAlign:
                  TextAlign.center,


              style:
                  const TextStyle(

                color:
                    AppColors.textPrimary,

                fontSize:14,

                fontWeight:
                    FontWeight.w700,

              ),

            ),

          ],

        ),

      ),

    ),

  );

}
// ---------- Insight Card ----------

Widget _buildInsightCard(BuildContext context) {

  return Padding(

    padding:
        const EdgeInsets.symmetric(
          horizontal:20,
        ),


    child:Container(

      padding:
          const EdgeInsets.all(20),


      decoration:BoxDecoration(

        color:
            AppColors.teal,


        borderRadius:
            BorderRadius.circular(18),

      ),



      child:Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,


        children:[



          Row(

            children:[



              Container(

                width:44,

                height:44,


                decoration:
                    const BoxDecoration(

                  color:
                      Colors.white,


                  shape:
                      BoxShape.circle,

                ),


                child:
                    const Icon(

                  Icons.lightbulb_outline,


                  color:
                      AppColors.teal,

                ),

              ),




              const SizedBox(width:12),




              Expanded(

                child:Text(

                  AppLocalizations.of(context)
                      .todaysInsight,


                  style:
                      const TextStyle(

                    color:
                        Colors.white,


                    fontSize:18,


                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ),




              InkWell(

                borderRadius:
                    BorderRadius.circular(20),



                onTap:(){


                  final language =
                      Localizations.localeOf(context)
                          .languageCode;



                  context
                      .read<AudioService>()
                      .playTTS(

                        text:
                            _insightText.isEmpty

                            ? AppLocalizations.of(context)
                                .defaultInsight

                            : _insightText,


                        languageCode:
                            language,

                      );


                },



                child:Container(

                  padding:
                      const EdgeInsets.all(8),


                  decoration:
                      BoxDecoration(

                    color:
                        Colors.white.withOpacity(.15),


                    shape:
                        BoxShape.circle,

                  ),



                  child:
                      const Icon(

                    Icons.volume_up_outlined,


                    color:
                        Colors.white,


                    size:22,

                  ),

                ),

              ),

            ],

          ),





          const SizedBox(height:16),




          Text(

            _insightText.isEmpty

                ? AppLocalizations.of(context)
                    .defaultInsight

                : _insightText,



            style:
                const TextStyle(

              color:
                  Colors.white,


              fontSize:15,


              height:1.5,

            ),

          ),


        ],

      ),

    ),

  );

}








// ---------- Book Specialist ----------


Widget _buildBookSpecialistSection(BuildContext context) {


  return Padding(

    padding:
        const EdgeInsets.symmetric(
          horizontal:20,
        ),



    child:Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,


      children:[



        Text(

          AppLocalizations.of(context)
              .bookSpecialist,


          style:
              const TextStyle(

            color:
                AppColors.textPrimary,


            fontSize:24,


            fontWeight:
                FontWeight.w800,

          ),

        ),




        const SizedBox(height:16),





        Container(

          padding:
              const EdgeInsets.all(20),



          decoration:
              BoxDecoration(

            color:
                Colors.white,



            borderRadius:
                BorderRadius.circular(22),



            border:

                Border.all(

              color:
                  Colors.grey.withOpacity(.15),


              width:1,

            ),



            boxShadow:[

              BoxShadow(

                color:
                    Colors.black.withOpacity(.08),


                blurRadius:12,


                offset:
                    const Offset(0,5),

              ),

            ],

          ),





          child:Row(

            children:[



              Expanded(

                flex:6,


                child:Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,



                  children:[



                    const SizedBox(height:8),




                    Text(

                      AppLocalizations.of(context)
                          .expertGuidance,


                      style:
                          const TextStyle(

                        color:
                            AppColors.textPrimary,


                        fontSize:15,


                        height:1.4,

                      ),

                    ),





                    const SizedBox(height:22),





                    SizedBox(

                      height:48,



                      child:
                          ElevatedButton(



                        style:
                            ElevatedButton.styleFrom(

                          backgroundColor:
                              AppColors.pinkAccent,


                          foregroundColor:
                              AppColors.cardBackground,


                          elevation:0,



                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(14),

                          ),



                        ),





                        onPressed:(){



                          Navigator.push(

                            context,


                            MaterialPageRoute(

                              builder:(_)=>

                                  const SpecialistSearchScreen(),


                            ),

                          );


                        },





                        child:
                            Text(

                          AppLocalizations.of(context)
                              .bookConsultation,


                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.w700,


                            fontSize:14,

                          ),

                        ),


                      ),

                    ),



                  ],

                ),

              ),





              const SizedBox(width:16),





              ClipRRect(

                borderRadius:
                    BorderRadius.circular(18),



                child:
                    Image.asset(

                  "assets/images/doctor_placeholder.png",


                  width:145,


                  height:170,


                  fit:
                      BoxFit.cover,

                ),

              ),



            ],

          ),

        ),

      ],

    ),

  );

}

}