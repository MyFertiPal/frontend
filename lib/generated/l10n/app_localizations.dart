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
  /// **'MyFertiPal'**
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

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get signInWithGoogle;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @rememberEmail.
  ///
  /// In en, this message translates to:
  /// **'Remember Email'**
  String get rememberEmail;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String googleSignInFailed(Object error);

  /// No description provided for @logYourSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Your Symptoms 📝'**
  String get logYourSymptoms;

  /// No description provided for @symptomReminderBody.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? Add your symptoms to get better fertility insights.'**
  String get symptomReminderBody;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

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

  /// No description provided for @signUpWith.
  ///
  /// In en, this message translates to:
  /// **'Sign up with'**
  String get signUpWith;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

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

  /// No description provided for @pleaseCorrectErrors.
  ///
  /// In en, this message translates to:
  /// **'Please correct highlighted errors before proceeding.'**
  String get pleaseCorrectErrors;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username too short'**
  String get usernameTooShort;

  /// No description provided for @sendingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code'**
  String get sendingVerificationCode;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyYourAccount;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code has been sent to your email.'**
  String get verificationCodeSent;

  /// No description provided for @resendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Resending OTP...'**
  String get resendingOtp;

  /// No description provided for @verificationCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully'**
  String get verificationCodeResent;

  /// No description provided for @unableToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend OTP. Please try again later.'**
  String get unableToResendOtp;

  /// No description provided for @incorrectVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect verification code. Please try again.'**
  String get incorrectVerificationCode;

  /// No description provided for @pleaseEnterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get pleaseEnterCompleteOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

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

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

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

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email to continue.'**
  String get pleaseEnterValidEmail;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a secure reset link to {email}.'**
  String resetLinkSentMessage(Object email);

  /// No description provided for @unableToSendLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to send link. Please try again later.'**
  String get unableToSendLink;

  /// No description provided for @enterNewPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below to secure your account.'**
  String get enterNewPasswordDescription;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Token is required.'**
  String get tokenRequired;

  /// No description provided for @passwordMinimumLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinimumLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @unableToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password. Please try again later.'**
  String get unableToResetPassword;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileSetup;

  /// No description provided for @profileSetupInfo.
  ///
  /// In en, this message translates to:
  /// **'This will help us personalize your cycle guide'**
  String get profileSetupInfo;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Let\'s complete your profile'**
  String get completeYourProfile;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageInfoText.
  ///
  /// In en, this message translates to:
  /// **'Select your age'**
  String get ageInfoText;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get cycleLength;

  /// No description provided for @selectCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Select cycle length'**
  String get selectCycleLength;

  /// Displays number of days
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String days(int count);

  /// No description provided for @averageCycleDays.
  ///
  /// In en, this message translates to:
  /// **'Average number of days between your periods'**
  String get averageCycleDays;

  /// No description provided for @periodLength.
  ///
  /// In en, this message translates to:
  /// **'Period Length'**
  String get periodLength;

  /// No description provided for @selectPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Select period length'**
  String get selectPeriodLength;

  /// No description provided for @typicalPeriodDays.
  ///
  /// In en, this message translates to:
  /// **'Typical number of days your period lasts'**
  String get typicalPeriodDays;

  /// No description provided for @lastPeriodDate.
  ///
  /// In en, this message translates to:
  /// **'Last Period Date'**
  String get lastPeriodDate;

  /// No description provided for @selectLastPeriodDate.
  ///
  /// In en, this message translates to:
  /// **'Select the date your last period started'**
  String get selectLastPeriodDate;

  /// No description provided for @lastPeriodStartedInfo.
  ///
  /// In en, this message translates to:
  /// **'When your last menstrual bleeding started'**
  String get lastPeriodStartedInfo;

  /// No description provided for @ttcHistory.
  ///
  /// In en, this message translates to:
  /// **'TTC History'**
  String get ttcHistory;

  /// No description provided for @selectTtcHistory.
  ///
  /// In en, this message translates to:
  /// **'Select your TTC history'**
  String get selectTtcHistory;

  /// No description provided for @tryingToConceive.
  ///
  /// In en, this message translates to:
  /// **'Trying To Conceive'**
  String get tryingToConceive;

  /// No description provided for @tryingToConceiveDefault.
  ///
  /// In en, this message translates to:
  /// **'Trying To Conceive - default'**
  String get tryingToConceiveDefault;

  /// No description provided for @preparingToConceive.
  ///
  /// In en, this message translates to:
  /// **'Preparing To Conceive'**
  String get preparingToConceive;

  /// No description provided for @justTrackingCycle.
  ///
  /// In en, this message translates to:
  /// **'Just Tracking My Cycle'**
  String get justTrackingCycle;

  /// No description provided for @ttcSixMonths.
  ///
  /// In en, this message translates to:
  /// **'TTC 6+ Months'**
  String get ttcSixMonths;

  /// No description provided for @ttcTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'TTC 12+ Months'**
  String get ttcTwelveMonths;

  /// No description provided for @usingFertilityTreatment.
  ///
  /// In en, this message translates to:
  /// **'Using Fertility Treatment'**
  String get usingFertilityTreatment;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer Not To Say'**
  String get preferNotToSay;

  /// No description provided for @faithPreference.
  ///
  /// In en, this message translates to:
  /// **'Faith Preference'**
  String get faithPreference;

  /// No description provided for @selectFaithPreference.
  ///
  /// In en, this message translates to:
  /// **'Select your faith preference'**
  String get selectFaithPreference;

  /// No description provided for @christian.
  ///
  /// In en, this message translates to:
  /// **'Christian'**
  String get christian;

  /// No description provided for @muslim.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get muslim;

  /// No description provided for @traditionalist.
  ///
  /// In en, this message translates to:
  /// **'Traditionalist'**
  String get traditionalist;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @audioGuidance.
  ///
  /// In en, this message translates to:
  /// **'Audio Guidance'**
  String get audioGuidance;

  /// No description provided for @enableAudioGuidance.
  ///
  /// In en, this message translates to:
  /// **'Enable audio guidance'**
  String get enableAudioGuidance;

  /// No description provided for @termsAndConditionsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions and Privacy Policy'**
  String get termsAndConditionsAgreement;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @profileSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Profile setup complete!'**
  String get profileSetupComplete;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get fertileWindow;

  /// No description provided for @ovulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get ovulation;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Current cycle day
  ///
  /// In en, this message translates to:
  /// **'Day {count}'**
  String day(int count);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// No description provided for @genderPrediction.
  ///
  /// In en, this message translates to:
  /// **'Gender Prediction'**
  String get genderPrediction;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @todaysInsight.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Insight'**
  String get todaysInsight;

  /// No description provided for @defaultInsight.
  ///
  /// In en, this message translates to:
  /// **'Your personalized fertility insight will appear here.'**
  String get defaultInsight;

  /// No description provided for @bookSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Talk to a specialist'**
  String get bookSpecialist;

  /// No description provided for @expertGuidance.
  ///
  /// In en, this message translates to:
  /// **'Get expert guidance from certified fertility doctors, anytime.'**
  String get expertGuidance;

  /// No description provided for @bookConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book Consultation'**
  String get bookConsultation;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @aboutMyFertiPal.
  ///
  /// In en, this message translates to:
  /// **'About MyFertiPal'**
  String get aboutMyFertiPal;

  /// No description provided for @basicMember.
  ///
  /// In en, this message translates to:
  /// **'Basic Member'**
  String get basicMember;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully.'**
  String get languageUpdated;

  /// No description provided for @languageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language.'**
  String get languageUpdateFailed;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all tracked data. This can\'t be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cyclesTracked.
  ///
  /// In en, this message translates to:
  /// **'Cycles Tracked'**
  String get cyclesTracked;

  /// No description provided for @symptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Logged'**
  String get symptomsLogged;

  /// No description provided for @consultations.
  ///
  /// In en, this message translates to:
  /// **'Consultations'**
  String get consultations;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// Shows required field validation
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @otpInfoText.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email.'**
  String get otpInfoText;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language'**
  String get pleaseSelectLanguage;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'Language selected successfully'**
  String get languageSelected;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'PODCAST'**
  String get podcast;

  /// No description provided for @fertiTalks.
  ///
  /// In en, this message translates to:
  /// **'FertiTalks By MyFertiPal'**
  String get fertiTalks;

  /// No description provided for @newEpisodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'New episodes available anytime'**
  String get newEpisodesAvailable;

  /// No description provided for @listenOnSpotify.
  ///
  /// In en, this message translates to:
  /// **'Listen on Spotify'**
  String get listenOnSpotify;

  /// No description provided for @connectWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Connect with others'**
  String get connectWithOthers;

  /// No description provided for @whatsAppCommunity.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Community'**
  String get whatsAppCommunity;

  /// No description provided for @whatsAppCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with women, share experiences and get fertility support.'**
  String get whatsAppCommunityDescription;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the community'**
  String get joinCommunity;

  /// No description provided for @successStories.
  ///
  /// In en, this message translates to:
  /// **'Success Stories'**
  String get successStories;

  /// No description provided for @successStoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Real stories from women who stayed hopeful and never gave up.'**
  String get successStoriesDescription;

  /// No description provided for @beInspired.
  ///
  /// In en, this message translates to:
  /// **'Be inspired'**
  String get beInspired;

  /// No description provided for @faithEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Faith & Encouragement'**
  String get faithEncouragement;

  /// No description provided for @faithEncouragementDescription.
  ///
  /// In en, this message translates to:
  /// **'Faith-based support and daily encouragement for your journey.'**
  String get faithEncouragementDescription;

  /// No description provided for @getEncouraged.
  ///
  /// In en, this message translates to:
  /// **'Get encouraged'**
  String get getEncouraged;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore & Learn'**
  String get explore;

  /// No description provided for @searchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search articles..'**
  String get searchArticles;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @specialists.
  ///
  /// In en, this message translates to:
  /// **'Find a Specialist'**
  String get specialists;

  /// No description provided for @searchSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Search specialists by name or specialty'**
  String get searchSpecialists;

  /// No description provided for @logSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptomsTitle;

  /// No description provided for @trackHowYouFeel.
  ///
  /// In en, this message translates to:
  /// **'Track how you feel. Every detail helps.'**
  String get trackHowYouFeel;

  /// No description provided for @selectSymptomsToLog.
  ///
  /// In en, this message translates to:
  /// **'Select symptoms to log'**
  String get selectSymptomsToLog;

  /// No description provided for @chooseMoreThanOne.
  ///
  /// In en, this message translates to:
  /// **'You can choose more than one'**
  String get chooseMoreThanOne;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @anxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get anxious;

  /// No description provided for @irritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get irritable;

  /// No description provided for @calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calm;

  /// No description provided for @energetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get energetic;

  /// No description provided for @bleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get bleeding;

  /// No description provided for @spotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get spotting;

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

  /// No description provided for @cervicalMucus.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get cervicalMucus;

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

  /// No description provided for @sexualActivity.
  ///
  /// In en, this message translates to:
  /// **'Sexual Activity'**
  String get sexualActivity;

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

  /// No description provided for @pain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get pain;

  /// No description provided for @headache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get headache;

  /// No description provided for @backPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get backPain;

  /// No description provided for @breastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get breastTenderness;

  /// No description provided for @ovulationPain.
  ///
  /// In en, this message translates to:
  /// **'Ovulation pain'**
  String get ovulationPain;

  /// No description provided for @abdominalCramps.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Cramps'**
  String get abdominalCramps;

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

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @insomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get insomnia;

  /// No description provided for @oversleeping.
  ///
  /// In en, this message translates to:
  /// **'Oversleeping'**
  String get oversleeping;

  /// No description provided for @appetite.
  ///
  /// In en, this message translates to:
  /// **'Appetite'**
  String get appetite;

  /// No description provided for @increased.
  ///
  /// In en, this message translates to:
  /// **'Increased'**
  String get increased;

  /// No description provided for @decreased.
  ///
  /// In en, this message translates to:
  /// **'Decreased'**
  String get decreased;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @cravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get cravings;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @describeFeeling.
  ///
  /// In en, this message translates to:
  /// **'Describe what you\'re feeling'**
  String get describeFeeling;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @symptomLoggingTip.
  ///
  /// In en, this message translates to:
  /// **'Logging symptoms daily helps us give you more accurate insights.'**
  String get symptomLoggingTip;

  /// No description provided for @saveSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Save Symptoms'**
  String get saveSymptoms;

  /// No description provided for @symptomsSaved.
  ///
  /// In en, this message translates to:
  /// **'Symptoms saved successfully'**
  String get symptomsSaved;

  /// No description provided for @failedToSaveSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Failed to save symptoms: {error}'**
  String failedToSaveSymptoms(Object error);

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @importantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Important Disclaimer'**
  String get importantDisclaimer;

  /// No description provided for @genderPredictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This feature uses fertility timing information to provide gender prediction guidance. It is not scientifically guaranteed and should not replace medical advice.'**
  String get genderPredictionDisclaimer;

  /// No description provided for @selectGenderExpectation.
  ///
  /// In en, this message translates to:
  /// **'Select your gender expectation'**
  String get selectGenderExpectation;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @hopingForGirl.
  ///
  /// In en, this message translates to:
  /// **'I\'m hoping for a baby girl'**
  String get hopingForGirl;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @hopingForBoy.
  ///
  /// In en, this message translates to:
  /// **'I\'m hoping for a baby boy'**
  String get hopingForBoy;

  /// No description provided for @noPreference.
  ///
  /// In en, this message translates to:
  /// **'No Preference'**
  String get noPreference;

  /// No description provided for @openToEither.
  ///
  /// In en, this message translates to:
  /// **'I\'m open to either'**
  String get openToEither;

  /// Shows selected gender prediction
  ///
  /// In en, this message translates to:
  /// **'Prediction for: {gender}'**
  String predictionFor(String gender);

  /// No description provided for @estimatedOvulation.
  ///
  /// In en, this message translates to:
  /// **'Estimated Ovulation'**
  String get estimatedOvulation;

  /// No description provided for @suggestedTiming.
  ///
  /// In en, this message translates to:
  /// **'Suggested Timing'**
  String get suggestedTiming;

  /// No description provided for @tryCloserToOvulation.
  ///
  /// In en, this message translates to:
  /// **'Try closer to ovulation:'**
  String get tryCloserToOvulation;

  /// No description provided for @tryBeforeOvulation.
  ///
  /// In en, this message translates to:
  /// **'Try a few days before ovulation:'**
  String get tryBeforeOvulation;

  /// No description provided for @yourFertileDays.
  ///
  /// In en, this message translates to:
  /// **'Your fertile days:'**
  String get yourFertileDays;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @predicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get predicted;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noSymptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged yet'**
  String get noSymptomsLogged;

  /// No description provided for @loggedSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Logged Symptoms'**
  String get loggedSymptoms;

  /// No description provided for @menstrual.
  ///
  /// In en, this message translates to:
  /// **'Menstrual'**
  String get menstrual;

  /// No description provided for @follicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get follicular;

  /// No description provided for @luteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get luteal;
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
