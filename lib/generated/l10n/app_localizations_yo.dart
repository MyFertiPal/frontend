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
  String get goodMorning => 'Ẹ káàárọ̀';

  @override
  String get goodAfternoon => 'Ẹ káàsán';

  @override
  String get goodEvening => 'Ẹ káalẹ́';

  @override
  String get cycle => 'Àyípadà oṣù';

  @override
  String get fertileWindow => 'Àkókò ìbímọ̀';

  @override
  String get ovulation => 'Ìtújáde ẹyin';

  @override
  String get period => 'Oṣù';

  @override
  String day(int count) {
    return 'Ọjọ́';
  }

  @override
  String get quickActions => 'Àwọn iṣẹ́ kíákíá';

  @override
  String get logSymptoms => 'Kọ Àwọn Àmì Sílẹ̀';

  @override
  String get genderPrediction => 'Àsọtẹ́lẹ̀ akọ tàbí abo ọmọ';

  @override
  String get calendar => 'Kàlẹ́ńdà';

  @override
  String get todaysInsight => 'Ìmọ̀ràn òní';

  @override
  String get defaultInsight =>
      'Ìmọ̀ràn pàtàkì nípa ìlera ìbímọ rẹ yóò hàn níbí.';

  @override
  String get bookSpecialist => 'Ba amọ̀ja sọ̀rọ̀';

  @override
  String get expertGuidance => 'Ìtọ́sọ́nà láti ọ̀dọ̀ amòye';

  @override
  String get bookConsultation => 'Pàṣẹ ìjíròrò pẹ̀lú amòye';

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
  String get basicMember => 'Ọmọ Ẹgbẹ́ Ìpilẹ̀';

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

  @override
  String get connect => 'Sopọ';

  @override
  String get podcast => 'PODCAST';

  @override
  String get fertiTalks => 'FertiTalks nipasẹ MyFertiPal';

  @override
  String get newEpisodesAvailable => 'Àwọn ìṣẹ̀lẹ̀ tuntun wà ní gbogbo ìgbà';

  @override
  String get listenOnSpotify => 'Tẹ́tí sí Spotify';

  @override
  String get connectWithOthers => 'Sopọ pẹlu àwọn míì';

  @override
  String get whatsAppCommunity => 'Àwùjọ WhatsApp';

  @override
  String get whatsAppCommunityDescription =>
      'Sopọ pẹlu àwọn obìnrin, pín ìrírí rẹ, kí o sì gba ìtìlẹ́yìn nípa ìbímọ.';

  @override
  String get joinCommunity => 'Darapọ mọ àwùjọ';

  @override
  String get successStories => 'Àwọn Ìtàn Àṣeyọrí';

  @override
  String get successStoriesDescription =>
      'Ìtàn gidi láti ọdọ àwọn obìnrin tí wọ́n ní ìrètí tí wọ́n kò sì fi ọwọ́ sílẹ̀.';

  @override
  String get beInspired => 'Ní ìmísí';

  @override
  String get faithEncouragement => 'Ìgbàgbọ́ àti Ìtìlẹ́yìn';

  @override
  String get faithEncouragementDescription =>
      'Ìtìlẹ́yìn tó dá lórí ìgbàgbọ́ àti ìmísí ojoojúmọ́ fún ìrìnàjò rẹ.';

  @override
  String get getEncouraged => 'Gba ìtìlẹ́yìn';

  @override
  String get explore => 'Ṣàwárí & Kọ́';

  @override
  String get searchArticles => 'Wa àwọn àpilẹ̀kọ...';

  @override
  String get articles => 'Àwọn Àpilẹ̀kọ';

  @override
  String get specialists => 'Wa Ọ̀jọ̀gbọ́n';

  @override
  String get searchSpecialists =>
      'Wa àwọn ọ̀jọ̀gbọ́n nípa orúkọ tàbí ẹ̀ka iṣẹ́ wọn';

  @override
  String get logSymptomsTitle => 'Ṣe Àkọsílẹ̀ Àwọn Àmì';

  @override
  String get trackHowYouFeel =>
      'Tẹ̀lé bí o ṣe ń rí lára. Gbogbo àlàyé ṣe pàtàkì.';

  @override
  String get selectSymptomsToLog => 'Yan àwọn àmì tí o fẹ́ kọ sílẹ̀';

  @override
  String get chooseMoreThanOne => 'O lè yan ju ọ̀kan lọ';

  @override
  String get mood => 'Ìmọ̀lára';

  @override
  String get happy => 'Ayọ̀';

  @override
  String get sad => 'Ìbànújẹ́';

  @override
  String get anxious => 'Ìdààmú ọkàn';

  @override
  String get irritable => 'Ìbínú rọrùn';

  @override
  String get calm => 'Ìfarabalẹ̀';

  @override
  String get energetic => 'Agbara kún fún';

  @override
  String get bleeding => 'Ẹ̀jẹ̀ jáde';

  @override
  String get spotting => 'Àmì ẹ̀jẹ̀ kékeré';

  @override
  String get light => 'Kéré';

  @override
  String get medium => 'Díẹ̀';

  @override
  String get heavy => 'Púpọ̀';

  @override
  String get cervicalMucus => 'Omi inú ọ̀nà ilé-ọmọ';

  @override
  String get dry => 'Gbígbẹ';

  @override
  String get sticky => 'Alárà';

  @override
  String get creamy => 'Bí kíríímù';

  @override
  String get watery => 'Bí omi';

  @override
  String get eggWhite => 'Bí funfun ẹyin';

  @override
  String get sexualActivity => 'Ìbálòpọ̀';

  @override
  String get protected => 'Pẹ̀lú ààbò';

  @override
  String get unprotected => 'Láìsí ààbò';

  @override
  String get none => 'Kò sí';

  @override
  String get pain => 'Ìrora';

  @override
  String get headache => 'Orí ọ̀fọ̀';

  @override
  String get backPain => 'Ìrora ẹ̀hìn';

  @override
  String get breastTenderness => 'Ìrora ọmú';

  @override
  String get ovulationPain => 'Ìrora ìtusilẹ̀ ẹyin';

  @override
  String get abdominalCramps => 'Ìrora inú';

  @override
  String get mild => 'Díẹ̀';

  @override
  String get moderate => 'Àárín';

  @override
  String get severe => 'Líle';

  @override
  String get sleep => 'Oorun';

  @override
  String get good => 'Dára';

  @override
  String get poor => 'Kò dára';

  @override
  String get insomnia => 'Àìsun oorun';

  @override
  String get oversleeping => 'Sísùn ju bó yẹ lọ';

  @override
  String get appetite => 'Ìfẹ́ oúnjẹ';

  @override
  String get increased => 'Ti pọ̀ sí i';

  @override
  String get decreased => 'Ti dín kù';

  @override
  String get normal => 'Déédéé';

  @override
  String get cravings => 'Ìfẹ́ pàtàkì sí oúnjẹ kan';

  @override
  String get other => 'Miíràn';

  @override
  String get describeFeeling => 'Ṣàlàyé ohun tí o ń ní ìrírí rẹ';

  @override
  String get tip => 'Ìmọ̀ràn';

  @override
  String get symptomLoggingTip =>
      'Kíkó àwọn àmì rẹ sílẹ̀ lojoojúmọ́ ń ràn wá lọ́wọ́ láti fún ọ ní ìmọ̀ràn tó péye sí i nípa ìbímọ.';

  @override
  String get saveSymptoms => 'Fipamọ́ Àwọn Àmì';

  @override
  String get symptomsSaved => 'A ti fipamọ́ àwọn àmì rẹ dáadáa';

  @override
  String failedToSaveSymptoms(Object error) {
    return 'A kò lè fipamọ́ àwọn àmì: $error';
  }

  @override
  String get symptoms => 'Àwọn Àmì';
}
