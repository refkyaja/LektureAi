import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../profile/domain/profile_model.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
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
            _buildSectionHeader(l10n.appearance),
            _buildSettingsGroup(context, [
              // Theme Dropdown Row
              _buildDropdownRow<String>(
                context,
                title: l10n.theme,
                desc: l10n.themeDesc,
                value: settings.themeMode,
                items: [
                  DropdownMenuItem(value: 'system', child: Text(l10n.system)),
                  DropdownMenuItem(value: 'dark', child: Text(l10n.dark)),
                  DropdownMenuItem(value: 'light', child: Text(l10n.light)),
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
                title: l10n.language,
                desc: l10n.languageDesc,
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
                title: l10n.compactView,
                desc: l10n.compactDesc,
                value: settings.compactView,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setCompactView(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Notifications Section
            _buildSectionHeader(l10n.notifications),
            _buildSettingsGroup(context, [
              _buildSwitchRow(
                context,
                title: l10n.quizReminders,
                desc: l10n.quizDesc,
                value: settings.notifQuiz,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifQuiz(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: l10n.studyStreaks,
                desc: l10n.streaksDesc,
                value: settings.notifStreak,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifStreak(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: l10n.autoSave,
                desc: l10n.autoSaveDesc,
                value: settings.autoSave,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setAutoSave(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Account Actions Section
            _buildSectionHeader(l10n.accountActions),
            _buildSettingsGroup(context, [
              _buildClickableRow(
                context,
                title: l10n.switchAccount,
                desc: l10n.switchAccountDesc,
                onTap: () => _showSwitchAccountDialog(context, ref, l10n),
              ),
              _buildClickableRow(
                context,
                title: l10n.logout,
                desc: l10n.logoutDesc,
                isDestructive: true,
                onTap: () => _confirmLogout(context, ref, l10n),
              ),
            ]),
            const SizedBox(height: 20),

            // API Key Settings Section
            _buildSectionHeader(l10n.apiKeySettings),
            _buildSettingsGroup(context, [
              _ApiKeyInputRow(settings: settings, l10n: l10n),
            ]),
            const SizedBox(height: 20),

            // Data Section
            _buildSectionHeader(l10n.data),
            _buildSettingsGroup(context, [
              _buildClickableRow(
                context,
                title: l10n.clearNotes,
                desc: l10n.clearNotesDesc,
                isDestructive: true,
                onTap: () => _confirmClearData(context, ref, l10n),
              ),
            ]),
            const SizedBox(height: 20),

            // About Section
            _buildSectionHeader(l10n.about),
            _buildSettingsGroup(context, [
              _buildStaticRow(
                context,
                title: l10n.version,
                value: '1.0.0',
              ),
              _buildClickableRow(
                context,
                title: l10n.contactSupport,
                desc: 'support@lekture.ai',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.supportEmailCopied)),
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

  void _showSwitchAccountDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final activeProfile = ref.read(profileProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.switchAccount, style: const TextStyle(fontSize: 18)),
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
                        SnackBar(content: Text('${l10n.switchSuccess}: ${acc.name}')),
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
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout, style: const TextStyle(fontSize: 18)),
          content: Text(l10n.confirmLogoutDesc, style: const TextStyle(fontSize: 13.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Sign out from Firebase
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  debugPrint("Firebase signOut error: $e");
                }

                // 2. Clear logged in state in local storage
                final storage = ref.read(localStorageServiceProvider);
                await storage.setIsLoggedIn(false);

                // 3. Reset profile details locally
                ref.read(profileProvider.notifier).updateProfile(
                  ProfileData(
                    name: 'Guest User',
                    email: 'guest@example.com',
                    bio: '',
                    school: '',
                    grade: '',
                    subjects: [],
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.logoutSuccess)),
                  );
                  // 4. Redirect to onboarding
                  context.go('/onboarding');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${l10n.clearNotes}?', style: const TextStyle(fontSize: 18)),
          content: Text(
            l10n.clearNotesDialogDesc,
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
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
                    SnackBar(content: Text(l10n.allDataCleared)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}

class _ApiKeyInputRow extends ConsumerStatefulWidget {
  final AppSettings settings;
  final AppLocalizations l10n;

  const _ApiKeyInputRow({
    required this.settings,
    required this.l10n,
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
    final l10n = widget.l10n;

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
                    Text(l10n.customApiKey, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text(l10n.customApiKeyDesc, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: widget.settings.useCustomApiKey,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[200],
                onChanged: (val) {
                  final key = _apiKeyController.text.trim();
                  ref.read(settingsProvider.notifier).setCustomApiKey(key);
                  ref.read(settingsProvider.notifier).setUseCustomApiKey(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? l10n.apiKeyActivated : l10n.apiKeyDisabled)),
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
                    hintText: l10n.enterApiKey,
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
                    SnackBar(content: Text(l10n.apiKeySaved)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(l10n.save, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
