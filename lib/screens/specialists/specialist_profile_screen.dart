import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import "calendly_screen.dart";
import '../../generated/l10n/app_localizations.dart';
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
  String _name = "User";
  String _firstName = "User";
  String _avatarUrl = "";

  int _cycleLength = 28;
  int _periodLength = 5;

  Map<String, dynamic>? specialist;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadSpecialist();
  }

  Future<void> _loadSpecialist() async {
    try {
      final results = await Future.wait([
        _api.getSpecialist(widget.specialistId),
        _api.getUser(),
        _api.getProfile(),
      ]);

      if (!mounted) return;

      setState(() {
        specialist = results[0] as Map<String, dynamic>;
        _user = results[1] as Map<String, dynamic>;
        _profile = results[2] as Map<String, dynamic>;

        _firstName = _user?["first_name"]?.toString() ?? "User";

        _name = "${_user?["first_name"] ?? ""} "
                "${_user?["last_name"] ?? ""}"
            .trim();

        _avatarUrl = _user?["profile_image"]?.toString() ?? "";

        _loading = false;
      });

      debugPrint("SPECIALIST: $specialist");
      debugPrint("USER: $_user");
      debugPrint("PROFILE: $_profile");
      debugPrint("USER ID: ${_profile?["user_id"]}");
      debugPrint("PROFILE IMAGE: $_avatarUrl");
    } catch (e) {
      debugPrint("Specialist profile error: $e");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _user == null) {
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
                  children: [
                    Text(
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
          ),
        ],
      ),
      bottomNavigationBar: _BookButton(
        specialistId: widget.specialistId,
        user: _user!,
        profile: _profile!,
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

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

// ============================================================
// REVIEW CARD
// ============================================================

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
            backgroundImage: AssetImage(
              "assets/images/avatar_placeholder.png",
            ),
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
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
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

// ============================================================
// BOOK BUTTON
// ============================================================

class _BookButton extends StatefulWidget {
  final int specialistId;
  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  const _BookButton({
    required this.specialistId,
    required this.user,
    required this.profile,
  });

  @override
  State<_BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<_BookButton> {
  final ApiService _api = ApiService();

  bool _booking = false;
  Future<void> _bookConsultation() async {
    if (_booking) return;

    try {
      setState(() {
        _booking = true;
      });

      // --------------------------------------------------
      // 1. Get authenticated user
      // --------------------------------------------------

      final user = await _api.getUser();

      // --------------------------------------------------
      // 2. Get profile because this contains user_id
      // --------------------------------------------------

      final profile = await _api.getProfile();

      final userId = profile["user_id"];

      debugPrint("BOOKING USER: $user");
      debugPrint("BOOKING PROFILE: $profile");
      debugPrint("BOOKING USER ID: $userId");

      if (userId == null) {
        throw Exception(
          "Unable to determine user ID from profile.",
        );
      }

      final email = user["email"]?.toString() ?? "";

      final firstName = user["first_name"]?.toString() ?? "";

      final lastName = user["last_name"]?.toString() ?? "";

      final username = user["username"]?.toString() ?? "";

      final name = "$firstName $lastName".trim().isNotEmpty
          ? "$firstName $lastName".trim()
          : username;

      if (email.isEmpty || name.isEmpty) {
        throw Exception(
          "Unable to get your account details.",
        );
      }

      // --------------------------------------------------
      // 3. Initiate booking
      // --------------------------------------------------

      debugPrint(
        "INITIATING BOOKING: "
        "userId=$userId, "
        "specialistId=${widget.specialistId}, "
        "email=$email, "
        "name=$name",
      );

      final booking = await _api.initiateBooking(
        userId: userId.toString(),
        specialistId: widget.specialistId,
        email: email,
        name: name,
      );

      debugPrint("BOOKING RESPONSE: $booking");

      final authorizationUrl = booking["authorization_url"]?.toString();

      final reference = booking["reference"]?.toString();

      if (authorizationUrl == null ||
          authorizationUrl.isEmpty ||
          reference == null ||
          reference.isEmpty) {
        throw Exception(
          "Invalid booking response.",
        );
      }

      if (!mounted) return;

      // --------------------------------------------------
      // 4. Open payment
      // --------------------------------------------------

      final paymentCompleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            authorizationUrl: authorizationUrl,
          ),
        ),
      );

      if (paymentCompleted != true) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _booking = true;
      });

      // --------------------------------------------------
      // 5. Verify payment
      // --------------------------------------------------

      final verification = await _api.verifyBooking(
        reference: reference,
        userId: userId.toString(),
        email: email,
        name: name,
      );

      debugPrint(
        "BOOKING VERIFICATION: $verification",
      );

      final status = verification["status"]?.toString();

      debugPrint(
        "Booking verification status: $status",
      );

      final calendlyUrl = verification["calendly_url"]?.toString();

      if (calendlyUrl == null || calendlyUrl.isEmpty) {
        throw Exception(
          "Payment could not be verified or Calendly link was not returned.",
        );
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CalendlyScreen(
            calendlyUrl: calendlyUrl,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Booking error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to complete booking: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _booking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: _booking ? null : _bookConsultation,
          icon: _booking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.calendar_month,
                ),
          label: Text(
            _booking
                ? "Processing..."
                : AppLocalizations.of(context).bookConsultation,
            style: const TextStyle(
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
    );
  }
}

// ============================================================
// PAYMENT SCREEN
// ============================================================

class PaymentScreen extends StatefulWidget {
  final String authorizationUrl;

  const PaymentScreen({
    super.key,
    required this.authorizationUrl,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;

  bool _pageLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          final url = request.url;

          debugPrint("PAYMENT NAVIGATION URL: $url");

          if (url.startsWith(
            "https://teamnexuss.netlify.app/booking/payment-callback",
          ) ||
              url.startsWith(
                "myfertipal://payment/success",
              )) {
            debugPrint("PAYMENT CALLBACK DETECTED");

            Navigator.pop(context, true);

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
        onPageStarted: (_) {
          if (mounted) {
            setState(() {
              _pageLoading = true;
            });
          }
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() {
              _pageLoading = false;
            });
          }
        },
        onWebResourceError: (error) {
          debugPrint(
            "Payment WebView error: ${error.description}",
          );
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
        ),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (_pageLoading)
            const LinearProgressIndicator(
              minHeight: 3,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "After completing your payment, "
                "tap the button below to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    "I've Completed Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
