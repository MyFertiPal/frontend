import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "calendly_screen.dart";


import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class SpecialistProfileScreen extends StatefulWidget {
  final int specialistId;

  const SpecialistProfileScreen({
    super.key,
    required this.specialistId,
  });

  @override
  State<SpecialistProfileScreen> createState() =>
      _SpecialistProfileScreenState();
}

class _SpecialistProfileScreenState extends State<SpecialistProfileScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  Map<String, dynamic>? specialist;

  @override
  void initState() {
    super.initState();
    _loadSpecialist();
  }

  Future<void> _loadSpecialist() async {
    try {
      final data = await _api.getSpecialist(widget.specialistId);

      if (!mounted) return;

      setState(() {
        specialist = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _bookConsultation() async {
    final url = specialist?["calendly_url"];

    if (url == null || url.toString().isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (specialist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("Unable to load specialist"),
        ),
      );
    }

    final image = specialist!["image_url"] ?? "";
    final name = specialist!["name"] ?? "";
    final qualification = specialist!["qualification"] ?? "";
    final expertise = specialist!["area_of_expertise"] ?? "";
    final fee = specialist!["consultation_fee"]?.toString() ?? "0";
  final availabilityInfo =
    specialist!["availability_info"] as Map<String, dynamic>?;

final days =
    availabilityInfo?["days"] ?? "Not specified";

final hours =
    availabilityInfo?["hours"] ?? "Not specified";

    return Scaffold(
      backgroundColor: const Color(0xfff5f6f7),
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 120,
                    ),
                  );
                },
              ),
            ),
          ),
          

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(
  name,
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 6),

Text(
  qualification,
  style: const TextStyle(
    color: AppColors.teal,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
),

const SizedBox(height: 24),

const _SectionTitle(
  title: "Area of Expertise",
),

Text(
  expertise,
  style: const TextStyle(
    fontSize: 16,
    height: 1.5,
  ),
),

const SizedBox(height: 28),

const _SectionTitle(
  title: "Consultation Fee",
),

Row(
  children: [
    const Icon(
      Icons.payments,
      color: AppColors.teal,
    ),
    const SizedBox(width: 10),
    Text(
      "NGN $fee",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

const SizedBox(height: 28),

const _SectionTitle(
  title: "Availability",
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.teal,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              days,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          const Icon(
            Icons.access_time,
            color: AppColors.teal,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hours,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 30),

const _SectionTitle(
  title: "Patient Reviews",
),

const _ReviewCard(),

const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          )
        ],
      ),
      bottomNavigationBar: _BookButton(
        calendlyUrl: specialist?["calendly_url"] ?? "",
      ),
    );
  }
}
                    class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:
                AssetImage("assets/images/avatar_placeholder.png"),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Anonymous User",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    Icon(Icons.star,
                        color: Colors.amber, size: 18),
                  ],
                ),

                SizedBox(height: 8),

                Text(
                  "Very knowledgeable and supportive throughout my fertility journey.",
                  style: TextStyle(
                    color: Colors.black54,
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
class _BookButton extends StatelessWidget {
  final String calendlyUrl;

  const _BookButton({
    required this.calendlyUrl,
  });

  Future<void> _openCalendar() async {
    final uri = Uri.parse(calendlyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _payForConsultation(BuildContext context) {
    // TODO:
    // Initialize your Paystack/Flutterwave payment here.
    // After successful payment, allow booking.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Initializing payment..."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _payForConsultation(context),
                icon: const Icon(Icons.payment),
                label: const Text(
                  "Pay for Consultation",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _openCalendar,
                icon: const Icon(Icons.calendar_month),
                label: const Text(
                  "Book Consultation",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(
                    color: AppColors.teal,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}