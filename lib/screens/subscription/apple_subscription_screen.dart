import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/apple_subscription_service.dart';
import '../../services/api_service.dart';

class AppleSubscriptionScreen extends StatefulWidget {
  const AppleSubscriptionScreen({
    super.key,
  });

  @override
  State<AppleSubscriptionScreen> createState() =>
      _AppleSubscriptionScreenState();
}

class _AppleSubscriptionScreenState
    extends State<AppleSubscriptionScreen> {
  final AppleSubscriptionService _appleService =
      AppleSubscriptionService();

  List<ProductDetails> _products = [];

  bool _loading = true;
  bool _purchasing = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _setupApplePayments();
  }

  // ============================================================
  // SETUP
  // ============================================================

  Future<void> _setupApplePayments() async {
    debugPrint('APPLE SCREEN: Initializing');

    _appleService.onPurchaseSuccess =
        _onPurchaseSuccess;

    _appleService.onPurchaseError =
        _onPurchaseError;

    _appleService.onPurchaseCancelled =
        _onPurchaseCancelled;

    final available =
        await _appleService.initialize();

    if (!available) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Apple subscriptions are not available.';
      });

      return;
    }

    final products =
        await _appleService.loadProducts();

    if (!mounted) return;

    setState(() {
      _products = products;
      _loading = false;

      if (products.isEmpty) {
        _error =
            'No subscription plans are available.';
      }
    });
  }

  // ============================================================
  // SUBSCRIBE
  // ============================================================

  Future<void> _subscribe(
    ProductDetails product,
  ) async {
    if (_purchasing) return;

    debugPrint(
      'APPLE SCREEN: Subscribe tapped',
    );

    debugPrint(
      'PRODUCT: ${product.id}',
    );

    setState(() {
      _purchasing = true;
      _error = null;
    });

    try {
      await _appleService.purchaseSubscription(
        product,
      );
    } catch (e) {
      debugPrint(
        'APPLE SCREEN PURCHASE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _purchasing = false;
        _error =
            'Unable to start the subscription.';
      });
    }
  }

  // ============================================================
  // PURCHASE SUCCESS
  // ============================================================

  Future<void> _onPurchaseSuccess(
  String transactionId,
  String productId,
) async {
  debugPrint(
    'APPLE SCREEN: Purchase successful',
  );

  debugPrint(
    'TRANSACTION ID: $transactionId',
  );

  debugPrint(
    'PRODUCT ID: $productId',
  );

  if (mounted) {
    setState(() {
      _purchasing = true;
      _error = null;
    });
  }

  try {
    // ==========================================================
    // SEND TRANSACTION TO BACKEND
    // ==========================================================

    final response =
        await ApiService()
            .verifyAppleSubscription(
      transactionId,
    );

    debugPrint(
      'APPLE BACKEND RESPONSE: $response',
    );

    // ==========================================================
    // CHECK BACKEND RESPONSE
    // ==========================================================

    final bool success =
        response['success'] == true;

    if (!success) {
      debugPrint(
        'APPLE SUBSCRIPTION VERIFICATION FAILED',
      );

      if (!mounted) return;

      setState(() {
        _purchasing = false;
        _error =
            'We could not verify your Apple subscription.';
      });

      return;
    }

    // ==========================================================
    // VERIFIED
    // ==========================================================

    debugPrint(
      'APPLE SUBSCRIPTION VERIFIED',
    );

    debugPrint(
      'STATUS: ${response['status']}',
    );

    debugPrint(
      'PLAN: ${response['plan_type']}',
    );

    debugPrint(
      'PRODUCT: ${response['product_id']}',
    );

    debugPrint(
      'EXPIRATION: ${response['expiration_date']}',
    );

    if (!mounted) return;

    setState(() {
      _purchasing = false;
    });

    // Tell the previous screen that the subscription
    // was successfully verified by our backend.
    Navigator.of(context).pop(true);
  } catch (e) {
    debugPrint(
      'APPLE VERIFICATION ERROR: $e',
    );

    if (!mounted) return;

    setState(() {
      _purchasing = false;
      _error =
          'We could not verify your subscription. '
          'Please try again.';
    });
  }
}

  // ============================================================
  // PURCHASE ERROR
  // ============================================================

  void _onPurchaseError(
    String error,
  ) {
    debugPrint(
      'APPLE SCREEN: Purchase error: $error',
    );

    if (!mounted) return;

    setState(() {
      _purchasing = false;
      _error = error;
    });
  }

  // ============================================================
  // PURCHASE CANCELLED
  // ============================================================

  void _onPurchaseCancelled() {
    debugPrint(
      'APPLE SCREEN: Purchase cancelled',
    );

    if (!mounted) return;

    setState(() {
      _purchasing = false;
    });
  }

  // ============================================================
  // RESTORE
  // ============================================================

  Future<void> _restorePurchases() async {
    if (_purchasing) return;

    debugPrint(
      'APPLE SCREEN: Restore purchases',
    );

    setState(() {
      _purchasing = true;
      _error = null;
    });

    try {
      await _appleService.restorePurchases();
    } catch (e) {
      debugPrint(
        'APPLE RESTORE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _purchasing = false;
        _error =
            'Unable to restore purchases.';
      });
    }
  }

  // ============================================================
  // PLAN CARD
  // ============================================================

  Widget _buildPlan(
    ProductDetails product,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.description,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              product.price,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _purchasing
                    ? null
                    : () => _subscribe(product),
                child: _purchasing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Subscribe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium Subscription',
        ),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Choose your Premium plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Subscribe securely through Apple.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (_error != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: Text(
                        _error!,
                        textAlign:
                            TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),

                  Expanded(
                    child: _products.isEmpty
                        ? const Center(
                            child: Text(
                              'No subscription plans found.',
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                _products.length,
                            itemBuilder:
                                (context, index) {
                              return _buildPlan(
                                _products[index],
                              );
                            },
                          ),
                  ),

                  TextButton(
                    onPressed: _purchasing
                        ? null
                        : _restorePurchases,
                    child: const Text(
                      'Restore Purchases',
                    ),
                  ),

                  TextButton(
                    onPressed: _purchasing
                        ? null
                        : () {
                            Navigator.of(
                              context,
                            ).pop(false);
                          },
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                ],
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