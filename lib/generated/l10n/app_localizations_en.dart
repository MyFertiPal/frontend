// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyFertiPal';

  @override
  String get appSubtitle => 'Your Fertility Tracking Journey';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get rememberEmail => 'Remember Email';

  @override
  String get required => 'Required';

  @override
  String googleSignInFailed(Object error) {
    return 'Google Sign-In failed: $error';
  }

  @override
  String get logYourSymptoms => 'Log Your Symptoms 📝';

  @override
  String get symptomReminderBody =>
      'How are you feeling today? Add your symptoms to get better fertility insights.';

  @override
  String get fullName => 'Full Name';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get signUpWith => 'Sign up with';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get pleaseCorrectErrors =>
      'Please correct highlighted errors before proceeding.';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get usernameTooShort => 'Username too short';

  @override
  String get sendingVerificationCode => 'Sending verification code';

  @override
  String get verifyYourAccount => 'Verify Your Account';

  @override
  String get verificationCodeSent =>
      'Verification code has been sent to your email.';

  @override
  String get resendingOtp => 'Resending OTP...';

  @override
  String get verificationCodeResent => 'Verification code resent successfully';

  @override
  String get unableToResendOtp =>
      'Unable to resend OTP. Please try again later.';

  @override
  String get incorrectVerificationCode =>
      'Incorrect verification code. Please try again.';

  @override
  String get pleaseEnterCompleteOtp => 'Please enter complete OTP';

  @override
  String get verify => 'Verify';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get trackYourCycle => 'Track your Cycle';

  @override
  String get trackYourCycleDesc =>
      'Monitor your cycle with ease and get personalised insight';

  @override
  String get learnInYourLanguage => 'Learn in your own language';

  @override
  String get learnInYourLanguageDesc =>
      'Access fertility education and resources in the language you understand best';

  @override
  String get feelSupported => 'Feel supported';

  @override
  String get feelSupportedDesc =>
      'Join a caring community and get the support you need on your journey';

  @override
  String get sendPasswordResetLink => 'Send password reset link';

  @override
  String get enterYourAccountEmail =>
      'Enter your account email and we\'ll send you a link to reset your password.';

  @override
  String get sendLink => 'Send Link';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get resetLinkSent =>
      'We sent you a password reset link. Click the button in the email to reset your password.';

  @override
  String get checkSpamFolder => '📧 Don\'t forget to check your spam folder';

  @override
  String get didntReceiveEmail => 'Didn\'t receive the email? Resend';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get passwordAtLeast6 => 'Password must be at least 6 characters';

  @override
  String get invalidOrMissingToken => 'Invalid or missing token.';

  @override
  String get failedToResetPassword => 'Failed to reset password.';

  @override
  String get passwordUpdated => 'Password Updated';

  @override
  String get passwordSuccessfully =>
      'Your password has been successfully updated. You can now log in with your new credentials.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email to continue.';

  @override
  String resetLinkSentMessage(Object email) {
    return 'We sent a secure reset link to $email.';
  }

  @override
  String get unableToSendLink => 'Unable to send link. Please try again later.';

  @override
  String get enterNewPasswordDescription =>
      'Enter your new password below to secure your account.';

  @override
  String get tokenRequired => 'Token is required.';

  @override
  String get passwordMinimumLength => 'Password must be at least 8 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get unableToResetPassword =>
      'Unable to reset password. Please try again later.';

  @override
  String get profileSetup => 'Complete Your Profile';

  @override
  String get profileSetupInfo =>
      'This will help us personalize your cycle guide';

  @override
  String get completeYourProfile => 'Let\'s complete your profile';

  @override
  String get age => 'Age';

  @override
  String get ageInfoText => 'Select your age';

  @override
  String get cycleLength => 'Cycle Length';

  @override
  String get selectCycleLength => 'Select cycle length';

  @override
  String days(int count) {
    return '$count Days';
  }

  @override
  String get averageCycleDays => 'Average number of days between your periods';

  @override
  String get periodLength => 'Period Length';

  @override
  String get selectPeriodLength => 'Select period length';

  @override
  String get typicalPeriodDays => 'Typical number of days your period lasts';

  @override
  String get lastPeriodDate => 'Last Period Date';

  @override
  String get selectLastPeriodDate => 'Select the date your last period started';

  @override
  String get lastPeriodStartedInfo =>
      'When your last menstrual bleeding started';

  @override
  String get ttcHistory => 'TTC History';

  @override
  String get selectTtcHistory => 'Select your TTC history';

  @override
  String get tryingToConceive => 'Trying To Conceive';

  @override
  String get tryingToConceiveDefault => 'Trying To Conceive - default';

  @override
  String get preparingToConceive => 'Preparing To Conceive';

  @override
  String get justTrackingCycle => 'Just Tracking My Cycle';

  @override
  String get ttcSixMonths => 'TTC 6+ Months';

  @override
  String get ttcTwelveMonths => 'TTC 12+ Months';

  @override
  String get usingFertilityTreatment => 'Using Fertility Treatment';

  @override
  String get preferNotToSay => 'Prefer Not To Say';

  @override
  String get faithPreference => 'Faith Preference';

  @override
  String get selectFaithPreference => 'Select your faith preference';

  @override
  String get christian => 'Christian';

  @override
  String get muslim => 'Muslim';

  @override
  String get traditionalist => 'Traditionalist';

  @override
  String get neutral => 'Neutral';

  @override
  String get audioGuidance => 'Audio Guidance';

  @override
  String get enableAudioGuidance => 'Enable audio guidance';

  @override
  String get termsAndConditionsAgreement =>
      'I agree to the Terms and Conditions and Privacy Policy';

  @override
  String get continueButton => 'Continue';

  @override
  String get profileSetupComplete => 'Profile setup complete!';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get cycle => 'Cycle';

  @override
  String get fertileWindow => 'Fertile Window';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get period => 'Period';

  @override
  String day(int count) {
    return 'Day $count';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get logSymptoms => 'Log\nSymptoms';

  @override
  String get genderPrediction => 'Gender\nPrediction';

  @override
  String get calendar => 'Calendar';

  @override
  String get todaysInsight => 'Today\'s Insight';

  @override
  String get defaultInsight =>
      'Your personalized fertility insight will appear here.';

  @override
  String get bookSpecialist => 'Talk to a specialist';

  @override
  String get expertGuidance =>
      'Get expert guidance from certified fertility doctors, anytime.';

  @override
  String get bookConsultation => 'Book Consultation';

  @override
  String get profileSettings => 'Settings';

  @override
  String get logOut => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get aboutMyFertiPal => 'About MyFertiPal';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get language => 'Language';

  @override
  String get languageUpdated => 'Language updated successfully.';

  @override
  String get languageUpdateFailed => 'Failed to update language.';

  @override
  String get deleteAccountMessage =>
      'This permanently deletes your account and all tracked data. This can\'t be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get cyclesTracked => 'Cycles Tracked';

  @override
  String get symptomsLogged => 'Symptoms Logged';

  @override
  String get consultations => 'Consultations';

  @override
  String get password => 'Password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get otpInfoText => 'Enter the verification code sent to your email.';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get settings => 'Settings';

  @override
  String get pleaseSelectLanguage => 'Please select your preferred language';

  @override
  String get languageSelected => 'Language selected successfully';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';
}
