import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The story and purpose behind Rafeeq'**
  String get aboutSubtitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Muslim Companion'**
  String get aboutTagline;

  /// No description provided for @aboutBeginningTitle.
  ///
  /// In en, this message translates to:
  /// **'How Rafeeq began'**
  String get aboutBeginningTitle;

  /// No description provided for @aboutBeginningBody.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq began with a simple idea from my elder brother. We are both software developers, and one day he decided to build an Islamic app that would bring essential Muslim needs such as the Qur\'an, Qiblah, prayer times and more together in one place. Later, I — Muzamil Ghafoor — joined him, and Rafeeq became a journey shared by two brothers.'**
  String get aboutBeginningBody;

  /// No description provided for @aboutTogetherTitle.
  ///
  /// In en, this message translates to:
  /// **'Growing together'**
  String get aboutTogetherTitle;

  /// No description provided for @aboutTogetherBody.
  ///
  /// In en, this message translates to:
  /// **'Since then, my brother and I have worked on Rafeeq as a team. We started again together, gradually implemented the core features and kept adding more over time. Whenever our other responsibilities leave us some time, we come back to Rafeeq to improve it and thoughtfully prepare the next update.'**
  String get aboutTogetherBody;

  /// No description provided for @aboutDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Our design journey'**
  String get aboutDesignTitle;

  /// No description provided for @aboutDesignBody.
  ///
  /// In en, this message translates to:
  /// **'When we first started, we did not have a complete design plan. Even after adding features, we often felt that something was still missing, so we rebuilt the app\'s entire design system twice. With this latest version, we have tried to create something minimal, clear and pleasantly refined. The Islamic app Sadiq was also a meaningful source of inspiration for us, and I am grateful for it.'**
  String get aboutDesignBody;

  /// No description provided for @aboutUmmahTitle.
  ///
  /// In en, this message translates to:
  /// **'For the Ummah'**
  String get aboutUmmahTitle;

  /// No description provided for @aboutUmmahBody.
  ///
  /// In en, this message translates to:
  /// **'For me, Rafeeq is more than just another software project. My brother and I want to keep improving it for the Ummah of Prophet Muhammad (PBUH). I am deeply thankful to Allah Almighty for giving us the ability to work on something that may benefit other Muslims.'**
  String get aboutUmmahBody;

  /// No description provided for @aboutFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free for life, In Sha Allah'**
  String get aboutFreeTitle;

  /// No description provided for @aboutFreeBody.
  ///
  /// In en, this message translates to:
  /// **'I want Rafeeq to remain free for everyone for its entire lifetime, In Sha Allah. In the future, we may add an optional way for Muslims to support the app\'s development and running costs. Any support will be used to maintain and improve Rafeeq; we do not intend to take anything from it for ourselves, In Sha Allah.'**
  String get aboutFreeBody;

  /// No description provided for @aboutCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'We are here for you'**
  String get aboutCommunityTitle;

  /// No description provided for @aboutCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'My brother and I are here for you. You can request a feature, report a bug or share an idea with us. We will listen, and we will keep doing our best to make Rafeeq better for Muslims everywhere.'**
  String get aboutCommunityBody;

  /// No description provided for @aboutClosingStatement.
  ///
  /// In en, this message translates to:
  /// **'Built by Muslims, for Muslims — for the Ummah of Prophet Muhammad (PBUH) and for the sake of Allah Almighty. ❤️ '**
  String get aboutClosingStatement;

  /// No description provided for @aboutPortfolioOpenError.
  ///
  /// In en, this message translates to:
  /// **'The portfolio could not be opened.'**
  String get aboutPortfolioOpenError;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @allowLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically updates prayer times.'**
  String get allowLocationDescription;

  /// No description provided for @appIconChanged.
  ///
  /// In en, this message translates to:
  /// **'App Icon Changed'**
  String get appIconChanged;

  /// No description provided for @appIconRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'The app icon will be updated. Would you like to restart now to see the change immediately, or later when you open the app?'**
  String get appIconRestartMessage;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq'**
  String get appTitle;

  /// No description provided for @arabicFont.
  ///
  /// In en, this message translates to:
  /// **'Arabic Font'**
  String get arabicFont;

  /// No description provided for @arabicFontSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic Font Size'**
  String get arabicFontSize;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLabel;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text'**
  String get arabicText;

  /// No description provided for @asmaulhusna.
  ///
  /// In en, this message translates to:
  /// **'Asma\'ul Husna'**
  String get asmaulhusna;

  /// No description provided for @asmaulhusnaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'99 Names of Allah'**
  String get asmaulhusnaSubtitle;

  /// No description provided for @asmaulhusnaExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get asmaulhusnaExplanation;

  /// No description provided for @asmaulhusnaMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get asmaulhusnaMeaning;

  /// No description provided for @asrCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Asr Calculation Method'**
  String get asrCalculationMethod;

  /// No description provided for @asrMethodHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrMethodHanafi;

  /// No description provided for @asrMethodStandard.
  ///
  /// In en, this message translates to:
  /// **'Shafi\'i, Maliki, Hanbali'**
  String get asrMethodStandard;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @autoHidePlayerControls.
  ///
  /// In en, this message translates to:
  /// **'Auto-hide Controls'**
  String get autoHidePlayerControls;

  /// No description provided for @autoHidePlayerControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide player controls after 30 seconds of inactivity'**
  String get autoHidePlayerControlsSubtitle;

  /// No description provided for @ayahFontSize.
  ///
  /// In en, this message translates to:
  /// **'Ayah Font Size'**
  String get ayahFontSize;

  /// No description provided for @ayahNumber.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}'**
  String ayahNumber(Object number);

  /// No description provided for @ayahProgress.
  ///
  /// In en, this message translates to:
  /// **'Ayah {current}/{total}'**
  String ayahProgress(Object current, Object total);

  /// No description provided for @ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahs;

  /// No description provided for @ayahTheme.
  ///
  /// In en, this message translates to:
  /// **'Ayah Theme'**
  String get ayahTheme;

  /// No description provided for @ayahThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the look of the Ayah card.'**
  String get ayahThemeSubtitle;

  /// No description provided for @bookmarkAyahsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Bookmark ayahs to see them here'**
  String get bookmarkAyahsPrompt;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @bookmarksCleared.
  ///
  /// In en, this message translates to:
  /// **'All bookmarks cleared'**
  String get bookmarksCleared;

  /// No description provided for @bookmarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksLabel;

  /// No description provided for @bookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved items'**
  String get bookmarksSubtitle;

  /// No description provided for @calcMethodDubai.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Dubai'**
  String get calcMethodDubai;

  /// No description provided for @calcMethodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority of Survey'**
  String get calcMethodEgyptian;

  /// No description provided for @calcMethodJafari.
  ///
  /// In en, this message translates to:
  /// **'Shia Ithna-Ashari (Jafari)'**
  String get calcMethodJafari;

  /// No description provided for @calcMethodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get calcMethodKarachi;

  /// No description provided for @calcMethodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Kuwait'**
  String get calcMethodKuwait;

  /// No description provided for @calcMethodMoonsighting.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get calcMethodMoonsighting;

  /// No description provided for @calcMethodMWL.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get calcMethodMWL;

  /// No description provided for @calcMethodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North American'**
  String get calcMethodNorthAmerica;

  /// No description provided for @calcMethodQatar.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Qatar'**
  String get calcMethodQatar;

  /// No description provided for @calcMethodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get calcMethodSingapore;

  /// No description provided for @calcMethodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran University'**
  String get calcMethodTehran;

  /// No description provided for @calcMethodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get calcMethodTurkey;

  /// No description provided for @calcMethodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Makkah'**
  String get calcMethodUmmAlQura;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendarView;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @changeReciter.
  ///
  /// In en, this message translates to:
  /// **'Change Reciter'**
  String get changeReciter;

  /// No description provided for @changeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Change Translation'**
  String get changeTranslation;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseReciter.
  ///
  /// In en, this message translates to:
  /// **'Choose Reciter'**
  String get chooseReciter;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @clearAllBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Clear all bookmarks'**
  String get clearAllBookmarks;

  /// No description provided for @clearAllBookmarksConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your bookmarked ayahs. This action cannot be undone.'**
  String get clearAllBookmarksConfirmation;

  /// No description provided for @clearAllBookmarksQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear all bookmarks?'**
  String get clearAllBookmarksQuestion;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @compassNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Compass not supported on this device'**
  String get compassNotSupported;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @continueToNextSurah.
  ///
  /// In en, this message translates to:
  /// **'Continue to Next Surah'**
  String get continueToNextSurah;

  /// No description provided for @continueToNextSurahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically play the next Surah'**
  String get continueToNextSurahSubtitle;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @contributeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq is open source. Help build it on GitHub'**
  String get contributeSubtitle;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @currentOption.
  ///
  /// In en, this message translates to:
  /// **'Current Option'**
  String get currentOption;

  /// No description provided for @dailyPrayer.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer'**
  String get dailyPrayer;

  /// No description provided for @dailyPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Namaz'**
  String get dailyPrayerLabel;

  /// No description provided for @dailyPrayerLabelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer with Arabic & Urdu Translation'**
  String get dailyPrayerLabelSubtitle;

  /// No description provided for @dailyPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full Prayer with translation'**
  String get dailyPrayerSubtitle;

  /// No description provided for @dayOfArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get dayOfArafah;

  /// No description provided for @daysFasted.
  ///
  /// In en, this message translates to:
  /// **'Days Fasted'**
  String get daysFasted;

  /// No description provided for @daysMissed.
  ///
  /// In en, this message translates to:
  /// **'Days Missed'**
  String get daysMissed;

  /// No description provided for @dummyHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading Text'**
  String get dummyHeading;

  /// No description provided for @dummySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle content goes here'**
  String get dummySubtitle;

  /// No description provided for @dummyText.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'**
  String get dummyText;

  /// No description provided for @eidCard.
  ///
  /// In en, this message translates to:
  /// **'Eid Card'**
  String get eidCard;

  /// No description provided for @eidCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Celebrate Eid-ul-Fitr or Eid-ul-Adha'**
  String get eidCardSubtitle;

  /// No description provided for @eidDay.
  ///
  /// In en, this message translates to:
  /// **'Eid Day'**
  String get eidDay;

  /// No description provided for @eidMubarak.
  ///
  /// In en, this message translates to:
  /// **'Eid Mubarak'**
  String get eidMubarak;

  /// No description provided for @eidPrayer.
  ///
  /// In en, this message translates to:
  /// **'Eid Prayer'**
  String get eidPrayer;

  /// No description provided for @eidUlAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid-ul-Adha'**
  String get eidUlAdha;

  /// No description provided for @eidUlAdhaGreeting.
  ///
  /// In en, this message translates to:
  /// **'Eid-ul-Adha Mubarak'**
  String get eidUlAdhaGreeting;

  /// No description provided for @eidUlFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid-ul-Fitr'**
  String get eidUlFitr;

  /// No description provided for @eidUlFitrGreeting.
  ///
  /// In en, this message translates to:
  /// **'Eid-ul-Fitr Mubarak'**
  String get eidUlFitrGreeting;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @enableRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Rafeeq. Prayer reminders won\'t be delivered until you allow them.'**
  String get enableRemindersMessage;

  /// No description provided for @enableRemindersSteps.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open Settings\", then enable notifications for Rafeeq.'**
  String get enableRemindersSteps;

  /// No description provided for @enableRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Prayer Reminders'**
  String get enableRemindersTitle;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter a city name'**
  String get enterCity;

  /// No description provided for @enterCountry.
  ///
  /// In en, this message translates to:
  /// **'Enter a country name'**
  String get enterCountry;

  /// No description provided for @errorLoadingQuranData.
  ///
  /// In en, this message translates to:
  /// **'Error loading Quran data'**
  String get errorLoadingQuranData;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @exactAlarmBanner.
  ///
  /// In en, this message translates to:
  /// **'Reminders may arrive late — tap to fix'**
  String get exactAlarmBanner;

  /// No description provided for @exactAlarmMessage.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq can\'t deliver reminders at exact prayer times because the \'Alarms & Reminders\' permission is not granted. Notifications may arrive late.'**
  String get exactAlarmMessage;

  /// No description provided for @exactAlarmSteps.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open Settings\", find \"Alarms & Reminders\", and enable it for Rafeeq.'**
  String get exactAlarmSteps;

  /// No description provided for @exactAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Precise Prayer Reminders'**
  String get exactAlarmTitle;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitApp;

  /// No description provided for @exitAppConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit Rafeeq?'**
  String get exitAppConfirmation;

  /// No description provided for @failedToLoadTranslations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load translations'**
  String get failedToLoadTranslations;

  /// No description provided for @fastingProgress.
  ///
  /// In en, this message translates to:
  /// **'Fasting Progress'**
  String get fastingProgress;

  /// No description provided for @fastingStatus.
  ///
  /// In en, this message translates to:
  /// **'Fasting Status'**
  String get fastingStatus;

  /// No description provided for @fastingTracker.
  ///
  /// In en, this message translates to:
  /// **'Fasting Tracker'**
  String get fastingTracker;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us your suggestions or report issues'**
  String get feedbackSubtitle;

  /// No description provided for @fridayCard.
  ///
  /// In en, this message translates to:
  /// **'Friday Card'**
  String get fridayCard;

  /// No description provided for @fridayMubarak.
  ///
  /// In en, this message translates to:
  /// **'Friday Mubarak'**
  String get fridayMubarak;

  /// No description provided for @fridaySunnahs.
  ///
  /// In en, this message translates to:
  /// **'Friday Sunnahs'**
  String get fridaySunnahs;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @googleFontDownloadInfo.
  ///
  /// In en, this message translates to:
  /// **'Google Font (downloads on first use)'**
  String get googleFontDownloadInfo;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @gradientColors.
  ///
  /// In en, this message translates to:
  /// **'Gradient Colors'**
  String get gradientColors;

  /// No description provided for @grantLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Location Permission'**
  String get grantLocationPermission;

  /// No description provided for @grantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No description provided for @highLatAngleBased.
  ///
  /// In en, this message translates to:
  /// **'Angle Based'**
  String get highLatAngleBased;

  /// No description provided for @highLatitudeRule.
  ///
  /// In en, this message translates to:
  /// **'High Latitude Rule'**
  String get highLatitudeRule;

  /// No description provided for @highLatMiddleNight.
  ///
  /// In en, this message translates to:
  /// **'Middle of the Night'**
  String get highLatMiddleNight;

  /// No description provided for @highLatOneSeventh.
  ///
  /// In en, this message translates to:
  /// **'1/7th of the Night'**
  String get highLatOneSeventh;

  /// No description provided for @hijriCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Islamic & Gregorian dates'**
  String get hijriCalendarSubtitle;

  /// No description provided for @hijriCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijriCalendarTitle;

  /// No description provided for @hijriCorrection.
  ///
  /// In en, this message translates to:
  /// **'Hijri Correction'**
  String get hijriCorrection;

  /// No description provided for @hijriMinus1Day.
  ///
  /// In en, this message translates to:
  /// **'One Day Ago (-1)'**
  String get hijriMinus1Day;

  /// No description provided for @hijriMinus2Days.
  ///
  /// In en, this message translates to:
  /// **'Two Days Ago (-2)'**
  String get hijriMinus2Days;

  /// No description provided for @hijriNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get hijriNone;

  /// No description provided for @hijriPlus1Day.
  ///
  /// In en, this message translates to:
  /// **'One Day Ahead (+1)'**
  String get hijriPlus1Day;

  /// No description provided for @hijriPlus2Days.
  ///
  /// In en, this message translates to:
  /// **'Two Days Ahead (+2)'**
  String get hijriPlus2Days;

  /// No description provided for @homeAdFreeMessage.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq is an ad-free Islamic app. Share it with your friends and family to earn hasanah and benefit the whole ummah.'**
  String get homeAdFreeMessage;

  /// No description provided for @homeAllahsNames.
  ///
  /// In en, this message translates to:
  /// **'Allah\'s Names'**
  String get homeAllahsNames;

  /// No description provided for @homeCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get homeCalendar;

  /// No description provided for @homeDailyDua.
  ///
  /// In en, this message translates to:
  /// **'Daily Dua'**
  String get homeDailyDua;

  /// No description provided for @homeDailyDuaText.
  ///
  /// In en, this message translates to:
  /// **'With the Name of Allah, the Most Gracious, the Most Merciful. Say: He is Allah, the One. Allah, the Self-Sufficient Master, Whom all creatures need. He begets not, nor was He begotten, and there is none equal to Him.'**
  String get homeDailyDuaText;

  /// No description provided for @homeDuaAndZikr.
  ///
  /// In en, this message translates to:
  /// **'Dua & Zikr'**
  String get homeDuaAndZikr;

  /// No description provided for @homeExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeExplore;

  /// No description provided for @homeAyahPicture.
  ///
  /// In en, this message translates to:
  /// **'Ayah Picture'**
  String get homeAyahPicture;

  /// No description provided for @asmaPicture.
  ///
  /// In en, this message translates to:
  /// **'Asma\'ul Husna Picture'**
  String get asmaPicture;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @licensesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 license} other{{count} licenses}}'**
  String licensesCount(int count);

  /// No description provided for @licensesIntro.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq is built on these open-source packages. Thank you to everyone who made them.'**
  String get licensesIntro;

  /// No description provided for @licensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source packages used in Rafeeq'**
  String get licensesSubtitle;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportIssue;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Found a bug? Let us know on GitHub'**
  String get reportIssueSubtitle;

  /// No description provided for @settingsSectionAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get settingsSectionAppInfo;

  /// No description provided for @settingsSectionPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer & Calendar'**
  String get settingsSectionPrayer;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support Rafeeq'**
  String get settingsSectionSupport;

  /// No description provided for @showArabic.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic'**
  String get showArabic;

  /// No description provided for @showMeaning.
  ///
  /// In en, this message translates to:
  /// **'Show Meaning'**
  String get showMeaning;

  /// No description provided for @includeArabicAyah.
  ///
  /// In en, this message translates to:
  /// **'Include the Arabic Ayah in the picture'**
  String get includeArabicAyah;

  /// No description provided for @includeArabicName.
  ///
  /// In en, this message translates to:
  /// **'Include Allah\'s Arabic name in the picture'**
  String get includeArabicName;

  /// No description provided for @includeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Include the selected translation in the picture'**
  String get includeTranslation;

  /// No description provided for @includeNameMeaning.
  ///
  /// In en, this message translates to:
  /// **'Include the name meaning in the picture'**
  String get includeNameMeaning;

  /// No description provided for @urduMode.
  ///
  /// In en, this message translates to:
  /// **'Urdu Mode'**
  String get urduMode;

  /// No description provided for @showMeaningInUrdu.
  ///
  /// In en, this message translates to:
  /// **'Show the meaning in Urdu'**
  String get showMeaningInUrdu;

  /// No description provided for @showingMeaningInUrdu.
  ///
  /// In en, this message translates to:
  /// **'Showing the meaning in Urdu'**
  String get showingMeaningInUrdu;

  /// No description provided for @useUrduPictureLayout.
  ///
  /// In en, this message translates to:
  /// **'Use Urdu card layout and translation'**
  String get useUrduPictureLayout;

  /// No description provided for @usingUrduPictureLayout.
  ///
  /// In en, this message translates to:
  /// **'Urdu card layout and translation defaults'**
  String get usingUrduPictureLayout;

  /// No description provided for @chooseSurah.
  ///
  /// In en, this message translates to:
  /// **'Choose Surah'**
  String get chooseSurah;

  /// No description provided for @jumpToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jump To Ayah'**
  String get jumpToAyah;

  /// No description provided for @unableToLoadQuran.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Quran'**
  String get unableToLoadQuran;

  /// No description provided for @unableToLoadAsma.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Asma\'ul Husna'**
  String get unableToLoadAsma;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudio;

  /// No description provided for @playFromAyah.
  ///
  /// In en, this message translates to:
  /// **'Play from this ayah'**
  String get playFromAyah;

  /// No description provided for @bookmarkAyah.
  ///
  /// In en, this message translates to:
  /// **'Bookmark ayah'**
  String get bookmarkAyah;

  /// No description provided for @shareAyah.
  ///
  /// In en, this message translates to:
  /// **'Share ayah'**
  String get shareAyah;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @noAyahPlaying.
  ///
  /// In en, this message translates to:
  /// **'No ayah playing'**
  String get noAyahPlaying;

  /// No description provided for @noQuranAudioPlaying.
  ///
  /// In en, this message translates to:
  /// **'No Quran audio is playing'**
  String get noQuranAudioPlaying;

  /// No description provided for @quranRecitation.
  ///
  /// In en, this message translates to:
  /// **'Quran recitation'**
  String get quranRecitation;

  /// No description provided for @tapToExpand.
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get tapToExpand;

  /// No description provided for @tapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// No description provided for @playbackComplete.
  ///
  /// In en, this message translates to:
  /// **'{name} complete'**
  String playbackComplete(Object name);

  /// No description provided for @homeForbiddenSalatTimes.
  ///
  /// In en, this message translates to:
  /// **'Forbidden Salat Times'**
  String get homeForbiddenSalatTimes;

  /// No description provided for @homeHadithSource.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim, Book 20, Hadith 4665'**
  String get homeHadithSource;

  /// No description provided for @homeHadithText.
  ///
  /// In en, this message translates to:
  /// **'Prophet Muhammad (PBUH) said: ‘Whoever guides someone to goodness will have a reward like the one who did it.’'**
  String get homeHadithText;

  /// No description provided for @homeMosques.
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get homeMosques;

  /// No description provided for @homeNoon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get homeNoon;

  /// No description provided for @homeSahih.
  ///
  /// In en, this message translates to:
  /// **'Sahih'**
  String get homeSahih;

  /// No description provided for @homeShareNow.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get homeShareNow;

  /// No description provided for @homeShareRafeeq.
  ///
  /// In en, this message translates to:
  /// **'Share Rafeeq'**
  String get homeShareRafeeq;

  /// No description provided for @homeSuhurEnd.
  ///
  /// In en, this message translates to:
  /// **'Suhur End'**
  String get homeSuhurEnd;

  /// No description provided for @homeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get homeSunset;

  /// No description provided for @homeTahajjud.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get homeTahajjud;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @installNow.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get installNow;

  /// No description provided for @juristicMethod.
  ///
  /// In en, this message translates to:
  /// **'Juristic Method'**
  String get juristicMethod;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationDataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Location data couldn\'t be loaded. Check your internet connection and try again.'**
  String get locationDataLoadError;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that location. Check the country and city names and try again.'**
  String get locationNotFound;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get locationNotSet;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied permanently. Please enable it in settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Required to calculate accurate prayer times and Qibla direction based on your position.'**
  String get locationPermissionDescription;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationPermissionTitle;

  /// No description provided for @locationRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Prayer times are calculated based on your location. Please grant location permission to see accurate prayer timings.'**
  String get locationRequiredDescription;

  /// No description provided for @locationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequiredTitle;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated'**
  String get locationUpdated;

  /// No description provided for @manualLocation.
  ///
  /// In en, this message translates to:
  /// **'Manual Location'**
  String get manualLocation;

  /// No description provided for @manualLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Manually select the country and city. Update the location if you change city.'**
  String get manualLocationDescription;

  /// No description provided for @markAs.
  ///
  /// In en, this message translates to:
  /// **'Mark as'**
  String get markAs;

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarksYet;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notification Enabled'**
  String get notificationEnabled;

  /// No description provided for @notificationEnabledOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this prayer'**
  String get notificationEnabledOff;

  /// No description provided for @notificationEnabledOn.
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications for this prayer'**
  String get notificationEnabledOn;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Required to send you prayer time reminders and alerts.'**
  String get notificationPermissionDescription;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationsDisabledBanner.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled — tap to enable reminders'**
  String get notificationsDisabledBanner;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @onboardingAsmaulHusnaDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn the 99 beautiful names of Allah with meanings'**
  String get onboardingAsmaulHusnaDescription;

  /// No description provided for @onboardingHijriCalendarDescription.
  ///
  /// In en, this message translates to:
  /// **'View and convert dates between Hijri and Gregorian calendars'**
  String get onboardingHijriCalendarDescription;

  /// No description provided for @onboardingLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to personalize your experience'**
  String get onboardingLanguageDescription;

  /// No description provided for @onboardingPrayerTimesDescription.
  ///
  /// In en, this message translates to:
  /// **'Get accurate prayer times for your location with notifications'**
  String get onboardingPrayerTimesDescription;

  /// No description provided for @onboardingQiblaDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the accurate Qibla direction from anywhere in the world'**
  String get onboardingQiblaDescription;

  /// No description provided for @onboardingQuranDescription.
  ///
  /// In en, this message translates to:
  /// **'Read and listen to the Holy Quran with translations and recitations'**
  String get onboardingQuranDescription;

  /// No description provided for @onboardingThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme that suits your style'**
  String get onboardingThemeDescription;

  /// No description provided for @onboardingThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a theme that suits your style'**
  String get onboardingThemeSubtitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your complete Islamic companion for daily spiritual needs'**
  String get onboardingWelcomeDescription;

  /// No description provided for @oneShawwal.
  ///
  /// In en, this message translates to:
  /// **'1 Shawwal'**
  String get oneShawwal;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionsDescription.
  ///
  /// In en, this message translates to:
  /// **'To provide you with accurate prayer times, Qibla direction, and prayer reminders, Rafeeq needs access to your location and notifications.'**
  String get permissionsDescription;

  /// No description provided for @permissionsGranted.
  ///
  /// In en, this message translates to:
  /// **'Permissions Granted'**
  String get permissionsGranted;

  /// No description provided for @permissionsSkipped.
  ///
  /// In en, this message translates to:
  /// **'Permissions Skipped'**
  String get permissionsSkipped;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Permissions'**
  String get permissionsTitle;

  /// No description provided for @playbackSettings.
  ///
  /// In en, this message translates to:
  /// **'Playback Settings'**
  String get playbackSettings;

  /// No description provided for @prayEidToday.
  ///
  /// In en, this message translates to:
  /// **'Pray Eid Today'**
  String get prayEidToday;

  /// No description provided for @prayEidUlAdhaToday.
  ///
  /// In en, this message translates to:
  /// **'Pray Eid-ul-Adha Today'**
  String get prayEidUlAdhaToday;

  /// No description provided for @prayEidUlFitrToday.
  ///
  /// In en, this message translates to:
  /// **'Pray Eid-ul-Fitr Today'**
  String get prayEidUlFitrToday;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerJumma.
  ///
  /// In en, this message translates to:
  /// **'Jumma'**
  String get prayerJumma;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get prayerNone;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @prayerAndFastingReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer, Fasting & Eid Reminders'**
  String get prayerAndFastingReminders;

  /// No description provided for @prayerTimesSettings.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times Settings'**
  String get prayerTimesSettings;

  /// No description provided for @prayerTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily salah schedule'**
  String get prayerTimesSubtitle;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'You are facing Qibla'**
  String get qiblaFacing;

  /// No description provided for @qiblaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the Qibla direction'**
  String get qiblaSubtitle;

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn {degrees}° Left'**
  String qiblaTurnLeft(int degrees);

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn {degrees}° Right'**
  String qiblaTurnRight(int degrees);

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an'**
  String get quran;

  /// No description provided for @quranAutoScrollDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll Disabled'**
  String get quranAutoScrollDisabled;

  /// No description provided for @quranAutoScrollEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll Enabled'**
  String get quranAutoScrollEnabled;

  /// No description provided for @quranPageTab.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get quranPageTab;

  /// No description provided for @quranSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read & explore the Holy Qur\'an'**
  String get quranSubtitle;

  /// No description provided for @quranTopicTab.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get quranTopicTab;

  /// No description provided for @quranViewSettings.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an View Settings'**
  String get quranViewSettings;

  /// No description provided for @qurbaniDay.
  ///
  /// In en, this message translates to:
  /// **'Qurbani Day'**
  String get qurbaniDay;

  /// No description provided for @ramadanCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Calendar'**
  String get ramadanCalendarTitle;

  /// No description provided for @ramadanCard.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Card'**
  String get ramadanCard;

  /// No description provided for @ramadanCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suhoor & Iftar times for today'**
  String get ramadanCardSubtitle;

  /// No description provided for @ramadanMubarak.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Mubarak'**
  String get ramadanMubarak;

  /// No description provided for @ramadanSettings.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Settings'**
  String get ramadanSettings;

  /// No description provided for @rateThisApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateThisApp;

  /// No description provided for @rateThisAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Love the app? Let us know on the Play Store'**
  String get rateThisAppSubtitle;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @readSurahKahf.
  ///
  /// In en, this message translates to:
  /// **'Tap To Read Surah Al-Kahf'**
  String get readSurahKahf;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'This will reset all Quran view settings including font sizes, theme, translation edition, and reciter to their default values. This action cannot be undone.'**
  String get resetSettingsMessage;

  /// No description provided for @resetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsTitle;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @resetToDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the home screen layout to default?'**
  String get resetToDefaultMessage;

  /// No description provided for @resetToDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all Quran view settings to default values'**
  String get resetToDefaultSubtitle;

  /// No description provided for @resetToDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefaultTitle;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get restartNow;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sacrifice.
  ///
  /// In en, this message translates to:
  /// **'Qurbani'**
  String get sacrifice;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @scriptStylingAndSize.
  ///
  /// In en, this message translates to:
  /// **'Script styling and size.'**
  String get scriptStylingAndSize;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchErrorHelp.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your search with the current translation.'**
  String get searchErrorHelp;

  /// No description provided for @searchOnlyTextEditions.
  ///
  /// In en, this message translates to:
  /// **'Please note that only text editions of the Quran are searchable.'**
  String get searchOnlyTextEditions;

  /// No description provided for @searchQuranHint.
  ///
  /// In en, this message translates to:
  /// **'Search Quran (Arabic or Translation)...'**
  String get searchQuranHint;

  /// No description provided for @searchTranslations.
  ///
  /// In en, this message translates to:
  /// **'Search translations...'**
  String get searchTranslations;

  /// No description provided for @selectArabicFont.
  ///
  /// In en, this message translates to:
  /// **'Select Arabic Font'**
  String get selectArabicFont;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @selectCollection.
  ///
  /// In en, this message translates to:
  /// **'Select Collection'**
  String get selectCollection;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @selectFont.
  ///
  /// In en, this message translates to:
  /// **'Select Font'**
  String get selectFont;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to continue'**
  String get selectLanguageSubtitle;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'SELECT OPTION'**
  String get selectOption;

  /// No description provided for @selectTranslation.
  ///
  /// In en, this message translates to:
  /// **'Select Translation'**
  String get selectTranslation;

  /// No description provided for @setLocationForPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Set Location for Prayer Times'**
  String get setLocationForPrayerTimes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to default'**
  String get settingsResetSuccess;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareThisApp.
  ///
  /// In en, this message translates to:
  /// **'Share this app'**
  String get shareThisApp;

  /// No description provided for @shareThisAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share Rafeeq with friends and family'**
  String get shareThisAppSubtitle;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show Translation'**
  String get showTranslation;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show Transliteration'**
  String get showTransliteration;

  /// No description provided for @showTransliterationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show phonetic line under Arabic.'**
  String get showTransliterationSubtitle;

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @sixteenLineQuran.
  ///
  /// In en, this message translates to:
  /// **'16 Line Quran'**
  String get sixteenLineQuran;

  /// No description provided for @sixteenLineQuranSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read 16 Line Tajweedi Quran'**
  String get sixteenLineQuranSubtitle;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerActive.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer Active'**
  String get sleepTimerActive;

  /// No description provided for @sleepTimerHours.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Hour} other{Hours}}'**
  String sleepTimerHours(int count);

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String sleepTimerMinutes(int count);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @soundAllahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get soundAllahuAkbar;

  /// No description provided for @soundAllahuAkbarDesc.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar call'**
  String get soundAllahuAkbarDesc;

  /// No description provided for @soundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get soundDefault;

  /// No description provided for @soundDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'System default notification sound'**
  String get soundDefaultDesc;

  /// No description provided for @soundFalahDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Salah azan sound'**
  String get soundFalahDesc;

  /// No description provided for @soundSalah.
  ///
  /// In en, this message translates to:
  /// **'Salah Sound'**
  String get soundSalah;

  /// No description provided for @soundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get soundSilent;

  /// No description provided for @soundSilentDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification will show without sound'**
  String get soundSilentDesc;

  /// No description provided for @statusFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get statusFasting;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get statusNone;

  /// No description provided for @suhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get suhoor;

  /// No description provided for @sunnahCleanClothes.
  ///
  /// In en, this message translates to:
  /// **'Clean Clothes'**
  String get sunnahCleanClothes;

  /// No description provided for @sunnahCleanClothesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wear fresh clean clothes for prayer'**
  String get sunnahCleanClothesSubtitle;

  /// No description provided for @sunnahDurood.
  ///
  /// In en, this message translates to:
  /// **'Send Salawat'**
  String get sunnahDurood;

  /// No description provided for @sunnahDuroodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recite blessings on the Prophet'**
  String get sunnahDuroodSubtitle;

  /// No description provided for @sunnahGhusl.
  ///
  /// In en, this message translates to:
  /// **'Perform Ghusl'**
  String get sunnahGhusl;

  /// No description provided for @sunnahGhuslSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full body purification before Friday'**
  String get sunnahGhuslSubtitle;

  /// No description provided for @sunnahMiswak.
  ///
  /// In en, this message translates to:
  /// **'Use Miswak'**
  String get sunnahMiswak;

  /// No description provided for @sunnahMiswakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean teeth before leaving home'**
  String get sunnahMiswakSubtitle;

  /// No description provided for @sunnahPerfume.
  ///
  /// In en, this message translates to:
  /// **'Apply Perfume'**
  String get sunnahPerfume;

  /// No description provided for @sunnahPerfumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wear pleasant fragrance for mosque'**
  String get sunnahPerfumeSubtitle;

  /// No description provided for @supportsRtlLanguages.
  ///
  /// In en, this message translates to:
  /// **'Supports RTL languages'**
  String get supportsRtlLanguages;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @surahRepeat.
  ///
  /// In en, this message translates to:
  /// **'Surah Repeat'**
  String get surahRepeat;

  /// No description provided for @surahRepeatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat the current Surah after it finishes'**
  String get surahRepeatSubtitle;

  /// No description provided for @switchToGridView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Grid View'**
  String get switchToGridView;

  /// No description provided for @switchToListView.
  ///
  /// In en, this message translates to:
  /// **'Switch to List View'**
  String get switchToListView;

  /// No description provided for @takbeer.
  ///
  /// In en, this message translates to:
  /// **'Takbeer'**
  String get takbeer;

  /// No description provided for @takbeerText.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get takbeerText;

  /// No description provided for @tenDhulHijjah.
  ///
  /// In en, this message translates to:
  /// **'10 Dhul Hijjah'**
  String get tenDhulHijjah;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeDefault;

  /// No description provided for @themeDefaultBlue.
  ///
  /// In en, this message translates to:
  /// **'Lime & Blue'**
  String get themeDefaultBlue;

  /// No description provided for @themeEmeraldGreen.
  ///
  /// In en, this message translates to:
  /// **'Emerald Green'**
  String get themeEmeraldGreen;

  /// No description provided for @themeGradientBlue.
  ///
  /// In en, this message translates to:
  /// **'Gradient (Blue)'**
  String get themeGradientBlue;

  /// No description provided for @themeGradientGreen.
  ///
  /// In en, this message translates to:
  /// **'Gradient (Green)'**
  String get themeGradientGreen;

  /// No description provided for @themeGradientPurple.
  ///
  /// In en, this message translates to:
  /// **'Gradient (Purple)'**
  String get themeGradientPurple;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeOceanTeal.
  ///
  /// In en, this message translates to:
  /// **'Ocean Teal'**
  String get themeOceanTeal;

  /// No description provided for @themePaperAged.
  ///
  /// In en, this message translates to:
  /// **'Aged Paper'**
  String get themePaperAged;

  /// No description provided for @themePaperCream.
  ///
  /// In en, this message translates to:
  /// **'Paper (Cream)'**
  String get themePaperCream;

  /// No description provided for @themePaperDark.
  ///
  /// In en, this message translates to:
  /// **'Paper (Dark)'**
  String get themePaperDark;

  /// No description provided for @themePaperLight.
  ///
  /// In en, this message translates to:
  /// **'Paper (Light)'**
  String get themePaperLight;

  /// No description provided for @themePaperWood.
  ///
  /// In en, this message translates to:
  /// **'Woody Pattern'**
  String get themePaperWood;

  /// No description provided for @themeSelectShortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeSelectShortDefault;

  /// No description provided for @themeSelectShortGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get themeSelectShortGreen;

  /// No description provided for @themeSelectShortGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get themeSelectShortGrey;

  /// No description provided for @themeSelectShortTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get themeSelectShortTeal;

  /// No description provided for @themeSlateGrey.
  ///
  /// In en, this message translates to:
  /// **'Slate Grey'**
  String get themeSlateGrey;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormat;

  /// No description provided for @timeFormat12Hour.
  ///
  /// In en, this message translates to:
  /// **'12-Hour Format'**
  String get timeFormat12Hour;

  /// No description provided for @timeFormat24Hour.
  ///
  /// In en, this message translates to:
  /// **'24-Hour Format'**
  String get timeFormat24Hour;

  /// No description provided for @timeLeftIftar.
  ///
  /// In en, this message translates to:
  /// **'Time until Iftar'**
  String get timeLeftIftar;

  /// No description provided for @timeLeftSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Time until Suhoor'**
  String get timeLeftSuhoor;

  /// No description provided for @toggleTranslationVisibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle translated text visibility.'**
  String get toggleTranslationVisibility;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @translationEdition.
  ///
  /// In en, this message translates to:
  /// **'Translation Edition'**
  String get translationEdition;

  /// No description provided for @translationFont.
  ///
  /// In en, this message translates to:
  /// **'Translation Font'**
  String get translationFont;

  /// No description provided for @translationFontSize.
  ///
  /// In en, this message translates to:
  /// **'Translation Font Size'**
  String get translationFontSize;

  /// No description provided for @translationFontSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to translations.'**
  String get translationFontSizeSubtitle;

  /// No description provided for @translationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationLabel;

  /// No description provided for @translationSettings.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationSettings;

  /// No description provided for @translationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language, font, and size.'**
  String get translationSettingsSubtitle;

  /// No description provided for @transliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get transliteration;

  /// No description provided for @transliterationFontSize.
  ///
  /// In en, this message translates to:
  /// **'Transliteration Font Size'**
  String get transliterationFontSize;

  /// No description provided for @transliterationFontSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always shown in English script.'**
  String get transliterationFontSizeSubtitle;

  /// No description provided for @transliterationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latin script pronunciation guide.'**
  String get transliterationSubtitle;

  /// No description provided for @translitLabel.
  ///
  /// In en, this message translates to:
  /// **'Translit'**
  String get translitLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @updateDownloadedMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of Rafeeq has been downloaded and is ready to be installed.'**
  String get updateDownloadedMessage;

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'Update Ready'**
  String get updateReady;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionDetailsBugFixes.
  ///
  /// In en, this message translates to:
  /// **'Bug Fixes'**
  String get versionDetailsBugFixes;

  /// No description provided for @versionDetailsBugFixesBody.
  ///
  /// In en, this message translates to:
  /// **'Restored the Qur\'an mini-player in the reader.'**
  String get versionDetailsBugFixesBody;

  /// No description provided for @versionDetailsDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get versionDetailsDesign;

  /// No description provided for @versionDetailsDesignBody.
  ///
  /// In en, this message translates to:
  /// **'Refined the About experience while preserving Rafeeq\'s familiar appearance.'**
  String get versionDetailsDesignBody;

  /// No description provided for @versionDetailsEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Enhancements'**
  String get versionDetailsEnhancements;

  /// No description provided for @versionDetailsEnhancementsBody.
  ///
  /// In en, this message translates to:
  /// **'The About page now links directly to the official WhatsApp channel and developer portfolio.'**
  String get versionDetailsEnhancementsBody;

  /// No description provided for @versionDetailsFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get versionDetailsFeatures;

  /// No description provided for @versionDetailsFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'• Simpler onboarding with no account or sign-in required'**
  String get versionDetailsFeaturesBody;

  /// No description provided for @versionDetailsIntro.
  ///
  /// In en, this message translates to:
  /// **'This update simplifies onboarding and improves the About experience and Qur\'an playback.'**
  String get versionDetailsIntro;

  /// No description provided for @versionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current installed version'**
  String get versionSubtitle;

  /// No description provided for @viewMonthlyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Tap To View Monthly Calendar'**
  String get viewMonthlyCalendar;

  /// No description provided for @viewType.
  ///
  /// In en, this message translates to:
  /// **'View Type'**
  String get viewType;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @volumeAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm Volume'**
  String get volumeAlarm;

  /// No description provided for @volumeAlarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum volume for important alerts'**
  String get volumeAlarmDesc;

  /// No description provided for @volumeControl.
  ///
  /// In en, this message translates to:
  /// **'VOLUME CONTROL'**
  String get volumeControl;

  /// No description provided for @volumeNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification Volume'**
  String get volumeNotification;

  /// No description provided for @volumeNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard notification volume level'**
  String get volumeNotificationDesc;

  /// No description provided for @waitingForLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for location...'**
  String get waitingForLocation;

  /// No description provided for @onboardingAppName.
  ///
  /// In en, this message translates to:
  /// **'Rafeeq'**
  String get onboardingAppName;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Muslim Companion'**
  String get onboardingWelcomeTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select a Language'**
  String get selectLanguage;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @onboardingNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer. Rafeeq can gently remind you when it is time to pray.'**
  String get onboardingNotificationsDescription;

  /// No description provided for @dhuhrPrayerBeginsSoon.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr prayer begins soon'**
  String get dhuhrPrayerBeginsSoon;

  /// No description provided for @prepareForPrayer.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to prepare for prayer.'**
  String get prepareForPrayer;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for the Dhuhr prayer'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It is prayer time.'**
  String get onboardingNotificationBody;

  /// No description provided for @onboardingLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your location so prayer times and Qibla guidance are accurate for you.'**
  String get onboardingLocationDescription;

  /// No description provided for @onboardingJuristicDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your school of thought (Madhab) for Asr prayer time.'**
  String get onboardingJuristicDescription;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @redesignDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'A fresh new look for Rafeeq'**
  String get redesignDialogTitle;

  /// No description provided for @redesignDialogBody.
  ///
  /// In en, this message translates to:
  /// **'We have fully revamped Rafeeq to make your daily Islamic experience cleaner, clearer and more beautiful.'**
  String get redesignDialogBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get imageLoadError;

  /// No description provided for @homeNewLook.
  ///
  /// In en, this message translates to:
  /// **'New Look'**
  String get homeNewLook;

  /// No description provided for @redesignHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get redesignHomeScreen;

  /// No description provided for @redesignQiblaScreen.
  ///
  /// In en, this message translates to:
  /// **'Qiblah Screen'**
  String get redesignQiblaScreen;

  /// No description provided for @redesignQuranView.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an View'**
  String get redesignQuranView;

  /// No description provided for @redesignSurahJuzList.
  ///
  /// In en, this message translates to:
  /// **'Surah / Juz List'**
  String get redesignSurahJuzList;

  /// No description provided for @redesignNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'More New Experiences'**
  String get redesignNewFeatures;

  /// No description provided for @redesignAyahMaker.
  ///
  /// In en, this message translates to:
  /// **'Ayah Picture Maker'**
  String get redesignAyahMaker;

  /// No description provided for @redesignAyahMakerDescription.
  ///
  /// In en, this message translates to:
  /// **'Create beautiful Ayah pictures with customization options for Arabic text, translations and editions, then share them on social media.'**
  String get redesignAyahMakerDescription;

  /// No description provided for @redesignExtendedHome.
  ///
  /// In en, this message translates to:
  /// **'Extended Home Experience'**
  String get redesignExtendedHome;

  /// No description provided for @redesignExtendedHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'See forbidden Salah times, the Daily Ayah and Share App cards, plus Iftar, Suhoor and Tahajjud times from the expanded Home screen.'**
  String get redesignExtendedHomeDescription;

  /// No description provided for @redesignAdaptiveTheme.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Theme Support'**
  String get redesignAdaptiveTheme;

  /// No description provided for @redesignAdaptiveThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch between Light and Dark themes, or follow the system setting to automatically adapt Rafeeq\'s complete appearance.'**
  String get redesignAdaptiveThemeDescription;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name.'**
  String get firstNameRequired;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'Save Name'**
  String get saveName;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data, permissions and choices'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsAndConditionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Using Rafeeq and its content'**
  String get termsAndConditionsSubtitle;

  /// No description provided for @legalRetry.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this page. Tap to retry.'**
  String get legalRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
