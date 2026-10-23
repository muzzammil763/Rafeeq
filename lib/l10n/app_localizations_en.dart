// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutBeginningBody =>
      'Rafeeq began with a simple idea from my elder brother. We are both software developers, and one day he decided to build an Islamic app that would bring essential Muslim needs such as the Qur\'an, Qiblah, prayer times and more together in one place. Later, I — Muzamil Ghafoor — joined him, and Rafeeq became a journey shared by two brothers.';

  @override
  String get aboutBeginningTitle => 'How Rafeeq began';

  @override
  String get aboutClosingStatement =>
      'Built by Muslims, for Muslims — for the Ummah of Prophet Muhammad (PBUH) and for the sake of Allah Almighty. ❤️ ';

  @override
  String get aboutCommunityBody =>
      'My brother and I are here for you. You can request a feature, report a bug or share an idea with us. We will listen, and we will keep doing our best to make Rafeeq better for Muslims everywhere.';

  @override
  String get aboutCommunityTitle => 'We are here for you';

  @override
  String get aboutDesignBody =>
      'When we first started, we did not have a complete design plan. Even after adding features, we often felt that something was still missing, so we rebuilt the app\'s entire design system twice. With this latest version, we have tried to create something minimal, clear and pleasantly refined. The Islamic app Sadiq was also a meaningful source of inspiration for us, and I am grateful for it.';

  @override
  String get aboutDesignTitle => 'Our design journey';

  @override
  String get aboutFreeBody =>
      'I want Rafeeq to remain free for everyone for its entire lifetime, In Sha Allah. In the future, we may add an optional way for Muslims to support the app\'s development and running costs. Any support will be used to maintain and improve Rafeeq; we do not intend to take anything from it for ourselves, In Sha Allah.';

  @override
  String get aboutFreeTitle => 'Free for life, In Sha Allah';

  @override
  String get aboutPortfolioOpenError => 'The portfolio could not be opened.';

  @override
  String get aboutSubtitle => 'The story and purpose behind Rafeeq';

  @override
  String get aboutTagline => 'Your Muslim Companion';

  @override
  String get aboutTogetherBody =>
      'Since then, my brother and I have worked on Rafeeq as a team. We started again together, gradually implemented the core features and kept adding more over time. Whenever our other responsibilities leave us some time, we come back to Rafeeq to improve it and thoughtfully prepare the next update.';

  @override
  String get aboutTogetherTitle => 'Growing together';

  @override
  String get aboutUmmahBody =>
      'For me, Rafeeq is more than just another software project. My brother and I want to keep improving it for the Ummah of Prophet Muhammad (PBUH). I am deeply thankful to Allah Almighty for giving us the ability to work on something that may benefit other Muslims.';

  @override
  String get aboutUmmahTitle => 'For the Ummah';

  @override
  String get allow => 'Allow';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get allowLocationDescription => 'Automatically updates prayer times.';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get appIconChanged => 'App Icon Changed';

  @override
  String get appIconRestartMessage =>
      'The app icon will be updated. Would you like to restart now to see the change immediately, or later when you open the app?';

  @override
  String get appTheme => 'App Theme';

  @override
  String get appTitle => 'Rafeeq';

  @override
  String get arabicFont => 'Arabic Font';

  @override
  String get arabicFontSize => 'Arabic Font Size';

  @override
  String get arabicLabel => 'Arabic';

  @override
  String get arabicText => 'Arabic Text';

  @override
  String get asmaPicture => 'Asma\'ul Husna Picture';

  @override
  String get asmaulhusna => 'Asma\'ul Husna';

  @override
  String get asmaulhusnaExplanation => 'Explanation';

  @override
  String get asmaulhusnaMeaning => 'Meaning';

  @override
  String get asmaulhusnaSubtitle => '99 Names of Allah';

  @override
  String get asrCalculationMethod => 'Asr Calculation Method';

  @override
  String get asrMethodHanafi => 'Hanafi';

  @override
  String get asrMethodStandard => 'Shafi\'i, Maliki, Hanbali';

  @override
  String get auto => 'Auto';

  @override
  String get autoHidePlayerControls => 'Auto-hide Controls';

  @override
  String get autoHidePlayerControlsSubtitle =>
      'Hide player controls after 30 seconds of inactivity';

  @override
  String get ayahFontSize => 'Ayah Font Size';

  @override
  String ayahNumber(Object number) {
    return 'Ayah $number';
  }

  @override
  String ayahProgress(Object current, Object total) {
    return 'Ayah $current/$total';
  }

  @override
  String get ayahs => 'Ayahs';

  @override
  String get ayahTheme => 'Ayah Theme';

  @override
  String get ayahThemeSubtitle => 'Choose the look of the Ayah card.';

  @override
  String get back => 'Back';

  @override
  String get bookmarkAyah => 'Bookmark ayah';

  @override
  String get bookmarkAyahsPrompt => 'Bookmark ayahs to see them here';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get bookmarksCleared => 'All bookmarks cleared';

  @override
  String get bookmarksLabel => 'Bookmarks';

  @override
  String get bookmarksSubtitle => 'Your saved items';

  @override
  String get calcMethodDubai => 'Umm al-Qura University, Dubai';

  @override
  String get calcMethodEgyptian => 'Egyptian General Authority of Survey';

  @override
  String get calcMethodJafari => 'Shia Ithna-Ashari (Jafari)';

  @override
  String get calcMethodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get calcMethodKuwait => 'Umm al-Qura University, Kuwait';

  @override
  String get calcMethodMoonsighting => 'Moonsighting Committee';

  @override
  String get calcMethodMWL => 'Muslim World League';

  @override
  String get calcMethodNorthAmerica => 'North American';

  @override
  String get calcMethodQatar => 'Umm al-Qura University, Qatar';

  @override
  String get calcMethodSingapore => 'Singapore';

  @override
  String get calcMethodTehran => 'Tehran University';

  @override
  String get calcMethodTurkey => 'Turkey';

  @override
  String get calcMethodUmmAlQura => 'Umm al-Qura University, Makkah';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get calendarView => 'Calendar View';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get changeReciter => 'Change Reciter';

  @override
  String get changeTranslation => 'Change Translation';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get chooseReciter => 'Choose Reciter';

  @override
  String get chooseSurah => 'Choose Surah';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get city => 'City';

  @override
  String get clearAllBookmarks => 'Clear all bookmarks';

  @override
  String get clearAllBookmarksConfirmation =>
      'This will remove all your bookmarked ayahs. This action cannot be undone.';

  @override
  String get clearAllBookmarksQuestion => 'Clear all bookmarks?';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get compassNotSupported => 'Compass not supported on this device';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get continueText => 'Continue';

  @override
  String get continueToNextSurah => 'Continue to Next Surah';

  @override
  String get continueToNextSurahSubtitle => 'Automatically play the next Surah';

  @override
  String get contribute => 'Contribute';

  @override
  String get contributeSubtitle =>
      'Rafeeq is open source. Help build it on GitHub';

  @override
  String get country => 'Country';

  @override
  String get currentOption => 'Current Option';

  @override
  String get dailyPrayer => 'Daily Prayer';

  @override
  String get dailyPrayerLabel => 'Namaz';

  @override
  String get dailyPrayerLabelSubtitle =>
      'Prayer with Arabic & Urdu Translation';

  @override
  String get dailyPrayerSubtitle => 'Full Prayer with translation';

  @override
  String get dayOfArafah => 'Day of Arafah';

  @override
  String get daysFasted => 'Days Fasted';

  @override
  String get daysMissed => 'Days Missed';

  @override
  String get dhuhrPrayerBeginsSoon => 'Dhuhr prayer begins soon';

  @override
  String get dummyHeading => 'Heading Text';

  @override
  String get dummySubtitle => 'Subtitle content goes here';

  @override
  String get dummyText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';

  @override
  String get eidCard => 'Eid Card';

  @override
  String get eidCardSubtitle => 'Celebrate Eid-ul-Fitr or Eid-ul-Adha';

  @override
  String get eidDay => 'Eid Day';

  @override
  String get eidMubarak => 'Eid Mubarak';

  @override
  String get eidPrayer => 'Eid Prayer';

  @override
  String get eidUlAdha => 'Eid-ul-Adha';

  @override
  String get eidUlAdhaGreeting => 'Eid-ul-Adha Mubarak';

  @override
  String get eidUlFitr => 'Eid-ul-Fitr';

  @override
  String get eidUlFitrGreeting => 'Eid-ul-Fitr Mubarak';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get enableRemindersMessage =>
      'Notifications are turned off for Rafeeq. Prayer reminders won\'t be delivered until you allow them.';

  @override
  String get enableRemindersSteps =>
      'Tap \"Open Settings\", then enable notifications for Rafeeq.';

  @override
  String get enableRemindersTitle => 'Enable Prayer Reminders';

  @override
  String get enterCity => 'Enter a city name';

  @override
  String get enterCountry => 'Enter a country name';

  @override
  String get errorLoadingQuranData => 'Error loading Quran data';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String get event => 'Event';

  @override
  String get exactAlarmBanner => 'Reminders may arrive late — tap to fix';

  @override
  String get exactAlarmMessage =>
      'Rafeeq can\'t deliver reminders at exact prayer times because the \'Alarms & Reminders\' permission is not granted. Notifications may arrive late.';

  @override
  String get exactAlarmSteps =>
      'Tap \"Open Settings\", find \"Alarms & Reminders\", and enable it for Rafeeq.';

  @override
  String get exactAlarmTitle => 'Enable Precise Prayer Reminders';

  @override
  String get exit => 'Exit';

  @override
  String get exitApp => 'Exit App?';

  @override
  String get exitAppConfirmation => 'Are you sure you want to exit Rafeeq?';

  @override
  String get failedToLoadTranslations => 'Failed to load translations';

  @override
  String get fastingProgress => 'Fasting Progress';

  @override
  String get fastingStatus => 'Fasting Status';

  @override
  String get fastingTracker => 'Fasting Tracker';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackSubtitle => 'Send us your suggestions or report issues';

  @override
  String get finish => 'Finish';

  @override
  String get firstNameRequired => 'Please enter your first name.';

  @override
  String get fridayCard => 'Friday Card';

  @override
  String get fridayMubarak => 'Friday Mubarak';

  @override
  String get fridaySunnahs => 'Friday Sunnahs';

  @override
  String get general => 'General';

  @override
  String get getStarted => 'Get Started';

  @override
  String get googleFontDownloadInfo => 'Google Font (downloads on first use)';

  @override
  String get gotIt => 'Got it';

  @override
  String get grade => 'Grade';

  @override
  String get gradientColors => 'Gradient Colors';

  @override
  String get grantLocationPermission => 'Grant Location Permission';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get gridView => 'Grid View';

  @override
  String get highLatAngleBased => 'Angle Based';

  @override
  String get highLatitudeRule => 'High Latitude Rule';

  @override
  String get highLatMiddleNight => 'Middle of the Night';

  @override
  String get highLatOneSeventh => '1/7th of the Night';

  @override
  String get hijriCalendarSubtitle => 'Islamic & Gregorian dates';

  @override
  String get hijriCalendarTitle => 'Hijri Calendar';

  @override
  String get hijriCorrection => 'Hijri Correction';

  @override
  String get hijriMinus1Day => 'One Day Ago (-1)';

  @override
  String get hijriMinus2Days => 'Two Days Ago (-2)';

  @override
  String get hijriNone => 'None';

  @override
  String get hijriPlus1Day => 'One Day Ahead (+1)';

  @override
  String get hijriPlus2Days => 'Two Days Ahead (+2)';

  @override
  String get homeAdFreeMessage =>
      'Rafeeq is an ad-free Islamic app. Share it with your friends and family to earn hasanah and benefit the whole ummah.';

  @override
  String get homeAllahsNames => 'Allah\'s Names';

  @override
  String get homeAyahPicture => 'Ayah Picture';

  @override
  String get homeCalendar => 'Calendar';

  @override
  String get homeDailyDua => 'Daily Dua';

  @override
  String get homeDailyDuaText =>
      'With the Name of Allah, the Most Gracious, the Most Merciful. Say: He is Allah, the One. Allah, the Self-Sufficient Master, Whom all creatures need. He begets not, nor was He begotten, and there is none equal to Him.';

  @override
  String get homeDuaAndZikr => 'Dua & Zikr';

  @override
  String get homeExplore => 'Explore';

  @override
  String get homeForbiddenSalatTimes => 'Forbidden Salat Times';

  @override
  String get homeHadithSource => 'Sahih Muslim, Book 20, Hadith 4665';

  @override
  String get homeHadithText =>
      'Prophet Muhammad (PBUH) said: ‘Whoever guides someone to goodness will have a reward like the one who did it.’';

  @override
  String get homeMosques => 'Mosques';

  @override
  String get homeNewLook => 'New Look';

  @override
  String get homeNoon => 'Noon';

  @override
  String get homeSahih => 'Sahih';

  @override
  String get homeShareNow => 'Share Now';

  @override
  String get homeShareRafeeq => 'Share Rafeeq';

  @override
  String get homeSuhurEnd => 'Suhur End';

  @override
  String get homeSunset => 'Sunset';

  @override
  String get homeTahajjud => 'Tahajjud';

  @override
  String get homeToday => 'Today';

  @override
  String get iftar => 'Iftar';

  @override
  String get imageLoadError => 'Unable to load image';

  @override
  String get includeArabicAyah => 'Include the Arabic Ayah in the picture';

  @override
  String get includeArabicName => 'Include Allah\'s Arabic name in the picture';

  @override
  String get includeNameMeaning => 'Include the name meaning in the picture';

  @override
  String get includeTranslation =>
      'Include the selected translation in the picture';

  @override
  String get installNow => 'Install Now';

  @override
  String get jumpToAyah => 'Jump To Ayah';

  @override
  String get juristicMethod => 'Juristic Method';

  @override
  String get juz => 'Juz';

  @override
  String get language => 'Language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get later => 'Later';

  @override
  String get legalRetry => 'Unable to load this page. Tap to retry.';

  @override
  String get licenses => 'Licenses';

  @override
  String licensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licenses',
      one: '1 license',
    );
    return '$_temp0';
  }

  @override
  String get licensesIntro =>
      'Rafeeq is built on these open-source packages. Thank you to everyone who made them.';

  @override
  String get licensesSubtitle => 'Open-source packages used in Rafeeq';

  @override
  String get listen => 'Listen';

  @override
  String get listView => 'List View';

  @override
  String get location => 'Location';

  @override
  String get locationDataLoadError =>
      'Location data couldn\'t be loaded. Check your internet connection and try again.';

  @override
  String get locationNotFound =>
      'We couldn\'t find that location. Check the country and city names and try again.';

  @override
  String get locationNotSet => 'Location not set';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission denied permanently. Please enable it in settings.';

  @override
  String get locationPermissionDescription =>
      'Required to calculate accurate prayer times and Qibla direction based on your position.';

  @override
  String get locationPermissionTitle => 'Location Access';

  @override
  String get locationRequiredDescription =>
      'Prayer times are calculated based on your location. Please grant location permission to see accurate prayer timings.';

  @override
  String get locationRequiredTitle => 'Location Required';

  @override
  String get locationUpdated => 'Location updated';

  @override
  String get manualLocation => 'Manual Location';

  @override
  String get manualLocationDescription =>
      'Manually select the country and city. Update the location if you change city.';

  @override
  String get markAs => 'Mark as';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String get next => 'Next';

  @override
  String get no => 'No';

  @override
  String get noAyahPlaying => 'No ayah playing';

  @override
  String get noBookmarksYet => 'No bookmarks yet';

  @override
  String get noQuranAudioPlaying => 'No Quran audio is playing';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get notification => 'Notification';

  @override
  String get notificationEnabled => 'Notification Enabled';

  @override
  String get notificationEnabledOff =>
      'Notifications are turned off for this prayer';

  @override
  String get notificationEnabledOn =>
      'You will receive notifications for this prayer';

  @override
  String get notificationPermissionDescription =>
      'Required to send you prayer time reminders and alerts.';

  @override
  String get notificationPermissionTitle => 'Notifications';

  @override
  String get notificationsDisabledBanner =>
      'Notifications disabled — tap to enable reminders';

  @override
  String get notNow => 'Not Now';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get onboardingAppName => 'Rafeeq';

  @override
  String get onboardingAsmaulHusnaDescription =>
      'Learn the 99 beautiful names of Allah with meanings';

  @override
  String get onboardingHijriCalendarDescription =>
      'View and convert dates between Hijri and Gregorian calendars';

  @override
  String get onboardingJuristicDescription =>
      'Choose your school of thought (Madhab) for Asr prayer time.';

  @override
  String get onboardingLanguageDescription =>
      'Choose your preferred language to personalize your experience';

  @override
  String get onboardingLocationDescription =>
      'Set your location so prayer times and Qibla guidance are accurate for you.';

  @override
  String get onboardingNotificationBody => 'It is prayer time.';

  @override
  String get onboardingNotificationsDescription =>
      'Never miss a prayer. Rafeeq can gently remind you when it is time to pray.';

  @override
  String get onboardingNotificationTitle => 'It\'s time for the Dhuhr prayer';

  @override
  String get onboardingPrayerTimesDescription =>
      'Get accurate prayer times for your location with notifications';

  @override
  String get onboardingQiblaDescription =>
      'Find the accurate Qibla direction from anywhere in the world';

  @override
  String get onboardingQuranDescription =>
      'Read and listen to the Holy Quran with translations and recitations';

  @override
  String get onboardingThemeDescription =>
      'Choose a theme that suits your style';

  @override
  String get onboardingThemeSubtitle => 'Select a theme that suits your style';

  @override
  String get onboardingWelcomeDescription =>
      'Your complete Islamic companion for daily spiritual needs';

  @override
  String get onboardingWelcomeTitle => 'Your Daily Muslim Companion';

  @override
  String get oneShawwal => '1 Shawwal';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get otherAppsSubtitle => 'View on Google Play';

  @override
  String get paused => 'Paused';

  @override
  String get permissionsDescription =>
      'To provide you with accurate prayer times, Qibla direction, and prayer reminders, Rafeeq needs access to your location and notifications.';

  @override
  String get permissionsGranted => 'Permissions Granted';

  @override
  String get permissionsSkipped => 'Permissions Skipped';

  @override
  String get permissionsTitle => 'Enable Permissions';

  @override
  String get playAudio => 'Play Audio';

  @override
  String playbackComplete(Object name) {
    return '$name complete';
  }

  @override
  String get playbackSettings => 'Playback Settings';

  @override
  String get playFromAyah => 'Play from this ayah';

  @override
  String get playing => 'Playing';

  @override
  String get prayEidToday => 'Pray Eid Today';

  @override
  String get prayEidUlAdhaToday => 'Pray Eid-ul-Adha Today';

  @override
  String get prayEidUlFitrToday => 'Pray Eid-ul-Fitr Today';

  @override
  String get prayerAndFastingReminders => 'Prayer, Fasting & Eid Reminders';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerJumma => 'Jumma';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerNone => '—';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get prayerTimesSettings => 'Prayer Times Settings';

  @override
  String get prayerTimesSubtitle => 'Daily salah schedule';

  @override
  String get prepareForPrayer => 'Take a moment to prepare for prayer.';

  @override
  String get preview => 'Preview';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Your data, permissions and choices';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaFacing => 'You are facing Qibla';

  @override
  String get qiblaSubtitle => 'Find the Qibla direction';

  @override
  String qiblaTurnLeft(int degrees) {
    return 'Turn $degrees° Left';
  }

  @override
  String qiblaTurnRight(int degrees) {
    return 'Turn $degrees° Right';
  }

  @override
  String get quran => 'Qur\'an';

  @override
  String get quranAutoScrollDisabled => 'Auto Scroll Disabled';

  @override
  String get quranAutoScrollEnabled => 'Auto Scroll Enabled';

  @override
  String get quranPageTab => 'Page';

  @override
  String get quranRecitation => 'Quran recitation';

  @override
  String get quranSubtitle => 'Read & explore the Holy Qur\'an';

  @override
  String get quranTopicTab => 'Topic';

  @override
  String get quranViewSettings => 'Qur\'an View Settings';

  @override
  String get qurbaniDay => 'Qurbani Day';

  @override
  String get ramadanCalendarTitle => 'Ramadan Calendar';

  @override
  String get ramadanCard => 'Ramadan Card';

  @override
  String get ramadanCardSubtitle => 'Suhoor & Iftar times for today';

  @override
  String get ramadanMubarak => 'Ramadan Mubarak';

  @override
  String get ramadanSettings => 'Ramadan Settings';

  @override
  String get rateThisApp => 'Rate this app';

  @override
  String get rateThisAppSubtitle =>
      'Love the app? Let us know on the Play Store';

  @override
  String get read => 'Read';

  @override
  String get readSurahKahf => 'Tap To Read Surah Al-Kahf';

  @override
  String get redesignAdaptiveTheme => 'Adaptive Theme Support';

  @override
  String get redesignAdaptiveThemeDescription =>
      'Switch between Light and Dark themes, or follow the system setting to automatically adapt Rafeeq\'s complete appearance.';

  @override
  String get redesignAyahMaker => 'Ayah Picture Maker';

  @override
  String get redesignAyahMakerDescription =>
      'Create beautiful Ayah pictures with customization options for Arabic text, translations and editions, then share them on social media.';

  @override
  String get redesignDialogBody =>
      'We have fully revamped Rafeeq to make your daily Islamic experience cleaner, clearer and more beautiful.';

  @override
  String get redesignDialogTitle => 'A fresh new look for Rafeeq';

  @override
  String get redesignExtendedHome => 'Extended Home Experience';

  @override
  String get redesignExtendedHomeDescription =>
      'See forbidden Salah times, the Daily Ayah and Share App cards, plus Iftar, Suhoor and Tahajjud times from the expanded Home screen.';

  @override
  String get redesignHomeScreen => 'Home Screen';

  @override
  String get redesignNewFeatures => 'More New Experiences';

  @override
  String get redesignQiblaScreen => 'Qiblah Screen';

  @override
  String get redesignQuranView => 'Qur\'an View';

  @override
  String get redesignSurahJuzList => 'Surah / Juz List';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get reportIssue => 'Report an issue';

  @override
  String get reportIssueSubtitle => 'Found a bug? Let us know on GitHub';

  @override
  String get reset => 'Reset';

  @override
  String get resetSettingsMessage =>
      'This will reset all Quran view settings including font sizes, theme, translation edition, and reciter to their default values. This action cannot be undone.';

  @override
  String get resetSettingsTitle => 'Reset Settings?';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetToDefaultMessage =>
      'Are you sure you want to reset the home screen layout to default?';

  @override
  String get resetToDefaultSubtitle =>
      'Reset all Quran view settings to default values';

  @override
  String get resetToDefaultTitle => 'Reset to Default';

  @override
  String get restartNow => 'Restart Now';

  @override
  String get retry => 'Retry';

  @override
  String get sacrifice => 'Qurbani';

  @override
  String get save => 'Save';

  @override
  String get saveName => 'Save Name';

  @override
  String get scriptStylingAndSize => 'Script styling and size.';

  @override
  String get search => 'Search';

  @override
  String get searchErrorHelp =>
      'We couldn\'t complete your search with the current translation.';

  @override
  String get searchOnlyTextEditions =>
      'Please note that only text editions of the Quran are searchable.';

  @override
  String get searchQuranHint => 'Search Quran (Arabic or Translation)...';

  @override
  String get searchTranslations => 'Search translations...';

  @override
  String get selectArabicFont => 'Select Arabic Font';

  @override
  String get selectCity => 'Select City';

  @override
  String get selectCollection => 'Select Collection';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get selectFont => 'Select Font';

  @override
  String get selectLanguage => 'Select a Language';

  @override
  String get selectLanguageSubtitle =>
      'Select your preferred language to continue';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get selectOption => 'SELECT OPTION';

  @override
  String get selectTranslation => 'Select Translation';

  @override
  String get setLocationForPrayerTimes => 'Set Location for Prayer Times';

  @override
  String get settings => 'Settings';

  @override
  String get settingsResetSuccess => 'Settings reset to default';

  @override
  String get settingsSectionAppInfo => 'App info';

  @override
  String get settingsSectionOtherApps => 'Our other apps';

  @override
  String get settingsSectionPrayer => 'Prayer & Calendar';

  @override
  String get settingsSectionSupport => 'Support Rafeeq';

  @override
  String get share => 'Share';

  @override
  String get shareAyah => 'Share ayah';

  @override
  String get shareThisApp => 'Share this app';

  @override
  String get shareThisAppSubtitle => 'Share Rafeeq with friends and family';

  @override
  String get showArabic => 'Show Arabic';

  @override
  String get showingMeaningInUrdu => 'Showing the meaning in Urdu';

  @override
  String get showMeaning => 'Show Meaning';

  @override
  String get showMeaningInUrdu => 'Show the meaning in Urdu';

  @override
  String get showTranslation => 'Show Translation';

  @override
  String get showTransliteration => 'Show Transliteration';

  @override
  String get showTransliterationSubtitle => 'Show phonetic line under Arabic.';

  @override
  String get simpleMode => 'Simple Mode';

  @override
  String get sixteenLineQuran => '16 Line Quran';

  @override
  String get sixteenLineQuranSubtitle => 'Read 16 Line Tajweedi Quran';

  @override
  String get sleepTimer => 'Sleep Timer';

  @override
  String get sleepTimerActive => 'Sleep Timer Active';

  @override
  String sleepTimerHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hours',
      one: 'Hour',
    );
    return '$count $_temp0';
  }

  @override
  String sleepTimerMinutes(int count) {
    return '$count Minutes';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get soundAllahuAkbar => 'Allahu Akbar';

  @override
  String get soundAllahuAkbarDesc => 'Allahu Akbar call';

  @override
  String get soundDefault => 'Default';

  @override
  String get soundDefaultDesc => 'System default notification sound';

  @override
  String get soundFalahDesc => 'Traditional Salah azan sound';

  @override
  String get soundSalah => 'Salah Sound';

  @override
  String get soundSilent => 'Silent';

  @override
  String get soundSilentDesc => 'Notification will show without sound';

  @override
  String get statusFasting => 'Fasting';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusNone => 'None';

  @override
  String get suhoor => 'Suhoor';

  @override
  String get sunnahCleanClothes => 'Clean Clothes';

  @override
  String get sunnahCleanClothesSubtitle =>
      'Wear fresh clean clothes for prayer';

  @override
  String get sunnahDurood => 'Send Salawat';

  @override
  String get sunnahDuroodSubtitle => 'Recite blessings on the Prophet';

  @override
  String get sunnahGhusl => 'Perform Ghusl';

  @override
  String get sunnahGhuslSubtitle => 'Full body purification before Friday';

  @override
  String get sunnahMiswak => 'Use Miswak';

  @override
  String get sunnahMiswakSubtitle => 'Clean teeth before leaving home';

  @override
  String get sunnahPerfume => 'Apply Perfume';

  @override
  String get sunnahPerfumeSubtitle => 'Wear pleasant fragrance for mosque';

  @override
  String get supportsRtlLanguages => 'Supports RTL languages';

  @override
  String get surah => 'Surah';

  @override
  String get surahRepeat => 'Surah Repeat';

  @override
  String get surahRepeatSubtitle =>
      'Repeat the current Surah after it finishes';

  @override
  String get switchToGridView => 'Switch to Grid View';

  @override
  String get switchToListView => 'Switch to List View';

  @override
  String get takbeer => 'Takbeer';

  @override
  String get takbeerText => 'Allahu Akbar';

  @override
  String get tapToExpand => 'Tap to expand';

  @override
  String get tapToView => 'Tap to view';

  @override
  String get tenDhulHijjah => '10 Dhul Hijjah';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get termsAndConditionsSubtitle => 'Using Rafeeq and its content';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get textColor => 'Text Color';

  @override
  String get theme => 'Theme';

  @override
  String get themeDefault => 'Default';

  @override
  String get themeDefaultBlue => 'Lime & Blue';

  @override
  String get themeEmeraldGreen => 'Emerald Green';

  @override
  String get themeGradientBlue => 'Gradient (Blue)';

  @override
  String get themeGradientGreen => 'Gradient (Green)';

  @override
  String get themeGradientPurple => 'Gradient (Purple)';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeOceanTeal => 'Ocean Teal';

  @override
  String get themePaperAged => 'Aged Paper';

  @override
  String get themePaperCream => 'Paper (Cream)';

  @override
  String get themePaperDark => 'Paper (Dark)';

  @override
  String get themePaperLight => 'Paper (Light)';

  @override
  String get themePaperWood => 'Woody Pattern';

  @override
  String get themeSelectShortDefault => 'Default';

  @override
  String get themeSelectShortGreen => 'Green';

  @override
  String get themeSelectShortGrey => 'Grey';

  @override
  String get themeSelectShortTeal => 'Teal';

  @override
  String get themeSlateGrey => 'Slate Grey';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get timeFormat12Hour => '12-Hour Format';

  @override
  String get timeFormat24Hour => '24-Hour Format';

  @override
  String get timeLeftIftar => 'Time until Iftar';

  @override
  String get timeLeftSuhoor => 'Time until Suhoor';

  @override
  String get toggleTranslationVisibility =>
      'Toggle translated text visibility.';

  @override
  String get totalDays => 'Total Days';

  @override
  String get translationEdition => 'Translation Edition';

  @override
  String get translationFont => 'Translation Font';

  @override
  String get translationFontSize => 'Translation Font Size';

  @override
  String get translationFontSizeSubtitle => 'Applies to translations.';

  @override
  String get translationLabel => 'Translation';

  @override
  String get translationSettings => 'Translation';

  @override
  String get translationSettingsSubtitle => 'Choose language, font, and size.';

  @override
  String get transliteration => 'Transliteration';

  @override
  String get transliterationFontSize => 'Transliteration Font Size';

  @override
  String get transliterationFontSizeSubtitle =>
      'Always shown in English script.';

  @override
  String get transliterationSubtitle => 'Latin script pronunciation guide.';

  @override
  String get translitLabel => 'Translit';

  @override
  String get typeLabel => 'Type';

  @override
  String get unableToLoadAsma => 'Unable to load Asma\'ul Husna';

  @override
  String get unableToLoadQuran => 'Unable to load Quran';

  @override
  String get updateDownloadedMessage =>
      'A new version of Rafeeq has been downloaded and is ready to be installed.';

  @override
  String get updateReady => 'Update Ready';

  @override
  String get urduMode => 'Urdu Mode';

  @override
  String get useUrduPictureLayout => 'Use Urdu card layout and translation';

  @override
  String get usingUrduPictureLayout =>
      'Urdu card layout and translation defaults';

  @override
  String get version => 'Version';

  @override
  String get versionDetailsBugFixes => 'Bug Fixes';

  @override
  String get versionDetailsBugFixesBody =>
      'Restored the Qur\'an mini-player in the reader.';

  @override
  String get versionDetailsDesign => 'Design';

  @override
  String get versionDetailsDesignBody =>
      'Refined the About experience while preserving Rafeeq\'s familiar appearance.';

  @override
  String get versionDetailsEnhancements => 'Enhancements';

  @override
  String get versionDetailsEnhancementsBody =>
      'The About page now links directly to the official WhatsApp channel and developer portfolio.';

  @override
  String get versionDetailsFeatures => 'Features';

  @override
  String get versionDetailsFeaturesBody =>
      '• Simpler onboarding with no account or sign-in required';

  @override
  String get versionDetailsIntro =>
      'This update simplifies onboarding and improves the About experience and Qur\'an playback.';

  @override
  String get versionSubtitle => 'Current installed version';

  @override
  String get viewMonthlyCalendar => 'Tap To View Monthly Calendar';

  @override
  String get viewType => 'View Type';

  @override
  String get visibility => 'Visibility';

  @override
  String get volumeAlarm => 'Alarm Volume';

  @override
  String get volumeAlarmDesc => 'Maximum volume for important alerts';

  @override
  String get volumeControl => 'VOLUME CONTROL';

  @override
  String get volumeNotification => 'Notification Volume';

  @override
  String get volumeNotificationDesc => 'Standard notification volume level';

  @override
  String get waitingForLocation => 'Waiting for location...';
}
