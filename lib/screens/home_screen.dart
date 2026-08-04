import 'package:flutter/material.dart';
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
  String _currentPhase() {
  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  bool sameDay(DateTime? date) {
    if (date == null) return false;

    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  if (_fertileStart != null &&
      _fertileEnd != null &&
      !today.isBefore(_fertileStart!) &&
      !today.isAfter(_fertileEnd!)) {
    return "Fertile Window";
  }

  if (sameDay(_ovulationDate)) {
    return "Ovulation";
  }

  if (_nextPeriod != null &&
      !today.isBefore(_nextPeriod!) &&
      today.isBefore(
        _nextPeriod!.add(Duration(days: _periodLength)),
      )) {
    return "Period";
  }

  return "Cycle";
}

  String _name = "User";
  String _firstName = "User";

  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime? _lastPeriodDate;

  bool _isLoading = true;

DateTime? _fertileStart;
DateTime? _fertileEnd;
DateTime? _ovulationDate;
DateTime? _nextPeriod;


  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }
  String _greeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return "Good Morning,";
  } else if (hour < 17) {
    return "Good Afternoon,";
  } else {
    return "Good Evening,";
  }
}


  Future<void> _loadHomeData() async {

    try {

      final user = await _apiService.getUser();
      final profile = await _apiService.getProfile();
      
      final predictions = await _apiService.getCyclePrediction();

       final prediction = predictions.first;


      debugPrint("HOME USER: $user");
      debugPrint("HOME PROFILE: $profile");


      setState(() {

        _firstName =
            user["first_name"] ?? "User";


        _name =
            "${user["first_name"] ?? ""} ${user["last_name"] ?? ""}".trim();


        _cycleLength =
            profile["cycle_length"] ?? 28;


        _periodLength =
            profile["period_length"] ?? 5;


        if(profile["last_period_date"] != null){

          _lastPeriodDate =
              DateTime.parse(
                profile["last_period_date"]
              );

        }
        _fertileStart = DateTime.parse(
  prediction["fertile_period_start"],
);

_fertileEnd = DateTime.parse(
  prediction["fertile_period_end"],
);

_ovulationDate = DateTime.parse(
  prediction["ovulation_day"],
);

_nextPeriod = DateTime.parse(
  prediction["next_period"],
);


        _isLoading = false;

      });


    } catch(e){

      debugPrint("HOME ERROR: $e");

      setState(() {
        _isLoading=false;
      });

    }

  }

  @override
Widget build(BuildContext context) {


if(_isLoading){

return const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
);

}


return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const SizedBox(height: 30),
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildTrackingCard(context),
              const SizedBox(height: 28),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildInsightCard(),
              const SizedBox(height: 28),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.asset(
  "assets/images/profile_placeholder.webp",
  fit: BoxFit.cover,
)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
  _greeting(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                Text(
            _name.split(" ").first,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  ProfileScreen(
                  name: _name,
                  privacyPolicyUrl: 'https://myfertipal.com/privacy-policy',
                )),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tracking card
 Widget _buildTrackingCard(BuildContext context) {
  int cycleDay = 1;

  if (_lastPeriodDate != null) {
    cycleDay =
        (DateTime.now().difference(_lastPeriodDate!).inDays % _cycleLength) + 1;

    if (cycleDay <= 0) cycleDay += _cycleLength;
  }

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
            /// Flower background
            Center(
              child: Opacity(
                opacity: 0.50,
                child: Image.asset(
                  "assets/images/flower.png",
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Day $cycleDay",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: Text(
                      _currentPhase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
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
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _quickActionCard(
                  icon: Icons.add,
                  iconBg: AppColors.pinkAccent,
                  label: 'Log\nSymptoms',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogSymptomsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _quickActionCard(
                  icon: Icons.male,
                  iconBg: AppColors.teal,
                  label: 'Gender\nPrediction',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenderPredictionScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _quickActionCard(
                  icon: Icons.calendar_today_outlined,
                  iconBg: Color(0XFFA8E4B7),
                  iconColor: AppColors.primaryDark,
                  label: 'Calendar',
                 onTap: () {
  RootScreen.of(context)?.changeTab(1);
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
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Insight card ----------
  Widget _buildInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insight',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Get expert guidance from certified fertility doctors, anytime.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Book Specialist ----------
 // ---------- Book Specialist ----------
Widget _buildBookSpecialistSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Book Specialist",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground, // Pink background
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              /// Left side
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    const SizedBox(height: 8),

                    const Text(
                      "Get expert guidance from certified fertility doctors, anytime.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SpecialistSearchScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Book Consultation",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              /// Right side image
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/images/doctor.jpeg",
                  width: 145,
                  height: 170,
                  fit: BoxFit.cover,
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