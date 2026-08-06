// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hausa (`ha`).
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appTitle => 'MyFertiPal';

  @override
  String get appSubtitle => 'Tafiyar Kula da Haihuwa Ta Ku';

  @override
  String get welcome => 'Barka da zuwa';

  @override
  String get login => 'Shiga';

  @override
  String get createAccount => 'Ƙirƙiri Asusun';

  @override
  String get dontHaveAccount => 'Ba ku da asusu?';

  @override
  String get signInWithGoogle => 'Shiga da Google';

  @override
  String get register => 'Yi Rajista';

  @override
  String get email => 'Adireshin Imel';

  @override
  String get forgotPassword => 'Kun manta kalmar sirri?';

  @override
  String get rememberEmail => 'Tuna Imel';

  @override
  String get required => 'Ana buƙata';

  @override
  String googleSignInFailed(Object error) {
    return 'Shigar Google ya kasa: $error';
  }

  @override
  String get logYourSymptoms => 'Rubuta Alamomin Ku 📝';

  @override
  String get symptomReminderBody =>
      'Yaya kuke ji yau? Ƙara alamominku don samun ingantaccen bayani game da haihuwa.';

  @override
  String get fullName => 'Cikakken Suna';

  @override
  String get username => 'Sunan Mai Amfani';

  @override
  String get confirmPassword => 'Tabbatar da Kalmar Sirri';

  @override
  String get phoneNumber => 'Lambar Waya';

  @override
  String get signUpWith => 'Yi rajista da';

  @override
  String get alreadyHaveAccount => 'Kun riga kuna da asusu?';

  @override
  String get cancel => 'Soke';

  @override
  String get submit => 'Aika';

  @override
  String get pleaseCorrectErrors =>
      'Da fatan za a gyara kurakuran da aka nuna kafin ci gaba.';

  @override
  String get unexpectedError =>
      'An sami kuskuren da ba a zata ba. Da fatan a sake gwadawa.';

  @override
  String get invalidEmail => 'Imel ba daidai ba';

  @override
  String get usernameTooShort => 'Sunan mai amfani ya yi gajarta';

  @override
  String get sendingVerificationCode => 'Ana aika lambar tabbatarwa';

  @override
  String get verifyYourAccount => 'Tabbatar da Asusunku';

  @override
  String get verificationCodeSent =>
      'An aika lambar tabbatarwa zuwa imel ɗinku.';

  @override
  String get resendingOtp => 'Ana sake aika OTP...';

  @override
  String get verificationCodeResent =>
      'An sake aika lambar tabbatarwa cikin nasara';

  @override
  String get unableToResendOtp =>
      'Ba za a iya sake aika OTP ba. Da fatan a sake gwadawa.';

  @override
  String get incorrectVerificationCode =>
      'Lambar tabbatarwa ba daidai ba ce. Da fatan a sake gwadawa.';

  @override
  String get pleaseEnterCompleteOtp =>
      'Da fatan a shigar da cikakkiyar lambar OTP';

  @override
  String get verify => 'Tabbatar';

  @override
  String get skip => 'Tsallake';

  @override
  String get next => 'Na gaba';

  @override
  String get trackYourCycle => 'Bibiyi Zagayen Ku';

  @override
  String get trackYourCycleDesc =>
      'Kula da zagayen ku cikin sauƙi kuma ku sami shawarwari na musamman';

  @override
  String get learnInYourLanguage => 'Koyi da harshen ku';

  @override
  String get learnInYourLanguageDesc =>
      'Samun ilimin haihuwa da bayanai cikin harshen da kuka fi fahimta';

  @override
  String get feelSupported => 'Samun Taimako';

  @override
  String get feelSupportedDesc =>
      'Kasance cikin al\'umma mai tallafi kuma ku sami taimakon da kuke buƙata';

  @override
  String get sendPasswordResetLink => 'Aika hanyar sake saita kalmar sirri';

  @override
  String get enterYourAccountEmail =>
      'Shigar da imel ɗin asusunka, za mu aika maka da hanyar sake saita kalmar sirri.';

  @override
  String get sendLink => 'Aika Hanya';

  @override
  String get checkYourEmail => 'Duba Imel ɗinka';

  @override
  String get resetLinkSent =>
      'Mun aika maka da hanyar sake saita kalmar sirri. Danna maɓallin da ke cikin imel ɗin don sake saita kalmar sirri.';

  @override
  String get checkSpamFolder => '📧 Kar ka manta ka duba babban fayil ɗin spam';

  @override
  String get didntReceiveEmail => 'Ba ka sami imel ɗin ba? Sake aikawa';

  @override
  String get backToLogin => 'Koma Shafin Shiga';

  @override
  String get resetPassword => 'Sake Saita Kalmar Sirri';

  @override
  String get newPassword => 'Sabuwar Kalmar Sirri';

  @override
  String get enterNewPassword => 'Shigar da sabuwar kalmar sirri';

  @override
  String get passwordAtLeast6 =>
      'Kalmar sirri dole ta kasance aƙalla haruffa 6';

  @override
  String get invalidOrMissingToken =>
      'Alamar izini ba ta da inganci ko ta ɓace.';

  @override
  String get failedToResetPassword => 'An kasa sake saita kalmar sirri.';

  @override
  String get passwordUpdated => 'An Sabunta Kalmar Sirri';

  @override
  String get passwordSuccessfully =>
      'An sabunta kalmar sirrinka cikin nasara. Yanzu za ka iya shiga da sabbin bayananka.';

  @override
  String get emailHint => 'misali@example.com';

  @override
  String get pleaseEnterValidEmail =>
      'Da fatan za ka shigar da imel mai inganci don ci gaba.';

  @override
  String resetLinkSentMessage(Object email) {
    return 'Mun aika maka da amintacciyar hanyar sake saita kalmar sirri zuwa $email.';
  }

  @override
  String get unableToSendLink =>
      'Ba za a iya aika hanyar ba. Ka sake gwadawa daga baya.';

  @override
  String get enterNewPasswordDescription =>
      'Shigar da sabuwar kalmar sirrinka a ƙasa don kare asusunka.';

  @override
  String get tokenRequired => 'Ana buƙatar alamar izini.';

  @override
  String get passwordMinimumLength =>
      'Kalmar sirri dole ta kasance aƙalla haruffa 8.';

  @override
  String get passwordsDoNotMatch => 'Kalmomin sirri ba su yi daidai ba.';

  @override
  String get unableToResetPassword =>
      'Ba za a iya sake saita kalmar sirri ba. Ka sake gwadawa daga baya.';

  @override
  String get profileSetup => 'Kammala Bayanan Ka';

  @override
  String get profileSetupInfo =>
      'Wannan zai taimaka mana mu tsara jagorar zagayowarka';

  @override
  String get completeYourProfile => 'Mu kammala bayananka';

  @override
  String get age => 'Shekaru';

  @override
  String get ageInfoText => 'Zaɓi shekarunka';

  @override
  String get cycleLength => 'Tsawon Zagaye';

  @override
  String get selectCycleLength => 'Zaɓi tsawon zagaye';

  @override
  String days(int count) {
    return '$count Kwanaki';
  }

  @override
  String get averageCycleDays =>
      'Matsakaicin kwanakin da ke tsakanin al\'adunka';

  @override
  String get periodLength => 'Tsawon Al\'ada';

  @override
  String get selectPeriodLength => 'Zaɓi tsawon lokacin al\'ada';

  @override
  String get typicalPeriodDays => 'Adadin kwanakin da al\'adarka ke ɗauka';

  @override
  String get lastPeriodDate => 'Ranar Ƙarshe ta Al\'ada';

  @override
  String get selectLastPeriodDate => 'Zaɓi ranar da al\'adarka ta fara';

  @override
  String get lastPeriodStartedInfo => 'Lokacin da jinin al\'adarka ya fara';

  @override
  String get ttcHistory => 'Tarihin Neman Haihuwa';

  @override
  String get selectTtcHistory => 'Zaɓi tarihin neman haihuwa';

  @override
  String get tryingToConceive => 'Ina ƙoƙarin samun ciki';

  @override
  String get tryingToConceiveDefault => 'Ƙoƙarin samun ciki - tsoho';

  @override
  String get preparingToConceive => 'Ina shirin samun ciki';

  @override
  String get justTrackingCycle => 'Ina bin zagayowata kawai';

  @override
  String get ttcSixMonths => 'Neman ciki fiye da watanni 6';

  @override
  String get ttcTwelveMonths => 'Neman ciki fiye da watanni 12';

  @override
  String get usingFertilityTreatment => 'Ina amfani da maganin haihuwa';

  @override
  String get preferNotToSay => 'Ban so in faɗa';

  @override
  String get faithPreference => 'Zaɓin Addini';

  @override
  String get selectFaithPreference => 'Zaɓi addininka';

  @override
  String get christian => 'Kirista';

  @override
  String get muslim => 'Musulmi';

  @override
  String get traditionalist => 'Mai bin al\'adun gargajiya';

  @override
  String get neutral => 'Ba tare da fifiko ba';

  @override
  String get audioGuidance => 'Jagorar Murya';

  @override
  String get enableAudioGuidance => 'Kunna jagorar murya';

  @override
  String get termsAndConditionsAgreement =>
      'Na yarda da Sharuɗɗa da Ka\'idoji da Dokar Sirri';

  @override
  String get continueButton => 'Ci gaba';

  @override
  String get profileSetupComplete => 'An kammala bayanan martaba!';

  @override
  String get goodMorning => 'Barka da safiya,';

  @override
  String get goodAfternoon => 'Barka da rana,';

  @override
  String get goodEvening => 'Barka da yamma,';

  @override
  String get cycle => 'Zagaye';

  @override
  String get fertileWindow => 'Lokacin Haihuwa';

  @override
  String get ovulation => 'Fitar Kwai';

  @override
  String get period => 'Al\'ada';

  @override
  String day(int count) {
    return 'Rana ta $count';
  }

  @override
  String get quickActions => 'Ayyuka Masu Sauri';

  @override
  String get logSymptoms => 'Rubuta\nAlamomi';

  @override
  String get genderPrediction => 'Hasashen\nJinsi';

  @override
  String get calendar => 'Kalanda';

  @override
  String get todaysInsight => 'Shawarar Yau';

  @override
  String get defaultInsight =>
      'Shawarwarinka na musamman game da haihuwa zai bayyana a nan.';

  @override
  String get bookSpecialist => 'Yi magana da ƙwararre';

  @override
  String get expertGuidance =>
      'Samu taimako daga ƙwararrun likitocin haihuwa a kowane lokaci.';

  @override
  String get bookConsultation => 'Tsara Ganawa';

  @override
  String get profileSettings => 'Saituna';

  @override
  String get logOut => 'Fita';

  @override
  String get deleteAccount => 'Goge Asusun';

  @override
  String get personalInformation => 'Bayanan Kai';

  @override
  String get notifications => 'Sanarwa';

  @override
  String get privacySecurity => 'Sirri da Tsaro';

  @override
  String get aboutMyFertiPal => 'Game da MyFertiPal';

  @override
  String get premiumMember => 'Mamba na Premium';

  @override
  String get language => 'Harshe';

  @override
  String get languageUpdated => 'An sabunta harshe cikin nasara.';

  @override
  String get languageUpdateFailed => 'An kasa sabunta harshe.';

  @override
  String get deleteAccountMessage =>
      'Wannan zai goge asusunka da duk bayanan da aka adana. Ba za a iya dawo da shi ba.';

  @override
  String get delete => 'Goge';

  @override
  String get cyclesTracked => 'Zagayen da Aka Bi';

  @override
  String get symptomsLogged => 'Alamomin da Aka Rubuta';

  @override
  String get consultations => 'Ganawar Likita';

  @override
  String get password => 'Kalmar Sirri';

  @override
  String get passwordMinLength =>
      'Kalmar sirri dole ta kasance aƙalla haruffa 8';

  @override
  String fieldRequired(String field) {
    return '$field ana buƙata';
  }

  @override
  String get otpInfoText =>
      'Shigar da lambar tabbatarwa da aka aika zuwa imel ɗinka.';

  @override
  String get resendCode => 'Sake Aika Lamba';

  @override
  String get settings => 'Saituna';

  @override
  String get pleaseSelectLanguage => 'Da fatan zaɓi harshen da kake so';

  @override
  String get languageSelected => 'An zaɓi harshe cikin nasara';

  @override
  String get selectPreferredLanguage => 'Zaɓi harshen da kake so';

  @override
  String get connect => 'Haɗu';

  @override
  String get podcast => 'PODCAST';

  @override
  String get fertiTalks => 'FertiTalks na MyFertiPal';

  @override
  String get newEpisodesAvailable =>
      'Sabbin shirye-shirye suna samuwa a kowane lokaci';

  @override
  String get listenOnSpotify => 'Saurara a Spotify';

  @override
  String get connectWithOthers => 'Haɗu da wasu';

  @override
  String get whatsAppCommunity => 'Ƙungiyar WhatsApp';

  @override
  String get whatsAppCommunityDescription =>
      'Haɗu da mata, raba abubuwan da kika fuskanta kuma ki sami tallafi kan haihuwa.';

  @override
  String get joinCommunity => 'Shiga ƙungiyar';

  @override
  String get successStories => 'Labaran Nasara';

  @override
  String get successStoriesDescription =>
      'Labarai na gaskiya daga mata waɗanda suka ci gaba da bege kuma ba su daina ba.';

  @override
  String get beInspired => 'Sami ƙwarin gwiwa';

  @override
  String get faithEncouragement => 'Imani da Ƙarfafawa';

  @override
  String get faithEncouragementDescription =>
      'Tallafin da ya dogara da addini da ƙarfafawa na yau da kullum don tafiyarki.';

  @override
  String get getEncouraged => 'Sami ƙarfafawa';

  @override
  String get explore => 'Bincika & Koya';

  @override
  String get searchArticles => 'Nemo makaloli...';

  @override
  String get articles => 'Makaloli';

  @override
  String get specialists => 'Nemo ƙwararre';

  @override
  String get searchSpecialists => 'Nemo ƙwararru da suna ko fannin aiki';

  @override
  String get logSymptomsTitle => 'Log Symptoms';

  @override
  String get trackHowYouFeel => 'Track how you feel. Every detail helps.';

  @override
  String get selectSymptomsToLog => 'Select symptoms to log';

  @override
  String get chooseMoreThanOne => 'You can choose more than one';

  @override
  String get mood => 'Mood';

  @override
  String get happy => 'Happy';

  @override
  String get sad => 'Sad';

  @override
  String get anxious => 'Anxious';

  @override
  String get irritable => 'Irritable';

  @override
  String get calm => 'Calm';

  @override
  String get energetic => 'Energetic';

  @override
  String get bleeding => 'Bleeding';

  @override
  String get spotting => 'Spotting';

  @override
  String get light => 'Light';

  @override
  String get medium => 'Medium';

  @override
  String get heavy => 'Heavy';

  @override
  String get cervicalMucus => 'Cervical Mucus';

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
  String get sexualActivity => 'Sexual Activity';

  @override
  String get protected => 'Protected';

  @override
  String get unprotected => 'Unprotected';

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
  String get abdominalCramps => 'Abdominal Cramps';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get sleep => 'Sleep';

  @override
  String get good => 'Good';

  @override
  String get poor => 'Poor';

  @override
  String get insomnia => 'Insomnia';

  @override
  String get oversleeping => 'Oversleeping';

  @override
  String get appetite => 'Appetite';

  @override
  String get increased => 'Increased';

  @override
  String get decreased => 'Decreased';

  @override
  String get normal => 'Normal';

  @override
  String get cravings => 'Cravings';

  @override
  String get other => 'Other';

  @override
  String get describeFeeling => 'Describe what you\'re feeling';

  @override
  String get tip => 'Tip';

  @override
  String get symptomLoggingTip =>
      'Logging symptoms daily helps us give you more accurate insights.';

  @override
  String get saveSymptoms => 'Save Symptoms';

  @override
  String get symptomsSaved => 'Symptoms saved successfully';

  @override
  String failedToSaveSymptoms(Object error) {
    return 'Failed to save symptoms: $error';
  }

  @override
  String get symptoms => 'Symptoms';
}
