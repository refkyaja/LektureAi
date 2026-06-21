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
  bool _isGridView = false;
  String _sortBy = 'newest';

  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  final List<String> _defaultTags = [
    "General",
    "Math",
    "Biology",
 "History",
    "Physics",
    "Chemistry",
    "Lit",
    "CS"
  ];

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
    Future.microtask(() {
      if (ref.context.mounted) {
        ref.read(hideNavbarProvider.notifier).state = false;
      }
    });
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

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
          ref.read(hideNavbarProvider.notifier).state = false;
        }
      } else {
        _selectedNoteIds.add(id);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
    ref.read(hideNavbarProvider.notifier).state = false;
  }

  void _selectAll(List<Note> notes) {
    setState(() {
      _selectedNoteIds.clear();
      _selectedNoteIds.addAll(notes.map((n) => n.id));
    });
  }

  Future<void> _batchDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.deleteNoteTitle,
            style: const TextStyle(fontSize: 18)),
        content: Text(
          l10n.confirmDeleteMultiple(_selectedNoteIds.length),
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ids = List<String>.from(_selectedNoteIds);
      for (final id in ids) {
        ref.read(notesProvider.notifier).deleteNote(id);
      }
      _exitSelectionMode();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.noteDeleted)));
      }
    }
  }

  void _batchTogglePin() {
    final notes = ref.read(notesProvider);
    final allPinned =
        _selectedNoteIds.every((id) => notes.firstWhere((n) => n.id == id).isPinned);
    final newPin = !allPinned;
    for (final id in _selectedNoteIds) {
      final note = notes.firstWhere((n) => n.id == id);
      ref.read(notesProvider.notifier).updateNote(note.copyWith(isPinned: newPin));
    }
    _exitSelectionMode();
  }

  void _batchChangeCategory() {
    final l10n = AppLocalizations.of(context)!;
    final notes = ref.read(notesProvider);
    final customTags = ref.read(customTagsProvider);
    final allTags = [..._defaultTags, ...customTags].toSet().toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.selectCategory,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final tag = allTags[index];
                    return ListTile(
                      title: Text(_getLocalizedTag(tag, l10n)),
                      onTap: () {
                        Navigator.pop(ctx);
                        for (final id in _selectedNoteIds) {
                          final note = notes.firstWhere((n) => n.id == id);
                          ref
                              .read(notesProvider.notifier)
                              .updateNote(note.copyWith(tag: tag));
                        }
                        _exitSelectionMode();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteSideModal(Note note) {
    final l10n = AppLocalizations.of(context)!;
    final customTags = ref.read(customTagsProvider);
    final allTags = [..._defaultTags, ...customTags].toSet().toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rootContext = Navigator.of(context, rootNavigator: true).context;

    showGeneralDialog(
      context: rootContext,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.78,
            height: MediaQuery.of(ctx).size.height,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      note.title.isEmpty ? l10n.untitled : note.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _getLocalizedTag(note.tag, l10n),
                      style: const TextStyle(
                          color: AppColors.secondary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      note.body.isEmpty
                          ? l10n.emptyNote
                          : note.body.replaceAll(RegExp(r'\s+'), ' ').trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  const Divider(height: 32),
                  _SideModalActionTile(
                    icon: note.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: AppColors.primary,
                    label: note.isPinned ? l10n.unpinNote : l10n.pinNote,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref
                          .read(notesProvider.notifier)
                          .updateNote(note.copyWith(isPinned: !note.isPinned));
                    },
                  ),
                  _SideModalActionTile(
                    icon: Icons.label_outline_rounded,
                    color: AppColors.secondary,
                    label: l10n.changeCategory,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showCategorySelection(context, note, allTags);
                    },
                  ),
                  _SideModalActionTile(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    label: l10n.deleteNoteOption,
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final confirm =
                          await _confirmDeleteDialog(context, note.title);
                      if (confirm == true) {
                        ref.read(notesProvider.notifier).deleteNote(note.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.noteDeleted)),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        );
      },
    );
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

    final filteredNotes = notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery) ||
          note.body.toLowerCase().contains(_searchQuery) ||
          note.tag.toLowerCase().contains(_searchQuery);

      final matchesTag =
          _selectedFilterTag == null || note.tag == _selectedFilterTag;

      return matchesSearch && matchesTag;
    }).toList();

    filteredNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      switch (_sortBy) {
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'az':
          final aTitle =
              a.title.isEmpty ? l10n.untitled : a.title;
          final bTitle =
              b.title.isEmpty ? l10n.untitled : b.title;
          return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
        case 'za':
          final aTitle =
              a.title.isEmpty ? l10n.untitled : a.title;
          final bTitle =
              b.title.isEmpty ? l10n.untitled : b.title;
          return bTitle.toLowerCase().compareTo(aTitle.toLowerCase());
        case 'newest':
        default:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : null,
        appBar: _isSelectionMode
            ? _buildSelectionAppBar(l10n)
            : AppHeader(title: l10n.notes),
        body: Column(
          children: [
            if (!_isSelectionMode)
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
                          prefixIcon:
                              const Icon(Icons.search_rounded, size: 20),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.surface : Colors.grey[200],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_rounded),
                      tooltip: 'Sort notes',
                      onSelected: (String value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'newest',
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 18,
                                  color: _sortBy == 'newest'
                                      ? AppColors.primary
                                      : Colors.grey),
                              const SizedBox(width: 8),
                              Text(l10n.sortNewest,
                                  style: TextStyle(
                                      fontWeight: _sortBy == 'newest'
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'oldest',
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 18,
                                  color: _sortBy == 'oldest'
                                      ? AppColors.primary
                                      : Colors.grey),
                              const SizedBox(width: 8),
                              Text(l10n.sortOldest,
                                  style: TextStyle(
                                      fontWeight: _sortBy == 'oldest'
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'az',
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha_rounded,
                                  size: 18,
                                  color: _sortBy == 'az'
                                      ? AppColors.primary
                                      : Colors.grey),
                              const SizedBox(width: 8),
                              Text(l10n.sortAlphabeticalAsc,
                                  style: TextStyle(
                                      fontWeight: _sortBy == 'az'
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'za',
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha_rounded,
                                  size: 18,
                                  color: _sortBy == 'za'
                                      ? AppColors.primary
                                      : Colors.grey),
                              const SizedBox(width: 8),
                              Text(l10n.sortAlphabeticalDesc,
                                  style: TextStyle(
                                      fontWeight: _sortBy == 'za'
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(_isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded),
                      tooltip:
                          _isGridView ? l10n.layoutList : l10n.layoutGrid,
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                  ],
                ),
              ),
            if (!_isSelectionMode)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allTags.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedFilterTag == null;
                      return ChoiceChip(
                        label: Text(l10n.allChips,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor:
                            isDark ? AppColors.surface : Colors.grey[200],
                        labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyLarge?.color),
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
                      label: Text(_getLocalizedTag(tag, l10n),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor:
                          isDark ? AppColors.surface : Colors.grey[200],
                      labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyLarge?.color),
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
            Expanded(
              child: filteredNotes.isEmpty
                  ? _buildEmptyState(context)
                  : _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 4, bottom: 130),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return _buildNoteCard(context, note, false);
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 4, bottom: 130),
                          itemCount: filteredNotes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            if (_isSelectionMode) {
                              return _buildNoteCard(context, note, settings.compactView);
                            }
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
                                child: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error),
                              ),
                              confirmDismiss: (direction) async {
                                return await _confirmDeleteDialog(
                                    context, note.title);
                              },
                              onDismissed: (direction) {
                                ref
                                    .read(notesProvider.notifier)
                                    .deleteNote(note.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.noteDeleted)),
                                );
                              },
                              child:
                                  _buildNoteCard(context, note, settings.compactView),
                            );
                          },
                        ),
            ),
          ],
        ),
        bottomNavigationBar:
            _isSelectionMode ? _buildSelectionBottomBar(l10n) : null,
        floatingActionButton: _isSelectionMode
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 112.0),
                child: FloatingActionButton(
                  onPressed: () => context.push('/notes/edit?id=new'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_rounded, size: 28),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.background.withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _exitSelectionMode,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.selectedCount(_selectedNoteIds.length),
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final notes = ref.read(notesProvider);
                    _selectAll(notes);
                  },
                  child: Text(l10n.selectAll),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notes = ref.read(notesProvider);
    final allPinned = _selectedNoteIds.isNotEmpty &&
        _selectedNoteIds.every((id) {
          final note = notes.firstWhere((n) => n.id == id, orElse: () => Note(id: '', title: '', body: '', tag: '', createdAt: 0, updatedAt: 0));
          return note.id.isNotEmpty && note.isPinned;
        });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBatchAction(
              icon: allPinned ? Icons.pin_drop_rounded : Icons.push_pin_rounded,
              label: allPinned ? l10n.unpinNote : l10n.pinNote,
              onTap: _batchTogglePin,
            ),
            _buildBatchAction(
              icon: Icons.label_outline_rounded,
              label: l10n.changeCategory,
              onTap: _batchChangeCategory,
            ),
            _buildBatchAction(
              icon: Icons.delete_outline_rounded,
              label: l10n.delete,
              color: AppColors.error,
              onTap: _batchDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note, bool compact) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final preview = note.body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final previewText = preview.isEmpty ? l10n.emptyNote : preview;
    final dateText = _formatDate(note.updatedAt);
    final isSelected = _selectedNoteIds.contains(note.id);

    return InkWell(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(note.id);
        } else {
          context.push('/notes/edit?id=${note.id}');
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedNoteIds.add(note.id);
          });
          ref.read(hideNavbarProvider.notifier).state = true;
        } else {
          _toggleSelection(note.id);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : isDark
                  ? AppColors.surface
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.04),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSelectionMode) ...[
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? l10n.untitled : note.title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (!_isSelectionMode && note.isPinned) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ],
                    if (!_isSelectionMode) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showNoteSideModal(note),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    previewText,
                    maxLines: _isGridView ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white30 : Colors.black38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelection(
      BuildContext context, Note note, List<String> tags) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.selectCategory,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = tags[index];
                    final isSelected = note.tag == t;
                    return ListTile(
                      title: Text(
                        _getLocalizedTag(t, l10n),
                        style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primary)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        ref
                            .read(notesProvider.notifier)
                            .updateNote(note.copyWith(tag: t));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
              _searchQuery.isNotEmpty
                  ? l10n.noMatches
                  : l10n.noNotesYet,
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

  Future<bool?> _confirmDeleteDialog(
      BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.deleteNoteTitle,
            style: const TextStyle(fontSize: 18)),
        content: Text(
          l10n.deleteNoteConfirm(
              title.isEmpty ? l10n.untitled : title),
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _SideModalActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SideModalActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: color)),
      onTap: onTap,
    );
  }
}
