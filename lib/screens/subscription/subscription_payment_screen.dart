import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String reference;

  const SubscriptionPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.reference,
  });

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends State<SubscriptionPaymentScreen> {
  late final WebViewController _controller;

  bool _pageLoading = true;

  @override
  void initState() {
    super.initState();

    debugPrint(
      "SUBSCRIPTION PAYMENT URL: ${widget.paymentUrl}",
    );

    debugPrint(
      "SUBSCRIPTION REFERENCE: ${widget.reference}",
    );

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            debugPrint(
              "SUBSCRIPTION PAYMENT NAVIGATION URL: $url",
            );

            // --------------------------------------------------
            // PAYMENT CALLBACK
            // --------------------------------------------------

            if (url.startsWith(
                  "https://teamnexuss.netlify.app/booking/payment-callback",
                ) ||
                url.startsWith(
                  "myfertipal://payment/success",
                )) {
              debugPrint(
                "SUBSCRIPTION PAYMENT CALLBACK DETECTED",
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
              "SUBSCRIPTION PAGE STARTED: $url",
            );

            if (mounted) {
              setState(() {
                _pageLoading = true;
              });
            }
          },

          onPageFinished: (url) {
            debugPrint(
              "SUBSCRIPTION PAGE FINISHED: $url",
            );

            if (mounted) {
              setState(() {
                _pageLoading = false;
              });
            }
          },

          onWebResourceError: (error) {
            debugPrint(
              "SUBSCRIPTION WEBVIEW ERROR: "
              "${error.description}",
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Premium Payment",
        ),
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
                    debugPrint(
                      "USER CONFIRMED SUBSCRIPTION PAYMENT",
                    );

                    Navigator.of(context).pop(true);
                  },
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
                    Navigator.of(context).pop(false);
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