import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../domain/study_model.dart';
import '../../notes/domain/note_model.dart';

class FlashRunnerScreen extends ConsumerStatefulWidget {
  final String noteId;
  final String? historyId;
  final int count;

  const FlashRunnerScreen({
    super.key,
    required this.noteId,
    this.historyId,
    this.count = 10,
  });

  @override
  ConsumerState<FlashRunnerScreen> createState() => _FlashRunnerScreenState();
}

class _FlashRunnerScreenState extends ConsumerState<FlashRunnerScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<Flashcard> _cards = [];
  late String _historyId;
  bool _isNewDeck = true;

  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrGenerateFlashcards();
    });
  }

  void _loadOrGenerateFlashcards() async {
    final history = ref.read(studyHistoryProvider);

    if (widget.historyId != null) {
      _isNewDeck = false;
      _historyId = widget.historyId!;
      final histItem = history.firstWhere((h) => h.id == _historyId);
      setState(() {
        _cards = histItem.cards ?? [];
      });
    } else {
      _historyId = const Uuid().v4();
      _generateFlashcards();
    }
  }

  Future<void> _generateFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _cards = [];
      _currentIndex = 0;
      _isFlipped = false;
    });

    try {
      final notes = ref.read(notesProvider);
      final note = notes.firstWhere((n) => n.id == widget.noteId);
      final ai = ref.read(aiServiceProvider);
      final l10n = AppLocalizations.of(context)!;

      final result = await ai.generateFlashcards(
        note.body,
        count: widget.count,
      );

      if (result.isEmpty) {
        throw Exception("AI did not return any cards.");
      }

      setState(() {
        _cards = result;
        _isLoading = false;
      });

      // Save generated flashcards to history
      final historyItem = StudyHistoryItem(
        id: _historyId,
        kind: 'flash',
        noteId: widget.noteId,
        noteTitle: note.title.isEmpty ? l10n.untitled : note.title,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        cards: result,
      );
      await ref.read(studyHistoryProvider.notifier).addHistoryItem(historyItem);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _nextCard() {
    if (_currentIndex + 1 < _cards.length) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
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
              l10n.flashcardsUpper,
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            height: 280,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.secondary),
                const SizedBox(height: 18),
                Text(l10n.extractingConcepts, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(l10n.extractionFailed, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateFlashcards,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return Center(child: Text(l10n.noFlashcardsLoaded));
    }

    final totalCards = _cards.length;
    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / totalCards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.cardNumberProgress(_currentIndex + 1, totalCards),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            if (_isNewDeck)
              GestureDetector(
                onTap: _generateFlashcards,
                child: Text(
                  l10n.regenerate,
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDark ? AppColors.surface : Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 24),

        // Flip Card Box
        Expanded(
          child: Center(
            child: InteractiveFlipCard(
              term: currentCard.term,
              definition: currentCard.definition,
              isFlipped: _isFlipped,
              onTap: _toggleFlip,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Navigation row
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: _currentIndex > 0 ? _previousCard : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                disabledBackgroundColor: (isDark ? AppColors.surface : Colors.grey[200])?.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _toggleFlip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isFlipped ? l10n.showTerm : l10n.showDefinition,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: _currentIndex + 1 < totalCards ? _nextCard : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                disabledBackgroundColor: (isDark ? AppColors.surface : Colors.grey[200])?.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// Reusable Flip Card utilizing TweenAnimationBuilder
class InteractiveFlipCard extends StatelessWidget {
  final String term;
  final String definition;
  final bool isFlipped;
  final VoidCallback onTap;

  const InteractiveFlipCard({
    super.key,
    required this.term,
    required this.definition,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: isFlipped ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 400),
        builder: (context, val, child) {
          final angle = val * math.pi;
          final isBack = angle >= math.pi / 2;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: isBack
                // Back card content (rotated Y)
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.primary.withOpacity(0.25), AppColors.secondary.withOpacity(0.2)]
                              : [AppColors.primary.withOpacity(0.08), AppColors.secondary.withOpacity(0.06)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.definitionUpper,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            definition,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                // Front card content
                : Container(
                    width: double.infinity,
                    height: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.termUpper,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          term,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.tapToFlip,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
