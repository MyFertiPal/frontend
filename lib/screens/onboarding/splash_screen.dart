import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2800));

      if (mounted) {
        _navigateToWelcome();
      }
    } catch (e) {
      debugPrint('Error during init: $e');
      if (mounted) {
        _navigateToWelcome();
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
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
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
                width: 140,
                height: 140,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Fertipath',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
