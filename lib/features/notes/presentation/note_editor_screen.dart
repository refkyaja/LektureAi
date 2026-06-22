import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../domain/note_model.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String? prefillTitle;
  final String? prefillBody;
  final String? prefillTag;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.prefillTitle,
    this.prefillBody,
    this.prefillTag,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _ProfileHeader extends StatelessWidget {
  final String dateText;
  final String noteTitle;

  const _ProfileHeader({required this.dateText, required this.noteTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dateText,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8),
        ),
        const SizedBox(height: 2),
        Text(
          noteTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late String _id;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _newTagController;
  String _selectedTag = 'General';
  bool _isNew = true;
  bool _isDirty = false;
  bool _isAddingTag = false;
  int _wordCount = 0;
  int _charCount = 0;
  Timer? _debounceTimer;

  final List<String> _defaultTags = ["General", "Math", "Biology", "History", "Physics", "Chemistry", "Lit", "CS"];

  @override
  void initState() {
    super.initState();
    _newTagController = TextEditingController();
    
    // Check if editing existing note
    if (widget.noteId != null && widget.noteId != 'new') {
      _isNew = false;
      _id = widget.noteId!;
      final note = ref.read(notesProvider).firstWhere((n) => n.id == _id);
      _titleController = TextEditingController(text: note.title);
      _bodyController = TextEditingController(text: note.body);
      _selectedTag = note.tag;
    } else {
      _id = const Uuid().v4();
      _titleController = TextEditingController(text: widget.prefillTitle ?? '');
      _bodyController = TextEditingController(text: widget.prefillBody ?? '');
      _selectedTag = widget.prefillTag ?? 'General';
    }

    _updateCounts();
    _titleController.addListener(_onContentChanged);
    _bodyController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  void _updateCounts() {
    final text = _bodyController.text;
    final clean = text.trim();
    setState(() {
      _charCount = text.length;
      _wordCount = clean.isEmpty ? 0 : clean.split(RegExp(r'\s+')).length;
    });
  }

  void _onContentChanged() {
    _updateCounts();
    
    // Check if dirty
    if (!_isNew) {
      final note = ref.read(notesProvider).firstWhere((n) => n.id == _id);
      setState(() {
        _isDirty = _titleController.text != note.title ||
            _bodyController.text != note.body ||
            _selectedTag != note.tag;
      });
    } else {
      setState(() {
        _isDirty = _titleController.text.isNotEmpty ||
            _bodyController.text.isNotEmpty ||
            _selectedTag != 'General';
      });
    }

    // Debounced Auto-Save
    final autoSave = ref.read(settingsProvider).autoSave;
    if (autoSave && _isDirty) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () {
        _saveNote();
      });
    }
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

  Future<void> _saveNote() async {
    _debounceTimer?.cancel();
    final titleText = _titleController.text.trim();
    final bodyText = _bodyController.text.trim();

    if (titleText.isEmpty && bodyText.isEmpty) {
      if (!_isNew) {
        await ref.read(notesProvider.notifier).deleteNote(_id);
      }
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final l10n = AppLocalizations.of(context)!;
    final note = Note(
      id: _id,
      title: titleText.isEmpty ? l10n.untitled : titleText,
      body: _bodyController.text,
      tag: _selectedTag,
      createdAt: _isNew ? now : ref.read(notesProvider).firstWhere((n) => n.id == _id).createdAt,
      updatedAt: now,
    );

    if (_isNew) {
      await ref.read(notesProvider.notifier).addNote(note);
      setState(() {
        _isNew = false;
        _isDirty = false;
      });
    } else {
      await ref.read(notesProvider.notifier).updateNote(note);
      setState(() {
        _isDirty = false;
      });
    }
  }

  void _addCustomTag() {
    final newTag = _newTagController.text.trim();
    if (newTag.isNotEmpty) {
      ref.read(customTagsProvider.notifier).addTag(newTag);
      setState(() {
        _selectedTag = newTag;
        _newTagController.clear();
        _isAddingTag = false;
      });
      _onContentChanged();
    }
  }

  void _copyToClipboard() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: _bodyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.noteCopied)),
    );
  }

  void _deleteNote() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNoteTitle, style: const TextStyle(fontSize: 18)),
        content: Text(
          l10n.deleteConfirmShort,
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(_id);
              Navigator.of(context).pop(); // Dismiss dialog
              context.pop(); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.noteDeleted)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _openStudyPicker() {
    final l10n = AppLocalizations.of(context)!;
    // If note is saved and not too short (React: min 20 chars)
    if (_bodyController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteTooShort)),
      );
      return;
    }

    _saveNote(); // Auto-save first
    
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.studyThisNote,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.psychology_rounded, color: AppColors.primary),
              title: Text(l10n.generateQuiz, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.practiceMcq, style: const TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/study/quiz?noteId=$_id&difficulty=medium&count=5');
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership_rounded, color: AppColors.secondary),
              title: Text(l10n.generateFlashcards, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.reviewTerms, style: const TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/study/flashcard?noteId=$_id&count=10');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customTags = ref.watch(customTagsProvider);
    final allTags = [..._defaultTags, ...customTags].toSet().toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final note = _isNew ? null : ref.read(notesProvider).firstWhere((n) => n.id == _id);
    final dateText = note != null
        ? DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(note.updatedAt))
        : l10n.newNote;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () async {
            if (_isDirty) {
              await _saveNote();
            }
            if (context.mounted) context.pop();
          },
        ),
        title: _ProfileHeader(dateText: dateText, noteTitle: _titleController.text.isEmpty ? l10n.untitled : _titleController.text),
        actions: [
          if (_isDirty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.save, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'study') _openStudyPicker();
              if (val == 'copy') _copyToClipboard();
              if (val == 'delete') _deleteNote();
            },
            icon: const Icon(Icons.more_horiz_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isDark ? AppColors.border : Colors.black12),
            ),
            color: AppColors.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'study',
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(l10n.studyThisNoteOption, style: TextStyle(fontSize: 13, color: isDark ? AppColors.text : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    const Icon(Icons.copy_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(l10n.copyText, style: TextStyle(fontSize: 13, color: isDark ? AppColors.text : Colors.black87)),
                  ],
                ),
              ),
              if (!_isNew)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(l10n.deleteNoteOption, style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.untitled,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags Wrap row
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...allTags.map((t) {
                          final isSelected = _selectedTag == t;
                          final isCustom = customTags.contains(t);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTag = t;
                              });
                              _onContentChanged();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.surface : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getLocalizedTag(t, l10n),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isCustom) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        if (_selectedTag == t) {
                                          _selectedTag = 'General';
                                        }
                                        ref.read(customTagsProvider.notifier).removeTag(t);
                                        _onContentChanged();
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 11,
                                        color: isSelected ? Colors.white70 : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        // Inline tag input
                        if (_isAddingTag)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surface : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 20,
                                  child: TextField(
                                    controller: _newTagController,
                                    autofocus: true,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: l10n.tagNameHint,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (_) => _addCustomTag(),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _addCustomTag,
                                  child: const Icon(Icons.check_rounded, size: 14, color: AppColors.accent),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isAddingTag = false;
                                      _newTagController.clear();
                                    });
                                  },
                                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                                ),
                              ],
                            ),
                          )
                        else
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isAddingTag = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 12,
                                    color: isDark ? AppColors.textMuted : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.tagOption,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textMuted : Colors.black54,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Body textarea field
                    TextField(
                      controller: _bodyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.startWritingOrDictating,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom stats bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.wordsCount(_wordCount),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  const Text('·', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.charsCount(_charCount),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
