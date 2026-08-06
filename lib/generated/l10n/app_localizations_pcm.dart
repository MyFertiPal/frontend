// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nigerian Pidgin (`pcm`).
class AppLocalizationsPcm extends AppLocalizations {
  AppLocalizationsPcm([String locale = 'pcm']) : super(locale);

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
  String get dontHaveAccount => 'You no get account?';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get forgotPassword => 'You forget password?';

  @override
  String get rememberEmail => 'Remember Email';

  @override
  String get required => 'E dey needed';

  @override
  String googleSignInFailed(Object error) {
    return 'Google Sign-In no work: $error';
  }

  @override
  String get logYourSymptoms => 'Write Your Symptoms 📝';

  @override
  String get symptomReminderBody =>
      'How you dey feel today? Add your symptoms make we give you better fertility advice.';

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
  String get alreadyHaveAccount => 'You don get account already?';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get pleaseCorrectErrors =>
      'Please correct the highlighted errors before you continue.';

  @override
  String get unexpectedError => 'Something happen. Please try again.';

  @override
  String get invalidEmail => 'Email no correct';

  @override
  String get usernameTooShort => 'Username too short';

  @override
  String get sendingVerificationCode => 'We dey send verification code';

  @override
  String get verifyYourAccount => 'Verify Your Account';

  @override
  String get verificationCodeSent =>
      'We don send verification code go your email.';

  @override
  String get resendingOtp => 'We dey send OTP again...';

  @override
  String get verificationCodeResent =>
      'Verification code don send again successfully';

  @override
  String get unableToResendOtp => 'We no fit send OTP again. Try later.';

  @override
  String get incorrectVerificationCode =>
      'Verification code no correct. Try again.';

  @override
  String get pleaseEnterCompleteOtp => 'Please enter the complete OTP';

  @override
  String get verify => 'Verify';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get trackYourCycle => 'Track Your Cycle';

  @override
  String get trackYourCycleDesc =>
      'Watch your cycle easily and get personal fertility advice';

  @override
  String get learnInYourLanguage => 'Learn for your own language';

  @override
  String get learnInYourLanguageDesc =>
      'Get fertility education and resources for language wey you understand';

  @override
  String get feelSupported => 'Feel Supported';

  @override
  String get feelSupportedDesc =>
      'Join caring community and get support for your journey';

  @override
  String get sendPasswordResetLink => 'Send password reset link';

  @override
  String get enterYourAccountEmail =>
      'Put your account email and we go send you link to reset your password.';

  @override
  String get sendLink => 'Send Link';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get resetLinkSent =>
      'We don send password reset link. Click the button for the email to reset your password.';

  @override
  String get checkSpamFolder => '📧 No forget to check your spam folder';

  @override
  String get didntReceiveEmail => 'You no receive the email? Send again';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get passwordAtLeast6 => 'Password must get at least 6 characters';

  @override
  String get invalidOrMissingToken => 'Token no valid or e no dey.';

  @override
  String get failedToResetPassword => 'We no fit reset your password.';

  @override
  String get passwordUpdated => 'Password Updated';

  @override
  String get passwordSuccessfully =>
      'Your password don update successfully. You fit login with your new details now.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get pleaseEnterValidEmail => 'Please enter correct email to continue.';

  @override
  String resetLinkSentMessage(Object email) {
    return 'We don send secure reset link to $email.';
  }

  @override
  String get unableToSendLink => 'We no fit send link. Try again later.';

  @override
  String get enterNewPasswordDescription =>
      'Enter your new password below to protect your account.';

  @override
  String get tokenRequired => 'Token dey needed.';

  @override
  String get passwordMinimumLength =>
      'Password must get at least 8 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords no match.';

  @override
  String get unableToResetPassword =>
      'We no fit reset password. Try again later.';

  @override
  String get profileSetup => 'Complete Your Profile';

  @override
  String get profileSetupInfo =>
      'This one go help us personalize your cycle guide';

  @override
  String get completeYourProfile => 'Make we complete your profile';

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
  String get typicalPeriodDays => 'Normal number of days your period dey last';

  @override
  String get lastPeriodDate => 'Last Period Date';

  @override
  String get selectLastPeriodDate => 'Select the date your last period start';

  @override
  String get lastPeriodStartedInfo => 'When your last menstrual bleeding start';

  @override
  String get ttcHistory => 'Trying To Conceive History';

  @override
  String get selectTtcHistory => 'Select your TTC history';

  @override
  String get tryingToConceive => 'I dey try to get pregnant';

  @override
  String get tryingToConceiveDefault => 'I dey try to get pregnant - default';

  @override
  String get preparingToConceive => 'I dey prepare to get pregnant';

  @override
  String get justTrackingCycle => 'I dey only track my cycle';

  @override
  String get ttcSixMonths => 'Trying for 6+ months';

  @override
  String get ttcTwelveMonths => 'Trying for 12+ months';

  @override
  String get usingFertilityTreatment => 'I dey use fertility treatment';

  @override
  String get preferNotToSay => 'I no wan talk';

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
  String get neutral => 'No preference';

  @override
  String get audioGuidance => 'Audio Guidance';

  @override
  String get enableAudioGuidance => 'Turn on audio guidance';

  @override
  String get termsAndConditionsAgreement =>
      'I agree to Terms and Conditions and Privacy Policy';

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
  String get fertileWindow => 'Fertile Time';

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
  String get defaultInsight => 'Your personal fertility insight go show here.';

  @override
  String get bookSpecialist => 'Talk to Doctor';

  @override
  String get expertGuidance =>
      'Get help from certified fertility doctors anytime.';

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
  String get languageUpdated => 'Language don update successfully.';

  @override
  String get languageUpdateFailed => 'Language update no work.';

  @override
  String get deleteAccountMessage =>
      'This one go delete your account and all your tracked data forever. You no fit undo am.';

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
  String get passwordMinLength => 'Password must get at least 8 characters';

  @override
  String fieldRequired(String field) {
    return '$field dey needed';
  }

  @override
  String get otpInfoText =>
      'Enter the verification code wey we send go your email.';

  @override
  String get resendCode => 'Send Code Again';

  @override
  String get settings => 'Settings';

  @override
  String get pleaseSelectLanguage =>
      'Please select the language wey you prefer';

  @override
  String get languageSelected => 'Language don select successfully';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';
}
