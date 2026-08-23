import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/apple_subscription_service.dart';
import '../../services/api_service.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  // Android payment information
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
  // ============================================================
  // ANDROID
  // ============================================================

  WebViewController? _controller;

  bool _pageLoading = true;

  // ============================================================
  // IOS
  // ============================================================

  final AppleSubscriptionService _appleService =
      AppleSubscriptionService();

  List<ProductDetails> _appleProducts = [];

  bool _appleLoading = true;
  bool _applePurchasing = false;

  String? _appleError;

  // ============================================================
  // INIT
  // ============================================================

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
      "ANDROID SUBSCRIPTION PAYMENT URL: "
      "${widget.paymentUrl}",
    );

    debugPrint(
      "ANDROID SUBSCRIPTION REFERENCE: "
      "${widget.reference}",
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
          onNavigationRequest:
              (NavigationRequest request) {
            final url = request.url;

            debugPrint(
              "ANDROID PAYMENT NAVIGATION URL: $url",
            );

            // --------------------------------------------------
            // PAYMENT CALLBACK
            // --------------------------------------------------

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
  // IOS APPLE PAYMENT
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

    final bool available =
        await _appleService.initialize();

    if (!available) {
      debugPrint(
        "APPLE IAP IS NOT AVAILABLE",
      );

      if (mounted) {
        setState(() {
          _appleLoading = false;
          _appleError =
              "Apple subscriptions are currently unavailable.";
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
              "No Apple subscription products were found.";
        }
      });
    }
  }

  // ============================================================
  // START APPLE PURCHASE
  // ============================================================

  Future<void> _purchaseAppleSubscription(
    ProductDetails product,
  ) async {
    if (_applePurchasing) {
      return;
    }

    debugPrint(
      "APPLE SUBSCRIPTION SELECTED: "
      "${product.id}",
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
              "Unable to start Apple subscription.";
        });
      }
    }
  }

  // ============================================================
  // APPLE PURCHASE SUCCESS
  // ============================================================

  Future<void> _handleApplePurchaseSuccess(
    String transactionId,
    String productId,
  ) async {
    debugPrint(
      "APPLE PURCHASE SUCCESS",
    );

    debugPrint(
      "APPLE TRANSACTION ID: $transactionId",
    );

    debugPrint(
      "APPLE PRODUCT ID: $productId",
    );

    if (mounted) {
      setState(() {
        _applePurchasing = true;
        _appleError = null;
      });
    }

    // ----------------------------------------------------------
    // SEND TRANSACTION TO BACKEND
    // ----------------------------------------------------------

    try {
      debugPrint(
        "VERIFYING APPLE TRANSACTION WITH BACKEND...",
      );

      /*
       * IMPORTANT:
       *
       * Replace this endpoint with the EXACT route from
       * your Swagger/OpenAPI documentation.
       *
       * Example:
       *
       * /subscriptions/verify-apple
       *
       * or:
       *
       * /subscription/verify-apple
       */

      final response = await ApiService().post(
        '/subscriptions/verify-apple',
        {
          'transaction_id': transactionId,
        },
      );

      debugPrint(
        "APPLE VERIFICATION RESPONSE: $response",
      );

      // --------------------------------------------------------
      // CHECK BACKEND RESPONSE
      // --------------------------------------------------------

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

        // ------------------------------------------------------
        // CLOSE PAYMENT SCREEN
        // true = payment successful
        // ------------------------------------------------------

        Navigator.of(context).pop(true);

        return;
      }

      // --------------------------------------------------------
      // BACKEND REJECTED TRANSACTION
      // --------------------------------------------------------

      debugPrint(
        "APPLE TRANSACTION VERIFICATION FAILED",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              "Apple payment could not be verified.";
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
              "We couldn't verify your Apple subscription. "
              "Please try again.";
        });
      }
    }
  }

  // ============================================================
  // APPLE PURCHASE ERROR
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

  // ============================================================
  // APPLE PURCHASE CANCELLED
  // ============================================================

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
  // RESTORE APPLE PURCHASES
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

      /*
       * Restored transactions will come through the same
       * purchase stream and eventually reach:
       *
       * _handleApplePurchaseSuccess()
       *
       * where the transaction is sent to your backend.
       */

    } catch (e) {
      debugPrint(
        "APPLE RESTORE ERROR: $e",
      );

      if (mounted) {
        setState(() {
          _applePurchasing = false;
          _appleError =
              "Unable to restore your subscription.";
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
                onPressed: _initializeApplePayment,
                child: const Text(
                  "Try Again",
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

            const Text(
              "Choose your Premium plan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your subscription will be billed "
              "through the App Store.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            if (_appleError != null)
              Container(
                margin:
                    const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),
                  color: Colors.red.withOpacity(0.08),
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
                      const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _applePurchasing
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
              child: const Text(
                "Restore Purchases",
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
              child: const Text(
                "Cancel",
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
      return const Center(
        child: Text(
          "Unable to load payment.",
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
              ? "Premium Subscription"
              : "Premium Payment",
        ),
      ),

      body: Platform.isIOS
          ? _buildApplePayment()
          : _buildAndroidPayment(),

      // --------------------------------------------------------
      // ANDROID BOTTOM BAR ONLY
      // --------------------------------------------------------

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
                    const Text(
                      "After completing your payment, "
                      "tap the button below to continue.",
                      textAlign:
                          TextAlign.center,
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
                          debugPrint(
                            "ANDROID USER CONFIRMED "
                            "SUBSCRIPTION PAYMENT",
                          );

                          Navigator.of(context)
                              .pop(true);
                        },
                        child: const Text(
                          "I've Completed Payment",
                          style: TextStyle(
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
                        child:
                            const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _appleService.dispose();

    super.dispose();
  }
}