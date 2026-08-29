import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/apple_subscription_service.dart';
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String? paymentUrl;
  final String? reference;

  const SubscriptionPaymentScreen({
    super.key,
    this.paymentUrl,
    this.reference,
  });

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends State<SubscriptionPaymentScreen> {
  WebViewController? _controller;
  bool _pageLoading = true;

  final AppleSubscriptionService _appleService =
      AppleSubscriptionService();

  List<ProductDetails> _appleProducts = [];

  bool _appleLoading = true;
  bool _applePurchasing = false;

  String? _appleError;

  AppLocalizations get _l10n =>
      AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _initializeApplePayment();
    } else {
      _initializeAndroidPayment();
    }
  }

  // ============================================================
  // ANDROID PAYMENT
  // ============================================================

  void _initializeAndroidPayment() {
    debugPrint(
      "ANDROID SUBSCRIPTION PAYMENT URL: ${widget.paymentUrl}",
    );

    debugPrint(
      "ANDROID SUBSCRIPTION REFERENCE: ${widget.reference}",
    );

    if (widget.paymentUrl == null ||
        widget.paymentUrl!.isEmpty) {
      debugPrint(
        "ANDROID PAYMENT ERROR: paymentUrl is missing",
      );
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (
            NavigationRequest request,
          ) {
            final url = request.url;

            debugPrint(
              "ANDROID PAYMENT NAVIGATION URL: $url",
            );

            if (url.startsWith(
                  "https://teamnexuss.netlify.app/"
                  "booking/payment-callback",
                ) ||
                url.startsWith(
                  "myfertipal://payment/success",
                )) {
              debugPrint(
                "ANDROID PAYMENT CALLBACK DETECTED",
              );

              if (mounted) {
                Navigator.of(context).pop(true);
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            debugPrint(
              "ANDROID PAYMENT PAGE STARTED: $url",
            );

            if (mounted) {
              setState(() {
                _pageLoading = true;
              });
            }
          },
          onPageFinished: (url) {
            debugPrint(
              "ANDROID PAYMENT PAGE FINISHED: $url",
            );

            if (mounted) {
              setState(() {
                _pageLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint(
              "ANDROID PAYMENT WEBVIEW ERROR: "
              "${error.description}",
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl!),
      );

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // IOS PAYMENT
  // ============================================================

  Future<void> _initializeApplePayment() async {
    debugPrint(
      "APPLE SUBSCRIPTION PAYMENT INITIALIZING",
    );

    _appleService.onPurchaseSuccess =
        _handleApplePurchaseSuccess;

    _appleService.onPurchaseError =
        _handleApplePurchaseError;

    _appleService.onPurchaseCancelled =
        _handleApplePurchaseCancelled;

    final available =
        await _appleService.initialize();

    if (!available) {
      debugPrint(
        "APPLE IAP IS NOT AVAILABLE",
      );

      if (mounted) {
        setState(() {
          _appleLoading = false;
          _appleError =
              _l10n.appleSubscriptionsUnavailable;
        });
      }

      return;
    }

    final products =
        await _appleService.loadProducts();

    if (mounted) {
      setState(() {
        _appleProducts = products;
        _appleLoading = false;

        if (products.isEmpty) {
          _appleError =
              _l10n.noAppleProducts;
        }
      });
    }
  }

  // ============================================================
  // PURCHASE
  // ============================================================

  Future<void> _purchaseAppleSubscription(
    ProductDetails product,
  ) async {
    if (_applePurchasing) {
      return;
    }

    debugPrint(
      "APPLE SUBSCRIPTION SELECTED: ${product.id}",
    );

    if (mounted) {
      setState(() {
        _applePurchasing = true;
        _appleError = null;
      });
    }

    try {
      await _appleService.purchaseSubscription(
        product,
      );
    } catch (e) {
      debugPrint(
        "APPLE PURCHASE START ERROR: $e",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              _l10n.unableToStartAppleSubscription;
        });
      }
    }
  }

  // ============================================================
  // PURCHASE SUCCESS
  // ============================================================

  Future<void> _handleApplePurchaseSuccess(
    String transactionId,
    String productId,
  ) async {
    debugPrint("APPLE PURCHASE SUCCESS");
    debugPrint("APPLE TRANSACTION ID: $transactionId");
    debugPrint("APPLE PRODUCT ID: $productId");

    if (mounted) {
      setState(() {
        _applePurchasing = true;
        _appleError = null;
      });
    }

    try {
      debugPrint(
        "VERIFYING APPLE TRANSACTION WITH BACKEND...",
      );

      final response = await ApiService().post(
        '/subscriptions/verify-apple',
        {
          'transaction_id': transactionId,
        },
      );

      debugPrint(
        "APPLE VERIFICATION RESPONSE: $response",
      );

      if (response != null &&
          response['success'] == true) {
        debugPrint(
          "APPLE SUBSCRIPTION VERIFIED SUCCESSFULLY",
        );

        debugPrint(
          "PLAN TYPE: ${response['plan_type']}",
        );

        debugPrint(
          "PRODUCT ID: ${response['product_id']}",
        );

        debugPrint(
          "EXPIRATION DATE: "
          "${response['expiration_date']}",
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _applePurchasing = false;
        });

        Navigator.of(context).pop(true);
        return;
      }

      debugPrint(
        "APPLE TRANSACTION VERIFICATION FAILED",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              _l10n.applePaymentNotVerified;
        });
      }
    } catch (e) {
      debugPrint(
        "APPLE VERIFICATION ERROR: $e",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              _l10n.verifyAppleSubscriptionError;
        });
      }
    }
  }

  // ============================================================
  // PURCHASE ERROR
  // ============================================================

  void _handleApplePurchaseError(
    String error,
  ) {
    debugPrint(
      "APPLE PURCHASE ERROR: $error",
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _applePurchasing = false;
      _appleError = error;
    });
  }

  void _handleApplePurchaseCancelled() {
    debugPrint(
      "APPLE PURCHASE CANCELLED BY USER",
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _applePurchasing = false;
    });
  }

  // ============================================================
  // RESTORE
  // ============================================================

  Future<void> _restoreApplePurchases() async {
    if (_applePurchasing) {
      return;
    }

    debugPrint(
      "RESTORING APPLE PURCHASES...",
    );

    if (mounted) {
      setState(() {
        _applePurchasing = true;
        _appleError = null;
      });
    }

    try {
      await _appleService.restorePurchases();
    } catch (e) {
      debugPrint(
        "APPLE RESTORE ERROR: $e",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              _l10n.unableToRestoreSubscription;
        });
      }
    }
  }

  // ============================================================
  // IOS UI
  // ============================================================

  Widget _buildApplePayment() {
    if (_appleLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_appleError != null &&
        _appleProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                _appleError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _initializeApplePayment,
                child: Text(
                  _l10n.tryAgain,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Text(
              _l10n.choosePremiumPlan,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _l10n.subscriptionBilledAppStore,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            if (_appleError != null)
              Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),
                  color:
                      Colors.red.withOpacity(0.08),
                ),
                child: Text(
                  _appleError!,
                  textAlign: TextAlign.center,
                ),
              ),

            ..._appleProducts.map(
              (product) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed:
                          _applePurchasing
                              ? null
                              : () =>
                                  _purchaseAppleSubscription(
                                    product,
                                  ),
                      child: _applePurchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "${product.title} • "
                              "${product.price}",
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            TextButton(
              onPressed: _applePurchasing
                  ? null
                  : _restoreApplePurchases,
              child: Text(
                _l10n.restorePurchases,
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _applePurchasing
                  ? null
                  : () {
                      Navigator.of(context)
                          .pop(false);
                    },
              child: Text(
                _l10n.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANDROID UI
  // ============================================================

  Widget _buildAndroidPayment() {
    if (_controller == null) {
      return Center(
        child: Text(
          _l10n.unableToLoadPayment,
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _controller!,
        ),
        if (_pageLoading)
          const LinearProgressIndicator(
            minHeight: 3,
          ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Platform.isIOS
              ? _l10n.premiumSubscription
              : _l10n.premiumPayment,
        ),
      ),

      body: Platform.isIOS
          ? _buildApplePayment()
          : _buildAndroidPayment(),

      bottomNavigationBar: Platform.isIOS
          ? null
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      _l10n.afterCompletingPayment,
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
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
                          debugPrint(
                            "ANDROID USER CONFIRMED "
                            "SUBSCRIPTION PAYMENT",
                          );

                          Navigator.of(context)
                              .pop(true);
                        },
                        child: Text(
                          _l10n.completedPayment,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
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
                          Navigator.of(context)
                              .pop(false);
                        },
                        child: Text(
                          _l10n.cancel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _appleService.dispose();
    super.dispose();
  }
}