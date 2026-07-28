import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;


  // Events
  static const String _eventAppOpen = 'app_open';
  static const String _eventLanguageSelected = 'language_selected';
  static const String _eventAgeRangeSelected = 'age_range_selected';

  static const String _eventLogin = 'login_completed';
  static const String _eventSignUp = 'signup_completed';

  static const String _eventSymptomsLogged = 'symptoms_logged';
  static const String _eventPeriodLogged = 'period_logged';

  static const String _eventArticleOpened = 'article_opened';
  static const String _eventArticleListened = 'article_audio_played';

  static const String _eventSupportQuoteRefreshed =
      'support_quote_refreshed';

  static const String _eventSupportAudioListened =
      'support_audio_played';

  static const String _eventGroupCreated =
      'group_created';

  static const String _eventPaymentPageViewed =
      'payment_page_viewed';

  static const String _eventPayClicked =
      'payment_started';

  static const String _eventSubscriptionCompleted =
      'subscription_completed';

  static const String _eventOnboardingSkipped =
      'onboarding_skipped';

  static const String _eventCalendarViewed =
      'calendar_viewed';

  static const String _eventFertileWindowViewed =
      'fertile_window_viewed';

  static const String _eventReminderEnabled =
      'reminder_enabled';


  // User properties

  static const String _propertyPreferredLanguage =
      'preferred_language';

  static const String _propertyAppLanguage =
      'app_language';

  static const String _propertyAgeRange =
      'age_range';



  /// Generic event
  /// 
  static Future<void> logCustomEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {

    try {

      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );

    } catch(e){

      debugPrint(
        "Analytics event error $name: $e"
      );

    }

  }




  /// App opened
  static Future<void> logAppOpen() async {

    try {

      await _analytics.logEvent(
        name: _eventAppOpen,
      );

    } catch(e){

      debugPrint(
        "App open analytics error: $e"
      );

    }

  }




  /// Correct Firebase screen tracking
  static Future<void> logScreenView({

    required String screenName,

    String? screenClass,

  }) async {


    try {


      await _analytics.logScreenView(

        screenName: screenName,

        screenClass:
            screenClass ?? screenName,

      );


    } catch(e){

      debugPrint(
        "Screen analytics error: $e"
      );

    }

  }




  /// Set app language
  static Future<void> setAppLanguage(
      String languageCode) async {

    try {

      await _analytics.setUserProperty(

        name: _propertyAppLanguage,

        value: languageCode,

      );


    } catch(e){

      debugPrint(
        "Language property error: $e"
      );

    }

  }




  /// Language selected by user
  static Future<void> logLanguageSelected(
      String languageCode) async {


    try {


      await _analytics.setUserProperty(

        name: _propertyPreferredLanguage,

        value: languageCode,

      );


      await _analytics.logEvent(

        name: _eventLanguageSelected,

        parameters: {

          'language_code':
              languageCode,

        },

      );


      await setAppLanguage(languageCode);



    } catch(e){

      debugPrint(
        "Language analytics error: $e"
      );

    }

  }





  /// Age range
  static Future<void> logAgeRange(
      int age) async {


    final range = _ageRangeFor(age);


    try {


      await _analytics.setUserProperty(

        name: _propertyAgeRange,

        value: range,

      );


      await _analytics.logEvent(

        name: _eventAgeRangeSelected,

        parameters: {

          'age_range':range,

        },

      );


    } catch(e){

      debugPrint(
        "Age analytics error: $e"
      );

    }

  }
static Future<void> logLogin({
  required String method,
}) async {
  try {
    await _analytics.logEvent(
      name: _eventLogin,
      parameters: {
        'method': method,
      },
    );
  } catch (e) {
    debugPrint(
      'Login analytics error: $e',
    );
  }
}




  static Future<void> logSignUp({
    required String method,
  }) async {


    await _analytics.logEvent(

      name:_eventSignUp,

      parameters:{

        'method':method,

      },

    );

  }





  static Future<void> logPeriodLogged({
  required int cycleLength,
  required int periodLength,
  String? source,
}) async {
  try {
    await _analytics.logEvent(
      name: _eventPeriodLogged,
      parameters: {
        'cycle_length': cycleLength,
        'period_length': periodLength,
        if (source != null) 'source': source,
      },
    );
  } catch (e) {
    debugPrint(
      'Failed to log period_logged event: $e',
    );
  }
}
  static Future<void> logSymptomsLogged({

    required int symptomCount,

  }) async {


    await _analytics.logEvent(

      name:_eventSymptomsLogged,

      parameters:{

        'symptom_count':symptomCount,

      },

    );


  }





  static Future<void> logArticleOpened({

    required String articleId,

    required String category,

  }) async {


    await _analytics.logEvent(

      name:_eventArticleOpened,

      parameters:{

        'article_id':articleId,

        'category':category,

      },

    );


  }





  static Future<void> logArticleListened({

    required String articleId,

  }) async {


    await _analytics.logEvent(

      name:_eventArticleListened,

      parameters:{

        'article_id':articleId,

      },

    );


  }





  static Future<void> logCalendarViewed() async {

    await _analytics.logEvent(

      name:_eventCalendarViewed,

    );

  }





  static Future<void> logFertileWindowViewed() async {

    await _analytics.logEvent(

      name:_eventFertileWindowViewed,

    );

  }





  static Future<void> logReminderEnabled() async {

    await _analytics.logEvent(

      name:_eventReminderEnabled,

    );

  }





  static Future<void> logSupportQuoteRefreshed() async {

    await _analytics.logEvent(

      name:_eventSupportQuoteRefreshed,

    );

  }





  static Future<void> logSupportAudioListened(
      String source) async {


    await _analytics.logEvent(

      name:_eventSupportAudioListened,

      parameters:{

        'source':source,

      },

    );

  }





  static Future<void> logGroupCreated() async {

    await _analytics.logEvent(

      name:_eventGroupCreated,

    );

  }





  static Future<void> logPaymentPageViewed() async {

    await _analytics.logEvent(

      name:_eventPaymentPageViewed,

    );

  }





  static Future<void> logPayClicked(
      String planName) async {


    await _analytics.logEvent(

      name:_eventPayClicked,

      parameters:{

        'plan_name':planName,

      },

    );

  }





  static Future<void> logSubscriptionCompleted(
      String planName) async {


    await _analytics.logEvent(

      name:_eventSubscriptionCompleted,

      parameters:{

        'plan_name':planName,

      },

    );

  }





  static Future<void> logOnboardingSkipped() async {

    await _analytics.logEvent(

      name:_eventOnboardingSkipped,

    );

  }




  static Future<void> setUserId(
  Object userId,
) async {
  try {
    await _analytics.setUserId(
      id: userId.toString(),
    );
  } catch (e) {
    debugPrint(
      'Analytics user id error: $e',
    );
  }
}


  static String _ageRangeFor(int age){

    if(age < 18){
      return 'under_18';
    }

    if(age <=24){
      return '18_24';
    }

    if(age <=34){
      return '25_34';
    }

    if(age <=44){
      return '35_44';
    }

    if(age <=54){
      return '45_54';
    }

    if(age <=64){
      return '55_64';
    }

    return '65_plus';

  }



  static FirebaseAnalytics get instance =>
      _analytics;

}