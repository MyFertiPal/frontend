import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/paystack_config.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _primaryColor = Color(0xFF0EA5A4);
  static const _accentColor = Color(0xFF0EA5A4);

  static const MethodChannel _channel = MethodChannel('paystack_android');
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializePaystack();
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment Plans',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a plan that fits you',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'Monthly',
              price: '# 2000',
              subtitle: 'Billed monthly',
              accent: _accentColor,
              onPressed: () => _startPayment(
                amountNaira: 2000,
                planName: 'Monthly',
              ),
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              title: 'Quarterly',
              price: '# 7600',
              subtitle: '5% discount',
              accent: _accentColor,
              onPressed: () => _startPayment(
                amountNaira: 7600,
                planName: 'Quarterly',
              ),
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              title: 'Yearly',
              price: '# 21,600',
              subtitle: '10% discount',
              accent: _accentColor,
              onPressed: () => _startPayment(
                amountNaira: 21600,
                planName: 'Yearly',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Plan Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              title: 'Free Plan',
              description: 'Basic tracking + limited content',
              borderColor: _accentColor,
            ),
            const SizedBox(height: 12),
            _buildPremiumCard(_primaryColor, _accentColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required Color accent,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0EA5A4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0EA5A4),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5A4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String description,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Color(0xFF0EA5A4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(Color primaryColor, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildBullet(
              'Unlimited audio (all audio languages) for fertility insights'),
          _buildBullet('Multi-language and audio-based educational hub'),
          _buildBullet('Virtual consultations'),
          _buildBullet('Access to verified fertility clinics'),
          _buildBullet('Free referrals'),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF0EA5A4),
              fontFamily: 'Poppins',
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializePaystack() async {
    if (PaystackConfig.publicKey.isEmpty) {
      return;
    }

    if (!_isAndroid) {
      return;
    }

    try {
      final response = await _channel.invokeMethod<bool>('initialize', {
        'publicKey': PaystackConfig.publicKey,
      });
      if (mounted) {
        setState(() {
          _isInitialized = response == true;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Paystack init error: ${e.message}');
    }
  }

  Future<void> _startPayment({
    required int amountNaira,
    required String planName,
  }) async {
    if (!_isAndroid) {
      _showMessage('Paystack Android SDK is only available on Android.');
      return;
    }

    if (PaystackConfig.publicKey.isEmpty) {
      _showMessage('Missing Paystack public key.');
      return;
    }

    if (!_isInitialized) {
      await _initializePaystack();
      if (!_isInitialized) {
        _showMessage('Paystack SDK failed to initialize.');
        return;
      }
    }

    final details = await _promptPaymentDetails(planName, amountNaira);
    if (details == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await _channel.invokeMethod<Map>('chargeCard', details);
      final status = response?['status']?.toString();
      final message = response?['message']?.toString();
      if (status == 'success') {
        _showMessage('Payment successful for $planName plan.');
      } else if (status == 'pending') {
        _showMessage('Payment is processing.');
      } else {
        _showMessage(message ?? 'Payment failed.');
      }
    } catch (e) {
      _showMessage('Payment failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _promptPaymentDetails(
    String planName,
    int amountNaira,
  ) async {
    final accessCodeController = TextEditingController();
    final cardNumberController = TextEditingController();
    final cvcController = TextEditingController();
    final expMonthController = TextEditingController();
    final expYearController = TextEditingController();
    final emailController = TextEditingController(
      text: PaystackConfig.fallbackEmail,
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter card details for $planName (# $amountNaira). Access code is optional for demos.',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accessCodeController,
                decoration: const InputDecoration(
                  labelText: 'Access code',
                  hintText: 'e.g. 2ksqdeqqlbpqg24',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  hintText: '4084 0840 8408 4081',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expMonthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Exp month',
                        hintText: 'MM',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: expYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Exp year',
                        hintText: 'YY',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cvcController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        hintText: '123',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final expMonth = int.tryParse(expMonthController.text.trim());
                final expYear = int.tryParse(expYearController.text.trim());
                if (expMonth == null || expYear == null) {
                  Navigator.of(context).pop();
                  _showMessage('Expiry date is required.');
                  return;
                }

                Navigator.of(context).pop({
                  'accessCode': accessCodeController.text.trim(),
                  'cardNumber':
                      cardNumberController.text.trim().replaceAll(' ', ''),
                  'cvc': cvcController.text.trim(),
                  'expMonth': expMonth,
                  'expYear': expYear,
                  'email': emailController.text.trim(),
                  'amountKobo': amountNaira * 100,
                  'currency': 'NGN',
                  'reference': _buildReference(planName),
                });
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) return null;
    return result;
  }

  String _buildReference(String planName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fertipath_${planName.toLowerCase()}_$timestamp';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
