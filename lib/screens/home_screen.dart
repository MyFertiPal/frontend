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

String _formatDateRange(DateTime? start, int days) {
  if (start == null) return "--";

  final end = start.add(Duration(days: days - 1));

  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  String format(DateTime d) =>
      "${d.day} ${months[d.month - 1]}";

  if (days == 1) {
    return format(start);
  }

  return "${format(start)} - ${format(end)}";
}
String _relativeStatus(DateTime? date) {
  if (date == null) return "--";

  final today = DateTime.now();

  final now = DateTime(
    today.year,
    today.month,
    today.day,
  );

  final target = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final diff = target.difference(now).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Tomorrow";
  if (diff == -1) return "Yesterday";

  if (diff > 1) return "In $diff days";

  return "${diff.abs()} days ago";
}


  @override
  void initState() {
    super.initState();
    _loadHomeData();
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
      backgroundColor: AppColors.scaffoldBackground,
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
                  'Good Morning,',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                Text(
            _name.split(" ").first,
                  style: TextStyle(
                    color: AppColors.primaryDark,
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
              child: const Icon(Icons.person, color: AppColors.pinkAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tracking card with silhouette + timeline ----------
  Widget _buildTrackingCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 380,
          decoration: const BoxDecoration(color: AppColors.primaryDark),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Silhouette side
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.white,
                  child: ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(28),
    bottomLeft: Radius.circular(28),
  ),
  child: Image.asset(
    "assets/images/pregnant.png",
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  ),
),
                ),
              ),
              // Timeline side
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timelineItem(
                        color: AppColors.primary,
                        title: 'Fertile Window',
                        titleColor: AppColors.primary,
status: _relativeStatus(_fertileStart),
dateRange: _formatDateRange(
  _fertileStart,
  5,
),
                      ),
                      _timelineItem(
                        color: Colors.amber,
                        title: 'Ovulation',
                        titleColor: Colors.amber,
    status: _relativeStatus(_ovulationDate),
dateRange: _formatDateRange(
  _ovulationDate,
  1,
),
                      ),
                      _timelineItem(
                        color: AppColors.pinkAccent,
                        title: 'Predicted Period',
                        titleColor: AppColors.pinkAccent,
      status: _relativeStatus(_nextPeriod),
dateRange: _formatDateRange(
  _nextPeriod,
  _periodLength,
),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineItem({
    required Color color,
    required String title,
    required Color titleColor,
    required String status,
    required String dateRange,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      status,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 2),
    Text(
      dateRange,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
  ],
)
          ],
        ),
      ],
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
              color: AppColors.primaryDark,
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
                  iconBg: AppColors.primaryMedium,
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
                  iconBg: AppColors.primaryLight,
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
                color: Colors.black12,
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
                  color: AppColors.primaryDark,
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

  // ---------- Insight card (not tappable, per requirements) ----------
  Widget _buildInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
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
                color: AppColors.primary,
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
  Widget _buildBookSpecialistSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Specialist',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pinkAccent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Talk to a Specialist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get expert guidance from certified fertility doctors, anytime.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SpecialistSearchScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            child: Text(
                              'Book Consultation',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 110,
                    height: 150,
                    child:Image.asset(
  "assets/images/doctor_placeholder.webp",
)
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