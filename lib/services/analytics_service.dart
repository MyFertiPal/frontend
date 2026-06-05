import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static const String _eventAppOpen = 'app_open';
  static const String _eventScreenView = 'screen_view';
  static const String _eventLanguageSelected = 'language_selected';
  static const String _eventAgeRangeSelected = 'age_range_selected';
  static const String _eventLogin = 'login';
  static const String _eventSignUp = 'sign_up';
  static const String _eventSymptomsLogged = 'symptoms_logged';
  static const String _eventPeriodLogged = 'period_logged';
  static const String _eventArticleRead = 'article_read';
  static const String _eventArticleListened = 'article_listened';
  static const String _eventSupportQuoteRefreshed = 'support_quote_refreshed';
  static const String _eventSupportAudioListened = 'support_audio_listened';
  static const String _eventGroupCreated = 'group_created';
  static const String _eventPaymentPageViewed = 'payment_page_viewed';
  static const String _eventPayClicked = 'pay_clicked';
  static const String _eventOnboardingSkipped = 'onboarding_skipped';

  static const String _userPropertyPreferredLanguage = 'preferred_language';
  static const String _userPropertyAgeRange = 'age_range';

  /// Log a simple app-open event for diagnostics
  static Future<void> logAppOpen() async {
    try {
      await _analytics.logEvent(name: _eventAppOpen);
    } catch (e) {
      debugPrint('Failed to log app_open event: $e');
    }
  }

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logEvent(
        name: _eventScreenView,
        parameters: {
          'screen_name': screenName,
          if (screenClass != null) 'screen_class': screenClass,
        },
      );
    } catch (e) {
      debugPrint('Failed to log screen_view event: $e');
    }
  }

  static Future<void> logLanguageSelected(String languageCode) async {
    try {
      await _analytics.setUserProperty(
        name: _userPropertyPreferredLanguage,
        value: languageCode,
      );
      await _analytics.logEvent(
        name: _eventLanguageSelected,
        parameters: {'language_code': languageCode},
      );
    } catch (e) {
      debugPrint('Failed to log language_selected event: $e');
    }
  }

  static Future<void> logAgeRange(int age) async {
    final ageRange = _ageRangeFor(age);

    try {
      await _analytics.setUserProperty(
        name: _userPropertyAgeRange,
        value: ageRange,
      );
      await _analytics.logEvent(
        name: _eventAgeRangeSelected,
        parameters: {
          'age': age,
          'age_range': ageRange,
        },
      );
    } catch (e) {
      debugPrint('Failed to log age_range_selected event: $e');
    }
  }

  static Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logEvent(
        name: _eventLogin,
        parameters: {'method': method},
      );
    } catch (e) {
      debugPrint('Failed to log login event: $e');
    }
  }

  static Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logEvent(
        name: _eventSignUp,
        parameters: {'method': method},
      );
    } catch (e) {
      debugPrint('Failed to log sign_up event: $e');
    }
  }

  static Future<void> logSymptomsLogged({
    required int symptomCount,
    required List<String> symptoms,
    String? screenName,
  }) async {
    try {
      await _analytics.logEvent(
        name: _eventSymptomsLogged,
        parameters: {
          'symptom_count': symptomCount,
          'symptoms': symptoms.join('|'),
          if (screenName != null) 'screen_name': screenName,
        },
      );
    } catch (e) {
      debugPrint('Failed to log symptoms_logged event: $e');
    }
  }

  static Future<void> logPeriodLogged({
    required int periodLength,
    required int cycleLength,
    String? source,
  }) async {
    try {
      await _analytics.logEvent(
        name: _eventPeriodLogged,
        parameters: {
          'period_length': periodLength,
          'cycle_length': cycleLength,
          if (source != null) 'source': source,
        },
      );
    } catch (e) {
      debugPrint('Failed to log period_logged event: $e');
    }
  }

  static Future<void> logArticleRead({required String title}) async {
    try {
      await _analytics.logEvent(
        name: _eventArticleRead,
        parameters: {'title': title},
      );
    } catch (e) {
      debugPrint('Failed to log article_read event: $e');
    }
  }

  static Future<void> logArticleListened({required String title}) async {
    try {
      await _analytics.logEvent(
        name: _eventArticleListened,
        parameters: {'title': title},
      );
    } catch (e) {
      debugPrint('Failed to log article_listened event: $e');
    }
  }

  static Future<void> logSupportQuoteRefreshed() async {
    try {
      await _analytics.logEvent(name: _eventSupportQuoteRefreshed);
    } catch (e) {
      debugPrint('Failed to log support_quote_refreshed event: $e');
    }
  }

  static Future<void> logSupportAudioListened({required String source}) async {
    try {
      await _analytics.logEvent(
        name: _eventSupportAudioListened,
        parameters: {'source': source},
      );
    } catch (e) {
      debugPrint('Failed to log support_audio_listened event: $e');
    }
  }

  static Future<void> logGroupCreated() async {
    try {
      await _analytics.logEvent(name: _eventGroupCreated);
    } catch (e) {
      debugPrint('Failed to log group_created event: $e');
    }
  }

  static Future<void> logPaymentPageViewed() async {
    try {
      await _analytics.logEvent(name: _eventPaymentPageViewed);
    } catch (e) {
      debugPrint('Failed to log payment_page_viewed event: $e');
    }
  }

  static Future<void> logPayClicked({required String planName}) async {
    try {
      await _analytics.logEvent(
        name: _eventPayClicked,
        parameters: {'plan_name': planName},
      );
    } catch (e) {
      debugPrint('Failed to log pay_clicked event: $e');
    }
  }

  static Future<void> logOnboardingSkipped() async {
    try {
      await _analytics.logEvent(name: _eventOnboardingSkipped);
    } catch (e) {
      debugPrint('Failed to log onboarding_skipped event: $e');
    }
  }

  static String _ageRangeFor(int age) {
    if (age < 18) {
      return 'under_18';
    }
    if (age <= 24) {
      return '18_24';
    }
    if (age <= 34) {
      return '25_34';
    }
    if (age <= 44) {
      return '35_44';
    }
    if (age <= 54) {
      return '45_54';
    }
    if (age <= 64) {
      return '55_64';
    }
    return '65_plus';
  }

  /// Expose the underlying analytics instance if needed
  static FirebaseAnalytics get instance => _analytics;
}
