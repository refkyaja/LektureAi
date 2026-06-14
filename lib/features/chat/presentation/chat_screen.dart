import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../domain/chat_model.dart';
import '../../notes/domain/note_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isSending = false;
  List<String> _selectedNoteIds = [];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    final sessions = ref.read(chatSessionsProvider);
    final notes = ref.read(notesProvider);
    final ai = ref.read(aiServiceProvider);
    final activeSessionId = ref.read(activeChatSessionIdProvider);

    final activeSession = activeSessionId != null
        ? sessions.firstWhere((s) => s.id == activeSessionId, orElse: () => ChatSession(id: '', title: '', updatedAt: 0, messages: [], noteIds: []))
        : null;

    final msgs = activeSession?.messages ?? [];

    final l10n = AppLocalizations.of(context)!;
    // Build context if notes selected
    String userContent = text;
    final selectedNotes = notes.where((n) => _selectedNoteIds.contains(n.id)).toList();
    if (selectedNotes.isNotEmpty && msgs.isEmpty) {
      final contextBuffer = StringBuffer();
      for (final n in selectedNotes) {
        contextBuffer.writeln('### ${n.title.isEmpty ? l10n.untitled : n.title} (${n.tag})');
        contextBuffer.writeln(n.body);
        contextBuffer.writeln();
      }
      userContent = '${l10n.useNotesReference}\n\n$contextBuffer---\n\n${l10n.questionLabel}: $text';
    }

    final newMsgUser = ChatMessage(role: 'user', content: text);
    final nextMsgs = [...msgs, newMsgUser];
    
    // API request messages (with context added to user content)
    final apiMsgs = [...msgs, ChatMessage(role: 'user', content: userContent)];

    final now = DateTime.now().millisecondsSinceEpoch;
    String sessId = activeSessionId ?? const Uuid().v4();

    if (activeSessionId == null) {
      // Create new session
      final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
      final newSession = ChatSession(
        id: sessId,
        title: title,
        updatedAt: now,
        messages: nextMsgs,
        noteIds: _selectedNoteIds,
      );
      await ref.read(chatSessionsProvider.notifier).saveSession(newSession);
      ref.read(activeChatSessionIdProvider.notifier).state = sessId;
    } else {
      // Update existing session
      final updatedSession = activeSession!.copyWith(
        messages: nextMsgs,
        updatedAt: now,
        noteIds: _selectedNoteIds,
      );
      await ref.read(chatSessionsProvider.notifier).saveSession(updatedSession);
    }

    _inputController.clear();
    setState(() => _isSending = true);
    _scrollToBottom();

    try {
      final response = await ai.tutorChat(apiMsgs);
      final newMsgAssistant = ChatMessage(role: 'assistant', content: response);

      final currentSessions = ref.read(chatSessionsProvider);
      final activeSessObj = currentSessions.firstWhere((s) => s.id == sessId);
      final finalSession = activeSessObj.copyWith(
        messages: [...activeSessObj.messages, newMsgAssistant],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await ref.read(chatSessionsProvider.notifier).saveSession(finalSession);
    } catch (e) {
      final errorMsg = ChatMessage(role: 'assistant', content: '${l10n.errorOccurred}: ${e.toString().replaceFirst("Exception: ", "")}');
      final currentSessions = ref.read(chatSessionsProvider);
      final activeSessObj = currentSessions.firstWhere((s) => s.id == sessId);
      final errorSession = activeSessObj.copyWith(
        messages: [...activeSessObj.messages, errorMsg],
      );
      await ref.read(chatSessionsProvider.notifier).saveSession(errorSession);
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _openNotePicker(BuildContext context, List<Note> notes) {
    final l10n = AppLocalizations.of(context)!;
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createNoteFirst)),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                    l10n.tagNotes,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final n = notes[index];
                    final isChecked = _selectedNoteIds.contains(n.id);
                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isChecked ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      title: Text(n.title.isEmpty ? l10n.untitled : n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(n.tag, style: const TextStyle(fontSize: 11)),
                      trailing: Checkbox(
                        value: isChecked,
                        activeColor: AppColors.primary,
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked == true) {
                              _selectedNoteIds.add(n.id);
                            } else {
                              _selectedNoteIds.remove(n.id);
                            }
                          });
                          setState(() {}); // Sync parent state
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          if (isChecked) {
                            _selectedNoteIds.remove(n.id);
                          } else {
                            _selectedNoteIds.add(n.id);
                          }
                        });
                        setState(() {}); // Sync parent state
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedNoteIds.clear();
                        });
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.clear, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('${l10n.done} (${_selectedNoteIds.length})'),
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

  String _getGreeting(String name, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '${l10n.goodMorning}, $name';
    } else if (hour >= 12 && hour < 17) {
      return '${l10n.goodAfternoon}, $name';
    } else if (hour >= 17 && hour < 21) {
      return '${l10n.goodEvening}, $name';
    } else {
      return '${l10n.goodNight}, $name';
    }
  }

  Widget _buildComposer(BuildContext context, List<Note> notes, bool isDark, {bool isCentered = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black12,
          width: 1,
        ),
        boxShadow: isCentered
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Tag Note Button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tag_rounded, size: 20),
                onPressed: () => _openNotePicker(context, notes),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppColors.surfaceVariant : Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              if (_selectedNoteIds.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${_selectedNoteIds.length}',
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),

          // Input Box
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: 5,
              minLines: 1,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.askLekture,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hoverColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Send Button
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            onPressed: _isSending ? null : _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionId = ref.watch(activeChatSessionIdProvider);
    final sessions = ref.watch(chatSessionsProvider);
    final notes = ref.watch(notesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final activeSession = activeSessionId != null
        ? sessions.firstWhere((s) => s.id == activeSessionId, orElse: () => ChatSession(id: '', title: '', updatedAt: 0, messages: [], noteIds: []))
        : null;

    final msgs = activeSession?.messages ?? [];
    final selectedNotes = notes.where((n) => _selectedNoteIds.contains(n.id)).toList();

    // Listen to active session changes to load notes and scroll to bottom
    ref.listen<String?>(activeChatSessionIdProvider, (previous, next) {
      if (next == null) {
        setState(() {
          _selectedNoteIds = [];
        });
      } else {
        final nextSession = sessions.firstWhere((s) => s.id == next, orElse: () => ChatSession(id: '', title: '', updatedAt: 0, messages: [], noteIds: []));
        setState(() {
          _selectedNoteIds = List.from(nextSession.noteIds);
        });
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                height: 28,
                width: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                activeSession != null && activeSession.title.isNotEmpty ? activeSession.title : '${l10n.appTitle} Tutor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selected Notes context chips
            if (selectedNotes.isNotEmpty)
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedNotes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final n = selectedNotes[index];
                    return InputChip(
                      label: Text(n.title.isEmpty ? l10n.untitled : n.title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      labelStyle: const TextStyle(color: AppColors.secondary),
                      onDeleted: () {
                        setState(() {
                          _selectedNoteIds.remove(n.id);
                        });
                      },
                      deleteIconColor: AppColors.secondary,
                    );
                  },
                ),
              ),

            // Chat content area
            Expanded(
              child: msgs.isEmpty && !_isSending
                  ? _buildEmptyState(context, notes, isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
                      itemCount: msgs.length + (_isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == msgs.length && _isSending) {
                          return _buildTypingIndicator();
                        }
                        final msg = msgs[index];
                        return _buildChatBubble(context, msg);
                      },
                    ),
            ),

            // Composer panel at the bottom (only when chat is active)
            if (msgs.isNotEmpty || _isSending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface.withOpacity(0.3) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12,
                    ),
                  ),
                ),
                child: _buildComposer(context, notes, isDark, isCentered: false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, ChatMessage msg) {
    final theme = Theme.of(context);
    final isUser = msg.role == 'user';
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : (isDark ? AppColors.surface : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: isUser ? Colors.white : (isDark ? AppColors.text : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const TypingIndicatorWidget(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, List<Note> notes, bool isDark) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    final greeting = _getGreeting(profile.name, l10n);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              greeting,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.whatCanHelp,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            _buildComposer(context, notes, isDark, isCentered: true),
          ],
        ),
      ),
    );
  }
}

// Bouncing dots typing indicator widget
class TypingIndicatorWidget extends StatefulWidget {
  const TypingIndicatorWidget({super.key});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final pos = (_controller.value - delay) % 1.0;
            // Generate bouncing scale factor
            double scale = 0.6;
            double opacity = 0.4;
            if (pos >= 0.0 && pos < 0.4) {
              final val = math.sin((pos / 0.4) * math.pi);
              scale = 0.6 + (val * 0.4);
              opacity = 0.4 + (val * 0.6);
            }
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
