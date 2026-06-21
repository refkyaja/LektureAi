import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../notes/domain/note_model.dart';
import '../../profile/domain/profile_model.dart';
import '../../study/domain/study_model.dart';
import '../../chat/domain/chat_model.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  late final Box _notesBox;
  late final Box _historyBox;
  late final Box _chatBox;
  late final Box _miscBox;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    
    // Open Hive boxes
    final notesBox = await Hive.openBox('lekture_notes_box');
    final historyBox = await Hive.openBox('lekture_history_box');
    final chatBox = await Hive.openBox('lekture_chat_box');
    final miscBox = await Hive.openBox('lekture_misc_box');
    
    final prefs = await SharedPreferences.getInstance();
    
    final service = LocalStorageService(prefs);
    service._notesBox = notesBox;
    service._historyBox = historyBox;
    service._chatBox = chatBox;
    service._miscBox = miscBox;
    
    return service;
  }

  // --- Notes CRUD ---
  List<Note> getNotes() {
    final List<Note> list = [];
    for (var key in _notesBox.keys) {
      final val = _notesBox.get(key);
      if (val is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(val);
        list.add(Note.fromJson(map));
      }
    }
    // Sort by updatedAt descending
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note.toJson());
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> clearAllNotes() async {
    await _notesBox.clear();
  }

  // --- Study History CRUD ---
  List<StudyHistoryItem> getStudyHistory() {
    final List<StudyHistoryItem> list = [];
    for (var key in _historyBox.keys) {
      final val = _historyBox.get(key);
      if (val is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(val);
        list.add(StudyHistoryItem.fromJson(map));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveStudyHistoryItem(StudyHistoryItem item) async {
    await _historyBox.put(item.id, item.toJson());
  }

  Future<void> deleteStudyHistoryItem(String id) async {
    await _historyBox.delete(id);
  }

  // --- Chat Sessions CRUD ---
  List<ChatSession> getChatSessions() {
    final List<ChatSession> list = [];
    for (var key in _chatBox.keys) {
      final val = _chatBox.get(key);
      if (val is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(val);
        list.add(ChatSession.fromJson(map));
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> saveChatSession(ChatSession session) async {
    await _chatBox.put(session.id, session.toJson());
  }

  Future<void> deleteChatSession(String id) async {
    await _chatBox.delete(id);
  }

  Future<void> clearAllChatSessions() async {
    await _chatBox.clear();
  }

  // --- Custom Tags ---
  List<String> getCustomTags() {
    final tags = _miscBox.get('custom_tags');
    if (tags is List) {
      return List<String>.from(tags);
    }
    return [];
  }

  Future<void> saveCustomTags(List<String> tags) async {
    await _miscBox.put('custom_tags', tags);
  }

  // --- Profile CRUD ---
  ProfileData getProfile() {
    final val = _miscBox.get('profile');
    if (val is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(val);
      return ProfileData.fromJson(map);
    }
    return ProfileData.defaultProfile();
  }

  Future<void> saveProfile(ProfileData profile) async {
    await _miscBox.put('profile', profile.toJson());
  }

  // --- Settings (SharedPreferences) ---
  String getThemeMode() {
    return _prefs.getString('settings_theme') ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('settings_theme', mode);
  }

  String getLanguage() {
    return _prefs.getString('settings_language') ?? 'en';
  }

  Future<void> setLanguage(String value) async {
    await _prefs.setString('settings_language', value);
  }

  String getCustomApiKey() {
    return _prefs.getString('settings_custom_api_key') ?? '';
  }

  Future<void> setCustomApiKey(String value) async {
    await _prefs.setString('settings_custom_api_key', value);
  }

  bool getUseCustomApiKey() {
    return _prefs.getBool('settings_use_custom_api_key') ?? false;
  }

  Future<void> setUseCustomApiKey(bool value) async {
    await _prefs.setBool('settings_use_custom_api_key', value);
  }

  bool getCompactView() {
    return _prefs.getBool('settings_compact_view') ?? false;
  }

  Future<void> setCompactView(bool value) async {
    await _prefs.setBool('settings_compact_view', value);
  }

  bool getNotifQuiz() {
    return _prefs.getBool('settings_notif_quiz') ?? true;
  }

  Future<void> setNotifQuiz(bool value) async {
    await _prefs.setBool('settings_notif_quiz', value);
  }

  bool getNotifStreak() {
    return _prefs.getBool('settings_notif_streak') ?? true;
  }

  Future<void> setNotifStreak(bool value) async {
    await _prefs.setBool('settings_notif_streak', value);
  }

  bool getAutoSave() {
    return _prefs.getBool('settings_auto_save') ?? true;
  }

  Future<void> setAutoSave(bool value) async {
    await _prefs.setBool('settings_auto_save', value);
  }

  bool getShowedOnboarding() {
    return _prefs.getBool('settings_showed_onboarding') ?? false;
  }

  Future<void> setShowedOnboarding(bool value) async {
    await _prefs.setBool('settings_showed_onboarding', value);
  }

  bool getIsLoggedIn() {
    return _prefs.getBool('settings_is_logged_in') ?? false;
  }

  Future<void> setIsLoggedIn(bool value) async {
    await _prefs.setBool('settings_is_logged_in', value);
  }

  int getStreakDays() {
    return _prefs.getInt('profile_streak') ?? 3;
  }

  Future<void> setStreakDays(int days) async {
    await _prefs.setInt('profile_streak', days);
  }

  String getJoinedDate() {
    return _prefs.getString('profile_joined') ?? 'Jun 2026';
  }

  Future<void> setJoinedDate(String value) async {
    await _prefs.setString('profile_joined', value);
  }

  Future<void> clearDatabase() async {
    await _notesBox.clear();
    await _historyBox.clear();
    await _chatBox.clear();
    await _miscBox.delete('profile');
    await _miscBox.delete('custom_tags');
  }
}
