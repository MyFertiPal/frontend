import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';
import 'subscription_payment_screen.dart';
import '../../screens/web/web_view_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends State<SubscriptionScreen> {
  final ApiService _apiService = ApiService();

  // ---------------------------------------------------------------------------
  // APPLE PRODUCT
  // ---------------------------------------------------------------------------

  static const String applePremiumProductId =
      'com.myfertipal.premium.monthly';

  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color headerBg = Color(0xFF163B30);
  static const Color premiumBg = Color(0xFF2F5C4A);
  static const Color gold = Color(0xFFE9B44C);
  static const Color background = Color(0xFFF7F7F5);
  static const Color textDark = Color(0xFF163B30);
  static const Color mutedText = Color(0xFF737873);
  static const Color linkColor = Color(0xFF096866);

  // ---------------------------------------------------------------------------
  // WEBSITE LINKS
  // ---------------------------------------------------------------------------

  static const String privacyPolicyUrl =
      'https://myfertipal.com/privacy-policy';

  static const String termsOfUseUrl =
      'https://myfertipal.com/terms-of-use';

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool _isRestoring = false;
  bool _restoreFoundPurchase = false;

  StreamSubscription<List<PurchaseDetails>>?
      _purchaseSubscription;

  AppLocalizations get _l10n =>
      AppLocalizations.of(context);

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(
      screenName: 'SubscriptionScreen',
    );

    // Listen for Apple purchase updates.
    //
    // This is important because restorePurchases()
    // does not directly return the restored purchase.
    // Apple sends the restored purchase through this stream.
    _purchaseSubscription =
        InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint(
          'PURCHASE STREAM ERROR: $error',
        );
      },
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // HANDLE PURCHASE STREAM
  // ---------------------------------------------------------------------------

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      debugPrint(
        'PURCHASE UPDATE: '
        'product=${purchase.productID}, '
        'status=${purchase.status}, '
        'transactionId=${purchase.purchaseID}',
      );

      // ---------------------------------------------------------
      // PENDING
      // ---------------------------------------------------------

      if (purchase.status == PurchaseStatus.pending) {
        debugPrint(
          'APPLE PURCHASE IS PENDING',
        );

        continue;
      }

      // ---------------------------------------------------------
      // ERROR
      // ---------------------------------------------------------

      if (purchase.status == PurchaseStatus.error) {
        debugPrint(
          'APPLE PURCHASE ERROR: ${purchase.error}',
        );

        if (mounted && _isRestoring) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to restore your purchase.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }

        continue;
      }

      // ---------------------------------------------------------
      // PURCHASED OR RESTORED
      // ---------------------------------------------------------

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Make sure this is our Premium subscription.
        if (purchase.productID !=
            applePremiumProductId) {
          debugPrint(
            'IGNORING UNKNOWN APPLE PRODUCT: '
            '${purchase.productID}',
          );

          continue;
        }

        await _verifyApplePurchase(purchase);
      }

      // ---------------------------------------------------------
      // COMPLETE PURCHASE
      // ---------------------------------------------------------

      if (purchase.pendingCompletePurchase) {
        debugPrint(
          'COMPLETING APPLE PURCHASE...',
        );

        try {
          await InAppPurchase.instance
              .completePurchase(purchase);

          debugPrint(
            'APPLE PURCHASE COMPLETED',
          );
        } catch (e) {
          debugPrint(
            'COMPLETE APPLE PURCHASE ERROR: $e',
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // VERIFY APPLE PURCHASE WITH BACKEND
  // ---------------------------------------------------------------------------

  Future<void> _verifyApplePurchase(
    PurchaseDetails purchase,
  ) async {
    try {
      final transactionId =
          purchase.purchaseID;

      if (transactionId == null ||
          transactionId.isEmpty) {
        debugPrint(
          'APPLE PURCHASE HAS NO TRANSACTION ID',
        );

        return;
      }

      debugPrint(
        'VERIFYING APPLE TRANSACTION...',
      );

      debugPrint(
        'APPLE TRANSACTION ID: $transactionId',
      );

      debugPrint(
        'APPLE PRODUCT ID: ${purchase.productID}',
      );

      debugPrint(
        'APPLE PURCHASE STATUS: ${purchase.status}',
      );

      // ---------------------------------------------------------
      // SEND TRANSACTION TO BACKEND
      // ---------------------------------------------------------

      final result =
          await _apiService.verifyAppleSubscription(
        transactionId,
      );

      debugPrint(
        'APPLE SUBSCRIPTION VERIFICATION RESULT: '
        '$result',
      );

      // ---------------------------------------------------------
      // READ BACKEND RESPONSE
      // ---------------------------------------------------------

      final planType =
          result['plan_type']?.toString();

      final productId =
          result['product_id']?.toString();

      final expirationDate =
          result['expiration_date']?.toString();

      debugPrint(
        'APPLE PLAN TYPE: $planType',
      );

      debugPrint(
        'APPLE PRODUCT ID FROM BACKEND: $productId',
      );

      debugPrint(
        'APPLE EXPIRATION DATE: $expirationDate',
      );

      // The transaction was successfully verified.
      _restoreFoundPurchase = true;

      if (!mounted) return;

      // ---------------------------------------------------------
      // RESTORED
      // ---------------------------------------------------------

      if (purchase.status ==
          PurchaseStatus.restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your Premium subscription has been restored.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      // ---------------------------------------------------------
      // NEW PURCHASE
      // ---------------------------------------------------------

      else if (purchase.status ==
          PurchaseStatus.purchased) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your Premium subscription is active.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'APPLE PURCHASE VERIFICATION ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not verify your Apple subscription.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UPGRADE / PAYSTACK
  // ---------------------------------------------------------------------------

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

      final user =
          await _apiService.getUser();

      final profile =
          await _apiService.getProfile();

      final userId =
          profile["user_id"]?.toString();

      final email =
          user["email"]?.toString();

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
            duration:
                const Duration(seconds: 4),
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
          duration:
              const Duration(seconds: 4),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // WEBVIEW
  // ---------------------------------------------------------------------------

  void _openWebPage(
    String title,
    String url,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          title: title,
          url: url,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESTORE APPLE PURCHASES
  // ---------------------------------------------------------------------------

  Future<void> _restorePurchases() async {
    if (_isRestoring) return;

    setState(() {
      _isRestoring = true;
      _restoreFoundPurchase = false;
    });

    try {
      final available =
          await InAppPurchase.instance.isAvailable();

      if (!available) {
        throw Exception(
          'In-app purchases are currently unavailable.',
        );
      }

      debugPrint(
        "RESTORING APPLE PURCHASES...",
      );

      // Apple will send restored transactions
      // through purchaseStream.
      await InAppPurchase.instance
          .restorePurchases();

      debugPrint(
        "APPLE RESTORE REQUEST COMPLETED",
      );

      // Give the purchase stream time to deliver
      // the restored transaction.
      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      if (!_restoreFoundPurchase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No previous Premium purchase was found.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "RESTORE PURCHASE ERROR: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to restore purchases. Please try again.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // -----------------------------------------------------------------------
      // TOP BAR
      // -----------------------------------------------------------------------

      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 23,
          ),
        ),

        title: Text(
          _l10n.membership,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            42,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ================================================================
              // HEADER
              // ================================================================

              Text(
                _l10n.upgradeExperience,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                _l10n.premiumDescription,
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 19,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 32),

              // ================================================================
              // PREMIUM CARD
              // ================================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  40,
                  30,
                  40,
                  34,
                ),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      headerBg,
                      premiumBg,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ==========================================================
                    // PREMIUM HEADER
                    // ==========================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [

                        Container(
                          width: 72,
                          height: 72,
                          decoration:
                              BoxDecoration(
                            color:
                                gold.withOpacity(0.18),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: gold,
                            size: 43,
                          ),
                        ),

                        const SizedBox(
                          width: 24,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                _l10n.premium,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                height: 7,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 18,
                                  vertical: 7,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFF2F806B,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    30,
                                  ),
                                ),
                                child:
                                    const Text(
                                  'Most Popular',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    // ==========================================================
                    // PRICE
                    // ==========================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [

                        const Text(
                          '₦2,000',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 45,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.only(
                            bottom: 7,
                          ),
                          child: Text(
                            '/ month',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Auto-renewable subscription',
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.85),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    Divider(
                      color: Colors.white
                          .withOpacity(0.25),
                      thickness: 1,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==========================================================
                    // FEATURES TITLE
                    // ==========================================================

                    const Text(
                      'With Premium, you get:',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==========================================================
                    // FEATURES
                    // ==========================================================

                    const _PremiumFeature(
                      text:
                          'Personalized fertility insights and recommendations',
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    const _PremiumFeature(
                      text:
                          'Advanced cycle and fertility tracking',
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    const _PremiumFeature(
                      text:
                          'Premium fertility education and resources',
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    const _PremiumFeature(
                      text:
                          'Access to expert consultations and resources',
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==========================================================
                    // UPGRADE BUTTON
                    // ==========================================================

                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _upgradeToPremium,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              gold,
                          foregroundColor:
                              textDark,
                          disabledBackgroundColor:
                              gold.withOpacity(
                            0.65,
                          ),
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              22,
                            ),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                      color:
                                          textDark,
                                    ),
                                  )
                                : Text(
                                    _l10n
                                        .upgradeNow,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          20,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 38,
              ),

              // ================================================================
              // RENEWAL INFORMATION
              // ================================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 64,
                    height: 64,
                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xFFE0E5DC),
                      shape:
                          BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: textDark,
                      size: 30,
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ),

                  const Expanded(
                    child: Text(
                      'Renews automatically every month unless cancelled.\n'
                      'You can manage or cancel your subscription in your '
                      'Apple Account settings.',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // ================================================================
              // DIVIDER
              // ================================================================

              Divider(
                color:
                    Colors.grey.shade300,
                thickness: 1,
              ),

              const SizedBox(
                height: 22,
              ),

              // ================================================================
              // TERMS + PRIVACY
              // ================================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  GestureDetector(
                    onTap: () {
                      _openWebPage(
                        'Terms of Use',
                        termsOfUseUrl,
                      );
                    },
                    child:
                        const Text(
                      'Terms of Use',
                      style:
                          TextStyle(
                        color:
                            linkColor,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        decoration:
                            TextDecoration.underline,
                      ),
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      '|',
                      style:
                          TextStyle(
                        color:
                            mutedText,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      _openWebPage(
                        'Privacy Policy',
                        privacyPolicyUrl,
                      );
                    },
                    child:
                        const Text(
                      'Privacy Policy',
                      style:
                          TextStyle(
                        color:
                            linkColor,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        decoration:
                            TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // ================================================================
              // RESTORE PURCHASES
              // ================================================================

              Center(
                child:
                    TextButton(
                  onPressed:
                      _isRestoring
                          ? null
                          : _restorePurchases,
                  style:
                      TextButton.styleFrom(
                    foregroundColor:
                        linkColor,
                  ),
                  child:
                      _isRestoring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    linkColor,
                              ),
                            )
                          : const Text(
                              'Restore Purchases',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                                decoration:
                                    TextDecoration
                                        .underline,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ================================================================
              // SECURE PAYMENT
              // ================================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.lock_outline,
                    color:
                        Colors.grey.shade500,
                    size: 23,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Text(
                    'Secure payment • Your data is safe',
                    style: TextStyle(
                      color:
                          Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM FEATURE
// ============================================================================

class _PremiumFeature
    extends StatelessWidget {
  final String text;

  const _PremiumFeature({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Container(
          width: 30,
          height: 30,
          decoration:
              const BoxDecoration(
            color:
                Color(0xFF68C878),
            shape:
                BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color:
                Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(
          width: 17,
        ),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 2,
            ),
            child: Text(
              text,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}