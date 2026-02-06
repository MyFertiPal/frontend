// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hausa (`ha`).
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appTitle => 'Fertipath';

  @override
  String get appSubtitle => 'Your Fertility Tracking Journey';

  @override
  String get welcome => 'Sannu';

  @override
  String get welcomeToJourney => 'Welcome to Your Journey';

  @override
  String get register => 'Yi Koyi';

  @override
  String get login => 'Shiga';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Ƙirƙiri akawu';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Malimai sirri?';

  @override
  String get resetPassword => 'Sake Sada Kalmar Sirri';

  @override
  String get dontHaveAccount => 'Ba ku da akaụnt? ';

  @override
  String get alreadyHaveAccount => 'Kin da ni akawu?';

  @override
  String get fullName => 'Cikakken Suna';

  @override
  String get email => 'Iméèlì';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get username => 'Suna Mai Amfani';

  @override
  String get usernameHint => 'Choose a unique username';

  @override
  String get password => 'Kalmar Sirri';

  @override
  String get passwordHint => 'Create a strong password';

  @override
  String get confirmPassword => 'Tabbatar da Kalmar Sirri';

  @override
  String get phoneNumber => 'Nomban Wayar';

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
  String get fertileWindow => 'Lokacin haihuwa';

  @override
  String get ovulationDay => 'Ranar Haifuwa';

  @override
  String get fertilityCountdown => 'Lanƙwan Haihuwa';

  @override
  String daysUntilFertile(Object days) {
    return '$days kwanaki har zuwa lokacin haihuwa';
  }

  @override
  String dayUntilFertile(Object day) {
    return '$day kwana har zuwa lokacin haihuwa';
  }

  @override
  String get inFertileWindow => '🌟 Kin iko a lokacin haihuwa yanzu!';

  @override
  String get logCycleSee => 'Bi da agogo don ganin lanƙwa';

  @override
  String get fertilityStatus => 'Fertility Status';

  @override
  String get home => 'Gida';

  @override
  String get calendar => 'Kalanda';

  @override
  String get educational => 'Karatu';

  @override
  String get support => 'Taimako';

  @override
  String get profile => 'Bayani';

  @override
  String get settings => 'Saita';

  @override
  String get logOut => 'Log out';

  @override
  String get logSymptoms => 'Rubuta Alamomi';

  @override
  String get trackCycle => 'Bi da Lokaci';

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
  String get fertilityBasics => 'Ainihin Asara Jiya';

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
  String get help => 'Taimako';

  @override
  String aboutApp(Object appName) {
    return 'About $appName';
  }

  @override
  String get success => 'Nasara';

  @override
  String get error => 'Kuskure';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get loading => 'Ana charge';

  @override
  String get noData => 'No data available';

  @override
  String get tryAgain => 'Sake ƙoƙari';

  @override
  String get cancel => 'Soki';

  @override
  String get submit => 'Kashe';

  @override
  String get save => 'Ajiya';

  @override
  String get delete => 'Gida';

  @override
  String get edit => 'Gyara';

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
  String get skip => 'Tsallake';

  @override
  String get finish => 'Finish';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get cycleInfo => 'Bayani lokaci';

  @override
  String get dateOfBirth => 'Rana haifa';

  @override
  String get cycleLength => 'Cycle Length';

  @override
  String get periodLength => 'Period Length';

  @override
  String get ttcHistory => 'TTC History';

  @override
  String get supportFeedback => 'Support Feedback';

  @override
  String get sendFeedback => 'Aika fahimta';

  @override
  String get reportIssue => 'Baje matsala';

  @override
  String get contactSupport => 'Tunada da taimako';

  @override
  String get contactSupportMessage =>
      'Kuna buƙatar taimako ko kuna da tambayoyi? Aika mana da imel kuma za mu mayar da ku da wuri.';

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
  String get genderPredictions => 'Hasashen Jinsi';

  @override
  String get findSpecialist => 'Nemo Ƙwararre';

  @override
  String get chatWithSpecialist => 'Yi Hira da Ƙwararre';

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
  String get language => 'Harshe';

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
  String get supportHub => 'Cibiyar Taimako';

  @override
  String get supportHubSubtitle =>
      'Taimakon lafiya ta hankali da ƙarfafawa na yau da kullum';

  @override
  String get dailyAffirmation => 'Ƙarfafawa ta yau da kullum';

  @override
  String get audioEncouragement => 'Ƙarfafawa ta sauti';

  @override
  String get audioTitle => '\'Yar Uwata, Dauke kai sama';

  @override
  String get culturalGuidance => 'Jagora na Al\'ada';

  @override
  String get culturalGuidanceDescription =>
      'Yadda za ku jimre wa matsin iyali da samun kwanciyar hankali a cikin goyon bayan al\'umma. Duba karatun da muka bayar da haɗuwa da ƙungiyoyi.';

  @override
  String get communityGroups => 'Ƙungiyoyin al\'umma';

  @override
  String get create => 'Ƙirƙira';

  @override
  String get fertilityCircle => 'Taron Haihuwa';

  @override
  String get generalSupport => 'Taimako na Gabaɗaya';

  @override
  String get members => 'mambobi';

  @override
  String get latestMessage => 'Sarah: Na gode wa ku duka don goyon baya!';

  @override
  String get exploreCommunityGroups => 'Bincika Ƙungiyoyin Al\'umma';

  @override
  String get groupChatComingSoon =>
      'Tattaunawar ƙungiyar tana zuwa nan ba da jimawa ba';

  @override
  String get howToUseFertipath => 'Yadda Ake Amfani da Fertipath';

  @override
  String get welcomeToFertipath => 'Maraba zuwa Fertipath!';

  @override
  String get guideIntro =>
      'Bi waɗannan matakai don samun sakamako mafi kyau daga fasalin bin haihuwa.';

  @override
  String get step1Title => 'Kammala Bayanan Ku';

  @override
  String get step1Description =>
      'Je zuwa Profile → Settings don shigar da tsawon zagayowar ku, tsawon lokacin al\'ada, da zaɓin bangaskiya. Bayanan daidai suna taimaka mana mu ba da hasashen da suka fi kyau.';

  @override
  String get step2Title => 'Bi Lokacin Al\'ada';

  @override
  String get step2Description =>
      'Danna shafin Kalanda kuma zaɓi kwanakin da kuke cikin al\'ada. Wannan yana taimaka mana mu hasashe zagayowar ku na gaba, lokacin haihuwa, da ranar fitarwar kwai.';

  @override
  String get step3Title => 'Rubuta Alamomi na Yau da Kullum';

  @override
  String get step3Description =>
      'Yi amfani da maɓallin \"Rubuta Alamomi\" don rikodin yanayin rai, gamshewar mahaifa, zafin jiki na ƙasa, da sauran alamomi. Wannan yana inganta daidaiton hasashe.';

  @override
  String get step4Title => 'Duba Fahimtar Ku';

  @override
  String get step4Description =>
      'Shafin gida yana nuna fahimtar haihuwa na yau da kullum bisa bayanan ku. Duba kwanakin haihuwa, hasashen fitarwar kwai, da taƙaitaccen zagayowar.';

  @override
  String get step5Title => 'Saurari Abun Ciki na Audio';

  @override
  String get step5Description =>
      'Bincika Educational Hub don labarai da darussa na audio. Yi amfani da sarrafa sauri (0.75x - 2x) don daidaita kunna zuwa abin da kuke so.';

  @override
  String get step6Title => 'Samun Goyon Bayan Lafiyar Hankali';

  @override
  String get step6Description =>
      'Ziyarci shafin Support don ƙarfafawa da tushen bangaskiya da kayayyaki. Zaɓi zaɓin bangaskiya a cikin saiti don abun ciki na musamman.';

  @override
  String get step7Title => 'Duba Hasashe';

  @override
  String get step7Description =>
      'Kalandar ku yana alamta kwanakin al\'ada na gaba da aka hasashe da da\'irori masu launi ja. Al\'adu da suka gabata suna bayyana a matsayin da\'irori ja cike.';

  @override
  String get proTips => 'Shawarwarin Ƙwararru';

  @override
  String get proTipsContent =>
      '• Rubuta alamomi yau da kullum na zagayoyi 2-3 don samun hasashe mafi daidai\n\n• Sabunta kwanakin al\'ada ku da zarar zagayowar ku ta fara\n\n• Duba lokacin haihuwa ku don shirya ko guje wa ciki\n\n• Yi amfani da abun ciki na audio a 1.25x ko 1.5x sauri don koyo da sauri\n\n• Kunna sanarwa don samun tunatarwa don rubuta alamomi';

  @override
  String get needHelp => 'Kuna Buƙatar Taimako?';

  @override
  String get needHelpContent =>
      'Idan kuna da tambayoyi ko kuna fuskantar matsaloli, ziyarci shafin Support ko duba Educational Hub don cikakkun jagororin bin haihuwa.';

  @override
  String get loggedSymptoms => 'Alamomi da Aka Rubuta';

  @override
  String get clear => 'Goge';

  @override
  String get noSymptomsLogged => 'Ba a rubuta alamomi ba tukuna.';

  @override
  String get calendarCleared => 'An goge kalanda da kwanakin al\'ada na gaba.';

  @override
  String get failedToClearCalendar => 'An kasa goge kwanakin kalanda';

  @override
  String get mood => 'Kamar yadda kake';

  @override
  String get bleeding => 'Jiya lokaci';

  @override
  String get cervicalMucus => 'Mucus Jiya';

  @override
  String get sexualActivity => 'Lokaci Na Jima';

  @override
  String get pain => 'Zafi';

  @override
  String get abdominalCramps => 'Zafi Cikin Jiya';

  @override
  String get fatigue => 'Gajiya';

  @override
  String get anxiety => 'Fahimta';

  @override
  String get moodSwings => 'Canji Kamar Yadda Kake';

  @override
  String get sadness => 'Bakin Ciki';

  @override
  String get light => 'Kadan';

  @override
  String get medium => 'Tsaka-tsaki';

  @override
  String get heavy => 'Yawa';

  @override
  String get spotting => 'Kadan Kadan';

  @override
  String get dry => 'Bushewa';

  @override
  String get sticky => 'Damshi';

  @override
  String get creamy => 'Krimu';

  @override
  String get watery => 'Ruwa';

  @override
  String get eggWhite => 'Farin Kwai';

  @override
  String get protected => 'Tare da Kariya';

  @override
  String get unprotected => 'Ba tare da Kariya ba';

  @override
  String get none => 'Babu';

  @override
  String get mild => 'Kadan';

  @override
  String get moderate => 'Tsaka-tsaki';

  @override
  String get severe => 'Sosai';

  @override
  String get selectSymptom => 'Zabar Alamomi';

  @override
  String get selectAtLeastOneSymptom => 'Biko zabar aƙalla ɗaya';

  @override
  String get symptomsLoggedSuccessfully => 'Alamomi an rubuta su fa!';

  @override
  String get failedToSaveSymptoms => 'Alamomi ba a rubutu su ba';

  @override
  String get noSymptomsSelected => 'Babu alamomi da aka zabar a yanzu.';

  @override
  String get selectPreferredLanguage => 'Zaɓi Harshen Da Kuke So';

  @override
  String get pleaseSelectLanguage => 'Don Allah zaɓi harshe';

  @override
  String get next => 'Gaba';

  @override
  String get trackYourCycle => 'Bi Zagayowar Ku';

  @override
  String get trackYourCycleDesc =>
      'Lura da zagayowar ku cikin sauƙi kuma samun bayanan da suka dace';

  @override
  String get learnInYourLanguage => 'Koyi cikin yaren ku';

  @override
  String get learnInYourLanguageDesc =>
      'Samun ilimin haihuwa da kayayyaki cikin yaren da kuka fahimta mafi kyau';

  @override
  String get feelSupported => 'Ku ji goyon baya';

  @override
  String get feelSupportedDesc =>
      'Shiga cikin al\'umma mai kulawa kuma samun goyon bayan da kuke buƙata a tafiyar ku';

  @override
  String get forgetPassword => 'Manta Kalmar Sirri.';

  @override
  String get signInWithGoogle => 'Shiga Da Google';

  @override
  String get signInWithFacebook => 'Shiga Da Facebook';

  @override
  String get registerTitle => 'Yi Koyi';

  @override
  String get passwordsDoNotMatch => 'Kalmomin sirri ba su dace ba';

  @override
  String get sendingVerificationCode => 'Aika lambar tabbatar...';

  @override
  String get failedToSendVerificationCode => 'An kasa aika lambar tabbatar';

  @override
  String get sendPasswordResetLink => 'Aika hanyar sake sada kalmar sirri';

  @override
  String get enterYourAccountEmail =>
      'Shigar da iméèlì akaũntin ka kuma aika ka goɗi ɗin sada kalmar sirri.';

  @override
  String get sendLink => 'Aika Goɗi';

  @override
  String get checkYourEmail => 'Duba Iméèlì Nka';

  @override
  String get resetLinkSent =>
      'Mun aika maka goɗi sada kalmar sirri. Buga bọ̀tin a cikin iméèlì don sada kalmar sirri.';

  @override
  String get checkSpamFolder => '📧 Kada manta dubawa folder spam nka';

  @override
  String get didntReceiveEmail => 'Ba ka karbo iméèlì ba? Aika sake';

  @override
  String get backToLogin => 'Koma Shiga';

  @override
  String get newPassword => 'Sabuwar Kalmar Sirri';

  @override
  String get enterNewPassword => 'Shigar da sabuwar kalmar sirri';

  @override
  String get passwordAtLeast6 => 'Kalmar sirri dole taba kene 6 k\'ara';

  @override
  String get invalidOrMissingToken => 'Token ba shi da kyau ko ba shi.';

  @override
  String get failedToResetPassword => 'An kasa sake sada kalmar sirri.';

  @override
  String get passwordUpdated => 'Kalmar Sirri Ta Sake Sada';

  @override
  String get passwordSuccessfully =>
      'Kalmar sirri nka ta sake sada cikin nasara. Kina iya shiga da sabuwar kalmar sirri nka.';

  @override
  String get mythsFacts => 'Jita & Gaskiyar';

  @override
  String get article1Title =>
      'Kamar Yadda Saura Ta Faru: Karanta Sakaci na Amfani da Saura';

  @override
  String get article1Excerpt =>
      'Saura ta faru lokacin da sperm ya tsunduma kwai kuma embryo ya shiga inuwa. Koyi lokacin da wazi furewa kuma kamar yadda lafiya, koli, da jiya sai da TTC.';

  @override
  String get article1Content =>
      'Saura ta faru lokacin da sperm ya tsunduma kwai kuma embryo ya shiga inuwa da sasaukar. Fahimtar haka yana taimaka maka sami saura.';

  @override
  String get article2Title => 'Yaya Tsunduma Kwai Ya Zama?';

  @override
  String get article2Excerpt =>
      'Tsunduma kwai shine kolin kadan (12-24 awar), sai da sperm zai iya zama har zuwa kwanaki biyar. Fahimtar wazi yana taimaka maka tsara ko dakatar da saura.';

  @override
  String get article2Content =>
      'Tsunduma kwai shine lokacin da ovary ta fito da kwai. Kwai yana nan kamar awar 12 zuwa 24 kuma zai iya zama jiya ga duk lokacin.';

  @override
  String get article3Title => 'Rashin Saura Ba Sata Ba Ne';

  @override
  String get article3Excerpt =>
      'A cikin yawancin jamaat na Nigeria da Afirka, matsi na saura ya yi. Rashin saura shine jiya, ba sata ba ko gazawa.';

  @override
  String get article3Content =>
      'In ka yi kokarin saura mun kowa kuma bai faru ba, tuna haka: rashin saura ba sata ba ne ko aziyya.';

  @override
  String get christianAffirmation1 =>
      '\"Zan iya yin duk abubuwa ta wurin Kristi wanda yake ba ni ƙarfi.\"\n- Filipiyawa 4:13';

  @override
  String get christianAffirmation2 =>
      '\"Domin na san shirye-shiryen da nake da su dominka, in ji Ubangiji, shirye-shiryen alheri ne, ba na sharri ba, don in ba ku bege da nan gaba.\"\n- Irmiya 29:11';

  @override
  String get christianAffirmation3 =>
      '\"Ubangiji shi ne makiyayina; ba zan rasa kome ba.\"\n- Zabura 23:1';

  @override
  String get muslimAffirmation1 =>
      '\"Saboda haka, lalle, tare da wahala, akwai sauƙi.\"\n- Alƙur\'ani 94:6';

  @override
  String get muslimAffirmation2 =>
      '\"Ya kuma same ka a ɓace ya kuma shirya ka.\"\n- Alƙur\'ani 93:7';

  @override
  String get muslimAffirmation3 =>
      '\"Lalle ne, Allah yana tare da masu haƙuri.\"\n- Alƙur\'ani 2:153';

  @override
  String get traditionalistAffirmation1 =>
      'Kakanninka sun bi ta cikin hadari suka sami hanyarsu. Kana ɗauke da ƙarfinsu a cikinka.';

  @override
  String get traditionalistAffirmation2 =>
      'Ƙasa tana bayarwa a lokacinta. Ka dogara ga yanayin halitta na rayuwa da jikinka.';

  @override
  String get traditionalistAffirmation3 =>
      'Al\'umma da danginka su ne ginshiƙanka. Ka ɗauki ƙarfi daga waɗanda suke ƙaunarka suna tafiya tare da kai.';

  @override
  String get traditionalistAffirmation4 =>
      'Kamar itacen baobab wanda yake lankwasawa amma ba ya karyewa, kana da juriya a kowane lokaci.';

  @override
  String get traditionalistAffirmation5 =>
      'Kogi yana gudu a kusa da cikas, ba ta wurinsu ba. Ka ba wa kanka alheri da haƙuri a wannan tafiya.';

  @override
  String get neutralAffirmation1 =>
      'Kana da juriya kuma kana iya shawo kan kowace ƙalubale.';

  @override
  String get neutralAffirmation2 =>
      'Kowace rana wani farko ne. Ka karɓa shi da bege da ƙarfin hali.';

  @override
  String get neutralAffirmation3 =>
      'Kai isashe ne, kamar yadda kake. Ka yi imani da tafiyarka.';

  @override
  String get genderPredictionTitle => 'Hasashen Jinsi';

  @override
  String get genderPredictionDisclaimer =>
      'Ìkéde: Wannan sifa ta yi amfani da AI don ba da shawarar hasashen jinsi. Wa\'annan bashashewaye ba su tabbace tsaye kuma ba sa kamata su maye gurbin shawara ta likita. Jiya gida ga likita mai gida don tunanin kula da lafiya.';

  @override
  String get selectGenderExpectation => 'Zabar jinsi wanda kake bukatan:';

  @override
  String get male => 'Namiji';

  @override
  String get female => 'Mace';

  @override
  String get noPreference => 'Babu za\'a';

  @override
  String get fertileWindowLabel => 'Lokacin saura';

  @override
  String get ovulationDayLabel => 'Ranar tsunduma kwai';

  @override
  String get adviceForTiming => 'Shawarar lokacin jima\'i:';

  @override
  String get bestChanceForMale => 'Mafi kyau saurar namiji.';

  @override
  String get lowerChanceForMale => 'Watarain saurar namiji.';

  @override
  String get bestChanceForFemale => 'Mafi kyau saurar mace.';

  @override
  String get lowerChanceForFemale => 'Watarain saurar mace.';

  @override
  String get generalAdviceForConception =>
      'Shawarar gaba\'aya don saurar jiya.';

  @override
  String get noPredictionDataAvailable =>
      'Babu bashashewa na saura a yanzu. Zabar jinsi kuma tabbatar da cewa bayananin agogo nka daidai.';

  @override
  String get readAffirmationAloud => 'Karanta imani a jarir';

  @override
  String get failedPlayAffirmation => 'An kasa bugawa imani. Jiya yi sau.';

  @override
  String get failedPlayAudio => 'An kasa bugawa sauti. Jiya yi sau.';
}
