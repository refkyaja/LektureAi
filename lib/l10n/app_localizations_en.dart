// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lekture';

  @override
  String get readyToStudy => 'Ready to study smarter?';

  @override
  String get heroDescription =>
      'Capture a lecture, scan your textbook, or quiz yourself in seconds.';

  @override
  String get startDictating => 'Start Dictating';

  @override
  String get askAi => 'Ask AI';

  @override
  String get notes => 'Notes';

  @override
  String get words => 'Words';

  @override
  String get tags => 'Tags';

  @override
  String get recentNotes => 'Recent Notes';

  @override
  String get seeAll => 'See all';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get startByDictating =>
      'Start by dictating or typing your first note.';

  @override
  String get captureNow => 'Capture now';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quizMe => 'Quiz me';

  @override
  String get fromAnyNote => 'From any note';

  @override
  String get scanPage => 'Scan page';

  @override
  String get ocrFromPhoto => 'OCR from photo';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeDesc => 'Select application theme';

  @override
  String get compactView => 'Compact view';

  @override
  String get compactDesc => 'Smaller cards, tighter spacing';

  @override
  String get notifications => 'Notifications';

  @override
  String get quizReminders => 'Quiz reminders';

  @override
  String get quizDesc => 'Daily prompt to review flashcards';

  @override
  String get studyStreaks => 'Study streaks';

  @override
  String get streaksDesc => 'Keep your daily streak alive';

  @override
  String get autoSave => 'Auto-save notes';

  @override
  String get autoSaveDesc => 'Save while you type';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get switchAccount => 'Switch Account';

  @override
  String get switchAccountDesc => 'Change to another user profile';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutDesc => 'Sign out of the current account';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Select application language';

  @override
  String get apiKeySettings => 'API Key Settings';

  @override
  String get customApiKey => 'Custom Gemini API Key';

  @override
  String get customApiKeyDesc => 'Use your own API key from Google AI Studio';

  @override
  String get enterApiKey => 'Enter API Key';

  @override
  String get activate => 'Activate Custom API Key';

  @override
  String get data => 'Data';

  @override
  String get clearNotes => 'Clear all notes';

  @override
  String get clearNotesDesc => 'This action cannot be undone';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get switchSuccess => 'Switched to account';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get apiKeySaved => 'API Key saved successfully';

  @override
  String get apiKeyActivated => 'Custom API Key activated';

  @override
  String get apiKeyDisabled => 'Custom API Key disabled';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get save => 'Save';

  @override
  String get whatCanHelp => 'What can I help with today?';

  @override
  String get askLekture => 'Ask Lekture...';

  @override
  String get newChat => 'New Chat';

  @override
  String get searchChat => 'Search Chat...';

  @override
  String get history => 'History';

  @override
  String get noChatsFound => 'No chats found';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get noConversationsYet => 'No conversations yet.';

  @override
  String get tagNotes => 'Tag notes for context';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get online => 'ONLINE';

  @override
  String get confirmLogoutDesc =>
      'This will reset your profile. Your notes will remain saved locally.';

  @override
  String get untitled => 'Untitled';

  @override
  String get emptyNote => 'Empty note';

  @override
  String get today => 'Today';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get createNoteFirst => 'Create a note first to tag it.';

  @override
  String get useNotesReference => 'Use these notes as reference:';

  @override
  String get questionLabel => 'Question';

  @override
  String get errorOccurred => 'Sorry, I hit an error';

  @override
  String get untitledChat => 'Untitled Chat';

  @override
  String get chatDeleted => 'Chat deleted';

  @override
  String get supportEmailCopied => 'Support email copied: support@lekture.ai';

  @override
  String get clearNotesDialogDesc =>
      'This will delete all your notes, custom tags, study history, and chat logs. This cannot be undone.';

  @override
  String get allDataCleared => 'All data cleared successfully.';

  @override
  String get home => 'Home';

  @override
  String get capture => 'Capture';

  @override
  String get study => 'Study';

  @override
  String get searchNotesHint => 'Search notes, tags...';

  @override
  String get newButton => '+ New';

  @override
  String get allChips => 'All';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noMatches => 'No matches';

  @override
  String get tryDifferentSearch =>
      'Try a different search query or select another filter tag.';

  @override
  String get createNote => 'Create note';

  @override
  String get deleteNoteTitle => 'Delete note?';

  @override
  String deleteNoteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get profile => 'Profile';

  @override
  String get edit => 'Edit';

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String get displayName => 'Display name';

  @override
  String get school => 'School';

  @override
  String get gradeLevel => 'Grade level';

  @override
  String get bio => 'Bio';

  @override
  String get favoriteSubjects => 'Favorite subjects';

  @override
  String get subjects => 'Subjects';

  @override
  String get streak => 'Streak';

  @override
  String get joined => 'Joined';

  @override
  String get gradeMiddleSchool => 'Middle School';

  @override
  String get gradeHighSchool9 => 'High School (9th)';

  @override
  String get gradeHighSchool10 => 'High School (10th)';

  @override
  String get gradeHighSchool11 => 'High School (11th)';

  @override
  String get gradeHighSchool12 => 'High School (12th)';

  @override
  String get gradeUndergrad => 'Undergrad';

  @override
  String get gradeGraduate => 'Graduate';

  @override
  String get subjectMath => 'Math';

  @override
  String get subjectBiology => 'Biology';

  @override
  String get subjectHistory => 'History';

  @override
  String get subjectPhysics => 'Physics';

  @override
  String get subjectChemistry => 'Chemistry';

  @override
  String get subjectLiterature => 'Literature';

  @override
  String get subjectCS => 'CS';

  @override
  String get subjectEconomics => 'Economics';

  @override
  String get subjectPsychology => 'Psychology';

  @override
  String get subjectArt => 'Art';

  @override
  String get voice => 'Voice';

  @override
  String get scan => 'Scan';

  @override
  String get listening => 'Listening…';

  @override
  String get tapToStartDictating => 'Tap to start dictating';

  @override
  String get speakClearly => 'Speak clearly. Tap again to stop.';

  @override
  String get realTimeStt => 'Real-time speech-to-text';

  @override
  String get transcript => 'TRANSCRIPT';

  @override
  String get wordsAppearHere => 'Your words will appear here as you speak.';

  @override
  String get nothingToSave => 'Nothing to save.';

  @override
  String voiceNoteTitle(String dateStr) {
    return 'Voice note $dateStr';
  }

  @override
  String get saveAsNote => 'Save as Note';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get scanTextbook => 'Scan a textbook page';

  @override
  String get takePhotoOrPick =>
      'Take a photo or pick from gallery. AI extracts the text.';

  @override
  String get readingPage => 'Reading page…';

  @override
  String get extractedTextHint => 'Extracted text will appear here...';

  @override
  String get retake => 'Retake';

  @override
  String get textExtracted => 'Text extracted successfully!';

  @override
  String ocrFailed(String error) {
    return 'OCR Failed: $error';
  }

  @override
  String dictationError(String error) {
    return 'Dictation error: $error';
  }

  @override
  String get speechNotAvailable => 'Speech recognition is not available.';

  @override
  String get scannedPageTitle => 'Scanned page';

  @override
  String get newNote => 'New note';

  @override
  String get noteCopied => 'Note copied to clipboard';

  @override
  String get studyThisNote => 'Study this Note';

  @override
  String get generateQuiz => 'Generate Quiz';

  @override
  String get practiceMcq => 'Practice multiple-choice questions';

  @override
  String get generateFlashcards => 'Generate Flashcards';

  @override
  String get reviewTerms => 'Review terms and key concepts';

  @override
  String get studyThisNoteOption => 'Study this note';

  @override
  String get copyText => 'Copy text';

  @override
  String get deleteNoteOption => 'Delete note';

  @override
  String get deleteConfirmShort =>
      'This action cannot be undone. Are you sure?';

  @override
  String get tagNameHint => 'Tag name';

  @override
  String get tagOption => 'Tag';

  @override
  String get startWritingOrDictating => 'Start writing or dictating...';

  @override
  String wordsCount(int count) {
    return '$count words';
  }

  @override
  String charsCount(int count) {
    return '$count chars';
  }

  @override
  String get noteTooShort => 'Note too short to study (min 20 characters).';

  @override
  String get quiz => 'Quiz';

  @override
  String get tagGeneral => 'General';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get generateNewQuiz => 'Generate new quiz';

  @override
  String get pickNoteCustomize => 'Pick a note + customize';

  @override
  String historyHeader(int count) {
    return 'HISTORY · $count';
  }

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String get historyItemRemoved => 'History item removed';

  @override
  String get noQuizzesYet => 'No quizzes yet';

  @override
  String get noFlashcardsYet => 'No flashcards yet';

  @override
  String get generateFirstStudySet =>
      'Generate your first study set from any saved note.';

  @override
  String get sourceNote => 'SOURCE NOTE';

  @override
  String get numberOfQuestions => 'NUMBER OF QUESTIONS';

  @override
  String get numberOfCards => 'NUMBER OF CARDS';

  @override
  String get difficulty => 'DIFFICULTY';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get generate => 'Generate';

  @override
  String get noteTooShortMin => 'Note too short (min 20 chars)';

  @override
  String get pleaseCreateNoteFirst => 'Please create a note first.';

  @override
  String scoreLabel(int score, int total) {
    return 'Score $score/$total';
  }

  @override
  String get flashcardsUpper => 'FLASHCARDS';

  @override
  String get extractingConcepts => 'Extracting key concepts…';

  @override
  String get extractionFailed => 'Extraction Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noFlashcardsLoaded => 'No flashcards loaded.';

  @override
  String cardNumberProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get regenerate => 'Regenerate';

  @override
  String get showTerm => 'Show term';

  @override
  String get showDefinition => 'Show definition';

  @override
  String get definitionUpper => 'DEFINITION';

  @override
  String get termUpper => 'TERM';

  @override
  String get tapToFlip => 'Tap to flip';

  @override
  String get quizUpper => 'QUIZ';

  @override
  String get aiCraftingQuiz => 'AI is crafting your quiz…';

  @override
  String get generationFailed => 'Generation Failed';

  @override
  String get noQuestionsLoaded => 'No questions loaded.';

  @override
  String get quizCompleteUpper => 'QUIZ COMPLETE';

  @override
  String percentCorrect(int percentage) {
    return '$percentage% correct';
  }

  @override
  String get newQuiz => 'New Quiz';

  @override
  String questionNumberProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String correctCount(int count) {
    return '$count correct';
  }

  @override
  String get seeResults => 'See results';

  @override
  String get next => 'Next';

  @override
  String streakDays(int count) {
    return '$count days';
  }
}
