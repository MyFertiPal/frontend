import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "calendly_screen.dart";
import '../../theme/app_colors.dart';
import 'specialist_profile_screen.dart';
import '../../services/api_service.dart';
import '../payment/payment_screen.dart';

class SpecialistSearchScreen extends StatefulWidget {
  const SpecialistSearchScreen({super.key});

  @override
  State<SpecialistSearchScreen> createState() => _SpecialistSearchScreenState();
}

class _SpecialistSearchScreenState extends State<SpecialistSearchScreen> {
  final ApiService _api = ApiService();

bool _loading = true;

List<dynamic> _specialists = [];

Future<void> _loadSpecialists() async {
  try {
    final data = await _api.getSpecialists();

    if (!mounted) return;

    setState(() {
      _specialists = data;
      _loading = false;
    });
  } catch (e) {
    debugPrint(e.toString());

    setState(() {
      _loading = false;
    });
  }
}

@override
void initState() {
  super.initState();
  _loadSpecialists();
}



  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.lock,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: 12),
              Text('Premium Feature'),
            ],
          ),
          content: const Text(
            'Upgrade to premium to chat with specialists and get personalized advice.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Specialist'),
        backgroundColor: AppColors.teal,
      ),
      backgroundColor: const Color(0xFFF5F5F0),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search specialists by name or specialty',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.teal,
                  ),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: AppColors.teal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              if (_loading)
  const Padding(
    padding: EdgeInsets.only(top: 40),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  )
else
  ..._specialists.map(
    (sp) => _SpecialistCard(
      data: Map<String, dynamic>.from(sp),
    ),
  ),
            ],
          ),

          //_LockedOverlay(//
           // onTap: () => _showPremiumDialog(context),
         // ),
        ],
      ),
    );
  }
}



class _SpecialistCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SpecialistCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final name = data["name"] ?? "";

    final qualification = data["qualification"] ?? "";

    final expertise = data["area_of_expertise"] ?? "";

    final fee = data["consultation_fee"].toString();

    final image = data["image_url"] ?? "";

    final calendly = data["calendly_url"] ?? "";

    final availability = data["availability_info"]?.toString() ?? "Available";

    String initials(String input) {
      final parts = input.trim().split(" ");

      if (parts.length == 1) {
        return parts.first.isNotEmpty
            ? parts.first[0].toUpperCase()
            : "?";
      }

      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }

    return InkWell(
  borderRadius: BorderRadius.circular(18),
  onTap: () {
    final specialistId = data["id"];

    if (specialistId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialistProfileScreen(
          specialistId: specialistId,
        ),
      ),
    );
  },
  child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.teal,
                      child: Text(
                        initials(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      qualification,
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
  expertise,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontSize: 16,
    height: 1.5,
  ),
),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
const SizedBox(height: 14),

Row(
  children: [
    const Icon(
      Icons.calendar_today_outlined,
      color: AppColors.teal,
      size: 18,
    ),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        availability,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.teal,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "NGN $fee",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (calendly.isEmpty) return;

                final uri = Uri.parse(calendly);

               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CalendlyScreen(
      calendlyUrl: calendly,
    ),
  ),
);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Book Consultation"),
            ),
          ),
        ],
      ),
        ),
  );
  }
}

class _LockedOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const _LockedOverlay({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(.28),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12,
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    color: Color(0xFF0F5132),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Premium Required",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
