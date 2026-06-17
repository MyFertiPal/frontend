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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
  try {
    await _initializeApp();

    final uri = Uri.base;
    final path = uri.path;

    if (path == '/reset-password') {
      final token = uri.queryParameters['token'];

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/reset-password',
          arguments: token,
        );
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 2800));

    if (mounted) {
      _navigateToWelcome();
    }
  } catch (e) {
    if (mounted) {
      _navigateToWelcome();
    }
  }
}

  Future<void> _initializeApp() async {
    try {
      final apiService = ApiService();
      final token = await apiService.getStoredToken();
      debugPrint('App initialized. Token exists: ${token != null}');
    } catch (e) {
      debugPrint('Init error: $e');
    }
  }

  void _navigateToWelcome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/welcome');
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