import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../profile/domain/profile_model.dart';

const Map<String, Map<String, String>> _localizedText = {
  'en': {
    'title': 'Settings',
    'profile': 'Profile',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'theme_desc': 'Select application theme',
    'compact_view': 'Compact view',
    'compact_desc': 'Smaller cards, tighter spacing',
    'notifications': 'Notifications',
    'quiz_reminders': 'Quiz reminders',
    'quiz_desc': 'Daily prompt to review flashcards',
    'study_streaks': 'Study streaks',
    'streaks_desc': 'Keep your daily streak alive',
    'auto_save': 'Auto-save notes',
    'auto_save_desc': 'Save while you type',
    'account_actions': 'Account Actions',
    'switch_account': 'Switch Account',
    'switch_account_desc': 'Change to another user profile',
    'logout': 'Sign Out',
    'logout_desc': 'Sign out of the current account',
    'language': 'Language',
    'language_desc': 'Select application language',
    'api_key_settings': 'API Key Settings',
    'custom_api_key': 'Custom Gemini API Key',
    'custom_api_key_desc': 'Use your own API key from Google AI Studio',
    'enter_api_key': 'Enter API Key',
    'activate': 'Activate Custom API Key',
    'data': 'Data',
    'clear_notes': 'Clear all notes',
    'clear_notes_desc': 'This action cannot be undone',
    'about': 'About',
    'version': 'Version',
    'contact_support': 'Contact support',
    'confirm_logout': 'Are you sure you want to sign out?',
    'confirm_logout_desc': 'This will reset your profile. Your notes will remain saved locally.',
    'switch_success': 'Switched to account',
    'logout_success': 'Logged out successfully',
    'api_key_saved': 'API Key saved successfully',
    'api_key_activated': 'Custom API Key activated',
    'api_key_disabled': 'Custom API Key disabled',
    'active': 'Active',
    'inactive': 'Inactive',
    'system': 'System',
    'dark': 'Dark',
    'light': 'Light',
  },
  'id': {
    'title': 'Pengaturan',
    'profile': 'Profil',
    'appearance': 'Tampilan',
    'theme': 'Tema',
    'theme_desc': 'Pilih tema aplikasi',
    'compact_view': 'Tampilan Kompak',
    'compact_desc': 'Kartu lebih kecil, jarak lebih rapat',
    'notifications': 'Notifikasi',
    'quiz_reminders': 'Pengingat Kuis',
    'quiz_desc': 'Pengingat harian untuk mengulas kartu flash',
    'study_streaks': 'Streak Belajar',
    'streaks_desc': 'Pertahankan streak belajar harian Anda',
    'auto_save': 'Simpan Otomatis',
    'auto_save_desc': 'Menyimpan catatan saat Anda mengetik',
    'account_actions': 'Aksi Akun',
    'switch_account': 'Beralih Akun',
    'switch_account_desc': 'Pindah ke profil pengguna lain',
    'logout': 'Keluar Akun',
    'logout_desc': 'Keluar dari akun saat ini',
    'language': 'Bahasa',
    'language_desc': 'Pilih bahasa aplikasi',
    'api_key_settings': 'Pengaturan API Key',
    'custom_api_key': 'Custom Gemini API Key',
    'custom_api_key_desc': 'Gunakan API key Anda sendiri dari Google AI Studio',
    'enter_api_key': 'Masukkan API Key',
    'activate': 'Aktifkan Custom API Key',
    'data': 'Data',
    'clear_notes': 'Hapus semua catatan',
    'clear_notes_desc': 'Tindakan ini tidak dapat dibatalkan',
    'about': 'Tentang',
    'version': 'Versi',
    'contact_support': 'Hubungi dukungan',
    'confirm_logout': 'Apakah Anda yakin ingin keluar?',
    'confirm_logout_desc': 'Ini akan mereset profil Anda. Catatan Anda akan tetap tersimpan secara lokal.',
    'switch_success': 'Beralih ke akun',
    'logout_success': 'Berhasil keluar akun',
    'api_key_saved': 'API Key berhasil disimpan',
    'api_key_activated': 'Custom API Key diaktifkan',
    'api_key_disabled': 'Custom API Key dinonaktifkan',
    'active': 'Aktif',
    'inactive': 'Nonaktif',
    'system': 'Sistem',
    'dark': 'Gelap',
    'light': 'Terang',
  }
};

final List<ProfileData> _mockAccounts = [
  ProfileData(
    name: 'Lekture User',
    email: 'student@example.com',
    bio: 'High school student learning biology and CS.',
    school: 'Lincoln High School',
    grade: 'High School (11th)',
    subjects: ['Biology', 'CS'],
  ),
  ProfileData(
    name: 'Rendi Wijaya',
    email: 'rendi@example.com',
    bio: 'Undergrad studying economics and data science.',
    school: 'Indonesia University',
    grade: 'Undergrad',
    subjects: ['Economics', 'Math'],
  ),
  ProfileData(
    name: 'Guest User',
    email: 'guest@example.com',
    bio: 'Just looking around.',
    school: '',
    grade: 'Graduate',
    subjects: [],
  ),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = settings.language;

    String text(String key) {
      return _localizedText[lang]?[key] ?? _localizedText['en']![key]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          text('title'),
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'L',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader(text('appearance')),
            _buildSettingsGroup(context, [
              // Theme Dropdown Row
              _buildDropdownRow<String>(
                context,
                title: text('theme'),
                desc: text('theme_desc'),
                value: settings.themeMode,
                items: [
                  DropdownMenuItem(value: 'system', child: Text(text('system'))),
                  DropdownMenuItem(value: 'dark', child: Text(text('dark'))),
                  DropdownMenuItem(value: 'light', child: Text(text('light'))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(settingsProvider.notifier).setThemeMode(val);
                  }
                },
              ),
              // Language Dropdown Row
              _buildDropdownRow<String>(
                context,
                title: text('language'),
                desc: text('language_desc'),
                value: settings.language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(settingsProvider.notifier).setLanguage(val);
                  }
                },
              ),
              // Compact View Switch
              _buildSwitchRow(
                context,
                title: text('compact_view'),
                desc: text('compact_desc'),
                value: settings.compactView,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setCompactView(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Notifications Section
            _buildSectionHeader(text('notifications')),
            _buildSettingsGroup(context, [
              _buildSwitchRow(
                context,
                title: text('quiz_reminders'),
                desc: text('quiz_desc'),
                value: settings.notifQuiz,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifQuiz(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: text('study_streaks'),
                desc: text('streaks_desc'),
                value: settings.notifStreak,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifStreak(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: text('auto_save'),
                desc: text('auto_save_desc'),
                value: settings.autoSave,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setAutoSave(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Account Actions Section
            _buildSectionHeader(text('account_actions')),
            _buildSettingsGroup(context, [
              _buildClickableRow(
                context,
                title: text('switch_account'),
                desc: text('switch_account_desc'),
                onTap: () => _showSwitchAccountDialog(context, ref, text),
              ),
              _buildClickableRow(
                context,
                title: text('logout'),
                desc: text('logout_desc'),
                isDestructive: true,
                onTap: () => _confirmLogout(context, ref, text),
              ),
            ]),
            const SizedBox(height: 20),

            // API Key Settings Section
            _buildSectionHeader(text('api_key_settings')),
            _buildSettingsGroup(context, [
              _ApiKeyInputRow(settings: settings, textHelper: text),
            ]),
            const SizedBox(height: 20),

            // Data Section
            _buildSectionHeader(text('data')),
            _buildSettingsGroup(context, [
              _buildClickableRow(
                context,
                title: text('clear_notes'),
                desc: text('clear_notes_desc'),
                isDestructive: true,
                onTap: () => _confirmClearData(context, ref, text),
              ),
            ]),
            const SizedBox(height: 20),

            // About Section
            _buildSectionHeader(text('about')),
            _buildSettingsGroup(context, [
              _buildStaticRow(
                context,
                title: text('version'),
                value: '1.0.0',
              ),
              _buildClickableRow(
                context,
                title: text('contact_support'),
                desc: 'support@lekture.ai',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support email copied: support@lekture.ai')),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(desc, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[200],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>(
    BuildContext context, {
    required String title,
    required String desc,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(desc, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: isDark ? AppColors.surface : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? AppColors.textMuted : Colors.black54),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.text : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(
    BuildContext context, {
    required String title,
    required String desc,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 13.5,
                      color: isDestructive ? AppColors.error : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDestructive ? AppColors.error : (isDark ? AppColors.textMuted : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  void _showSwitchAccountDialog(BuildContext context, WidgetRef ref, String Function(String) text) {
    final activeProfile = ref.read(profileProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text('switch_account'), style: const TextStyle(fontSize: 18)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _mockAccounts.length,
                itemBuilder: (context, index) {
                  final acc = _mockAccounts[index];
                  final isCurrent = activeProfile.email == acc.email;
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(acc.email),
                    trailing: isCurrent 
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) 
                        : null,
                    onTap: () {
                      ref.read(profileProvider.notifier).updateProfile(acc);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${text('switch_success')}: ${acc.name}')),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, String Function(String) text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text('logout'), style: const TextStyle(fontSize: 18)),
          content: Text(text('confirm_logout_desc'), style: const TextStyle(fontSize: 13.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(profileProvider.notifier).updateProfile(
                  ProfileData(
                    name: 'Guest User',
                    email: 'guest@example.com',
                    bio: '',
                    school: '',
                    grade: '',
                    subjects: [],
                  )
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(text('logout_success'))),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(text('logout')),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref, String Function(String) text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${text('clear_notes')}?', style: const TextStyle(fontSize: 18)),
          content: Text(
            'This will delete all your notes, custom tags, study history, and chat logs. This cannot be undone.',
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(localStorageServiceProvider).clearDatabase();
                ref.read(notesProvider.notifier).loadNotes();
                ref.read(studyHistoryProvider.notifier).loadHistory();
                ref.read(chatSessionsProvider.notifier).loadSessions();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared successfully.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _ApiKeyInputRow extends ConsumerStatefulWidget {
  final AppSettings settings;
  final String Function(String) textHelper;

  const _ApiKeyInputRow({
    required this.settings,
    required this.textHelper,
  });

  @override
  ConsumerState<_ApiKeyInputRow> createState() => _ApiKeyInputRowState();
}

class _ApiKeyInputRowState extends ConsumerState<_ApiKeyInputRow> {
  late TextEditingController _apiKeyController;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.settings.customApiKey);
  }

  @override
  void didUpdateWidget(covariant _ApiKeyInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.customApiKey != widget.settings.customApiKey) {
      _apiKeyController.text = widget.settings.customApiKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = widget.textHelper;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text('custom_api_key'), style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text(text('custom_api_key_desc'), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: widget.settings.useCustomApiKey,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[200],
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setUseCustomApiKey(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? text('api_key_activated') : text('api_key_disabled'))),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _apiKeyController,
                  obscureText: _obscured,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: text('enter_api_key'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: IconButton(
                      icon: Icon(_obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 16),
                      onPressed: () => setState(() => _obscured = !_obscured),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final key = _apiKeyController.text.trim();
                  ref.read(settingsProvider.notifier).setCustomApiKey(key);
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(text('api_key_saved'))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
