import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/api_service.dart';

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

  bool _isVerifying = false;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
              });
            }
          },

          onPageStarted: (url) {
            debugPrint(
              "SUBSCRIPTION WEBVIEW STARTED: $url",
            );

            _checkPaymentUrl(url);
          },

          onPageFinished: (url) {
            debugPrint(
              "SUBSCRIPTION WEBVIEW FINISHED: $url",
            );

            _checkPaymentUrl(url);
          },

          onNavigationRequest: (request) {
            debugPrint(
              "SUBSCRIPTION NAVIGATION: ${request.url}",
            );

            _checkPaymentUrl(request.url);

            return NavigationDecision.navigate;
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

  void _checkPaymentUrl(String url) {
    debugPrint(
      "CHECKING SUBSCRIPTION URL: $url",
    );

    // This is the callback URL configured
    // in your FastAPI backend.
    if (url.startsWith(
      'myfertipal://payment/success',
    )) {
      _verifySubscription();
    }
  }

  Future<void> _verifySubscription() async {
    if (_isVerifying) return;

    if (!mounted) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      debugPrint(
        "VERIFYING SUBSCRIPTION...",
      );

      debugPrint(
        "REFERENCE: ${widget.reference}",
      );

      final result =
          await ApiService().verifySubscription(
        reference: widget.reference,
      );

      debugPrint(
        "SUBSCRIPTION VERIFICATION RESULT: $result",
      );

      if (!mounted) return;

      final status = result['status']?.toString();
      final planType =
          result['plan_type']?.toString().toLowerCase();

      if (status == 'success' &&
          planType == 'premium') {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription could not be verified.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "VERIFY SUBSCRIPTION ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not verify your payment. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium Payment',
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),

          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
            ),

          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 18),
                        Text(
                          'Verifying your payment...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}