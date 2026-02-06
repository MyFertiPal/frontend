import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_web_plugins/flutter_web_plugins.dart";
import "package:provider/provider.dart";
// import "package:flutter_localizations/flutter_localizations.dart";
import "generated/l10n/app_localizations.dart";
import "config/fallback_localizations_delegate.dart";
import "providers/language_provider.dart";
import "screens/onboarding/splash_screen.dart";
import "screens/onboarding/welcome_screen.dart";
import "screens/onboarding/login_screen.dart";
import "screens/onboarding/registration_screen.dart";
import "screens/onboarding/profile_setup_screen.dart";
import "screens/onboarding/email_signup_screen.dart";
import "screens/onboarding/forget_password_flow.dart"
    show ForgotPasswordScreen, ResetPasswordScreen, PasswordUpdatedScreen;
import "screens/home_screen.dart";
import "services/auth_service.dart";
import "services/audio_service.dart";
import "services/notification_manager.dart";
import "theme/app_theme.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setPathUrlStrategy();
  }

  // Initialize notification system
  try {
    final notificationManager = NotificationManager();
    await notificationManager.initialize();
  } catch (e) {
    debugPrint('Failed to initialize notifications: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initDeepLinks();
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks!.getInitialAppLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) {
      debugPrint('Deep link init error: $e');
    }

    _linkSub = _appLinks!.uriLinkStream.listen(
      _handleIncomingUri,
      onError: (Object err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  void _handleIncomingUri(Uri uri) {
    if (uri.path == '/reset-password' || uri.path == '/reset_password') {
      final token = uri.queryParameters['token'];
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(prefilledToken: token),
          settings: const RouteSettings(name: '/reset-password'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider(create: (_) => AudioService()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: "Fertipath",
            navigatorKey: _navigatorKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              FallbackWidgetsLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              // Fallback to English if locale not supported
              if (locale == null) {
                return supportedLocales.first;
              }

              // Try to find exact match
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }

              // Try to find language match
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }

              // Default to English (first in supportedLocales)
              return supportedLocales.first;
            },
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Prevent gray screen during widget building
              return child ?? const SizedBox.shrink();
            },
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/signup-email': (context) => const EmailSignupScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/password-updated': (context) => const PasswordUpdatedScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
