import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AppleSubscriptionService {
  // ============================================================
  // PLACEHOLDER APPLE PRODUCT IDS
  // ============================================================
  //
  // Replace these later with the EXACT product IDs from
  // App Store Connect.
  //
 static const String monthlyProductId =
    'com.myfertipal.premium.monthly';

static const Set<String> productIds = {
  monthlyProductId,
};

  // ============================================================
  // IN-APP PURCHASE INSTANCE
  // ============================================================

  final InAppPurchase _inAppPurchase =
      InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>?
      _purchaseSubscription;

  // ============================================================
  // CALLBACKS
  // ============================================================

  /// Called when a purchase has been successfully completed
  /// and we have the Apple transaction ID.
 Future<void> Function(
  String transactionId,
  String productId,
)?
    onPurchaseSuccess;

  /// Called when the purchase fails.
  Function(String error)?
      onPurchaseError;

  /// Called when the user cancels the purchase.
  VoidCallback?
      onPurchaseCancelled;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<bool> initialize() async {
    if (!Platform.isIOS) {
      debugPrint(
        'APPLE IAP: Not running on iOS.',
      );

      return false;
    }

    final bool available =
        await _inAppPurchase.isAvailable();

    debugPrint(
      'APPLE IAP AVAILABLE: $available',
    );

    if (!available) {
      return false;
    }

    // Listen for Apple purchase updates.
    _purchaseSubscription =
        _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        debugPrint(
          'APPLE IAP PURCHASE STREAM CLOSED',
        );
      },
      onError: (error) {
        debugPrint(
          'APPLE IAP STREAM ERROR: $error',
        );
      },
    );

    return true;
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<List<ProductDetails>> loadProducts() async {
    if (!Platform.isIOS) {
      return [];
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(
      productIds,
    );

    if (response.error != null) {
      debugPrint(
        'APPLE IAP PRODUCT ERROR: '
        '${response.error}',
      );

      return [];
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'APPLE IAP PRODUCTS NOT FOUND: '
        '${response.notFoundIDs}',
      );
    }

    debugPrint(
      'APPLE IAP PRODUCTS FOUND: '
      '${response.productDetails.length}',
    );

    for (final product in response.productDetails) {
      debugPrint(
        'APPLE PRODUCT: '
        '${product.id} | '
        '${product.title} | '
        '${product.price}',
      );
    }

    return response.productDetails;
  }

  // ============================================================
  // PURCHASE SUBSCRIPTION
  // ============================================================

  Future<bool> purchaseSubscription(
    ProductDetails product,
  ) async {
    if (!Platform.isIOS) {
      debugPrint(
        'APPLE IAP: Purchase attempted on non-iOS.',
      );

      return false;
    }

    debugPrint(
      'APPLE IAP STARTING PURCHASE: '
      '${product.id}',
    );

    final PurchaseParam purchaseParam =
        PurchaseParam(
      productDetails: product,
    );

    return _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  // ============================================================
  // HANDLE PURCHASE UPDATES
  // ============================================================

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final PurchaseDetails purchase
        in purchases) {
      debugPrint(
        'APPLE PURCHASE UPDATE: '
        '${purchase.productID}',
      );

      debugPrint(
        'APPLE PURCHASE STATUS: '
        '${purchase.status}',
      );

      debugPrint(
        'APPLE PURCHASE ID: '
        '${purchase.purchaseID}',
      );

      // --------------------------------------------------------
      // PURCHASED
      // --------------------------------------------------------

      if (purchase.status ==
          PurchaseStatus.purchased) {
        final String? transactionId =
            purchase.purchaseID;

        if (transactionId != null &&
            transactionId.isNotEmpty) {
          debugPrint(
            'APPLE PURCHASE SUCCESS',
          );

          debugPrint(
            'APPLE TRANSACTION ID: '
            '$transactionId',
          );

          onPurchaseSuccess?.call(
            transactionId,
            purchase.productID,
          );
        } else {
          debugPrint(
            'APPLE PURCHASE HAS NO TRANSACTION ID',
          );

          onPurchaseError?.call(
            'Apple purchase did not return a transaction ID.',
          );
        }
      }

      // --------------------------------------------------------
      // RESTORED
      // --------------------------------------------------------

      else if (purchase.status ==
          PurchaseStatus.restored) {
        final String? transactionId =
            purchase.purchaseID;

        if (transactionId != null &&
            transactionId.isNotEmpty) {
          debugPrint(
            'APPLE PURCHASE RESTORED',
          );

          onPurchaseSuccess?.call(
            transactionId,
            purchase.productID,
          );
        }
      }

      // --------------------------------------------------------
      // ERROR
      // --------------------------------------------------------

      else if (purchase.status ==
          PurchaseStatus.error) {
        debugPrint(
          'APPLE PURCHASE ERROR: '
          '${purchase.error}',
        );

        onPurchaseError?.call(
          purchase.error?.message ??
              'Apple purchase failed.',
        );
      }

      // --------------------------------------------------------
      // CANCELLED
      // --------------------------------------------------------

      else if (purchase.status ==
          PurchaseStatus.canceled) {
        debugPrint(
          'APPLE PURCHASE CANCELLED',
        );

        onPurchaseCancelled?.call();
      }

      // --------------------------------------------------------
      // COMPLETE TRANSACTION
      // --------------------------------------------------------

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(
          purchase,
        );

        debugPrint(
          'APPLE PURCHASE COMPLETED',
        );
      }
    }
  }

  // ============================================================
  // RESTORE PURCHASES
  // ============================================================

  Future<void> restorePurchases() async {
    if (!Platform.isIOS) {
      return;
    }

    debugPrint(
      'APPLE IAP RESTORING PURCHASES...',
    );

    await _inAppPurchase.restorePurchases();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();

    _purchaseSubscription = null;
  }
}