// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Igbo (`ig`).
class AppLocalizationsIg extends AppLocalizations {
  AppLocalizationsIg([String locale = 'ig']) : super(locale);

  @override
  String get appTitle => 'MyFertiPal';

  @override
  String get appSubtitle => 'Njem Nlekọta Ọmụmụ Gị';

  @override
  String get welcome => 'Nnọọ';

  @override
  String get login => 'Banye';

  @override
  String get createAccount => 'Mepụta Akaụntụ';

  @override
  String get dontHaveAccount => 'Ị nweghị akaụntụ?';

  @override
  String get signInWithGoogle => 'Banye site na Google';

  @override
  String get register => 'Debanye aha';

  @override
  String get email => 'Adreesị ozi-e';

  @override
  String get forgotPassword => 'Chefuru paswọọdụ?';

  @override
  String get rememberEmail => 'Cheta ozi-e';

  @override
  String get required => 'Achọrọ';

  @override
  String googleSignInFailed(Object error) {
    return 'Nbanye Google dara: $error';
  }

  @override
  String get logYourSymptoms => 'Detuo Mgbaàmà Gị 📝';

  @override
  String get symptomReminderBody =>
      'Kedu ka ị na-adị taa? Tinye mgbaàmà gị iji nweta nghọta gbasara ọmụmụ ka mma.';

  @override
  String get fullName => 'Aha zuru ezu';

  @override
  String get username => 'Aha njirimara';

  @override
  String get confirmPassword => 'Kwenye paswọọdụ';

  @override
  String get phoneNumber => 'Nọmba ekwentị';

  @override
  String get signUpWith => 'Debanye site na';

  @override
  String get alreadyHaveAccount => 'Ị nwere akaụntụ ugbua?';

  @override
  String get cancel => 'Kagbuo';

  @override
  String get submit => 'Zipu';

  @override
  String get pleaseCorrectErrors =>
      'Biko dozie njehie ndị e gosiri tupu ị gaa n\'ihu.';

  @override
  String get unexpectedError =>
      'Njehie a na-atụghị anya ya mere. Biko nwaa ọzọ.';

  @override
  String get invalidEmail => 'Ozi-e ezighi ezi';

  @override
  String get usernameTooShort => 'Aha njirimara dị mkpụmkpụ';

  @override
  String get sendingVerificationCode => 'Na-eziga koodu nkwenye';

  @override
  String get verifyYourAccount => 'Kwenye Akaụntụ Gị';

  @override
  String get verificationCodeSent => 'Ezigaala koodu nkwenye na ozi-e gị.';

  @override
  String get resendingOtp => 'Na-ezighachi OTP...';

  @override
  String get verificationCodeResent => 'Ezighachila koodu nkwenye nke ọma';

  @override
  String get unableToResendOtp => 'Enweghị ike izighachi OTP. Biko nwaa ọzọ.';

  @override
  String get incorrectVerificationCode =>
      'Koodu nkwenye ezighi ezi. Biko nwaa ọzọ.';

  @override
  String get pleaseEnterCompleteOtp => 'Biko tinye koodu OTP zuru ezu';

  @override
  String get verify => 'Kwenye';

  @override
  String get skip => 'Wụpụ';

  @override
  String get next => 'Ọzọ';

  @override
  String get trackYourCycle => 'Soro okirikiri gị';

  @override
  String get trackYourCycleDesc =>
      'Jikwaa okirikiri gị n\'ụzọ dị mfe ma nweta nghọta onwe gị';

  @override
  String get learnInYourLanguage => 'Mụta n\'asụsụ nke gị';

  @override
  String get learnInYourLanguageDesc =>
      'Nweta mmụta gbasara ọmụmụ n\'asụsụ ị ghọtara nke ọma';

  @override
  String get feelSupported => 'Nweta nkwado';

  @override
  String get feelSupportedDesc =>
      'Soro obodo na-akwado gị ma nweta enyemaka n\'oge njem gị';

  @override
  String get sendPasswordResetLink => 'Zipu njikọ ịtọgharịa paswọọdụ';

  @override
  String get enterYourAccountEmail =>
      'Tinye ozi-e akaụntụ gị ka anyị ziga gị njikọ ịtọgharịa paswọọdụ.';

  @override
  String get sendLink => 'Zipu Njikọ';

  @override
  String get checkYourEmail => 'Lelee Ozi-e Gị';

  @override
  String get resetLinkSent => 'Anyị ezitela gị njikọ ịtọgharịa paswọọdụ.';

  @override
  String get checkSpamFolder => '📧 Echefukwala ilele spam gị';

  @override
  String get didntReceiveEmail => 'Ị nataghị ozi-e? Zighachi';

  @override
  String get backToLogin => 'Laghachi na Nbanye';

  @override
  String get resetPassword => 'Tọgharịa Paswọọdụ';

  @override
  String get newPassword => 'Paswọọdụ Ọhụrụ';

  @override
  String get enterNewPassword => 'Tinye paswọọdụ ọhụrụ';

  @override
  String get passwordAtLeast6 =>
      'Paswọọdụ ga-abụrịrị mkpụrụedemede 6 ma ọ bụ karịa';

  @override
  String get invalidOrMissingToken => 'Token ezighi ezi ma ọ bụ efu.';

  @override
  String get failedToResetPassword => 'Ịtọgharị paswọọdụ dara.';

  @override
  String get passwordUpdated => 'Emelitela Paswọọdụ';

  @override
  String get passwordSuccessfully =>
      'Emelitela paswọọdụ gị nke ọma. Ị nwere ike ịbanye ugbu a.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get pleaseEnterValidEmail =>
      'Biko tinye ozi-e ziri ezi ka ị gaa n\'ihu.';

  @override
  String resetLinkSentMessage(Object email) {
    return 'Anyị ezitela njikọ nchekwa na $email.';
  }

  @override
  String get unableToSendLink => 'Enweghị ike izipu njikọ. Biko nwaa ọzọ.';

  @override
  String get enterNewPasswordDescription =>
      'Tinye paswọọdụ ọhụrụ gị iji chekwaa akaụntụ gị.';

  @override
  String get tokenRequired => 'Achọrọ token.';

  @override
  String get passwordMinimumLength =>
      'Paswọọdụ ga-abụrịrị mkpụrụedemede 8 ma ọ bụ karịa.';

  @override
  String get passwordsDoNotMatch => 'Paswọọdụ abụọ adịghị otu.';

  @override
  String get unableToResetPassword =>
      'Enweghị ike ịtọgharị paswọọdụ. Biko nwaa ọzọ.';

  @override
  String get profileSetup => 'Mezue Profaịlụ Gị';

  @override
  String get profileSetupInfo =>
      'Nke a ga-enyere anyị ịhazi ntuziaka okirikiri gị';

  @override
  String get completeYourProfile => 'Ka anyị mezue profaịlụ gị';

  @override
  String get age => 'Afọ';

  @override
  String get ageInfoText => 'Họrọ afọ gị';

  @override
  String get cycleLength => 'Ogologo Okirikiri';

  @override
  String get selectCycleLength => 'Họrọ ogologo okirikiri';

  @override
  String days(int count) {
    return 'Ụbọchị $count';
  }

  @override
  String get averageCycleDays => 'Ọnụọgụ ụbọchị dị n\'etiti nsọ gị';

  @override
  String get periodLength => 'Ogologo Oge Nsọ';

  @override
  String get selectPeriodLength => 'Họrọ ogologo oge nsọ';

  @override
  String get typicalPeriodDays => 'Ụbọchị nsọ na-adịkarị';

  @override
  String get lastPeriodDate => 'Ụbọchị Nsọ Ikpeazụ';

  @override
  String get selectLastPeriodDate => 'Họrọ ụbọchị nsọ ikpeazụ malitere';

  @override
  String get lastPeriodStartedInfo => 'Mgbe ọbara nsọ ikpeazụ gị malitere';

  @override
  String get ttcHistory => 'Akụkọ TTC';

  @override
  String get selectTtcHistory => 'Họrọ akụkọ TTC gị';

  @override
  String get tryingToConceive => 'Na-achọ Ịtụrụ Ime';

  @override
  String get tryingToConceiveDefault => 'Na-achọ Ịtụrụ Ime - ndabara';

  @override
  String get preparingToConceive => 'Na-akwado Ịtụrụ Ime';

  @override
  String get justTrackingCycle => 'Na-esochi Okirikiri M naanị';

  @override
  String get ttcSixMonths => 'TTC ọnwa 6+';

  @override
  String get ttcTwelveMonths => 'TTC ọnwa 12+';

  @override
  String get usingFertilityTreatment => 'Na-eji ọgwụgwọ ọmụmụ';

  @override
  String get preferNotToSay => 'Achọghị m ikwu';

  @override
  String get faithPreference => 'Okpukpe';

  @override
  String get selectFaithPreference => 'Họrọ okpukpe gị';

  @override
  String get christian => 'Onye Kraịst';

  @override
  String get muslim => 'Onye Alakụba';

  @override
  String get traditionalist => 'Onye omenala';

  @override
  String get neutral => 'Enweghị mmasị';

  @override
  String get audioGuidance => 'Nduzi Olu';

  @override
  String get enableAudioGuidance => 'Kwado nduzi olu';

  @override
  String get termsAndConditionsAgreement =>
      'Ekwenyere m Usoro na Ọnọdụ yana Iwu Nzuzo';

  @override
  String get continueButton => 'Gaa n\'ihu';

  @override
  String get profileSetupComplete => 'Emechala nhazi profaịlụ!';

  @override
  String get goodMorning => 'Ụtụtụ ọma,';

  @override
  String get goodAfternoon => 'Ehihie ọma,';

  @override
  String get goodEvening => 'Mgbede ọma,';

  @override
  String get cycle => 'Okirikiri';

  @override
  String get fertileWindow => 'Oge ọmụmụ';

  @override
  String get ovulation => 'Ịhapụ akwa';

  @override
  String get period => 'Nsọ';

  @override
  String day(int count) {
    return 'Ụbọchị $count';
  }

  @override
  String get quickActions => 'Omume ngwa ngwa';

  @override
  String get logSymptoms => 'Detuo Mgbaàmà';

  @override
  String get genderPrediction => 'Amụma\nMmekọahụ nwa';

  @override
  String get calendar => 'Kalenda';

  @override
  String get todaysInsight => 'Nghọta Taa';

  @override
  String get defaultInsight => 'Nghọta gbasara ọmụmụ gị ga-apụta ebe a.';

  @override
  String get bookSpecialist => 'Gwa ọkachamara okwu';

  @override
  String get expertGuidance =>
      'Nweta nduzi site n\'aka ndị dọkịta ọmụmụ nwere ikike.';

  @override
  String get bookConsultation => 'Debe oge ndụmọdụ';

  @override
  String get profileSettings => 'Ntọala';

  @override
  String get logOut => 'Pụọ';

  @override
  String get deleteAccount => 'Hichapụ Akaụntụ';

  @override
  String get personalInformation => 'Ozi Onwe Gị';

  @override
  String get notifications => 'Ọkwa';

  @override
  String get privacySecurity => 'Nzuzo na Nchekwa';

  @override
  String get aboutMyFertiPal => 'Banyere MyFertiPal';

  @override
  String get basicMember => 'Onye Otu Nkịtị';

  @override
  String get language => 'Asụsụ';

  @override
  String get languageUpdated => 'Emelitela asụsụ nke ọma.';

  @override
  String get languageUpdateFailed => 'Ịgbanwe asụsụ dara.';

  @override
  String get deleteAccountMessage =>
      'Nke a ga-ehichapụ akaụntụ gị na data niile. Enweghị ike ịgbanwe ya.';

  @override
  String get delete => 'Hichapụ';

  @override
  String get cyclesTracked => 'Okirikiri Edekọrọ';

  @override
  String get symptomsLogged => 'Mgbaàmà Edekọrọ';

  @override
  String get consultations => 'Ndụmọdụ';

  @override
  String get password => 'Paswọọdụ';

  @override
  String get passwordMinLength =>
      'Paswọọdụ ga-abụrịrị mkpụrụedemede 8 ma ọ bụ karịa';

  @override
  String fieldRequired(String field) {
    return 'Achọrọ $field';
  }

  @override
  String get otpInfoText => 'Tinye koodu nkwenye ezigara na ozi-e gị.';

  @override
  String get resendCode => 'Zighachi Koodu';

  @override
  String get settings => 'Ntọala';

  @override
  String get pleaseSelectLanguage => 'Biko họrọ asụsụ ịchọrọ';

  @override
  String get languageSelected => 'Ahọrọla asụsụ nke ọma';

  @override
  String get selectPreferredLanguage => 'Họrọ asụsụ ịchọrọ';

  @override
  String get connect => 'Jikọọ';

  @override
  String get podcast => 'PODCAST';

  @override
  String get fertiTalks => 'FertiTalks nke MyFertiPal';

  @override
  String get newEpisodesAvailable => 'A na-enwe akụkụ ọhụrụ mgbe niile';

  @override
  String get listenOnSpotify => 'Gee na Spotify';

  @override
  String get connectWithOthers => 'Jikọọ na ndị ọzọ';

  @override
  String get whatsAppCommunity => 'Obodo WhatsApp';

  @override
  String get whatsAppCommunityDescription =>
      'Jikọọ na ụmụ nwanyị, kesaa ahụmịhe gị ma nweta nkwado gbasara ọmụmụ.';

  @override
  String get joinCommunity => 'Soro obodo ahụ';

  @override
  String get successStories => 'Akụkọ Ịga nke Ọma';

  @override
  String get successStoriesDescription =>
      'Akụkọ ndị nwanyị n\'ezie bụ ndị nọgidere nwee olileanya ma ghara ịda mba.';

  @override
  String get beInspired => 'Nweta mkpali';

  @override
  String get faithEncouragement => 'Okwukwe na Nkwado';

  @override
  String get faithEncouragementDescription =>
      'Nkwado dabere n\'okwukwe na mkpali kwa ụbọchị maka njem gị.';

  @override
  String get getEncouraged => 'Nweta mkpali';

  @override
  String get explore => 'Nyochaa & Mụta';

  @override
  String get searchArticles => 'Chọọ edemede...';

  @override
  String get articles => 'Edemede';

  @override
  String get specialists => 'Chọta Ọkachamara';

  @override
  String get searchSpecialists =>
      'Chọọ ndị ọkachamara site n\'aha ma ọ bụ ngalaba ha';

  @override
  String get logSymptomsTitle => 'Detuo Mgbaàmà';

  @override
  String get trackHowYouFeel => 'Soro otú ị na-adị. Ihe ọ bụla dị mkpa.';

  @override
  String get selectSymptomsToLog => 'Họrọ mgbaàmà ị chọrọ idekọ';

  @override
  String get chooseMoreThanOne => 'Ị nwere ike ịhọrọ karịa otu';

  @override
  String get mood => 'Ọnọdụ uche';

  @override
  String get happy => 'Obi ụtọ';

  @override
  String get sad => 'Mwute';

  @override
  String get anxious => 'Nchekasị';

  @override
  String get irritable => 'Iwe ngwa ngwa';

  @override
  String get calm => 'Udo';

  @override
  String get energetic => 'Ike zuru oke';

  @override
  String get bleeding => 'Ọbara ọpụpụ';

  @override
  String get spotting => 'Obere ntụpọ ọbara';

  @override
  String get light => 'Obere';

  @override
  String get medium => 'Ọkara';

  @override
  String get heavy => 'Ọtụtụ';

  @override
  String get cervicalMucus => 'Mmiri dị n\'ọnụ akpa nwa';

  @override
  String get dry => 'Akọrọ';

  @override
  String get sticky => 'Na-arapara';

  @override
  String get creamy => 'Dị ka ude';

  @override
  String get watery => 'Dị ka mmiri';

  @override
  String get eggWhite => 'Dị ka akwa ọcha';

  @override
  String get sexualActivity => 'Mmekọahụ';

  @override
  String get protected => 'Echekwara';

  @override
  String get unprotected => 'Enweghị nchebe';

  @override
  String get none => 'Ọ dịghị';

  @override
  String get pain => 'Mgbu';

  @override
  String get headache => 'Isi ọwụwa';

  @override
  String get backPain => 'Mgbu azụ';

  @override
  String get breastTenderness => 'Mgbu ara';

  @override
  String get ovulationPain => 'Mgbu mgbe akwa na-apụta';

  @override
  String get abdominalCramps => 'Mgbu afọ';

  @override
  String get mild => 'Dị nro';

  @override
  String get moderate => 'Ọkara';

  @override
  String get severe => 'Siri ike';

  @override
  String get sleep => 'Ụra';

  @override
  String get good => 'Ọma';

  @override
  String get poor => 'Adịghị mma';

  @override
  String get insomnia => 'Enweghị ike ihi ụra';

  @override
  String get oversleeping => 'Ihi ụra nke ukwuu';

  @override
  String get appetite => 'Agụụ nri';

  @override
  String get increased => 'Abawanyela';

  @override
  String get decreased => 'Belatala';

  @override
  String get normal => 'Nkịtị';

  @override
  String get cravings => 'Ọchịchọ iri nri ụfọdụ';

  @override
  String get other => 'Ndị ọzọ';

  @override
  String get describeFeeling => 'Kọwaa ihe ị na-enwe';

  @override
  String get tip => 'Ndụmọdụ';

  @override
  String get symptomLoggingTip =>
      'Idekekọ mgbaàmà kwa ụbọchị na-enyere anyị inye gị nghọta ziri ezi gbasara ọmụmụ nwa gị.';

  @override
  String get saveSymptoms => 'Chekwaa Mgbaàmà';

  @override
  String get symptomsSaved => 'E chekwala mgbaàmà nke ọma';

  @override
  String failedToSaveSymptoms(Object error) {
    return 'Ọ gaghị ekwe omume ichekwa mgbaàmà: $error';
  }

  @override
  String get symptoms => 'Mgbaàmà';
}
