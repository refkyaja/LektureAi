import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
            // Profile link Card
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
            _buildSectionHeader('Appearance'),
            _buildSettingsGroup(context, [
              _buildSwitchRow(
                context,
                title: 'Theme',
                desc: settings.themeMode == 'dark' ? 'Dark mode' : 'Light mode',
                value: settings.themeMode == 'dark',
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setThemeMode(val ? 'dark' : 'light');
                },
              ),
              _buildSwitchRow(
                context,
                title: 'Compact view',
                desc: 'Smaller cards, tighter spacing',
                value: settings.compactView,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setCompactView(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsGroup(context, [
              _buildSwitchRow(
                context,
                title: 'Quiz reminders',
                desc: 'Daily prompt to review flashcards',
                value: settings.notifQuiz,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifQuiz(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: 'Study streaks',
                desc: 'Keep your daily streak alive',
                value: settings.notifStreak,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setNotifStreak(val);
                },
              ),
              _buildSwitchRow(
                context,
                title: 'Auto-save notes',
                desc: 'Save while you type',
                value: settings.autoSave,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setAutoSave(val);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Data Section
            _buildSectionHeader('Data'),
            _buildSettingsGroup(context, [
              _buildClickableRow(
                context,
                title: 'Clear all notes',
                desc: 'This action cannot be undone',
                isDestructive: true,
                onTap: () => _confirmClearData(context, ref),
              ),
            ]),
            const SizedBox(height: 20),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsGroup(context, [
              _buildStaticRow(
                context,
                title: 'Version',
                value: '1.0.0',
              ),
              _buildClickableRow(
                context,
                title: 'Contact support',
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

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear all notes?', style: TextStyle(fontSize: 18)),
          content: const Text(
            'This will delete all your notes, custom tags, study history, and chat logs. This cannot be undone.',
            style: TextStyle(fontSize: 13.5),
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
