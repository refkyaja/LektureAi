import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../shared/widgets/app_header.dart';
import '../../notes/domain/note_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  int _getWordCount(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).length;
  }

  String _formatWordCount(int count) {
    if (count > 999) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d').format(dt);
  }

  String _getLocalizedTag(String tag, AppLocalizations l10n) {
    switch (tag) {
      case 'General':
        return l10n.tagGeneral;
      case 'Math':
        return l10n.subjectMath;
      case 'Biology':
        return l10n.subjectBiology;
      case 'History':
        return l10n.subjectHistory;
      case 'Physics':
        return l10n.subjectPhysics;
      case 'Chemistry':
        return l10n.subjectChemistry;
      case 'Lit':
        return l10n.subjectLiterature;
      case 'CS':
        return l10n.subjectCS;
      default:
        return tag;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Get recent 3 notes
    final recentNotes = [...notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final displayNotes = recentNotes.take(3).toList();

    // Stats calculations
    final totalNotes = notes.length;
    final totalWords = notes.fold<int>(0, (sum, note) => sum + _getWordCount(note.body));
    final distinctTags = notes.map((n) => n.tag).toSet().length;

    return Scaffold(
      appBar: AppHeader(title: l10n.appTitle),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.read(notesProvider.notifier).loadNotes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Greeting Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.primary.withOpacity(0.25),
                            AppColors.surface,
                            AppColors.secondary.withOpacity(0.15)
                          ]
                        : [
                            AppColors.primary.withOpacity(0.1),
                            Colors.white,
                            AppColors.secondary.withOpacity(0.05)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.today.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.readyToStudy,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.heroDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.go('/capture'),
                            child: Text(l10n.startDictating),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => context.go('/chat'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          child: Text(
                            l10n.askAi,
                            style: TextStyle(
                              color: isDark ? AppColors.text : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Stats row
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, l10n.notes, '$totalNotes')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(context, l10n.words, _formatWordCount(totalWords))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(context, l10n.tags, '$distinctTags')),
                ],
              ),
              const SizedBox(height: 20),

              // Recent Notes Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentNotes,
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go('/notes'),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Notes List
              if (displayNotes.isEmpty)
                _buildEmptyNotesCard(context)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: displayNotes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = displayNotes[index];
                    return _buildNoteCard(context, note);
                  },
                ),
              const SizedBox(height: 14),

              // Quick Actions Header
              Text(
                l10n.quickActions,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),

              // Quick Actions Grid
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.psychology_rounded,
                      title: l10n.quizMe,
                      desc: l10n.fromAnyNote,
                      onTap: () => context.go('/study'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.camera_alt_rounded,
                      title: l10n.scanPage,
                      desc: l10n.ocrFromPhoto,
                      onTap: () => context.go('/capture?mode=scan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final wordCountText = '${_getWordCount(note.body)} ${l10n.words.toLowerCase()}';
    final dateText = _formatDate(note.updatedAt);
    
    final preview = note.body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final previewText = preview.isEmpty ? l10n.emptyNote : (preview.length > 90 ? '${preview.substring(0, 90)}...' : preview);

    return InkWell(
      onTap: () => context.push('/notes/edit?id=${note.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? l10n.untitled : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getLocalizedTag(note.tag, l10n),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              previewText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textMuted : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
                Text(
                  wordCountText,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotesCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noNotesYet,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.startByDictating,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.go('/capture'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.captureNow, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
