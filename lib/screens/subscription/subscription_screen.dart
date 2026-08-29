import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';
import 'subscription_payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends State<SubscriptionScreen> {
  final ApiService _apiService = ApiService();

  static const Color headerBg = Color(0xFF163B30);
  static const Color premiumBg = Color(0xFF2F5C4A);
  static const Color gold = Color(0xFFE9B44C);
  static const Color background = Color(0xFFF7F7F5);
  static const Color textDark = Color(0xFF163B30);

  bool _isLoading = false;

  AppLocalizations get _l10n =>
      AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(
      screenName: 'SubscriptionScreen',
    );
  }

  Future<void> _upgradeToPremium() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    AnalyticsService.logPayClicked('premium');

    try {
      debugPrint(
        "STARTING PREMIUM SUBSCRIPTION...",
      );

      final user = await _apiService.getUser();
      final profile = await _apiService.getProfile();

      final userId = profile["user_id"]?.toString();
      final email = user["email"]?.toString();

      debugPrint(
        "SUBSCRIPTION USER ID: $userId",
      );

      debugPrint(
        "SUBSCRIPTION EMAIL: $email",
      );

      if (userId == null || userId.isEmpty) {
        throw Exception(
          _l10n.subscriptionUserIdNotFound,
        );
      }

      if (email == null || email.isEmpty) {
        throw Exception(
          _l10n.subscriptionEmailNotFound,
        );
      }

      final response =
          await _apiService.initiateSubscription(
        userId: userId,
        email: email,
      );

      debugPrint(
        "INITIATE SUBSCRIPTION RESULT: $response",
      );

      final paymentUrl =
          response['authorization_url']?.toString();

      final reference =
          response['reference']?.toString();

      if (paymentUrl == null ||
          paymentUrl.isEmpty) {
        throw Exception(
          _l10n.paymentUrlNotReturned,
        );
      }

      if (reference == null ||
          reference.isEmpty) {
        throw Exception(
          _l10n.subscriptionReferenceNotReturned,
        );
      }

      debugPrint(
        "PAYMENT URL: $paymentUrl",
      );

      debugPrint(
        "PAYMENT REFERENCE: $reference",
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final paymentCompleted =
          await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              SubscriptionPaymentScreen(
            paymentUrl: paymentUrl,
            reference: reference,
          ),
        ),
      );

      if (!mounted) return;

      debugPrint(
        "PAYMENT SCREEN RESULT: $paymentCompleted",
      );

      if (paymentCompleted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _l10n.subscriptionActive,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "START SUBSCRIPTION ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.subscriptionStartError,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () =>
              Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _l10n.membership,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            28,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.upgradeExperience,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _l10n.premiumDescription,
                style: const TextStyle(
                  color: Color(0xFF737873),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      headerBg,
                      premiumBg,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.10),
                      blurRadius: 14,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration:
                              BoxDecoration(
                            color: gold
                                .withOpacity(0.18),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: gold,
                            size: 25,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          _l10n.premium,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      "₦2,000",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _l10n.premiumMembership,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Divider(
                      color: Colors.white
                          .withOpacity(0.15),
                      height: 1,
                    ),

                    const SizedBox(height: 20),

                    _PremiumFeature(
                      icon:
                          Icons.check_circle_outline,
                      text:
                          _l10n.premiumAccess,
                    ),

                    const SizedBox(height: 14),

                    _PremiumFeature(
                      icon:
                          Icons.check_circle_outline,
                      text:
                          _l10n.enhancedExperience,
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _upgradeToPremium,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor:
                              headerBg,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _l10n.upgradeNow,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  _l10n.securePaymentCancelAnytime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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

class _PremiumFeature
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PremiumFeature({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xFFE9B44C),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}