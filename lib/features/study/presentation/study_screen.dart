import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a note first.')),
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
    final notes = ref.watch(notesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredHistory = history.where((h) => h.kind == _mode).toList();

    return Scaffold(
      appBar: const AppHeader(title: 'Study'),
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
                          'Quizzes',
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
                          'Flashcards',
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
                            _mode == 'quiz' ? 'Generate new quiz' : 'Generate flashcards',
                            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pick a note + customize',
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
            child: filteredHistory.isEmpty
                ? _buildEmptyState(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text(
                          'HISTORY · ${filteredHistory.length}',
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
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                          itemCount: filteredHistory.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredHistory[index];
                            return _buildHistoryCard(context, item);
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
                          isQuiz ? 'Quiz' : 'Flashcards',
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
                            'Score ${item.scoreCorrect}/${item.scoreTotal}',
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
                    '${isQuiz ? '${item.questions?.length ?? 0} questions' : '${item.cards?.length ?? 0} cards'} · ${_formatDateTime(item.createdAt)}',
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
                  const SnackBar(content: Text('History item removed')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
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
              _mode == 'quiz' ? 'No quizzes yet' : 'No flashcards yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Generate your first study set from any saved note.',
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
class GenerateStudySheet extends StatefulWidget {
  final String mode;
  final List<Note> notes;

  const GenerateStudySheet({super.key, required this.mode, required this.notes});

  @override
  State<GenerateStudySheet> createState() => _GenerateStudySheetState();
}

class _GenerateStudySheetState extends State<GenerateStudySheet> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final note = widget.notes.firstWhere((n) => n.id == _selectedNoteId);
    
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
                widget.mode == 'quiz' ? 'Generate quiz' : 'Generate flashcards',
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
          const Text(
            'SOURCE NOTE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
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
                  title: Text(n.title.isEmpty ? 'Untitled' : n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${_getWordCount(n.body)} words · ${n.tag}', style: const TextStyle(fontSize: 11)),
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
            widget.mode == 'quiz' ? 'NUMBER OF QUESTIONS' : 'NUMBER OF CARDS',
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
            const Text(
              'DIFFICULTY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['easy', 'medium', 'hard'].map((d) {
                final isSelected = _difficulty == d;
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
                      child: Text(d[0].toUpperCase() + d.substring(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                    if (widget.mode == 'quiz') {
                      context.push('/study/quiz?noteId=$_selectedNoteId&count=$_count&difficulty=$_difficulty');
                    } else {
                      context.push('/study/flashcard?noteId=$_selectedNoteId&count=$_count');
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              noteBodyLen < 20 ? 'Note too short (min 20 chars)' : 'Generate',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
