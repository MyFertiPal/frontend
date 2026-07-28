import "dart:async";
import "package:app_links/app_links.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';
import "package:provider/provider.dart";

import "generated/l10n/app_localizations.dart";
import "config/fallback_localizations_delegate.dart";
import "providers/language_provider.dart";

import "screens/onboarding/splash_screen.dart";
import "screens/root_screen.dart";
import "screens/onboarding/welcome_screen.dart";
import "screens/onboarding/login_screen.dart";
import "screens/onboarding/registration_screen.dart";
import "screens/onboarding/profile_setup_screen.dart";
import "screens/onboarding/email_signup_screen.dart";
import "screens/profile/profile_screen.dart";

import "screens/onboarding/forget_password_flow.dart"
    show ForgotPasswordScreen, ResetPasswordScreen, PasswordUpdatedScreen;

import "screens/privacy_and_security/delete_account_screen.dart";

import "services/auth_service.dart";
import "services/audio_service.dart";
import "services/notification_manager.dart";
import "theme/app_theme.dart";
import "utils/url_strategy.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AnalyticsService.logAppOpen();
}
   
    } catch (e) {
      debugPrint('Analytics log failed: $e');
    }
 

  if (kIsWeb) {
    setAppUrlStrategy();
  }

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
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks!.getInitialLink();

      if (initialUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleIncomingUri(initialUri);
        });
      }
    } catch (e) {
      debugPrint('Initial deep link error: $e');
    }

    _linkSub = _appLinks!.uriLinkStream.listen(
      _handleIncomingUri,
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleIncomingUri(Uri uri) async {
    debugPrint('Incoming URI: $uri');

    // -------------------------
    // OAuth LOGIN FLOW
    // -------------------------
    if (uri.scheme == 'myfertipal' && uri.host == 'auth') {
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }

        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
      return;
    }

    // -------------------------
    // RESET PASSWORD FLOW
    // -------------------------
    final token = uri.queryParameters['token'];

    if (uri.path == '/reset-password' && token != null) {
      _navigatorKey.currentState?.pushNamed(
        '/reset-password',
        arguments: token,
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
            title: "MyFertiPal",
            navigatorKey: _navigatorKey,

           onGenerateRoute: (settings) {
  final name = settings.name ?? '';

  final uri = Uri.parse(name);

  final path = uri.path;

  if (path == '/reset-password') {
    final token = uri.queryParameters['token'];

    return MaterialPageRoute(
      builder: (_) => ResetPasswordScreen(token: token),
    );
  }

  return null; // IMPORTANT: let routes table handle others
},

            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              FallbackWidgetsLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
            ],

            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,

            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return supportedLocales.first;

              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }

              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }

              return supportedLocales.first;
            },

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            initialRoute: '/',
navigatorObservers: kIsWeb
    ? []
    : [
        FirebaseAnalyticsObserver(
          analytics: AnalyticsService.instance,
        ),
      ],

            debugShowCheckedModeBanner: false,

            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
        
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/login-new': (context) => const LoginScreen(forceProfileSetup: true),
              '/register': (context) => const RegistrationScreen(),
              '/signup-email': (context) => const EmailSignupScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/reset-password': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return ResetPasswordScreen(token: args as String?);
              },
              '/password-updated': (context) => const PasswordUpdatedScreen(),
              '/delete-account': (context) => const DeleteAccountScreen(),
              '/profile': (context) => ProfileScreen(
                 name: "MyFertiPal User",
  privacyPolicyUrl: "https://myfertipal.com/privacy-policy",
),
              '/home': (context) => const RootScreen(),
            },
          );
        },
      ),
    );
  }
}