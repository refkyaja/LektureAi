import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../shared/widgets/app_header.dart';
import '../domain/study_model.dart';
import '../../notes/domain/note_model.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  String _mode = 'quiz'; // 'quiz' or 'flash'

  String _formatDateTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('d MMM yyyy, HH:mm').format(dt);
  }

  void _openGenerateSheet(BuildContext context, List<Note> notes) {
    final l10n = AppLocalizations.of(context)!;
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseCreateNoteFirst)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => GenerateStudySheet(mode: _mode, notes: notes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(studyHistoryProvider);
    final pending = ref.watch(pendingGenerationsProvider);
    final notes = ref.watch(notesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final filteredHistory = history.where((h) => h.kind == _mode).toList();
    final filteredPending = pending.where((p) => p.kind == _mode).toList();
    final isEmpty = filteredHistory.isEmpty && filteredPending.isEmpty;

    return Scaffold(
      appBar: AppHeader(title: l10n.study),
      body: Column(
        children: [
          // Submode selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mode = 'quiz'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'quiz' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.quizzes,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mode == 'quiz' ? Colors.white : (isDark ? AppColors.textMuted : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mode = 'flash'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'flash' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.flashcards,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mode == 'flash' ? Colors.white : (isDark ? AppColors.textMuted : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Generate card button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: InkWell(
              onTap: () => _openGenerateSheet(context, notes),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.primary.withOpacity(0.15), AppColors.surface, AppColors.secondary.withOpacity(0.1)]
                        : [AppColors.primary.withOpacity(0.08), Colors.white, AppColors.secondary.withOpacity(0.04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mode == 'quiz' ? l10n.generateNewQuiz : l10n.generateFlashcards,
                            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.pickNoteCustomize,
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
          ),
          const SizedBox(height: 12),

          // History header list
          Expanded(
            child: isEmpty
                ? _buildEmptyState(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text(
                          l10n.historyHeader(filteredHistory.length),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 130),
                          itemCount: filteredPending.length + filteredHistory.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index < filteredPending.length) {
                              final item = filteredPending[index];
                              return _buildLoadingCard(context, item);
                            } else {
                              final item = filteredHistory[index - filteredPending.length];
                              return _buildHistoryCard(context, item);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, StudyHistoryItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isQuiz = item.kind == 'quiz';
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        if (isQuiz) {
          context.push('/study/quiz?noteId=${item.noteId}&historyId=${item.id}');
        } else {
          context.push('/study/flashcard?noteId=${item.noteId}&historyId=${item.id}');
        }
      },
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isQuiz ? AppColors.success : AppColors.secondary).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isQuiz ? l10n.quiz : l10n.flashcards,
                          style: TextStyle(
                            color: isQuiz ? AppColors.success : AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isQuiz && item.scoreCorrect != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.scoreLabel(item.scoreCorrect!, item.scoreTotal!),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.noteTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isQuiz ? l10n.questionsCount(item.questions?.length ?? 0) : l10n.cardsCount(item.cards?.length ?? 0)} · ${_formatDateTime(item.createdAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
              onPressed: () {
                ref.read(studyHistoryProvider.notifier).deleteHistoryItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.historyItemRemoved)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, PendingGeneration item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isQuiz = item.kind == 'quiz';
    final l10n = AppLocalizations.of(context)!;

    return PulsingWidget(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isQuiz ? AppColors.success : AppColors.secondary).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isQuiz ? l10n.quiz : l10n.flashcards,
                          style: TextStyle(
                            color: isQuiz ? AppColors.success : AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.noteTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isQuiz ? l10n.generatingQuiz : l10n.generatingFlashcard,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _mode == 'quiz' ? Icons.psychology_rounded : Icons.card_membership_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _mode == 'quiz' ? l10n.noQuizzesYet : l10n.noFlashcardsYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.generateFirstStudySet,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Generate Sheet modal
class GenerateStudySheet extends ConsumerStatefulWidget {
  final String mode;
  final List<Note> notes;

  const GenerateStudySheet({super.key, required this.mode, required this.notes});

  @override
  ConsumerState<GenerateStudySheet> createState() => _GenerateStudySheetState();
}

class _GenerateStudySheetState extends ConsumerState<GenerateStudySheet> {
  late String _selectedNoteId;
  late int _count;
  String _difficulty = 'medium';

  @override
  void initState() {
    super.initState();
    _selectedNoteId = widget.notes[0].id;
    _count = widget.mode == 'quiz' ? 5 : 10;
  }

  int _getWordCount(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).length;
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final note = widget.notes.firstWhere((n) => n.id == _selectedNoteId);
    final l10n = AppLocalizations.of(context)!;
    
    final countsList = widget.mode == 'quiz' ? [3, 5, 10, 15] : [5, 10, 15, 20];
    final noteBodyLen = note.body.trim().length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.mode == 'quiz' ? l10n.generateQuiz : l10n.generateFlashcards,
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Note Picker list
          Text(
            l10n.sourceNote,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.notes.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
              itemBuilder: (context, index) {
                final n = widget.notes[index];
                final isSelected = _selectedNoteId == n.id;
                return ListTile(
                  dense: true,
                  title: Text(n.title.isEmpty ? l10n.untitled : n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${l10n.wordsCount(_getWordCount(n.body))} · ${_getLocalizedTag(n.tag, l10n)}', style: const TextStyle(fontSize: 11)),
                  trailing: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedNoteId = n.id;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Count Selector
          Text(
            widget.mode == 'quiz' ? l10n.numberOfQuestions : l10n.numberOfCards,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: countsList.map((c) {
              final isSelected = _count == c;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _count = c),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.primary : (isDark ? AppColors.surface : Colors.grey[200]),
                      foregroundColor: isSelected ? Colors.white : (isDark ? AppColors.text : Colors.black87),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('$c', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Difficulty (Only for Quiz)
          if (widget.mode == 'quiz') ...[
            Text(
              l10n.difficulty,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['easy', 'medium', 'hard'].map((d) {
                final isSelected = _difficulty == d;
                final diffText = d == 'easy'
                    ? l10n.difficultyEasy
                    : (d == 'medium' ? l10n.difficultyMedium : l10n.difficultyHard);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _difficulty = d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? AppColors.primary : (isDark ? AppColors.surface : Colors.grey[200]),
                        foregroundColor: isSelected ? Colors.white : (isDark ? AppColors.text : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(diffText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Generate Submit Button
          ElevatedButton(
            onPressed: noteBodyLen < 20
                ? null
                : () {
                    Navigator.pop(context); // Close bottom sheet
                    ref.read(pendingGenerationsProvider.notifier).startGeneration(
                      noteId: _selectedNoteId,
                      noteTitle: note.title,
                      noteBody: note.body,
                      kind: widget.mode,
                      count: _count,
                      difficulty: widget.mode == 'quiz' ? _difficulty : null,
                      l10n: l10n,
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              noteBodyLen < 20 ? l10n.noteTooShortMin : l10n.generate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class PulsingWidget extends StatefulWidget {
  final Widget child;
  const PulsingWidget({super.key, required this.child});

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: widget.child,
    );
  }
}
