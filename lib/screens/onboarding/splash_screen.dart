import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import 'forget_password_flow.dart' show ResetPasswordScreen;
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(
      screenName: 'splash',
      screenClass: 'SplashScreen',
    );

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Create a two-phase animation: zoom in (0-60%), then zoom out (60-100%)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
    ]).animate(_controller);

    _controller.forward();

    // Initialize and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Initialize API service
      await _initializeApp();

      if (_isResetPasswordLink()) {
        await Future.delayed(const Duration(milliseconds: 2800));
        if (mounted) {
          _navigateToResetPassword();
        }
        return;
      }

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2800));

      if (mounted) {
        _navigateToWelcome();
      }
    } catch (e) {
      debugPrint('Error during init: $e');
      if (mounted) {
        if (_isResetPasswordLink()) {
          _navigateToResetPassword();
        } else {
          _navigateToWelcome();
        }
      }
    }
  }

  void _navigateToWelcome() {
    if (!mounted) return;
    try {
      Navigator.of(context).pushReplacementNamed('/welcome');
    } catch (e) {
      debugPrint('Route navigation failed: $e, using direct navigation');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
            settings: const RouteSettings(name: '/welcome'),
          ),
        );
      }
    }
  }

  bool _isResetPasswordLink() {
    if (!kIsWeb) {
      return false;
    }

    final uri = Uri.base;
    final resolved = _resolveWebUri(uri);
    return resolved.path == '/reset_password' ||
        resolved.path == '/reset-password';
  }

  void _navigateToResetPassword() {
    if (!mounted) return;

    final resolved = _resolveWebUri(Uri.base);
    final token = resolved.queryParameters['token'];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(prefilledToken: token),
        settings: const RouteSettings(name: '/reset_password'),
      ),
    );
  }

  Uri _resolveWebUri(Uri uri) {
    if (uri.fragment.isEmpty) {
      return uri;
    }

    final fragment = uri.fragment;
    final normalized = fragment.startsWith('/') ? fragment : '/$fragment';
    return Uri.parse(normalized);
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize API service - this loads the token from SharedPreferences
      final apiService = ApiService();
      final token = await apiService.getStoredToken();
      debugPrint('App initialized. Token available: ${token != null}');
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use the provided app logo asset
              SizedBox(
                width: 240,
                height: 240,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
