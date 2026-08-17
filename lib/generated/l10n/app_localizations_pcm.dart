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
  String get updateProfile => 'Update Profile';

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
  String get logSymptoms => 'Log Symptoms';

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
  String get basicMember => 'Basic Member';

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

  @override
  String get connect => 'Connect';

  @override
  String get podcast => 'PODCAST';

  @override
  String get fertiTalks => 'FertiTalks by MyFertiPal';

  @override
  String get newEpisodesAvailable => 'New episodes dey available anytime';

  @override
  String get listenOnSpotify => 'Listen for Spotify';

  @override
  String get connectWithOthers => 'Connect with others';

  @override
  String get whatsAppCommunity => 'WhatsApp Community';

  @override
  String get whatsAppCommunityDescription =>
      'Connect with women, share your experience and get fertility support.';

  @override
  String get joinCommunity => 'Join the community';

  @override
  String get successStories => 'Success Stories';

  @override
  String get successStoriesDescription =>
      'Real stories from women wey keep hope alive and never give up.';

  @override
  String get beInspired => 'Make e inspire you';

  @override
  String get faithEncouragement => 'Faith & Encouragement';

  @override
  String get faithEncouragementDescription =>
      'Faith-based support and daily encouragement for your journey.';

  @override
  String get getEncouraged => 'Get encouraged';

  @override
  String get explore => 'Explore & Learn';

  @override
  String get searchArticles => 'Find articles...';

  @override
  String get articles => 'Articles';

  @override
  String get specialists => 'Find Specialist';

  @override
  String get searchSpecialists =>
      'Search specialists by name or area of expertise';

  @override
  String get logSymptomsTitle => 'Write Symptoms';

  @override
  String get trackHowYouFeel =>
      'Follow how you dey feel. Every detail dey important.';

  @override
  String get selectSymptomsToLog => 'Choose symptoms wey you wan record';

  @override
  String get chooseMoreThanOne => 'You fit choose more than one';

  @override
  String get mood => 'How you dey feel';

  @override
  String get happy => 'Happy';

  @override
  String get sad => 'Sad';

  @override
  String get anxious => 'Worried';

  @override
  String get irritable => 'Quick to vex';

  @override
  String get calm => 'Calm';

  @override
  String get energetic => 'Full of energy';

  @override
  String get bleeding => 'Bleeding';

  @override
  String get spotting => 'Small blood spot';

  @override
  String get light => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get heavy => 'Plenty';

  @override
  String get cervicalMucus => 'Cervical mucus';

  @override
  String get dry => 'Dry';

  @override
  String get sticky => 'Sticky';

  @override
  String get creamy => 'Creamy';

  @override
  String get watery => 'Like water';

  @override
  String get eggWhite => 'Like egg white';

  @override
  String get sexualActivity => 'Sexual activity';

  @override
  String get protected => 'With protection';

  @override
  String get unprotected => 'Without protection';

  @override
  String get none => 'None';

  @override
  String get pain => 'Pain';

  @override
  String get headache => 'Headache';

  @override
  String get backPain => 'Back pain';

  @override
  String get breastTenderness => 'Breast tenderness';

  @override
  String get ovulationPain => 'Ovulation pain';

  @override
  String get abdominalCramps => 'Stomach cramps';

  @override
  String get mild => 'Small';

  @override
  String get moderate => 'Medium';

  @override
  String get severe => 'Serious';

  @override
  String get sleep => 'Sleep';

  @override
  String get good => 'Good';

  @override
  String get poor => 'Poor';

  @override
  String get insomnia => 'Cannot sleep';

  @override
  String get oversleeping => 'Sleeping too much';

  @override
  String get appetite => 'Appetite';

  @override
  String get increased => 'Increase';

  @override
  String get decreased => 'Decrease';

  @override
  String get normal => 'Normal';

  @override
  String get cravings => 'Strong desire for some food';

  @override
  String get other => 'Other';

  @override
  String get describeFeeling => 'Explain wetin you dey feel';

  @override
  String get tip => 'Tip';

  @override
  String get symptomLoggingTip =>
      'If you dey record your symptoms every day, e go help us give you better fertility information.';

  @override
  String get saveSymptoms => 'Save Symptoms';

  @override
  String get symptomsSaved => 'Symptoms don save successfully';

  @override
  String failedToSaveSymptoms(Object error) {
    return 'We no fit save symptoms: $error';
  }

  @override
  String get symptoms => 'Symptoms';

  @override
  String get importantDisclaimer => 'Important Information';

  @override
  String get genderPredictionDisclaimer =>
      'This gender prediction no get scientific guarantee and e no fit guarantee the baby gender. We dey provide this information for educational purpose only.';

  @override
  String get selectGenderExpectation => 'Choose the gender you dey hope for';

  @override
  String get girl => 'Baby girl';

  @override
  String get hopingForGirl => 'I dey hope for baby girl';

  @override
  String get boy => 'Baby boy';

  @override
  String get hopingForBoy => 'I dey hope for baby boy';

  @override
  String get noPreference => 'I no get preference';

  @override
  String get openToEither => 'Any one dey okay for me';

  @override
  String predictionFor(String gender) {
    return 'Prediction for: $gender';
  }

  @override
  String get estimatedOvulation => 'Estimated ovulation day';

  @override
  String get suggestedTiming => 'Suggested timing';

  @override
  String get tryCloserToOvulation =>
      'Try around the time wey ovulation dey happen.';

  @override
  String get tryBeforeOvulation => 'Try a few days before ovulation.';

  @override
  String get yourFertileDays => 'Use your fertile days.';

  @override
  String get notAvailable => 'No information available';

  @override
  String get jan => 'January';

  @override
  String get feb => 'February';

  @override
  String get mar => 'March';

  @override
  String get apr => 'April';

  @override
  String get may => 'May';

  @override
  String get jun => 'June';

  @override
  String get jul => 'July';

  @override
  String get aug => 'August';

  @override
  String get sep => 'September';

  @override
  String get oct => 'October';

  @override
  String get nov => 'November';

  @override
  String get dec => 'December';

  @override
  String get monday => 'Monde';

  @override
  String get tuesday => 'Tiusde';

  @override
  String get wednesday => 'Wenesde';

  @override
  String get thursday => 'Tursde';

  @override
  String get friday => 'Fride';

  @override
  String get saturday => 'Saturde';

  @override
  String get sunday => 'Sunde';

  @override
  String get predicted => 'Predicted';

  @override
  String get today => 'Today';

  @override
  String get noSymptomsLogged => 'You never log any symptom yet';

  @override
  String get loggedSymptoms => 'Symptoms wey you don log';

  @override
  String get menstrual => 'Menstrual';

  @override
  String get follicular => 'Follicular';

  @override
  String get luteal => 'Luteal';
}
