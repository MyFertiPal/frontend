import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_ig.dart';
import 'app_localizations_pcm.dart';
import 'app_localizations_yo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ha'),
    Locale('ig'),
    Locale('pcm'),
    Locale('yo')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertipath'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Fertility Tracking Journey'**
  String get appSubtitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeToJourney.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Journey'**
  String get welcomeToJourney;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneHint;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(Object field);

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase, lowercase, and number'**
  String get passwordStrength;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @firstAndLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter first and last name'**
  String get firstAndLastName;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @validPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validPhoneNumber;

  /// No description provided for @cycleSummary.
  ///
  /// In en, this message translates to:
  /// **'Cycle Summary'**
  String get cycleSummary;

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get fertileWindow;

  /// No description provided for @ovulationDay.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Day'**
  String get ovulationDay;

  /// No description provided for @fertilityCountdown.
  ///
  /// In en, this message translates to:
  /// **'Fertility Countdown'**
  String get fertilityCountdown;

  /// No description provided for @daysUntilFertile.
  ///
  /// In en, this message translates to:
  /// **'{days} days until fertile window'**
  String daysUntilFertile(Object days);

  /// No description provided for @dayUntilFertile.
  ///
  /// In en, this message translates to:
  /// **'{day} day until fertile window'**
  String dayUntilFertile(Object day);

  /// No description provided for @inFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'🌟 You\'re in your fertile window now!'**
  String get inFertileWindow;

  /// No description provided for @logCycleSee.
  ///
  /// In en, this message translates to:
  /// **'Log your cycle to see countdown'**
  String get logCycleSee;

  /// No description provided for @fertilityStatus.
  ///
  /// In en, this message translates to:
  /// **'Fertility Status'**
  String get fertilityStatus;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get educational;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms'**
  String get logSymptoms;

  /// No description provided for @trackCycle.
  ///
  /// In en, this message translates to:
  /// **'Track Cycle'**
  String get trackCycle;

  /// No description provided for @viewInsights.
  ///
  /// In en, this message translates to:
  /// **'View Insights'**
  String get viewInsights;

  /// No description provided for @readArticles.
  ///
  /// In en, this message translates to:
  /// **'Read Articles'**
  String get readArticles;

  /// No description provided for @getSupport.
  ///
  /// In en, this message translates to:
  /// **'Get Support'**
  String get getSupport;

  /// No description provided for @educationalHub.
  ///
  /// In en, this message translates to:
  /// **'Educational Hub'**
  String get educationalHub;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @readArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Article'**
  String get readArticle;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudio;

  /// No description provided for @fertilityBasics.
  ///
  /// In en, this message translates to:
  /// **'Fertility Basics'**
  String get fertilityBasics;

  /// No description provided for @mythsAndFacts.
  ///
  /// In en, this message translates to:
  /// **'Myths & Facts'**
  String get mythsAndFacts;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @loadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Loading audio...'**
  String get loadingAudio;

  /// No description provided for @failedLoadAudio.
  ///
  /// In en, this message translates to:
  /// **'Failed to load audio. Please try again.'**
  String get failedLoadAudio;

  /// No description provided for @playbackError.
  ///
  /// In en, this message translates to:
  /// **'Playback error. Please try again.'**
  String get playbackError;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String aboutApp(Object appName);

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'Language selected'**
  String get languageSelected;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Set Up Profile'**
  String get setupProfile;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @cycleInfo.
  ///
  /// In en, this message translates to:
  /// **'Cycle Information'**
  String get cycleInfo;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get cycleLength;

  /// No description provided for @periodLength.
  ///
  /// In en, this message translates to:
  /// **'Period Length'**
  String get periodLength;

  /// No description provided for @ttcHistory.
  ///
  /// In en, this message translates to:
  /// **'TTC History'**
  String get ttcHistory;

  /// No description provided for @supportFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support Feedback'**
  String get supportFeedback;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contactSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Need help or have questions? Send us an email and we\'ll get back to you as soon as possible.'**
  String get contactSupportMessage;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Period Day'**
  String get periodDay;

  /// No description provided for @logPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log Period'**
  String get logPeriod;

  /// No description provided for @selectDates.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get selectDates;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @minsRead.
  ///
  /// In en, this message translates to:
  /// **'5 mins read'**
  String get minsRead;

  /// No description provided for @genderPredictions.
  ///
  /// In en, this message translates to:
  /// **'Gender Predictions'**
  String get genderPredictions;

  /// No description provided for @findSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Find Specialist'**
  String get findSpecialist;

  /// No description provided for @chatWithSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Chat with Specialist'**
  String get chatWithSpecialist;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettings;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @faithPreference.
  ///
  /// In en, this message translates to:
  /// **'Faith Preference'**
  String get faithPreference;

  /// No description provided for @lastPeriodDate.
  ///
  /// In en, this message translates to:
  /// **'Last Period Date'**
  String get lastPeriodDate;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @preference.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get preference;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @dataPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy Policy'**
  String get dataPrivacyPolicy;

  /// No description provided for @manageDataPermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Data & Permissions'**
  String get manageDataPermissions;

  /// No description provided for @exploreMyData.
  ///
  /// In en, this message translates to:
  /// **'Explore my Data'**
  String get exploreMyData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Once you delete your account, there is no going back. This action is permanent and cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get deleteAccountFailed;

  /// No description provided for @supportHub.
  ///
  /// In en, this message translates to:
  /// **'Support hub'**
  String get supportHub;

  /// No description provided for @supportHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mental health support and daily affirmations'**
  String get supportHubSubtitle;

  /// No description provided for @dailyAffirmation.
  ///
  /// In en, this message translates to:
  /// **'Daily affirmation'**
  String get dailyAffirmation;

  /// No description provided for @audioEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Audio encouragement'**
  String get audioEncouragement;

  /// No description provided for @audioTitle.
  ///
  /// In en, this message translates to:
  /// **'My Sister, Hold your Head High'**
  String get audioTitle;

  /// No description provided for @culturalGuidance.
  ///
  /// In en, this message translates to:
  /// **'Cultural Guidance'**
  String get culturalGuidance;

  /// No description provided for @culturalGuidanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Coping with family pressure and finding peace in community support. Explore recommended readings and groups.'**
  String get culturalGuidanceDescription;

  /// No description provided for @communityGroups.
  ///
  /// In en, this message translates to:
  /// **'Community groups'**
  String get communityGroups;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @fertilityCircle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Circle'**
  String get fertilityCircle;

  /// No description provided for @generalSupport.
  ///
  /// In en, this message translates to:
  /// **'General Support'**
  String get generalSupport;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @latestMessage.
  ///
  /// In en, this message translates to:
  /// **'Sarah: Thank you all for the support!'**
  String get latestMessage;

  /// No description provided for @exploreCommunityGroups.
  ///
  /// In en, this message translates to:
  /// **'Explore Community Groups'**
  String get exploreCommunityGroups;

  /// No description provided for @groupChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group chat coming soon'**
  String get groupChatComingSoon;

  /// No description provided for @howToUseFertipath.
  ///
  /// In en, this message translates to:
  /// **'How to Use Fertipath'**
  String get howToUseFertipath;

  /// No description provided for @welcomeToFertipath.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fertipath!'**
  String get welcomeToFertipath;

  /// No description provided for @guideIntro.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to get the best results from our fertility tracking features.'**
  String get guideIntro;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get step1Title;

  /// No description provided for @step1Description.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → Settings to enter your cycle length, period length, and faith preference. Accurate data helps us provide better predictions.'**
  String get step1Description;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Period'**
  String get step2Title;

  /// No description provided for @step2Description.
  ///
  /// In en, this message translates to:
  /// **'Tap the Calendar tab and select the days you\'re on your period. This helps us predict your next cycle, fertile window, and ovulation day.'**
  String get step2Description;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Log Daily Symptoms'**
  String get step3Title;

  /// No description provided for @step3Description.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Log Symptoms\" button to record mood, cervical mucus, basal body temperature, and other symptoms. This improves prediction accuracy.'**
  String get step3Description;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Check Your Insights'**
  String get step4Title;

  /// No description provided for @step4Description.
  ///
  /// In en, this message translates to:
  /// **'Your home screen shows daily fertility insights based on your data. Review fertile days, ovulation predictions, and cycle summaries.'**
  String get step4Description;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'Listen to Audio Content'**
  String get step5Title;

  /// No description provided for @step5Description.
  ///
  /// In en, this message translates to:
  /// **'Explore the Educational Hub for articles and audio lessons. Use the speed controls (0.75x - 2x) to adjust playback to your preference.'**
  String get step5Description;

  /// No description provided for @step6Title.
  ///
  /// In en, this message translates to:
  /// **'Get Mental Health Support'**
  String get step6Title;

  /// No description provided for @step6Description.
  ///
  /// In en, this message translates to:
  /// **'Visit the Support tab for faith-based affirmations and resources. Choose your faith preference in settings for personalized content.'**
  String get step6Description;

  /// No description provided for @step7Title.
  ///
  /// In en, this message translates to:
  /// **'Review Predictions'**
  String get step7Title;

  /// No description provided for @step7Description.
  ///
  /// In en, this message translates to:
  /// **'Your calendar marks predicted next period days with red outlined circles. Past periods appear as filled red circles.'**
  String get step7Description;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get proTips;

  /// No description provided for @proTipsContent.
  ///
  /// In en, this message translates to:
  /// **'• Log symptoms daily for 2-3 cycles to get the most accurate predictions\n\n• Update your period dates as soon as your cycle starts\n\n• Check your fertile window to plan or avoid conception\n\n• Use audio content at 1.25x or 1.5x speed to learn faster\n\n• Enable notifications to get reminders for symptom logging'**
  String get proTipsContent;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @needHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If you have questions or encounter issues, visit the Support tab or check the Educational Hub for detailed guides on fertility tracking.'**
  String get needHelpContent;

  /// No description provided for @loggedSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Logged Symptoms'**
  String get loggedSymptoms;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noSymptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged yet.'**
  String get noSymptomsLogged;

  /// No description provided for @calendarCleared.
  ///
  /// In en, this message translates to:
  /// **'Calendar and next period days cleared.'**
  String get calendarCleared;

  /// No description provided for @failedToClearCalendar.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear calendar days'**
  String get failedToClearCalendar;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @bleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get bleeding;

  /// No description provided for @cervicalMucus.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get cervicalMucus;

  /// No description provided for @sexualActivity.
  ///
  /// In en, this message translates to:
  /// **'Sexual Activity'**
  String get sexualActivity;

  /// No description provided for @pain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get pain;

  /// No description provided for @abdominalCramps.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Cramps'**
  String get abdominalCramps;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @anxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get anxiety;

  /// No description provided for @moodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get moodSwings;

  /// No description provided for @sadness.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get sadness;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @spotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get spotting;

  /// No description provided for @dry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get dry;

  /// No description provided for @sticky.
  ///
  /// In en, this message translates to:
  /// **'Sticky'**
  String get sticky;

  /// No description provided for @creamy.
  ///
  /// In en, this message translates to:
  /// **'Creamy'**
  String get creamy;

  /// No description provided for @watery.
  ///
  /// In en, this message translates to:
  /// **'Watery'**
  String get watery;

  /// No description provided for @eggWhite.
  ///
  /// In en, this message translates to:
  /// **'Egg white'**
  String get eggWhite;

  /// No description provided for @protected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected;

  /// No description provided for @unprotected.
  ///
  /// In en, this message translates to:
  /// **'Unprotected'**
  String get unprotected;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @selectSymptom.
  ///
  /// In en, this message translates to:
  /// **'Select symptom'**
  String get selectSymptom;

  /// No description provided for @selectAtLeastOneSymptom.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one symptom'**
  String get selectAtLeastOneSymptom;

  /// No description provided for @symptomsLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Symptoms logged successfully!'**
  String get symptomsLoggedSuccessfully;

  /// No description provided for @failedToSaveSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Failed to save symptoms'**
  String get failedToSaveSymptoms;

  /// No description provided for @noSymptomsSelected.
  ///
  /// In en, this message translates to:
  /// **'No symptoms selected yet. Tap a symptom to begin.'**
  String get noSymptomsSelected;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Language'**
  String get selectPreferredLanguage;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get pleaseSelectLanguage;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @trackYourCycle.
  ///
  /// In en, this message translates to:
  /// **'Track your Cycle'**
  String get trackYourCycle;

  /// No description provided for @trackYourCycleDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor your cycle with ease and get personalised insight'**
  String get trackYourCycleDesc;

  /// No description provided for @learnInYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learn in your own language'**
  String get learnInYourLanguage;

  /// No description provided for @learnInYourLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Access fertility education and resources in the language you understand best'**
  String get learnInYourLanguageDesc;

  /// No description provided for @feelSupported.
  ///
  /// In en, this message translates to:
  /// **'Feel supported'**
  String get feelSupported;

  /// No description provided for @feelSupportedDesc.
  ///
  /// In en, this message translates to:
  /// **'Join a caring community and get the support you need on your journey'**
  String get feelSupportedDesc;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password.'**
  String get forgetPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Facebook'**
  String get signInWithFacebook;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @sendingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get sendingVerificationCode;

  /// No description provided for @failedToSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failedToSendVerificationCode;

  /// No description provided for @sendPasswordResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send password reset link'**
  String get sendPasswordResetLink;

  /// No description provided for @enterYourAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we\'ll send you a link to reset your password.'**
  String get enterYourAccountEmail;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a password reset link. Click the button in the email to reset your password.'**
  String get resetLinkSent;

  /// No description provided for @checkSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'📧 Don\'t forget to check your spam folder'**
  String get checkSpamFolder;

  /// No description provided for @didntReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Resend'**
  String get didntReceiveEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordAtLeast6;

  /// No description provided for @invalidOrMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid or missing token.'**
  String get invalidOrMissingToken;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password.'**
  String get failedToResetPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password Updated'**
  String get passwordUpdated;

  /// No description provided for @passwordSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated. You can now log in with your new credentials.'**
  String get passwordSuccessfully;

  /// No description provided for @mythsFacts.
  ///
  /// In en, this message translates to:
  /// **'Myths & Facts'**
  String get mythsFacts;

  /// No description provided for @article1Title.
  ///
  /// In en, this message translates to:
  /// **'How Pregnancy Happens: A Simple Guide to Conception'**
  String get article1Title;

  /// No description provided for @article1Excerpt.
  ///
  /// In en, this message translates to:
  /// **'Conception happens when sperm fertilizes an egg and the embryo implants. Learn when the fertile window opens and how health, timing, and patience support TTC.'**
  String get article1Excerpt;

  /// No description provided for @article1Content.
  ///
  /// In en, this message translates to:
  /// **'Getting pregnant happens when a sperm fertilizes an egg and the fertilized egg successfully implants in the uterus. Understanding this helps improve your chances.\n\nUnderstanding the fertile window\nYou are most likely to conceive during the fertile window: the days leading up to and including ovulation (about 14 days before the next period in a regular cycle). Because sperm can live in the body for several days, pregnancy can happen if sperm is present during this time.\n\nHealthy body, better chances\nGood overall health supports conception. Eat balanced meals, stay hydrated, manage stress, sleep well, and avoid smoking and alcohol. Maintaining a healthy weight matters, since being underweight or overweight can affect ovulation.\n\nTracking ovulation\n- Monitoring menstrual cycles (this is included in the Fertilpath app)\n- Watching for changes in cervical mucus\n- Using ovulation predictor kits\n\nThese tools help you know your most fertile days.\n\nMedical checkups matter\nBefore trying to conceive, see a healthcare provider. They can advise on prenatal vitamins like folic acid, review any health conditions, and guide you toward a healthy pregnancy.\n\nPatience is normal\nEven with perfect timing, it can take months to conceive. That is normal and does not always mean something is wrong. Consider seeing a doctor if you have tried for 12 months (or sooner if over 35).'**
  String get article1Content;

  /// No description provided for @article2Title.
  ///
  /// In en, this message translates to:
  /// **'How Long Does Ovulation Last?'**
  String get article2Title;

  /// No description provided for @article2Excerpt.
  ///
  /// In en, this message translates to:
  /// **'Ovulation is brief (12-24 hours), but sperm can live up to five days. Knowing this window helps plan or prevent pregnancy.'**
  String get article2Excerpt;

  /// No description provided for @article2Content.
  ///
  /// In en, this message translates to:
  /// **'Ovulation is when an ovary releases a mature egg. The egg lives about 12 to 24 hours, and can be fertilized only in that short time.\n\nThe fertile window\nEven though ovulation is brief, sperm can survive in the reproductive tract for up to five days. Pregnancy can happen if sperm are present in the days before ovulation or on the ovulation day itself.\n\nWhen ovulation occurs\nIn a regular cycle, ovulation is roughly 14 days before the next period, but timing varies by person and by cycle.\n\nSigns of ovulation\nSome people notice mild lower abdominal discomfort or changes in cervical mucus around ovulation. These clues can help identify fertile days, but they differ for everyone.\n\nWhy it matters\nKnowing how long ovulation lasts and how long sperm survive can guide timing for conception, family planning, or simply understanding your body.'**
  String get article2Content;

  /// No description provided for @article3Title.
  ///
  /// In en, this message translates to:
  /// **'Infertility Is Not a Curse'**
  String get article3Title;

  /// No description provided for @article3Excerpt.
  ///
  /// In en, this message translates to:
  /// **'In many Nigerian and African communities, pressure to conceive is heavy. Infertility is a medical challenge, not a curse or a failure.'**
  String get article3Excerpt;

  /// No description provided for @article3Content.
  ///
  /// In en, this message translates to:
  /// **'If you are trying to conceive and it has not happened yet, remember this: infertility is not a curse or a punishment.\n\nIn many Nigerian and African societies, motherhood is tightly linked to identity, and delays can bring painful pressure. Terms like \"barren\" or \"waiting on God\" can leave emotional wounds, but difficulty conceiving is a medical and biological challenge, not a spiritual verdict.\n\nInfertility has many possible causes: hormonal imbalances, infections, fibroids, blocked tubes, age, stress, or male-factor issues. Men and women are affected nearly equally, yet women often carry the blame alone.\n\nYou deserve care, not shame. Seeking medical help does not mean you lack faith. Many women conceive after proper diagnosis, treatment, lifestyle changes, or assisted medical support. And even when the journey is long, your life has meaning and purpose beyond motherhood.\n\nBe kind to yourself. Protect your mental and emotional health. Surround yourself with people who support you, ask questions, seek credible medical advice, and give yourself permission to hope—without self-blame. Your body is not your enemy, and your story is not over.'**
  String get article3Content;

  /// No description provided for @christianAffirmation1.
  ///
  /// In en, this message translates to:
  /// **'\"I can do all things through Christ who strengthens me.\"\n- Philippians 4:13'**
  String get christianAffirmation1;

  /// No description provided for @christianAffirmation2.
  ///
  /// In en, this message translates to:
  /// **'\"For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.\"\n- Jeremiah 29:11'**
  String get christianAffirmation2;

  /// No description provided for @christianAffirmation3.
  ///
  /// In en, this message translates to:
  /// **'\"The Lord is my shepherd; I shall not want.\"\n- Psalm 23:1'**
  String get christianAffirmation3;

  /// No description provided for @muslimAffirmation1.
  ///
  /// In en, this message translates to:
  /// **'\"So verily, with the hardship, there is relief.\"\n- Quran 94:6'**
  String get muslimAffirmation1;

  /// No description provided for @muslimAffirmation2.
  ///
  /// In en, this message translates to:
  /// **'\"And He found you lost and guided [you].\"\n- Quran 93:7'**
  String get muslimAffirmation2;

  /// No description provided for @muslimAffirmation3.
  ///
  /// In en, this message translates to:
  /// **'\"Indeed, Allah is with the patient.\"\n- Quran 2:153'**
  String get muslimAffirmation3;

  /// No description provided for @traditionalistAffirmation1.
  ///
  /// In en, this message translates to:
  /// **'Your ancestors walked through storms and found their way. You carry their strength within you.'**
  String get traditionalistAffirmation1;

  /// No description provided for @traditionalistAffirmation2.
  ///
  /// In en, this message translates to:
  /// **'The earth provides in its own time. Trust the natural rhythm of life and your body.'**
  String get traditionalistAffirmation2;

  /// No description provided for @traditionalistAffirmation3.
  ///
  /// In en, this message translates to:
  /// **'Community and family are your pillars. Draw strength from those who love you and walk beside you.'**
  String get traditionalistAffirmation3;

  /// No description provided for @traditionalistAffirmation4.
  ///
  /// In en, this message translates to:
  /// **'Like the baobab tree that bends but does not break, you are resilient through every season.'**
  String get traditionalistAffirmation4;

  /// No description provided for @traditionalistAffirmation5.
  ///
  /// In en, this message translates to:
  /// **'The river flows around obstacles, not through them. Allow yourself grace and patience on this journey.'**
  String get traditionalistAffirmation5;

  /// No description provided for @neutralAffirmation1.
  ///
  /// In en, this message translates to:
  /// **'You are resilient and capable of overcoming any challenge.'**
  String get neutralAffirmation1;

  /// No description provided for @neutralAffirmation2.
  ///
  /// In en, this message translates to:
  /// **'Every day is a new beginning. Embrace it with hope and courage.'**
  String get neutralAffirmation2;

  /// No description provided for @neutralAffirmation3.
  ///
  /// In en, this message translates to:
  /// **'You are enough, just as you are. Believe in your journey.'**
  String get neutralAffirmation3;

  /// No description provided for @genderPredictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender Prediction'**
  String get genderPredictionTitle;

  /// No description provided for @genderPredictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: This feature uses AI to provide gender prediction advice. These predictions may not be fully accurate and should not replace professional medical advice. Please consult a qualified doctor for health decisions.'**
  String get genderPredictionDisclaimer;

  /// No description provided for @selectGenderExpectation.
  ///
  /// In en, this message translates to:
  /// **'Select your gender expectation:'**
  String get selectGenderExpectation;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @noPreference.
  ///
  /// In en, this message translates to:
  /// **'No Preference'**
  String get noPreference;

  /// No description provided for @fertileWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get fertileWindowLabel;

  /// No description provided for @ovulationDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Day'**
  String get ovulationDayLabel;

  /// No description provided for @adviceForTiming.
  ///
  /// In en, this message translates to:
  /// **'Advice for intercourse timing:'**
  String get adviceForTiming;

  /// No description provided for @bestChanceForMale.
  ///
  /// In en, this message translates to:
  /// **'Best chance for male conception.'**
  String get bestChanceForMale;

  /// No description provided for @lowerChanceForMale.
  ///
  /// In en, this message translates to:
  /// **'Lower chance for male.'**
  String get lowerChanceForMale;

  /// No description provided for @bestChanceForFemale.
  ///
  /// In en, this message translates to:
  /// **'Best chance for female conception.'**
  String get bestChanceForFemale;

  /// No description provided for @lowerChanceForFemale.
  ///
  /// In en, this message translates to:
  /// **'Lower chance for female.'**
  String get lowerChanceForFemale;

  /// No description provided for @generalAdviceForConception.
  ///
  /// In en, this message translates to:
  /// **'General advice for conception.'**
  String get generalAdviceForConception;

  /// No description provided for @noPredictionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No gender prediction data available yet. Select a gender and ensure your cycle data is up to date.'**
  String get noPredictionDataAvailable;

  /// No description provided for @readAffirmationAloud.
  ///
  /// In en, this message translates to:
  /// **'Read affirmation aloud'**
  String get readAffirmationAloud;

  /// No description provided for @failedPlayAffirmation.
  ///
  /// In en, this message translates to:
  /// **'Failed to play affirmation. Please try again.'**
  String get failedPlayAffirmation;

  /// No description provided for @failedPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Failed to play audio. Please try again.'**
  String get failedPlayAudio;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ha', 'ig', 'pcm', 'yo'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ha':
      return AppLocalizationsHa();
    case 'ig':
      return AppLocalizationsIg();
    case 'pcm':
      return AppLocalizationsPcm();
    case 'yo':
      return AppLocalizationsYo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
