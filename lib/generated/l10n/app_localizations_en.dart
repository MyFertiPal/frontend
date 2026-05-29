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
  String get welcomeToJourney => 'Welcome to Your Journey';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Choose a unique username';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Create a strong password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => 'Enter phone number';

  @override
  String fieldRequired(Object field) {
    return '$field is required';
  }

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordStrength =>
      'Password must contain uppercase, lowercase, and number';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get firstAndLastName => 'Please enter first and last name';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get validPhoneNumber => 'Enter a valid phone number';

  @override
  String get cycleSummary => 'Cycle Summary';

  @override
  String get fertileWindow => 'Fertile Window';

  @override
  String get ovulationDay => 'Ovulation Day';

  @override
  String get fertilityCountdown => 'Fertility Countdown';

  @override
  String daysUntilFertile(Object days) {
    return '$days days until fertile window';
  }

  @override
  String dayUntilFertile(Object day) {
    return '$day day until fertile window';
  }

  @override
  String get inFertileWindow => '🌟 You\'re in your fertile window now!';

  @override
  String get logCycleSee => 'Log your cycle to see countdown';

  @override
  String get fertilityStatus => 'Fertility Status';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get educational => 'Educational';

  @override
  String get support => 'Support';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logOut => 'Log out';

  @override
  String get logSymptoms => 'Log symptoms';

  @override
  String get trackCycle => 'Track Cycle';

  @override
  String get viewInsights => 'View Insights';

  @override
  String get readArticles => 'Read Articles';

  @override
  String get getSupport => 'Get Support';

  @override
  String get educationalHub => 'Educational Hub';

  @override
  String get article => 'Article';

  @override
  String get listen => 'Listen';

  @override
  String get english => 'English';

  @override
  String get readArticle => 'Read Article';

  @override
  String get playAudio => 'Play Audio';

  @override
  String get fertilityBasics => 'Fertility Basics';

  @override
  String get mythsAndFacts => 'Myths & Facts';

  @override
  String get playbackSpeed => 'Playback Speed';

  @override
  String get loadingAudio => 'Loading audio...';

  @override
  String get failedLoadAudio => 'Failed to load audio. Please try again.';

  @override
  String get playbackError => 'Playback error. Please try again.';

  @override
  String get howToUse => 'How to Use';

  @override
  String get contact => 'Contact Us';

  @override
  String get help => 'Help & Support';

  @override
  String aboutApp(Object appName) {
    return 'About $appName';
  }

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageSelected => 'Language selected';

  @override
  String get setupProfile => 'Set Up Profile';

  @override
  String get nextStep => 'Next Step';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get cycleInfo => 'Cycle Information';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get cycleLength => 'Cycle Length';

  @override
  String get periodLength => 'Period Length';

  @override
  String get ttcHistory => 'TTC History';

  @override
  String get supportFeedback => 'Support Feedback';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get contactSupportMessage =>
      'Need help or have questions? Send us an email and we\'ll get back to you as soon as possible.';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get periodDay => 'Period Day';

  @override
  String get logPeriod => 'Log Period';

  @override
  String get selectDates => 'Select dates';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get minsRead => '5 mins read';

  @override
  String get genderPredictions => 'Gender Predictions';

  @override
  String get findSpecialist => 'Find Specialist';

  @override
  String get chatWithSpecialist => 'Chat with Specialist';

  @override
  String get profileSettings => 'Profile & Settings';

  @override
  String get notSet => 'Not set';

  @override
  String get faithPreference => 'Faith Preference';

  @override
  String get lastPeriodDate => 'Last Period Date';

  @override
  String get days => 'days';

  @override
  String get preference => 'Preference';

  @override
  String get language => 'Language';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get dataPrivacyPolicy => 'Data Privacy Policy';

  @override
  String get manageDataPermissions => 'Manage Data & Permissions';

  @override
  String get exploreMyData => 'Explore my Data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'Once you delete your account, there is no going back. This action is permanent and cannot be undone.';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully.';

  @override
  String get deleteAccountFailed => 'Failed to delete account';

  @override
  String get supportHub => 'Support hub';

  @override
  String get supportHubSubtitle =>
      'Mental health support and daily affirmations';

  @override
  String get dailyAffirmation => 'Daily affirmation';

  @override
  String get audioEncouragement => 'Audio encouragement';

  @override
  String get audioTitle => 'My Sister, Hold your Head High';

  @override
  String get culturalGuidance => 'Cultural Guidance';

  @override
  String get culturalGuidanceDescription =>
      'Coping with family pressure and finding peace in community support. Explore recommended readings and groups.';

  @override
  String get communityGroups => 'Community groups';

  @override
  String get create => 'Create';

  @override
  String get fertilityCircle => 'Fertility Circle';

  @override
  String get generalSupport => 'General Support';

  @override
  String get members => 'members';

  @override
  String get latestMessage => 'Sarah: Thank you all for the support!';

  @override
  String get exploreCommunityGroups => 'Explore Community Groups';

  @override
  String get groupChatComingSoon => 'Group chat coming soon';

  @override
  String get howToUseFertipath => 'How to Use MyFertiPal';

  @override
  String get welcomeToFertipath => 'Welcome to MyFertiPal!';

  @override
  String get guideIntro =>
      'Follow these steps to get the best results from our fertility tracking features.';

  @override
  String get step1Title => 'Complete Your Profile';

  @override
  String get step1Description =>
      'Go to Profile → Settings to enter your cycle length, period length, and faith preference. Accurate data helps us provide better predictions.';

  @override
  String get step2Title => 'Track Your Period';

  @override
  String get step2Description =>
      'Tap the Calendar tab and select the days you\'re on your period. This helps us predict your next cycle, fertile window, and ovulation day.';

  @override
  String get step3Title => 'Log Daily Symptoms';

  @override
  String get step3Description =>
      'Use the \"Log Symptoms\" button to record mood, cervical mucus, basal body temperature, and other symptoms. This improves prediction accuracy.';

  @override
  String get step4Title => 'Check Your Insights';

  @override
  String get step4Description =>
      'Your home screen shows daily fertility insights based on your data. Review fertile days, ovulation predictions, and cycle summaries.';

  @override
  String get step5Title => 'Listen to Audio Content';

  @override
  String get step5Description =>
      'Explore the Educational Hub for articles and audio lessons. Use the speed controls (0.75x - 2x) to adjust playback to your preference.';

  @override
  String get step6Title => 'Get Mental Health Support';

  @override
  String get step6Description =>
      'Visit the Support tab for faith-based affirmations and resources. Choose your faith preference in settings for personalized content.';

  @override
  String get step7Title => 'Review Predictions';

  @override
  String get step7Description =>
      'Your calendar marks predicted next period days with red outlined circles. Past periods appear as filled red circles.';

  @override
  String get proTips => 'Pro Tips';

  @override
  String get proTipsContent =>
      '• Log symptoms daily for 2-3 cycles to get the most accurate predictions\n\n• Update your period dates as soon as your cycle starts\n\n• Check your fertile window to plan or avoid conception\n\n• Use audio content at 1.25x or 1.5x speed to learn faster\n\n• Enable notifications to get reminders for symptom logging';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get needHelpContent =>
      'If you have questions or encounter issues, visit the Support tab or check the Educational Hub for detailed guides on fertility tracking.';

  @override
  String get loggedSymptoms => 'Logged Symptoms';

  @override
  String get clear => 'Clear';

  @override
  String get noSymptomsLogged => 'No symptoms logged yet.';

  @override
  String get calendarCleared => 'Calendar and next period days cleared.';

  @override
  String get failedToClearCalendar => 'Failed to clear calendar days';

  @override
  String get mood => 'Mood';

  @override
  String get bleeding => 'Bleeding';

  @override
  String get cervicalMucus => 'Cervical Mucus';

  @override
  String get sexualActivity => 'Sexual Activity';

  @override
  String get pain => 'Pain';

  @override
  String get abdominalCramps => 'Abdominal Cramps';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get anxiety => 'Anxiety';

  @override
  String get moodSwings => 'Mood swings';

  @override
  String get sadness => 'Sadness';

  @override
  String get light => 'Light';

  @override
  String get medium => 'Medium';

  @override
  String get heavy => 'Heavy';

  @override
  String get spotting => 'Spotting';

  @override
  String get dry => 'Dry';

  @override
  String get sticky => 'Sticky';

  @override
  String get creamy => 'Creamy';

  @override
  String get watery => 'Watery';

  @override
  String get eggWhite => 'Egg white';

  @override
  String get protected => 'Protected';

  @override
  String get unprotected => 'Unprotected';

  @override
  String get none => 'None';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get selectSymptom => 'Select symptom';

  @override
  String get selectAtLeastOneSymptom => 'Please select at least one symptom';

  @override
  String get symptomsLoggedSuccessfully => 'Symptoms logged successfully!';

  @override
  String get failedToSaveSymptoms => 'Failed to save symptoms';

  @override
  String get noSymptomsSelected =>
      'No symptoms selected yet. Tap a symptom to begin.';

  @override
  String get selectPreferredLanguage => 'Select Preferred Language';

  @override
  String get pleaseSelectLanguage => 'Please select a language';

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
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get signInWithFacebook => 'Sign In with Facebook';

  @override
  String get registerTitle => 'Register';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get sendingVerificationCode => 'Sending verification code...';

  @override
  String get failedToSendVerificationCode => 'Failed to send verification code';

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
  String get mythsFacts => 'Myths & Facts';

  @override
  String get article1Title =>
      'How Pregnancy Happens: A Simple Guide to Conception';

  @override
  String get article1Excerpt =>
      'Conception happens when sperm fertilizes an egg and the embryo implants. Learn when the fertile window opens and how health, timing, and patience support TTC.';

  @override
  String get article1Content =>
      'Getting pregnant happens when a sperm fertilizes an egg and the fertilized egg successfully implants in the uterus. Understanding this helps improve your chances.\n\nUnderstanding the fertile window\nYou are most likely to conceive during the fertile window: the days leading up to and including ovulation (about 14 days before the next period in a regular cycle). Because sperm can live in the body for several days, pregnancy can happen if sperm is present during this time.\n\nHealthy body, better chances\nGood overall health supports conception. Eat balanced meals, stay hydrated, manage stress, sleep well, and avoid smoking and alcohol. Maintaining a healthy weight matters, since being underweight or overweight can affect ovulation.\n\nTracking ovulation\n- Monitoring menstrual cycles (this is included in the Fertilpath app)\n- Watching for changes in cervical mucus\n- Using ovulation predictor kits\n\nThese tools help you know your most fertile days.\n\nMedical checkups matter\nBefore trying to conceive, see a healthcare provider. They can advise on prenatal vitamins like folic acid, review any health conditions, and guide you toward a healthy pregnancy.\n\nPatience is normal\nEven with perfect timing, it can take months to conceive. That is normal and does not always mean something is wrong. Consider seeing a doctor if you have tried for 12 months (or sooner if over 35).';

  @override
  String get article2Title => 'How Long Does Ovulation Last?';

  @override
  String get article2Excerpt =>
      'Ovulation is brief (12-24 hours), but sperm can live up to five days. Knowing this window helps plan or prevent pregnancy.';

  @override
  String get article2Content =>
      'Ovulation is when an ovary releases a mature egg. The egg lives about 12 to 24 hours, and can be fertilized only in that short time.\n\nThe fertile window\nEven though ovulation is brief, sperm can survive in the reproductive tract for up to five days. Pregnancy can happen if sperm are present in the days before ovulation or on the ovulation day itself.\n\nWhen ovulation occurs\nIn a regular cycle, ovulation is roughly 14 days before the next period, but timing varies by person and by cycle.\n\nSigns of ovulation\nSome people notice mild lower abdominal discomfort or changes in cervical mucus around ovulation. These clues can help identify fertile days, but they differ for everyone.\n\nWhy it matters\nKnowing how long ovulation lasts and how long sperm survive can guide timing for conception, family planning, or simply understanding your body.';

  @override
  String get article3Title => 'Infertility Is Not a Curse';

  @override
  String get article3Excerpt =>
      'In many Nigerian and African communities, pressure to conceive is heavy. Infertility is a medical challenge, not a curse or a failure.';

  @override
  String get article3Content =>
      'If you are trying to conceive and it has not happened yet, remember this: infertility is not a curse or a punishment.\n\nIn many Nigerian and African societies, motherhood is tightly linked to identity, and delays can bring painful pressure. Terms like \"barren\" or \"waiting on God\" can leave emotional wounds, but difficulty conceiving is a medical and biological challenge, not a spiritual verdict.\n\nInfertility has many possible causes: hormonal imbalances, infections, fibroids, blocked tubes, age, stress, or male-factor issues. Men and women are affected nearly equally, yet women often carry the blame alone.\n\nYou deserve care, not shame. Seeking medical help does not mean you lack faith. Many women conceive after proper diagnosis, treatment, lifestyle changes, or assisted medical support. And even when the journey is long, your life has meaning and purpose beyond motherhood.\n\nBe kind to yourself. Protect your mental and emotional health. Surround yourself with people who support you, ask questions, seek credible medical advice, and give yourself permission to hope—without self-blame. Your body is not your enemy, and your story is not over.';

  @override
  String get christianAffirmation1 =>
      '\"I can do all things through Christ who strengthens me.\"\n- Philippians 4:13';

  @override
  String get christianAffirmation2 =>
      '\"For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.\"\n- Jeremiah 29:11';

  @override
  String get christianAffirmation3 =>
      '\"The Lord is my shepherd; I shall not want.\"\n- Psalm 23:1';

  @override
  String get muslimAffirmation1 =>
      '\"So verily, with the hardship, there is relief.\"\n- Quran 94:6';

  @override
  String get muslimAffirmation2 =>
      '\"And He found you lost and guided [you].\"\n- Quran 93:7';

  @override
  String get muslimAffirmation3 =>
      '\"Indeed, Allah is with the patient.\"\n- Quran 2:153';

  @override
  String get traditionalistAffirmation1 =>
      'Your ancestors walked through storms and found their way. You carry their strength within you.';

  @override
  String get traditionalistAffirmation2 =>
      'The earth provides in its own time. Trust the natural rhythm of life and your body.';

  @override
  String get traditionalistAffirmation3 =>
      'Community and family are your pillars. Draw strength from those who love you and walk beside you.';

  @override
  String get traditionalistAffirmation4 =>
      'Like the baobab tree that bends but does not break, you are resilient through every season.';

  @override
  String get traditionalistAffirmation5 =>
      'The river flows around obstacles, not through them. Allow yourself grace and patience on this journey.';

  @override
  String get neutralAffirmation1 =>
      'You are resilient and capable of overcoming any challenge.';

  @override
  String get neutralAffirmation2 =>
      'Every day is a new beginning. Embrace it with hope and courage.';

  @override
  String get neutralAffirmation3 =>
      'You are enough, just as you are. Believe in your journey.';

  @override
  String get genderPredictionTitle => 'Gender Prediction';

  @override
  String get genderPredictionDisclaimer =>
      'Disclaimer: This feature uses AI to provide gender prediction advice. These predictions may not be fully accurate and should not replace professional medical advice. Please consult a qualified doctor for health decisions.';

  @override
  String get selectGenderExpectation => 'Select your gender expectation:';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get noPreference => 'No Preference';

  @override
  String get fertileWindowLabel => 'Fertile Window';

  @override
  String get ovulationDayLabel => 'Ovulation Day';

  @override
  String get adviceForTiming => 'Advice for intercourse timing:';

  @override
  String get bestChanceForMale => 'Best chance for male conception.';

  @override
  String get lowerChanceForMale => 'Lower chance for male.';

  @override
  String get bestChanceForFemale => 'Best chance for female conception.';

  @override
  String get lowerChanceForFemale => 'Lower chance for female.';

  @override
  String get generalAdviceForConception => 'General advice for conception.';

  @override
  String get noPredictionDataAvailable =>
      'No gender prediction data available yet. Select a gender and ensure your cycle data is up to date.';

  @override
  String get readAffirmationAloud => 'Read affirmation aloud';

  @override
  String get failedPlayAffirmation =>
      'Failed to play affirmation. Please try again.';

  @override
  String get failedPlayAudio => 'Failed to play audio. Please try again.';
}
