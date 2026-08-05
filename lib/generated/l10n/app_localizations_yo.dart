// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Yoruba (`yo`).
class AppLocalizationsYo extends AppLocalizations {
  AppLocalizationsYo([String locale = 'yo']) : super(locale);

  @override
  String get appTitle => 'MyFertiPal';

  @override
  String get appSubtitle => 'Ìrìnàjò Títọ́jú Ìbímọ Rẹ';

  @override
  String get welcome => 'Kaabo';

  @override
  String get login => 'Wọlé';

  @override
  String get createAccount => 'Ṣẹ̀dá Àkọọlẹ';

  @override
  String get dontHaveAccount => 'Ṣe o kò ní àkọọlẹ?';

  @override
  String get signInWithGoogle => 'Wọlé pẹ̀lú Google';

  @override
  String get register => 'Forúkọsílẹ̀';

  @override
  String get email => 'Àdírẹ́sì imeeli';

  @override
  String get forgotPassword => 'Gbagbé Ọ̀rọ̀ aṣínà?';

  @override
  String get rememberEmail => 'Rántí imeeli';

  @override
  String get required => 'Ó nílò rẹ̀';

  @override
  String googleSignInFailed(Object error) {
    return 'Wíwọlé Google kuna: $error';
  }

  @override
  String get logYourSymptoms => 'Kọ Àwọn Àmì Rẹ Sílẹ̀ 📝';

  @override
  String get symptomReminderBody =>
      'Báwo ni ara rẹ ṣe rí lónìí? Ṣafikun àwọn àmì rẹ láti gba ìmọ̀ràn tó dára síi nípa ìbímọ.';

  @override
  String get fullName => 'Orúkọ Kíkún';

  @override
  String get username => 'Orúkọ Olùlò';

  @override
  String get confirmPassword => 'Jẹ́rìí Ọ̀rọ̀ aṣínà';

  @override
  String get phoneNumber => 'Nọ́mbà Fóònù';

  @override
  String get signUpWith => 'Forúkọsílẹ̀ pẹ̀lú';

  @override
  String get alreadyHaveAccount => 'Ṣe o ti ní àkọọlẹ tẹ́lẹ̀?';

  @override
  String get cancel => 'Fagilee';

  @override
  String get submit => 'Firanṣẹ́';

  @override
  String get pleaseCorrectErrors =>
      'Jọ̀wọ́ ṣàtúnṣe àwọn aṣiṣe tí a samisi kí o tó tẹ̀síwájú.';

  @override
  String get unexpectedError =>
      'Aṣiṣe tí a kò retí ṣẹlẹ̀. Jọ̀wọ́ tún gbìyànjú.';

  @override
  String get invalidEmail => 'Imeeli kò tọ́';

  @override
  String get usernameTooShort => 'Orúkọ olùlò kúrú jù';

  @override
  String get sendingVerificationCode => 'Ń rán kóòdù ìmúdájú';

  @override
  String get verifyYourAccount => 'Jẹ́rìí Àkọọlẹ Rẹ';

  @override
  String get verificationCodeSent => 'A ti rán kóòdù ìmúdájú sí imeeli rẹ.';

  @override
  String get resendingOtp => 'Ń tún rán OTP...';

  @override
  String get verificationCodeResent => 'A tún rán kóòdù ìmúdájú dáadáa';

  @override
  String get unableToResendOtp =>
      'A kò lè tún rán OTP. Jọ̀wọ́ gbìyànjú lẹ́ẹ̀kan síi.';

  @override
  String get incorrectVerificationCode =>
      'Kóòdù ìmúdájú kò tọ́. Jọ̀wọ́ gbìyànjú lẹ́ẹ̀kan síi.';

  @override
  String get pleaseEnterCompleteOtp => 'Jọ̀wọ́ tẹ gbogbo kóòdù OTP sílẹ̀';

  @override
  String get verify => 'Jẹ́rìí';

  @override
  String get skip => 'Foju kọ́';

  @override
  String get next => 'Tẹ̀síwájú';

  @override
  String get trackYourCycle => 'Tọ́pinpin Àyíká Rẹ';

  @override
  String get trackYourCycleDesc =>
      'Ṣàbójútó àyíká rẹ ní rọrùn kí o sì gba ìmọ̀ràn tó dá lórí rẹ';

  @override
  String get learnInYourLanguage => 'Kọ́ ní èdè tirẹ';

  @override
  String get learnInYourLanguageDesc =>
      'Gba ẹ̀kọ́ àti àlàyé nípa ìbímọ ní èdè tí o mọ̀ dáadáa';

  @override
  String get feelSupported => 'Gba ìrànlọ́wọ́';

  @override
  String get feelSupportedDesc =>
      'Darapọ̀ mọ́ àwùjọ tó ń ṣe atilẹyin fún ọ ní ìrìnàjò rẹ';

  @override
  String get sendPasswordResetLink => 'Firanṣẹ́ ìjápọ̀ àtúnṣe ọ̀rọ̀ aṣínà';

  @override
  String get enterYourAccountEmail =>
      'Tẹ imeeli àkọọlẹ rẹ sílẹ̀, a ó fi ìjápọ̀ sí ọ láti tún ọ̀rọ̀ aṣínà rẹ ṣe.';

  @override
  String get sendLink => 'Firanṣẹ́ Ìjápọ̀';

  @override
  String get checkYourEmail => 'Ṣàyẹ̀wò Imeeli Rẹ';

  @override
  String get resetLinkSent => 'A ti fi ìjápọ̀ àtúnṣe ọ̀rọ̀ aṣínà ránṣẹ́ sí ọ.';

  @override
  String get checkSpamFolder => '📧 Má ṣe gbàgbé láti ṣàyẹ̀wò àpò spam rẹ';

  @override
  String get didntReceiveEmail => 'O kò gba imeeli náà? Tun rán';

  @override
  String get backToLogin => 'Padà sí Wíwọlé';

  @override
  String get resetPassword => 'Tún Ọ̀rọ̀ aṣínà Ṣe';

  @override
  String get newPassword => 'Ọ̀rọ̀ aṣínà Tuntun';

  @override
  String get enterNewPassword => 'Tẹ ọ̀rọ̀ aṣínà tuntun sílẹ̀';

  @override
  String get passwordAtLeast6 => 'Ọ̀rọ̀ aṣínà gbọ́dọ̀ ní o kere tán lẹ́tà 6';

  @override
  String get invalidOrMissingToken => 'Token kò tọ́ tàbí kò sí.';

  @override
  String get failedToResetPassword => 'Àtúnṣe ọ̀rọ̀ aṣínà kuna.';

  @override
  String get passwordUpdated => 'A ti ṣe àtúnṣe Ọ̀rọ̀ aṣínà';

  @override
  String get passwordSuccessfully =>
      'A ti ṣe àtúnṣe ọ̀rọ̀ aṣínà rẹ dáadáa. O lè wọlé báyìí.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get pleaseEnterValidEmail => 'Jọ̀wọ́ tẹ imeeli tó tọ́ sílẹ̀.';

  @override
  String resetLinkSentMessage(Object email) {
    return 'A ti fi ìjápọ̀ ààbò ránṣẹ́ sí $email.';
  }

  @override
  String get unableToSendLink =>
      'A kò lè rán ìjápọ̀. Jọ̀wọ́ gbìyànjú lẹ́ẹ̀kan síi.';

  @override
  String get enterNewPasswordDescription =>
      'Tẹ ọ̀rọ̀ aṣínà tuntun rẹ sílẹ̀ láti dáàbò bo àkọọlẹ rẹ.';

  @override
  String get tokenRequired => 'Token nílò rẹ̀.';

  @override
  String get passwordMinimumLength =>
      'Ọ̀rọ̀ aṣínà gbọ́dọ̀ ní o kere tán lẹ́tà 8.';

  @override
  String get passwordsDoNotMatch => 'Àwọn ọ̀rọ̀ aṣínà kò bá ara mu.';

  @override
  String get unableToResetPassword =>
      'A kò lè tún ọ̀rọ̀ aṣínà ṣe. Jọ̀wọ́ tún gbìyànjú.';

  @override
  String get profileSetup => 'Parí Ìṣètò Àkọọlẹ Rẹ';

  @override
  String get profileSetupInfo =>
      'Èyí yóò ràn wá lọ́wọ́ láti ṣe àtúnṣe ìtọ́sọ́nà àyíká rẹ';

  @override
  String get completeYourProfile => 'Jẹ́ kí a parí àkọọlẹ rẹ';

  @override
  String get age => 'Ọjọ́ orí';

  @override
  String get ageInfoText => 'Yan ọjọ́ orí rẹ';

  @override
  String get cycleLength => 'Gígùn Àyíká';

  @override
  String get selectCycleLength => 'Yan gígùn àyíká';

  @override
  String days(int count) {
    return 'Ọjọ́ $count';
  }

  @override
  String get averageCycleDays => 'Apapọ iye ọjọ́ láàárín àwọn oṣù rẹ';

  @override
  String get periodLength => 'Gígùn Àkókò Oṣù';

  @override
  String get selectPeriodLength => 'Yan gígùn àkókò oṣù';

  @override
  String get typicalPeriodDays => 'Iye ọjọ́ tí oṣù rẹ máa ń wà';

  @override
  String get lastPeriodDate => 'Ọjọ́ Oṣù Kẹ́yìn';

  @override
  String get selectLastPeriodDate => 'Yan ọjọ́ tí oṣù rẹ kẹ́yìn bẹ̀rẹ̀';

  @override
  String get lastPeriodStartedInfo => 'Nígbà tí ẹ̀jẹ̀ oṣù rẹ kẹ́yìn bẹ̀rẹ̀';

  @override
  String get ttcHistory => 'Ìtàn TTC';

  @override
  String get selectTtcHistory => 'Yan ìtàn TTC rẹ';

  @override
  String get tryingToConceive => 'Ń Gbìyànjú Láti Loyun';

  @override
  String get tryingToConceiveDefault => 'Ń Gbìyànjú Láti Loyun - àiyipada';

  @override
  String get preparingToConceive => 'Ń Múra Sílẹ̀ Láti Loyun';

  @override
  String get justTrackingCycle => 'Ń Tọ́pinpin Àyíká Mi Nìkan';

  @override
  String get ttcSixMonths => 'TTC Oṣù 6+';

  @override
  String get ttcTwelveMonths => 'TTC Oṣù 12+';

  @override
  String get usingFertilityTreatment => 'Ń Lo Ìtọ́jú Ìbímọ';

  @override
  String get preferNotToSay => 'Mo fẹ́ kí n má sọ';

  @override
  String get faithPreference => 'Ìfẹ́ Ẹ̀sìn';

  @override
  String get selectFaithPreference => 'Yan ìfẹ́ ẹ̀sìn rẹ';

  @override
  String get christian => 'Kristẹni';

  @override
  String get muslim => 'Musulumi';

  @override
  String get traditionalist => 'Ẹlẹ́sin Ìbílẹ̀';

  @override
  String get neutral => 'Kò sí ààyò';

  @override
  String get audioGuidance => 'Ìtọ́sọ́nà Ohùn';

  @override
  String get enableAudioGuidance => 'Jẹ́ kí ìtọ́sọ́nà ohùn ṣiṣẹ́';

  @override
  String get termsAndConditionsAgreement =>
      'Mo gba Àwọn Òfin àti Àdéhùn àti Ìlànà Àṣírí';

  @override
  String get continueButton => 'Tẹ̀síwájú';

  @override
  String get profileSetupComplete => 'A ti parí ìṣètò àkọọlẹ!';

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
  String get bookSpecialist => 'Book Specialist';

  @override
  String get expertGuidance =>
      'Get expert guidance from certified fertility doctors, anytime.';

  @override
  String get bookConsultation => 'Book Consultation';

  @override
  String get profileSettings => 'Ètò';

  @override
  String get logOut => 'Jáde';

  @override
  String get deleteAccount => 'Paarẹ Àkọọlẹ';

  @override
  String get personalInformation => 'Alaye Ti Ara Ẹni';

  @override
  String get notifications => 'Àwọn Ìkìlọ̀';

  @override
  String get privacySecurity => 'Àṣírí àti Aabo';

  @override
  String get aboutMyFertiPal => 'Nípa MyFertiPal';

  @override
  String get premiumMember => 'Ọmọ Ẹgbẹ́ Premium';

  @override
  String get language => 'Èdè';

  @override
  String get languageUpdated => 'A ti yí èdè padà dáadáa.';

  @override
  String get languageUpdateFailed => 'Yíyí èdè padà kuna.';

  @override
  String get deleteAccountMessage =>
      'Èyí yóò pa àkọọlẹ rẹ àti gbogbo àlàyé tí a tọ́pinpin rẹ rẹ́. A kò lè dá a padà.';

  @override
  String get delete => 'Paarẹ';

  @override
  String get cyclesTracked => 'Àwọn Àyíká Tí A Tọ́pinpin';

  @override
  String get symptomsLogged => 'Àwọn Àmì Tí A Kọ Sílẹ̀';

  @override
  String get consultations => 'Àwọn Ìpàdé Ìmọ̀ràn';

  @override
  String get password => 'Ọ̀rọ̀ aṣínà';

  @override
  String get passwordMinLength => 'Ọ̀rọ̀ aṣínà gbọ́dọ̀ ní o kere tán lẹ́tà 8';

  @override
  String fieldRequired(String field) {
    return '$field nílò rẹ̀';
  }

  @override
  String get otpInfoText => 'Tẹ kóòdù ìmúdájú tí a fi ránṣẹ́ sí imeeli rẹ.';

  @override
  String get resendCode => 'Tun Firanṣẹ́ Kóòdù';

  @override
  String get settings => 'Ètò';

  @override
  String get pleaseSelectLanguage => 'Jọ̀wọ́ yan èdè tí o fẹ́';

  @override
  String get languageSelected => 'A ti yan èdè dáadáa';

  @override
  String get selectPreferredLanguage => 'Yan èdè tí o fẹ́ lo';
}
