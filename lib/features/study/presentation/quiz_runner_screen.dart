import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../domain/study_model.dart';
import '../../notes/domain/note_model.dart';

class QuizRunnerScreen extends ConsumerStatefulWidget {
  final String noteId;
  final String? historyId;
  final int count;
  final String difficulty;

  const QuizRunnerScreen({
    super.key,
    required this.noteId,
    this.historyId,
    this.count = 5,
    this.difficulty = 'medium',
  });

  @override
  ConsumerState<QuizRunnerScreen> createState() => _QuizRunnerScreenState();
}

class _QuizRunnerScreenState extends ConsumerState<QuizRunnerScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizQuestion> _questions = [];
  late String _historyId;
  bool _isNewQuiz = true;

  int _currentIndex = 0;
  int? _pickedIndex;
  List<int> _picks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrGenerateQuiz();
    });
  }

  void _loadOrGenerateQuiz() async {
    final history = ref.read(studyHistoryProvider);
    
    if (widget.historyId != null) {
      // Load preloaded history quiz
      _isNewQuiz = false;
      _historyId = widget.historyId!;
      final histItem = history.firstWhere((h) => h.id == _historyId);
      setState(() {
        _questions = histItem.questions ?? [];
      });
    } else {
      // Generate new quiz
      _historyId = const Uuid().v4();
      _generateQuiz();
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _questions = [];
      _currentIndex = 0;
      _pickedIndex = null;
      _picks = [];
    });

    try {
      final notes = ref.read(notesProvider);
      final note = notes.firstWhere((n) => n.id == widget.noteId);
      final ai = ref.read(aiServiceProvider);
      final l10n = AppLocalizations.of(context)!;
      
      final result = await ai.generateQuiz(
        note.body,
        count: widget.count,
        difficulty: widget.difficulty,
      );

      if (result.isEmpty) {
        throw Exception("AI did not return any questions.");
      }

      setState(() {
        _questions = result;
        _isLoading = false;
      });

      // Save generated quiz to history
      final historyItem = StudyHistoryItem(
        id: _historyId,
        kind: 'quiz',
        noteId: widget.noteId,
        noteTitle: note.title.isEmpty ? l10n.untitled : note.title,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        questions: result,
      );
      await ref.read(studyHistoryProvider.notifier).addHistoryItem(historyItem);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _optionSelected(int index) {
    if (_pickedIndex != null) return; // Disallow picking twice
    setState(() {
      _pickedIndex = index;
    });
  }

  void _nextQuestion() {
    if (_pickedIndex == null) return;
    
    _picks.add(_pickedIndex!);
    final totalQs = _questions.length;
    
    if (_currentIndex + 1 >= totalQs) {
      // Quiz complete! Save score to history
      final score = _picks.asMap().entries.where((entry) => entry.value == _questions[entry.key].answerIndex).length;
      
      // Update history score
      final history = ref.read(studyHistoryProvider);
      final existingItem = history.firstWhere((h) => h.id == _historyId);
      final updatedItem = existingItem.copyWithScore(score, totalQs);
      ref.read(studyHistoryProvider.notifier).addHistoryItem(updatedItem);
    }

    setState(() {
      _currentIndex++;
      _pickedIndex = null;
    });
  }

  void _retake() {
    setState(() {
      _currentIndex = 0;
      _pickedIndex = null;
      _picks = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = ref.read(notesProvider);
    final note = notes.firstWhere((n) => n.id == widget.noteId, orElse: () => Note(id: '', title: 'Deleted Note', body: '', tag: '', createdAt: 0, updatedAt: 0));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quizUpper,
              style: const TextStyle(fontSize: 9, color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            Text(
              note.title.isEmpty ? l10n.untitled : note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 18),
                Text(l10n.aiCraftingQuiz, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSkeletonLine(double.infinity),
                const SizedBox(height: 8),
                _buildSkeletonLine(140),
                const SizedBox(height: 8),
                _buildSkeletonLine(180),
              ],
            ),
          ),
        ],
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(l10n.generationFailed, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateQuiz,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(child: Text(l10n.noQuestionsLoaded));
    }

    final totalQs = _questions.length;

    // Completed Screen
    if (_currentIndex >= totalQs) {
      final score = _picks.asMap().entries.where((entry) => entry.value == _questions[entry.key].answerIndex).length;
      final percentage = ((score / totalQs) * 100).round();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [AppColors.success.withOpacity(0.2), AppColors.surface, AppColors.primary.withOpacity(0.15)]
                    : [AppColors.success.withOpacity(0.08), Colors.white, AppColors.primary.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.quizCompleteUpper,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success, letterSpacing: 1.2),
                ),
                const SizedBox(height: 14),
                Text(
                  '$score/$totalQs',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.percentCorrect(percentage),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _retake,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(l10n.retake, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                    ),
                    if (_isNewQuiz) ...[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _generateQuiz,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(l10n.newQuiz),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = _currentIndex / totalQs;
    final correctPickCount = _picks.asMap().entries.where((entry) => entry.value == _questions[entry.key].answerIndex).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.questionNumberProgress(_currentIndex + 1, totalQs),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            Text(
              l10n.correctCount(correctPickCount),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 20),

        // Question Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentQuestion.question,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(currentQuestion.options.length, (i) {
                final option = currentQuestion.options[i];
                final prefix = String.fromCharCode(65 + i); // A, B, C, D
                
                // Styling classes based on status
                Color borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black12;
                Color bgColor = Colors.transparent;
                Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
                double opacity = 1.0;

                if (_pickedIndex != null) {
                   if (i == currentQuestion.answerIndex) {
                    // Correct answer (Always highlight in green once picked)
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withOpacity(0.15);
                    textColor = AppColors.success;
                  } else if (i == _pickedIndex) {
                    // Wrong choice picked (highlight in red)
                    borderColor = AppColors.error;
                    bgColor = AppColors.error.withOpacity(0.15);
                    textColor = AppColors.error;
                  } else {
                    opacity = 0.4;
                  }
                }

                return Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => _optionSelected(i),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: bgColor,
                        side: BorderSide(color: borderColor, width: _pickedIndex != null && (i == _pickedIndex || i == currentQuestion.answerIndex) ? 1.5 : 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        '$prefix.  $option',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              if (_pickedIndex != null) ...[
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(_currentIndex + 1 == totalQs ? l10n.seeResults : l10n.next),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLine(double width) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
