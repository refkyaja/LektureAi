import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lekture'**
  String get appTitle;

  /// No description provided for @readyToStudy.
  ///
  /// In en, this message translates to:
  /// **'Ready to study smarter?'**
  String get readyToStudy;

  /// No description provided for @heroDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture a lecture, scan your textbook, or quiz yourself in seconds.'**
  String get heroDescription;

  /// No description provided for @startDictating.
  ///
  /// In en, this message translates to:
  /// **'Start Dictating'**
  String get startDictating;

  /// No description provided for @askAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAi;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @startByDictating.
  ///
  /// In en, this message translates to:
  /// **'Start by dictating or typing your first note.'**
  String get startByDictating;

  /// No description provided for @captureNow.
  ///
  /// In en, this message translates to:
  /// **'Capture now'**
  String get captureNow;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quizMe.
  ///
  /// In en, this message translates to:
  /// **'Quiz me'**
  String get quizMe;

  /// No description provided for @fromAnyNote.
  ///
  /// In en, this message translates to:
  /// **'From any note'**
  String get fromAnyNote;

  /// No description provided for @scanPage.
  ///
  /// In en, this message translates to:
  /// **'Scan page'**
  String get scanPage;

  /// No description provided for @ocrFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'OCR from photo'**
  String get ocrFromPhoto;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDesc.
  ///
  /// In en, this message translates to:
  /// **'Select application theme'**
  String get themeDesc;

  /// No description provided for @compactView.
  ///
  /// In en, this message translates to:
  /// **'Compact view'**
  String get compactView;

  /// No description provided for @compactDesc.
  ///
  /// In en, this message translates to:
  /// **'Smaller cards, tighter spacing'**
  String get compactDesc;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @quizReminders.
  ///
  /// In en, this message translates to:
  /// **'Quiz reminders'**
  String get quizReminders;

  /// No description provided for @quizDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily prompt to review flashcards'**
  String get quizDesc;

  /// No description provided for @studyStreaks.
  ///
  /// In en, this message translates to:
  /// **'Study streaks'**
  String get studyStreaks;

  /// No description provided for @streaksDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your daily streak alive'**
  String get streaksDesc;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto-save notes'**
  String get autoSave;

  /// No description provided for @autoSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Save while you type'**
  String get autoSaveDesc;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchAccount;

  /// No description provided for @switchAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Change to another user profile'**
  String get switchAccountDesc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @logoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account'**
  String get logoutDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get languageDesc;

  /// No description provided for @apiKeySettings.
  ///
  /// In en, this message translates to:
  /// **'API Key Settings'**
  String get apiKeySettings;

  /// No description provided for @customApiKey.
  ///
  /// In en, this message translates to:
  /// **'Custom Gemini API Key'**
  String get customApiKey;

  /// No description provided for @customApiKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your own API key from Google AI Studio'**
  String get customApiKeyDesc;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter API Key'**
  String get enterApiKey;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate Custom API Key'**
  String get activate;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @clearNotes.
  ///
  /// In en, this message translates to:
  /// **'Clear all notes'**
  String get clearNotes;

  /// No description provided for @clearNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get clearNotesDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @switchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Switched to account'**
  String get switchSuccess;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved successfully'**
  String get apiKeySaved;

  /// No description provided for @apiKeyActivated.
  ///
  /// In en, this message translates to:
  /// **'Custom API Key activated'**
  String get apiKeyActivated;

  /// No description provided for @apiKeyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Custom API Key disabled'**
  String get apiKeyDisabled;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @whatCanHelp.
  ///
  /// In en, this message translates to:
  /// **'What can I help with today?'**
  String get whatCanHelp;

  /// No description provided for @askLekture.
  ///
  /// In en, this message translates to:
  /// **'Ask Lekture...'**
  String get askLekture;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @searchChat.
  ///
  /// In en, this message translates to:
  /// **'Search Chat...'**
  String get searchChat;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get noChatsFound;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noConversationsYet;

  /// No description provided for @tagNotes.
  ///
  /// In en, this message translates to:
  /// **'Tag notes for context'**
  String get tagNotes;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get online;

  /// No description provided for @confirmLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'This will reset your profile. Your notes will remain saved locally.'**
  String get confirmLogoutDesc;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty note'**
  String get emptyNote;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @createNoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a note first to tag it.'**
  String get createNoteFirst;

  /// No description provided for @useNotesReference.
  ///
  /// In en, this message translates to:
  /// **'Use these notes as reference:'**
  String get useNotesReference;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I hit an error'**
  String get errorOccurred;

  /// No description provided for @untitledChat.
  ///
  /// In en, this message translates to:
  /// **'Untitled Chat'**
  String get untitledChat;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chatDeleted;

  /// No description provided for @supportEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Support email copied: support@lekture.ai'**
  String get supportEmailCopied;

  /// No description provided for @clearNotesDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your notes, custom tags, study history, and chat logs. This cannot be undone.'**
  String get clearNotesDialogDesc;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully.'**
  String get allDataCleared;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes, tags...'**
  String get searchNotesHint;

  /// No description provided for @newButton.
  ///
  /// In en, this message translates to:
  /// **'+ New'**
  String get newButton;

  /// No description provided for @allChips.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allChips;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search query or select another filter tag.'**
  String get tryDifferentSearch;

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'Create note'**
  String get createNote;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteNoteConfirm(String title);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @gradeLevel.
  ///
  /// In en, this message translates to:
  /// **'Grade level'**
  String get gradeLevel;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @favoriteSubjects.
  ///
  /// In en, this message translates to:
  /// **'Favorite subjects'**
  String get favoriteSubjects;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @gradeMiddleSchool.
  ///
  /// In en, this message translates to:
  /// **'Middle School'**
  String get gradeMiddleSchool;

  /// No description provided for @gradeHighSchool9.
  ///
  /// In en, this message translates to:
  /// **'High School (9th)'**
  String get gradeHighSchool9;

  /// No description provided for @gradeHighSchool10.
  ///
  /// In en, this message translates to:
  /// **'High School (10th)'**
  String get gradeHighSchool10;

  /// No description provided for @gradeHighSchool11.
  ///
  /// In en, this message translates to:
  /// **'High School (11th)'**
  String get gradeHighSchool11;

  /// No description provided for @gradeHighSchool12.
  ///
  /// In en, this message translates to:
  /// **'High School (12th)'**
  String get gradeHighSchool12;

  /// No description provided for @gradeUndergrad.
  ///
  /// In en, this message translates to:
  /// **'Undergrad'**
  String get gradeUndergrad;

  /// No description provided for @gradeGraduate.
  ///
  /// In en, this message translates to:
  /// **'Graduate'**
  String get gradeGraduate;

  /// No description provided for @subjectMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get subjectMath;

  /// No description provided for @subjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get subjectBiology;

  /// No description provided for @subjectHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get subjectHistory;

  /// No description provided for @subjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get subjectPhysics;

  /// No description provided for @subjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get subjectChemistry;

  /// No description provided for @subjectLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get subjectLiterature;

  /// No description provided for @subjectCS.
  ///
  /// In en, this message translates to:
  /// **'CS'**
  String get subjectCS;

  /// No description provided for @subjectEconomics.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get subjectEconomics;

  /// No description provided for @subjectPsychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get subjectPsychology;

  /// No description provided for @subjectArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get subjectArt;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @tapToStartDictating.
  ///
  /// In en, this message translates to:
  /// **'Tap to start dictating'**
  String get tapToStartDictating;

  /// No description provided for @speakClearly.
  ///
  /// In en, this message translates to:
  /// **'Speak clearly. Tap again to stop.'**
  String get speakClearly;

  /// No description provided for @realTimeStt.
  ///
  /// In en, this message translates to:
  /// **'Real-time speech-to-text'**
  String get realTimeStt;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'TRANSCRIPT'**
  String get transcript;

  /// No description provided for @wordsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your words will appear here as you speak.'**
  String get wordsAppearHere;

  /// No description provided for @nothingToSave.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save.'**
  String get nothingToSave;

  /// No description provided for @voiceNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice note {dateStr}'**
  String voiceNoteTitle(String dateStr);

  /// No description provided for @saveAsNote.
  ///
  /// In en, this message translates to:
  /// **'Save as Note'**
  String get saveAsNote;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @scanTextbook.
  ///
  /// In en, this message translates to:
  /// **'Scan a textbook page'**
  String get scanTextbook;

  /// No description provided for @takePhotoOrPick.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or pick from gallery. AI extracts the text.'**
  String get takePhotoOrPick;

  /// No description provided for @readingPage.
  ///
  /// In en, this message translates to:
  /// **'Reading page…'**
  String get readingPage;

  /// No description provided for @extractedTextHint.
  ///
  /// In en, this message translates to:
  /// **'Extracted text will appear here...'**
  String get extractedTextHint;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @textExtracted.
  ///
  /// In en, this message translates to:
  /// **'Text extracted successfully!'**
  String get textExtracted;

  /// No description provided for @ocrFailed.
  ///
  /// In en, this message translates to:
  /// **'OCR Failed: {error}'**
  String ocrFailed(String error);

  /// No description provided for @dictationError.
  ///
  /// In en, this message translates to:
  /// **'Dictation error: {error}'**
  String dictationError(String error);

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available.'**
  String get speechNotAvailable;

  /// No description provided for @scannedPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanned page'**
  String get scannedPageTitle;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @noteCopied.
  ///
  /// In en, this message translates to:
  /// **'Note copied to clipboard'**
  String get noteCopied;

  /// No description provided for @studyThisNote.
  ///
  /// In en, this message translates to:
  /// **'Study this Note'**
  String get studyThisNote;

  /// No description provided for @generateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateQuiz;

  /// No description provided for @practiceMcq.
  ///
  /// In en, this message translates to:
  /// **'Practice multiple-choice questions'**
  String get practiceMcq;

  /// No description provided for @generateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards'**
  String get generateFlashcards;

  /// No description provided for @reviewTerms.
  ///
  /// In en, this message translates to:
  /// **'Review terms and key concepts'**
  String get reviewTerms;

  /// No description provided for @studyThisNoteOption.
  ///
  /// In en, this message translates to:
  /// **'Study this note'**
  String get studyThisNoteOption;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// No description provided for @deleteNoteOption.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNoteOption;

  /// No description provided for @deleteConfirmShort.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure?'**
  String get deleteConfirmShort;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameHint;

  /// No description provided for @tagOption.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tagOption;

  /// No description provided for @startWritingOrDictating.
  ///
  /// In en, this message translates to:
  /// **'Start writing or dictating...'**
  String get startWritingOrDictating;

  /// No description provided for @wordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordsCount(int count);

  /// No description provided for @charsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String charsCount(int count);

  /// No description provided for @noteTooShort.
  ///
  /// In en, this message translates to:
  /// **'Note too short to study (min 20 characters).'**
  String get noteTooShort;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @tagGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get tagGeneral;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @generateNewQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generate new quiz'**
  String get generateNewQuiz;

  /// No description provided for @pickNoteCustomize.
  ///
  /// In en, this message translates to:
  /// **'Pick a note + customize'**
  String get pickNoteCustomize;

  /// No description provided for @historyHeader.
  ///
  /// In en, this message translates to:
  /// **'HISTORY · {count}'**
  String historyHeader(int count);

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(int count);

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(int count);

  /// No description provided for @historyItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'History item removed'**
  String get historyItemRemoved;

  /// No description provided for @noQuizzesYet.
  ///
  /// In en, this message translates to:
  /// **'No quizzes yet'**
  String get noQuizzesYet;

  /// No description provided for @noFlashcardsYet.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get noFlashcardsYet;

  /// No description provided for @generateFirstStudySet.
  ///
  /// In en, this message translates to:
  /// **'Generate your first study set from any saved note.'**
  String get generateFirstStudySet;

  /// No description provided for @sourceNote.
  ///
  /// In en, this message translates to:
  /// **'SOURCE NOTE'**
  String get sourceNote;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'NUMBER OF QUESTIONS'**
  String get numberOfQuestions;

  /// No description provided for @numberOfCards.
  ///
  /// In en, this message translates to:
  /// **'NUMBER OF CARDS'**
  String get numberOfCards;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY'**
  String get difficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @noteTooShortMin.
  ///
  /// In en, this message translates to:
  /// **'Note too short (min 20 chars)'**
  String get noteTooShortMin;

  /// No description provided for @pleaseCreateNoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create a note first.'**
  String get pleaseCreateNoteFirst;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score {score}/{total}'**
  String scoreLabel(int score, int total);

  /// No description provided for @flashcardsUpper.
  ///
  /// In en, this message translates to:
  /// **'FLASHCARDS'**
  String get flashcardsUpper;

  /// No description provided for @extractingConcepts.
  ///
  /// In en, this message translates to:
  /// **'Extracting key concepts…'**
  String get extractingConcepts;

  /// No description provided for @extractionFailed.
  ///
  /// In en, this message translates to:
  /// **'Extraction Failed'**
  String get extractionFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noFlashcardsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No flashcards loaded.'**
  String get noFlashcardsLoaded;

  /// No description provided for @cardNumberProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String cardNumberProgress(int current, int total);

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @showTerm.
  ///
  /// In en, this message translates to:
  /// **'Show term'**
  String get showTerm;

  /// No description provided for @showDefinition.
  ///
  /// In en, this message translates to:
  /// **'Show definition'**
  String get showDefinition;

  /// No description provided for @definitionUpper.
  ///
  /// In en, this message translates to:
  /// **'DEFINITION'**
  String get definitionUpper;

  /// No description provided for @termUpper.
  ///
  /// In en, this message translates to:
  /// **'TERM'**
  String get termUpper;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get tapToFlip;

  /// No description provided for @quizUpper.
  ///
  /// In en, this message translates to:
  /// **'QUIZ'**
  String get quizUpper;

  /// No description provided for @aiCraftingQuiz.
  ///
  /// In en, this message translates to:
  /// **'AI is crafting your quiz…'**
  String get aiCraftingQuiz;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get generationFailed;

  /// No description provided for @noQuestionsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No questions loaded.'**
  String get noQuestionsLoaded;

  /// No description provided for @quizCompleteUpper.
  ///
  /// In en, this message translates to:
  /// **'QUIZ COMPLETE'**
  String get quizCompleteUpper;

  /// No description provided for @percentCorrect.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% correct'**
  String percentCorrect(int percentage);

  /// No description provided for @newQuiz.
  ///
  /// In en, this message translates to:
  /// **'New Quiz'**
  String get newQuiz;

  /// No description provided for @questionNumberProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionNumberProgress(int current, int total);

  /// No description provided for @correctCount.
  ///
  /// In en, this message translates to:
  /// **'{count} correct'**
  String correctCount(int count);

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get seeResults;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin Note'**
  String get pinNote;

  /// No description provided for @unpinNote.
  ///
  /// In en, this message translates to:
  /// **'Unpin Note'**
  String get unpinNote;

  /// No description provided for @changeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change Category'**
  String get changeCategory;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortAlphabeticalAsc.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAlphabeticalAsc;

  /// No description provided for @sortAlphabeticalDesc.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortAlphabeticalDesc;

  /// No description provided for @layoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get layoutGrid;

  /// No description provided for @layoutList.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get layoutList;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
