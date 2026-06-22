import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../services/local_storage_service.dart';
import '../services/ai_service.dart';
import '../../../features/notes/domain/note_model.dart';
import '../../../features/profile/domain/profile_model.dart';
import '../../../features/study/domain/study_model.dart';
import '../../../features/chat/domain/chat_model.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// --- Services ---
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden in main()');
});

final aiServiceProvider = Provider<AIService>((ref) {
  final settings = ref.watch(settingsProvider);
  return AIService(
    customApiKey: settings.customApiKey,
    useCustomApiKey: settings.useCustomApiKey,
  );
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
  final String language;
  final String customApiKey;
  final bool useCustomApiKey;

  AppSettings({
    required this.themeMode,
    required this.compactView,
    required this.notifQuiz,
    required this.notifStreak,
    required this.autoSave,
    required this.language,
    required this.customApiKey,
    required this.useCustomApiKey,
  });

  AppSettings copyWith({
    String? themeMode,
    bool? compactView,
    bool? notifQuiz,
    bool? notifStreak,
    bool? autoSave,
    String? language,
    String? customApiKey,
    bool? useCustomApiKey,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    compactView: compactView ?? this.compactView,
    notifQuiz: notifQuiz ?? this.notifQuiz,
    notifStreak: notifStreak ?? this.notifStreak,
    autoSave: autoSave ?? this.autoSave,
    language: language ?? this.language,
    customApiKey: customApiKey ?? this.customApiKey,
    useCustomApiKey: useCustomApiKey ?? this.useCustomApiKey,
  );
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageService _storage;
  
  SettingsNotifier(this._storage) : super(AppSettings(
    themeMode: 'system',
    compactView: false,
    notifQuiz: true,
    notifStreak: true,
    autoSave: true,
    language: 'en',
    customApiKey: '',
    useCustomApiKey: false,
  )) {
    state = AppSettings(
      themeMode: _storage.getThemeMode(),
      compactView: _storage.getCompactView(),
      notifQuiz: _storage.getNotifQuiz(),
      notifStreak: _storage.getNotifStreak(),
      autoSave: _storage.getAutoSave(),
      language: _storage.getLanguage(),
      customApiKey: _storage.getCustomApiKey(),
      useCustomApiKey: _storage.getUseCustomApiKey(),
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

  Future<void> setLanguage(String value) async {
    await _storage.setLanguage(value);
    state = state.copyWith(language: value);
  }

  Future<void> setCustomApiKey(String value) async {
    await _storage.setCustomApiKey(value);
    state = state.copyWith(customApiKey: value);
  }

  Future<void> setUseCustomApiKey(bool value) async {
    await _storage.setUseCustomApiKey(value);
    state = state.copyWith(useCustomApiKey: value);
  }
}

// --- Active Chat Session Sync ---
final activeChatSessionIdProvider = StateProvider<String?>((ref) => null);

// --- Bottom Navigation Hide/Show State ---
final hideNavbarProvider = StateProvider<bool>((ref) => false);

// --- Background Study Set Generation ---
class PendingGeneration {
  final String id;
  final String noteId;
  final String noteTitle;
  final String kind; // 'quiz' or 'flash'
  final int count;
  final String? difficulty; // only for quiz
  final int createdAt;

  PendingGeneration({
    required this.id,
    required this.noteId,
    required this.noteTitle,
    required this.kind,
    required this.count,
    this.difficulty,
    required this.createdAt,
  });
}

final pendingGenerationsProvider = StateNotifierProvider<PendingGenerationsNotifier, List<PendingGeneration>>((ref) {
  return PendingGenerationsNotifier(ref);
});

class PendingGenerationsNotifier extends StateNotifier<List<PendingGeneration>> {
  final Ref _ref;
  PendingGenerationsNotifier(this._ref) : super([]);

  Future<void> startGeneration({
    required String noteId,
    required String noteTitle,
    required String noteBody,
    required String kind,
    required int count,
    String? difficulty,
    required AppLocalizations l10n,
  }) async {
    final genId = const Uuid().v4();
    final item = PendingGeneration(
      id: genId,
      noteId: noteId,
      noteTitle: noteTitle.isEmpty ? l10n.untitled : noteTitle,
      kind: kind,
      count: count,
      difficulty: difficulty,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [...state, item];

    try {
      final ai = _ref.read(aiServiceProvider);
      
      if (kind == 'quiz') {
        final result = await ai.generateQuiz(
          noteBody,
          count: count,
          difficulty: difficulty ?? 'medium',
        );

        if (result.isEmpty) {
          throw Exception("AI did not return any questions.");
        }

        final historyItem = StudyHistoryItem(
          id: genId,
          kind: 'quiz',
          noteId: noteId,
          noteTitle: noteTitle.isEmpty ? l10n.untitled : noteTitle,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          questions: result,
        );

        await _ref.read(studyHistoryProvider.notifier).addHistoryItem(historyItem);
        _showSnackBar(l10n.quizGeneratedSuccess);
      } else {
        final result = await ai.generateFlashcards(
          noteBody,
          count: count,
        );

        if (result.isEmpty) {
          throw Exception("AI did not return any cards.");
        }

        final historyItem = StudyHistoryItem(
          id: genId,
          kind: 'flash',
          noteId: noteId,
          noteTitle: noteTitle.isEmpty ? l10n.untitled : noteTitle,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          cards: result,
        );

        await _ref.read(studyHistoryProvider.notifier).addHistoryItem(historyItem);
        _showSnackBar(l10n.flashcardGeneratedSuccess);
      }
    } catch (e) {
      final errorStr = e.toString().replaceFirst('Exception: ', '');
      if (kind == 'quiz') {
        _showSnackBar(l10n.quizGenerationFailed(errorStr));
      } else {
        _showSnackBar(l10n.flashcardGenerationFailed(errorStr));
      }
    } finally {
      state = state.where((x) => x.id != genId).toList();
    }
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
