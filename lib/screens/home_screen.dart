import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../generated/l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/period_service.dart';
import '../services/analytics_service.dart';

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
final LocalPeriodService _periodService = LocalPeriodService();

  final ApiService _apiService = ApiService();


  String _insightText = "";

  String? _currentLanguage;
bool _isLoadingProfileImage = true;

  String _name = "User";
  String _firstName = "User";
  String _avatarUrl = "";
  int _currentCycleDay = 1;


  int _cycleLength = 28;
  int _periodLength = 5;


  DateTime? _lastPeriodDate;

  DateTime? _fertileStart;
  DateTime? _fertileEnd;
  DateTime? _ovulationDate;
  DateTime? _nextPeriod;


  bool _isLoading = true;

Future<void> _calculateCurrentCycleDay() async {
  try {
    if (_lastPeriodDate == null) {
      debugPrint("HOME: No last period date available.");

      if (mounted) {
        setState(() {
          _currentCycleDay = 1;
        });
      }

      return;
    }

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final startDate = DateTime(
      _lastPeriodDate!.year,
      _lastPeriodDate!.month,
      _lastPeriodDate!.day,
    );

    final difference = today.difference(startDate).inDays;

    if (difference < 0) {
      if (mounted) {
        setState(() {
          _currentCycleDay = 1;
        });
      }

      return;
    }

    final cycleDay = (difference % _cycleLength) + 1;

    debugPrint(
      "HOME CYCLE CALCULATION: "
      "lastPeriodDate=$startDate, "
      "today=$today, "
      "difference=$difference, "
      "cycleLength=$_cycleLength, "
      "cycleDay=$cycleDay",
    );

    if (mounted) {
      setState(() {
        _currentCycleDay = cycleDay;
      });
    }
  } catch (e) {
    debugPrint("HOME CYCLE CALCULATION ERROR: $e");
  }
}
  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(screenName: 'HomeScreen');

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


Future<void> _reloadInsights() async {
  try {
    final language =
        Localizations.localeOf(context).languageCode;

    final todayInsight =
        await _apiService.getTodayInsight(
      lang: language,
    );

    debugPrint(
      "TODAY INSIGHT STATUS: 200",
    );

    debugPrint(
      "TODAY INSIGHT RESPONSE: $todayInsight",
    );

    if (!mounted) return;

    // ---------------------------------------------
    // Get current cycle day from backend
    // ---------------------------------------------
    final backendCycleDay = int.tryParse(
      todayInsight["current_cycle_day"]?.toString() ?? "",
    );

    // ---------------------------------------------
    // Get daily insight object
    // ---------------------------------------------
    final dailyInsight =
        todayInsight["daily_insight"];

    String? insightMessage;

    if (dailyInsight is Map<String, dynamic>) {
      insightMessage =
          dailyInsight["message"]?.toString().trim();
    }

    // ---------------------------------------------
    // Update UI
    // ---------------------------------------------
    setState(() {
      if (backendCycleDay != null) {
        _currentCycleDay = backendCycleDay;
      }

      if (insightMessage != null &&
          insightMessage.isNotEmpty) {
        _insightText = insightMessage;
      }
    });

    debugPrint(
      "HOME TODAY INSIGHT MESSAGE: $_insightText",
    );

  } catch (e) {
    debugPrint(
      "TODAY INSIGHT RELOAD ERROR: $e",
    );
  }
}
Future<void> _loadHomeData() async {
  try {
    // --------------------------------------------------
    // 1. LOAD USER
    // --------------------------------------------------

    Map<String, dynamic> user = {};

    try {
      user = await _apiService.getUser();

      debugPrint("HOME USER: $user");

      if (mounted) {
        setState(() {
          final firstName =
              user["first_name"]?.toString().trim() ?? "";

          final lastName =
              user["last_name"]?.toString().trim() ?? "";

          _firstName =
              firstName.isNotEmpty ? firstName : "User";

          _name =
              "$firstName $lastName".trim();

          if (_name.isEmpty) {
            _name = "User";
          }
        });
      }
    } catch (e) {
      debugPrint("HOME USER ERROR: $e");
    }

    // --------------------------------------------------
    // 2. LOAD PROFILE
    // --------------------------------------------------

    Map<String, dynamic> profile = {};

    try {
      profile = await _apiService.getProfile();

      debugPrint("HOME PROFILE: $profile");

      final userId = profile["user_id"];

      if (mounted) {
        setState(() {
          _cycleLength =
              int.tryParse(
                    profile["cycle_length"]?.toString() ?? "",
                  ) ??
                  28;

          _periodLength =
              int.tryParse(
                    profile["period_length"]?.toString() ?? "",
                  ) ??
                  5;

          if (profile["last_period_date"] != null) {
            _lastPeriodDate = DateTime.tryParse(
              profile["last_period_date"].toString(),
            );
          }
        });
        
      }
      await _calculateCurrentCycleDay();

      // --------------------------------------------------
      // 3. LOAD PROFILE PICTURE
      // --------------------------------------------------

      if (userId != null) {
        try {
          final profilePicture =
              await _apiService.getProfilePicture(
            userId: userId.toString(),
          );

          debugPrint(
            "HOME PROFILE PICTURE RESPONSE: $profilePicture",
          );

          final data =
              profilePicture["data"]
                  as Map<String, dynamic>?;

          final avatarUrl =
              data?["url"]?.toString() ?? "";

          debugPrint(
            "HOME PROFILE PICTURE URL: $avatarUrl",
          );

          if (mounted) {
            setState(() {
              _avatarUrl = avatarUrl;
              _isLoadingProfileImage = false;
            });
          }
        } catch (e) {
          debugPrint(
            "HOME PROFILE PICTURE ERROR: $e",
          );

          if (mounted) {
            setState(() {
              _isLoadingProfileImage = false;
            });
          }
        }
      } else {
        debugPrint(
          "HOME: No user_id found in profile",
        );

        if (mounted) {
          setState(() {
            _isLoadingProfileImage = false;
          });
        }
      }
    } catch (e) {
      debugPrint("HOME PROFILE ERROR: $e");

      if (mounted) {
        setState(() {
          _isLoadingProfileImage = false;
        });
      }
    }

    // --------------------------------------------------
    // 4. LOAD FERTILITY PREDICTIONS
    // --------------------------------------------------

    try {
      final predictions =
          await _apiService.getInsights();

      debugPrint(
        "HOME INSIGHTS: $predictions",
      );

      if (mounted && predictions.isNotEmpty) {
  final prediction = predictions.first;

  debugPrint(
    "HOME SELECTED PREDICTION: $prediction",
  );

  setState(() {
    // -----------------------------
    // Fertility dates
    // -----------------------------

    if (prediction["fertile_period_start"] != null) {
      _fertileStart = DateTime.tryParse(
        prediction["fertile_period_start"].toString(),
      );
    }

    if (prediction["fertile_period_end"] != null) {
      _fertileEnd = DateTime.tryParse(
        prediction["fertile_period_end"].toString(),
      );
    }

    if (prediction["ovulation_day"] != null) {
      _ovulationDate = DateTime.tryParse(
        prediction["ovulation_day"].toString(),
      );
    }

    if (prediction["next_period"] != null) {
      _nextPeriod = DateTime.tryParse(
        prediction["next_period"].toString(),
      );
    }

   
  });
}
    } catch (e) {
      debugPrint(
        "HOME FERTILITY PREDICTIONS ERROR: $e",
      );
    }

 // --------------------------------------------------
// 5. LOAD TODAY'S INSIGHT
// --------------------------------------------------
try {
  await _reloadInsights();
} catch (e) {
  debugPrint(
    "HOME TODAY INSIGHT ERROR: $e",
  );
}



    // --------------------------------------------------
    // 6. FINISHED LOADING
    // --------------------------------------------------

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e, stackTrace) {
    debugPrint("HOME GENERAL ERROR: $e");
    debugPrint("$stackTrace");

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  String _currentPhase(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  final day = _currentCycleDay;

  // --------------------------------------------------
  // MENSTRUAL PHASE
  // --------------------------------------------------
  if (day <= _periodLength) {
    return l10n.menstrual;
  }

  // --------------------------------------------------
  // OVULATION
  //
  // Ovulation is approximately 14 days before
  // the next period.
  // --------------------------------------------------
  final ovulationDay = _cycleLength - 14;

  if (day == ovulationDay) {
    return l10n.ovulation;
  }

  // --------------------------------------------------
  // FOLLICULAR PHASE
  // --------------------------------------------------
  if (day < ovulationDay) {
    return l10n.follicular;
  }

  // --------------------------------------------------
  // LUTEAL PHASE
  // --------------------------------------------------
  return l10n.luteal;
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
    child: _avatarUrl.isEmpty
        ? const _HomeProfileSkeleton()
        : Image.network(
            _avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/images/profile_placeholder.webp",
                fit: BoxFit.cover,
              );
            },
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

  if (!mounted) return;

  await _loadHomeData();
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
  final phase = _currentPhase(context);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.teal,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background flower
            Center(
              child: Opacity(
                opacity: .50,
                child: Image.asset(
                  "assets/images/flower.png",
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cycle day
                  Text(
                    AppLocalizations.of(context)
                        .day(_currentCycleDay),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // Current phase
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          phase,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
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





          child: LayoutBuilder(
            builder: (context, constraints) {
              // Below this width, a fixed 145px image next to
              // flex:6 text leaves too little room for the text
              // column in some languages/screen sizes — stack
              // vertically instead so the button and heading
              // always have full width to work with.
              final isNarrow = constraints.maxWidth < 340;

              final textColumn = Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)
                        .expertGuidance,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),





                    const SizedBox(height:22),





                 // NOTE: previously this was a SizedBox with a hard
                 // `height: 48`. When the localized label wrapped to
                 // a second line (long translations, or a narrow
                 // screen squeezing this Expanded(flex: 6) column),
                 // the text needed more vertical space than 48px
                 // could give it — so the second line (sometimes the
                 // whole label) was silently clipped/invisible.
                 //
                 // Fix: give the button a MINIMUM height instead of a
                 // fixed one, so it grows to fit 2 lines when needed,
                 // and wrap the text in a FittedBox as a last-resort
                 // safety net so even an unusually long translation
                 // shrinks to fit rather than ever getting clipped.
                 ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 48),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pinkAccent,
        foregroundColor: AppColors.cardBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SpecialistSearchScreen(),
          ),
        );
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppLocalizations.of(context).bookConsultation,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ),
  ),
),



                ],
              );

              final image = ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/images/doctor_placeholder.png",
                  width: isNarrow ? double.infinity : 145,
                  height: isNarrow ? 160 : 170,
                  fit: BoxFit.cover,
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(height: 16),
                    textColumn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: textColumn,
                  ),
                  const SizedBox(width: 16),
                  image,
                ],
              );
            },
          ),
        ),

      ],

    ),

  );

}

}
class _HomeProfileSkeleton extends StatefulWidget {
  const _HomeProfileSkeleton();

  @override
  State<_HomeProfileSkeleton> createState() =>
      _HomeProfileSkeletonState();
}

class _HomeProfileSkeletonState
    extends State<_HomeProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.35);

        return Container(
          color: Colors.grey.withOpacity(opacity),
        );
      },
    );
  }
}