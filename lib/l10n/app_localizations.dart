import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

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
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran App'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran App'**
  String get homeTitle;

  /// No description provided for @readQuran.
  ///
  /// In en, this message translates to:
  /// **'Read Quran'**
  String get readQuran;

  /// No description provided for @quranAudio.
  ///
  /// In en, this message translates to:
  /// **'Quran Audio'**
  String get quranAudio;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @prayerTimesAndQibla.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times & Qibla'**
  String get prayerTimesAndQibla;

  /// No description provided for @reflectionJournal.
  ///
  /// In en, this message translates to:
  /// **'Reflection Journal'**
  String get reflectionJournal;

  /// No description provided for @azkaarAndDua.
  ///
  /// In en, this message translates to:
  /// **'Azkaar and Dua'**
  String get azkaarAndDua;

  /// No description provided for @verseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get verseOfTheDay;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @findGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find verses that speak to your heart right now'**
  String get findGuidanceSubtitle;

  /// No description provided for @findGuidance.
  ///
  /// In en, this message translates to:
  /// **'Find Guidance'**
  String get findGuidance;

  /// No description provided for @findingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Finding Guidance'**
  String get findingGuidance;

  /// No description provided for @forWhenYoure.
  ///
  /// In en, this message translates to:
  /// **'For when you\'re {emotion}'**
  String forWhenYoure(Object emotion);

  /// No description provided for @yourStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Your Study Plan'**
  String get yourStudyPlan;

  /// No description provided for @studyPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a personalized plan for reading, understanding, or memorizing'**
  String get studyPlanSubtitle;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @azkaarAndDuaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily remembrance and supplications from the Quran and Sunnah'**
  String get azkaarAndDuaSubtitle;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App theme switches instantly to a dark palette for night reading'**
  String get darkModeSubtitle;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @defaultReciter.
  ///
  /// In en, this message translates to:
  /// **'Default Reciter'**
  String get defaultReciter;

  /// No description provided for @streaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get streaming;

  /// No description provided for @streamingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stream audio instead of downloading'**
  String get streamingSubtitle;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @ayahBeforeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Ayah before translation'**
  String get ayahBeforeTranslation;

  /// No description provided for @ayahBeforeTranslationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic above the translation'**
  String get ayahBeforeTranslationSubtitle;

  /// No description provided for @ayahTextSize.
  ///
  /// In en, this message translates to:
  /// **'Ayah text size'**
  String get ayahTextSize;

  /// No description provided for @transliterationTextSize.
  ///
  /// In en, this message translates to:
  /// **'Transliteration text size'**
  String get transliterationTextSize;

  /// No description provided for @translationTextSize.
  ///
  /// In en, this message translates to:
  /// **'Translation text size'**
  String get translationTextSize;

  /// No description provided for @referenceTextSize.
  ///
  /// In en, this message translates to:
  /// **'Reference text size'**
  String get referenceTextSize;

  /// No description provided for @quranScript.
  ///
  /// In en, this message translates to:
  /// **'Quran Script'**
  String get quranScript;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @feedbackChat.
  ///
  /// In en, this message translates to:
  /// **'Feedback / Chat'**
  String get feedbackChat;

  /// No description provided for @feedbackChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s share your thoughts with us'**
  String get feedbackChatSubtitle;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @rateUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback will help millions of users worldwide'**
  String get rateUsSubtitle;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite & Share 5 Friends to Remove Ads'**
  String get shareAppSubtitle;

  /// No description provided for @chooseAReciter.
  ///
  /// In en, this message translates to:
  /// **'Choose a reciter'**
  String get chooseAReciter;

  /// No description provided for @searchReciters.
  ///
  /// In en, this message translates to:
  /// **'Search reciters'**
  String get searchReciters;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selected;

  /// No description provided for @allReciters.
  ///
  /// In en, this message translates to:
  /// **'ALL RECITERS'**
  String get allReciters;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @downloadRecitations.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD RECITATIONS'**
  String get downloadRecitations;

  /// No description provided for @downloadedReciters.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADED RECITERS'**
  String get downloadedReciters;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get used;

  /// No description provided for @freeStorage.
  ///
  /// In en, this message translates to:
  /// **'free storage'**
  String get freeStorage;

  /// No description provided for @quranText.
  ///
  /// In en, this message translates to:
  /// **'Quran text'**
  String get quranText;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @noDownloadedRecitations.
  ///
  /// In en, this message translates to:
  /// **'No downloaded recitations yet'**
  String get noDownloadedRecitations;

  /// No description provided for @downloadedFilesInfo.
  ///
  /// In en, this message translates to:
  /// **'Downloaded audio files will appear here for offline listening.'**
  String get downloadedFilesInfo;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @notDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get notDownloaded;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @newReflection.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newReflection;

  /// No description provided for @noReflectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No reflections yet'**
  String get noReflectionsYet;

  /// No description provided for @startReadingAndReflecting.
  ///
  /// In en, this message translates to:
  /// **'Start Reading & Reflecting'**
  String get startReadingAndReflecting;

  /// No description provided for @yourPersonalJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Journey'**
  String get yourPersonalJourney;

  /// No description provided for @reflectionJourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write reflections as you read the Quran. Track your spiritual growth and insights over time.'**
  String get reflectionJourneySubtitle;

  /// No description provided for @yourReflectionStats.
  ///
  /// In en, this message translates to:
  /// **'Your Reflection Stats'**
  String get yourReflectionStats;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No Bookmarks Yet'**
  String get noBookmarksYet;

  /// No description provided for @exploreQuran.
  ///
  /// In en, this message translates to:
  /// **'Explore Quran'**
  String get exploreQuran;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @verses.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get verses;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @rememberAllah.
  ///
  /// In en, this message translates to:
  /// **'Remember Allah'**
  String get rememberAllah;

  /// No description provided for @rememberAllahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'\"Verily, in the remembrance of Allah do hearts find rest.\" (Quran 13:28)'**
  String get rememberAllahSubtitle;

  /// No description provided for @azkaar.
  ///
  /// In en, this message translates to:
  /// **'Azkaar'**
  String get azkaar;

  /// No description provided for @azkaarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remembrance and phrases from the Sunnah to say throughout your day'**
  String get azkaarSubtitle;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duas;

  /// No description provided for @duasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supplications from the Holy Quran for every need'**
  String get duasSubtitle;

  /// No description provided for @benefitsOfDhikr.
  ///
  /// In en, this message translates to:
  /// **'Benefits of Dhikr'**
  String get benefitsOfDhikr;

  /// No description provided for @yourFeelingsMatter.
  ///
  /// In en, this message translates to:
  /// **'Your feelings matter'**
  String get yourFeelingsMatter;

  /// No description provided for @yourFeelingsMatterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allah knows what\'s in your heart. Turn to the Quran for comfort, guidance, and strength.'**
  String get yourFeelingsMatterSubtitle;

  /// No description provided for @whyThisVerse.
  ///
  /// In en, this message translates to:
  /// **'Why this verse?'**
  String get whyThisVerse;

  /// No description provided for @readFullSurah.
  ///
  /// In en, this message translates to:
  /// **'Read Full Surah'**
  String get readFullSurah;

  /// No description provided for @openPage.
  ///
  /// In en, this message translates to:
  /// **'Open Page'**
  String get openPage;

  /// No description provided for @tafseer.
  ///
  /// In en, this message translates to:
  /// **'Tafseer'**
  String get tafseer;

  /// No description provided for @reflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// No description provided for @asSalamuAlaykum.
  ///
  /// In en, this message translates to:
  /// **'As-Salamu Alaykum'**
  String get asSalamuAlaykum;

  /// No description provided for @mayPeaceBeUponYou.
  ///
  /// In en, this message translates to:
  /// **'May peace be upon you'**
  String get mayPeaceBeUponYou;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @startReadingToContinue.
  ///
  /// In en, this message translates to:
  /// **'Start reading to continue'**
  String get startReadingToContinue;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get startReading;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @versesRead.
  ///
  /// In en, this message translates to:
  /// **'Verses Read'**
  String get versesRead;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @numberOfSurahs.
  ///
  /// In en, this message translates to:
  /// **'114 Surahs'**
  String get numberOfSurahs;

  /// No description provided for @searchSurah.
  ///
  /// In en, this message translates to:
  /// **'Search surah...'**
  String get searchSurah;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get lastRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @profileAndProgress.
  ///
  /// In en, this message translates to:
  /// **'Profile & Progress'**
  String get profileAndProgress;

  /// No description provided for @readingSince.
  ///
  /// In en, this message translates to:
  /// **'Reading since'**
  String get readingSince;

  /// No description provided for @quranProgress.
  ///
  /// In en, this message translates to:
  /// **'Quran Progress'**
  String get quranProgress;

  /// No description provided for @overallCompletion.
  ///
  /// In en, this message translates to:
  /// **'Overall completion'**
  String get overallCompletion;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going!'**
  String get keepGoing;

  /// No description provided for @keepGoingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing amazing. Continue your journey with the Quran.'**
  String get keepGoingSubtitle;

  /// No description provided for @listenToRecitations.
  ///
  /// In en, this message translates to:
  /// **'Listen to beautiful recitations'**
  String get listenToRecitations;

  /// No description provided for @recitersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Reciters'**
  String recitersCount(Object count);

  /// No description provided for @featuredReciters.
  ///
  /// In en, this message translates to:
  /// **'Featured Reciters'**
  String get featuredReciters;

  /// No description provided for @featuredRecitersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from renowned Quran reciters from around the world'**
  String get featuredRecitersSubtitle;

  /// No description provided for @searchByReciterName.
  ///
  /// In en, this message translates to:
  /// **'Search by reciter name or country...'**
  String get searchByReciterName;

  /// No description provided for @aboutQuranAudio.
  ///
  /// In en, this message translates to:
  /// **'About Quran Audio'**
  String get aboutQuranAudio;

  /// No description provided for @aboutQuranAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to the complete Quran recited by world-renowned reciters. Each reciter brings their unique style and melodious voice to the sacred text.'**
  String get aboutQuranAudioSubtitle;

  /// No description provided for @adhanTime.
  ///
  /// In en, this message translates to:
  /// **'Adhan time'**
  String get adhanTime;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @findDirectionToMecca.
  ///
  /// In en, this message translates to:
  /// **'Find direction to Mecca'**
  String get findDirectionToMecca;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @azkarCategories.
  ///
  /// In en, this message translates to:
  /// **'Azkar Categories'**
  String get azkarCategories;

  /// No description provided for @azkarCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily remembrance from the Sunnah'**
  String get azkarCategoriesSubtitle;

  /// No description provided for @selectSpecificOccasion.
  ///
  /// In en, this message translates to:
  /// **'Select a specific occasion'**
  String get selectSpecificOccasion;

  /// No description provided for @readAndReflect.
  ///
  /// In en, this message translates to:
  /// **'Read and reflect'**
  String get readAndReflect;

  /// No description provided for @emotionStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get emotionStressed;

  /// No description provided for @emotionGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get emotionGrateful;

  /// No description provided for @emotionSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get emotionSad;

  /// No description provided for @emotionHopeless.
  ///
  /// In en, this message translates to:
  /// **'Hopeless'**
  String get emotionHopeless;

  /// No description provided for @emotionSeekingForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Seeking Forgiveness'**
  String get emotionSeekingForgiveness;

  /// No description provided for @emotionNeedMotivation.
  ///
  /// In en, this message translates to:
  /// **'Need Motivation'**
  String get emotionNeedMotivation;

  /// No description provided for @emotionInAwe.
  ///
  /// In en, this message translates to:
  /// **'In Awe'**
  String get emotionInAwe;

  /// No description provided for @emotionSeekingWisdom.
  ///
  /// In en, this message translates to:
  /// **'Seeking Wisdom'**
  String get emotionSeekingWisdom;

  /// No description provided for @catMorningEvening.
  ///
  /// In en, this message translates to:
  /// **'Morning & Evening'**
  String get catMorningEvening;

  /// No description provided for @catHomeFamily.
  ///
  /// In en, this message translates to:
  /// **'Home & Family'**
  String get catHomeFamily;

  /// No description provided for @catFoodDrink.
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get catFoodDrink;

  /// No description provided for @catJoyDistress.
  ///
  /// In en, this message translates to:
  /// **'Joy & Distress'**
  String get catJoyDistress;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get catPrayer;

  /// No description provided for @catPraisingAllah.
  ///
  /// In en, this message translates to:
  /// **'Praising Allah'**
  String get catPraisingAllah;

  /// No description provided for @catHajjUmrah.
  ///
  /// In en, this message translates to:
  /// **'Hajj & Umrah'**
  String get catHajjUmrah;

  /// No description provided for @catGoodEtiquette.
  ///
  /// In en, this message translates to:
  /// **'Good Etiquette'**
  String get catGoodEtiquette;

  /// No description provided for @catNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get catNature;

  /// No description provided for @catSicknessDeath.
  ///
  /// In en, this message translates to:
  /// **'Sickness & Death'**
  String get catSicknessDeath;

  /// No description provided for @versesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String versesCount(Object count);

  /// No description provided for @azkarCount.
  ///
  /// In en, this message translates to:
  /// **'{count} azkar'**
  String azkarCount(Object count);
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
      <String>['en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
