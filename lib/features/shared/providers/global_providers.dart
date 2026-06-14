import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/ai_service.dart';
import '../../../features/notes/domain/note_model.dart';
import '../../../features/profile/domain/profile_model.dart';
import '../../../features/study/domain/study_model.dart';
import '../../../features/chat/domain/chat_model.dart';

// --- Services ---
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden in main()');
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// --- Notes State ---
final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return NotesNotifier(storage);
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final LocalStorageService _storage;
  
  NotesNotifier(this._storage) : super([]) {
    loadNotes();
  }
  
  void loadNotes() {
    state = _storage.getNotes();
  }
  
  Future<void> addNote(Note note) async {
    await _storage.saveNote(note);
    loadNotes();
  }
  
  Future<void> updateNote(Note note) async {
    await _storage.saveNote(note);
    loadNotes();
  }
  
  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    loadNotes();
  }
  
  Future<void> clearAll() async {
    await _storage.clearAllNotes();
    state = [];
  }
}

// --- Custom Tags State ---
final customTagsProvider = StateNotifierProvider<CustomTagsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return CustomTagsNotifier(storage);
});

class CustomTagsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;
  
  CustomTagsNotifier(this._storage) : super([]) {
    state = _storage.getCustomTags();
  }
  
  Future<void> addTag(String tag) async {
    final t = tag.trim();
    if (t.isEmpty) return;
    if (!state.contains(t)) {
      final next = [...state, t];
      await _storage.saveCustomTags(next);
      state = next;
    }
  }
  
  Future<void> removeTag(String tag) async {
    final next = state.where((x) => x != tag).toList();
    await _storage.saveCustomTags(next);
    state = next;
  }
}

// --- Profile State ---
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileData>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ProfileNotifier(storage);
});

class ProfileNotifier extends StateNotifier<ProfileData> {
  final LocalStorageService _storage;
  
  ProfileNotifier(this._storage) : super(ProfileData.defaultProfile()) {
    state = _storage.getProfile();
  }
  
  Future<void> updateProfile(ProfileData profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }
}

// --- Study History State ---
final studyHistoryProvider = StateNotifierProvider<StudyHistoryNotifier, List<StudyHistoryItem>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return StudyHistoryNotifier(storage);
});

class StudyHistoryNotifier extends StateNotifier<List<StudyHistoryItem>> {
  final LocalStorageService _storage;
  
  StudyHistoryNotifier(this._storage) : super([]) {
    loadHistory();
  }
  
  void loadHistory() {
    state = _storage.getStudyHistory();
  }
  
  Future<void> addHistoryItem(StudyHistoryItem item) async {
    await _storage.saveStudyHistoryItem(item);
    loadHistory();
  }
  
  Future<void> deleteHistoryItem(String id) async {
    await _storage.deleteStudyHistoryItem(id);
    loadHistory();
  }
}

// --- Chat Sessions State ---
final chatSessionsProvider = StateNotifierProvider<ChatSessionsNotifier, List<ChatSession>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ChatSessionsNotifier(storage);
});

class ChatSessionsNotifier extends StateNotifier<List<ChatSession>> {
  final LocalStorageService _storage;
  
  ChatSessionsNotifier(this._storage) : super([]) {
    loadSessions();
  }
  
  void loadSessions() {
    state = _storage.getChatSessions();
  }
  
  Future<void> saveSession(ChatSession session) async {
    await _storage.saveChatSession(session);
    loadSessions();
  }
  
  Future<void> deleteSession(String id) async {
    await _storage.deleteChatSession(id);
    loadSessions();
  }
  
  Future<void> clearAll() async {
    await _storage.clearAllChatSessions();
    state = [];
  }
}

// --- App Settings State ---
class AppSettings {
  final String themeMode;
  final bool compactView;
  final bool notifQuiz;
  final bool notifStreak;
  final bool autoSave;

  AppSettings({
    required this.themeMode,
    required this.compactView,
    required this.notifQuiz,
    required this.notifStreak,
    required this.autoSave,
  });

  AppSettings copyWith({
    String? themeMode,
    bool? compactView,
    bool? notifQuiz,
    bool? notifStreak,
    bool? autoSave,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    compactView: compactView ?? this.compactView,
    notifQuiz: notifQuiz ?? this.notifQuiz,
    notifStreak: notifStreak ?? this.notifStreak,
    autoSave: autoSave ?? this.autoSave,
  );
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageService _storage;
  
  SettingsNotifier(this._storage) : super(AppSettings(
    themeMode: 'dark',
    compactView: false,
    notifQuiz: true,
    notifStreak: true,
    autoSave: true,
  )) {
    state = AppSettings(
      themeMode: _storage.getThemeMode(),
      compactView: _storage.getCompactView(),
      notifQuiz: _storage.getNotifQuiz(),
      notifStreak: _storage.getNotifStreak(),
      autoSave: _storage.getAutoSave(),
    );
  }

  Future<void> setThemeMode(String value) async {
    await _storage.setThemeMode(value);
    state = state.copyWith(themeMode: value);
  }
  
  Future<void> setCompactView(bool value) async {
    await _storage.setCompactView(value);
    state = state.copyWith(compactView: value);
  }
  
  Future<void> setNotifQuiz(bool value) async {
    await _storage.setNotifQuiz(value);
    state = state.copyWith(notifQuiz: value);
  }
  
  Future<void> setNotifStreak(bool value) async {
    await _storage.setNotifStreak(value);
    state = state.copyWith(notifStreak: value);
  }
  
  Future<void> setAutoSave(bool value) async {
    await _storage.setAutoSave(value);
    state = state.copyWith(autoSave: value);
  }
}
