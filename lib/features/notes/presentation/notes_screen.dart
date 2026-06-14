import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../shared/widgets/app_header.dart';
import '../domain/note_model.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilterTag;

  final List<String> _defaultTags = ["General", "Math", "Biology", "History", "Physics", "Chemistry", "Lit", "CS"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getWordCount(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).length;
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
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final customTags = ref.watch(customTagsProvider);
    final allTags = [..._defaultTags, ...customTags].toSet().toList();
    final settings = ref.watch(settingsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Filter notes
    final filteredNotes = notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery) ||
          note.body.toLowerCase().contains(_searchQuery) ||
          note.tag.toLowerCase().contains(_searchQuery);
      
      final matchesTag = _selectedFilterTag == null || note.tag == _selectedFilterTag;

      return matchesSearch && matchesTag;
    }).toList();

    return Scaffold(
      appBar: AppHeader(title: l10n.notes),
      body: Column(
        children: [
          // Search & New Note Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: l10n.searchNotesHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: isDark ? AppColors.surface : Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.push('/notes/edit?id=new'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.newButton,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Tags chips row
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allTags.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedFilterTag == null;
                  return ChoiceChip(
                    label: Text(l10n.allChips, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilterTag = null;
                      });
                    },
                  );
                }
                final tag = allTags[index - 1];
                final isSelected = _selectedFilterTag == tag;
                return ChoiceChip(
                  label: Text(_getLocalizedTag(tag, l10n), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilterTag = selected ? tag : null;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Notes Listing
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 130),
                    itemCount: filteredNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Dismissible(
                        key: Key(note.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        ),
                        confirmDismiss: (direction) async {
                          return await _confirmDeleteDialog(context, note.title);
                        },
                        onDismissed: (direction) {
                          ref.read(notesProvider.notifier).deleteNote(note.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.noteDeleted)),
                          );
                        },
                        child: _buildNoteCard(context, note, settings.compactView),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note, bool compact) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final preview = note.body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final previewText = preview.isEmpty ? l10n.emptyNote : (preview.length > 90 ? '${preview.substring(0, 90)}...' : preview);
    final dateText = _formatDate(note.updatedAt);
    final wordsText = '${_getWordCount(note.body)} ${l10n.words.toLowerCase()}';

    return InkWell(
      onTap: () => context.push('/notes/edit?id=${note.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
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
                      fontSize: compact ? 13.5 : 15,
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
            if (!compact) ...[
              const SizedBox(height: 8),
              Text(
                previewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
                Text(
                  wordsText,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
              ],
            ),
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
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ? l10n.noMatches : l10n.noNotesYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.tryDifferentSearch
                  : l10n.startByDictating,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/notes/edit?id=new'),
                child: Text(l10n.createNote),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteDialog(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNoteTitle, style: const TextStyle(fontSize: 18)),
        content: Text(
          l10n.deleteNoteConfirm(title.isEmpty ? l10n.untitled : title),
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
