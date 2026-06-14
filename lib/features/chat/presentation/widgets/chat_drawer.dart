import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../../theme.dart';
import '../../../../features/shared/providers/global_providers.dart';

class ChatDrawer extends ConsumerStatefulWidget {
  const ChatDrawer({super.key});

  @override
  ConsumerState<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends ConsumerState<ChatDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(chatSessionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeSessionId = ref.watch(activeChatSessionIdProvider);
    final l10n = AppLocalizations.of(context)!;

    final filteredSessions = sessions.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Drawer(
      backgroundColor: isDark ? AppColors.background : const Color(0xFFF6F8FC),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                '${l10n.appTitle} AI',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            
            // New Chat Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(activeChatSessionIdProvider.notifier).state = null;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.newChat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),

            // Search Chat Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: l10n.searchChat,
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  fillColor: isDark ? AppColors.surface : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // History Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.history,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // History List
            Expanded(
              child: filteredSessions.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noChatsFound,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredSessions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final s = filteredSessions[index];
                        final isSelected = activeSessionId == s.id;
                        return InkWell(
                          onTap: () {
                            ref.read(activeChatSessionIdProvider.notifier).state = s.id;
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s.title.isNotEmpty ? s.title : l10n.untitledChat,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.text : (isDark ? AppColors.text.withOpacity(0.8) : Colors.black87),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                  onPressed: () {
                                    ref.read(chatSessionsProvider.notifier).deleteSession(s.id);
                                    if (activeSessionId == s.id) {
                                      ref.read(activeChatSessionIdProvider.notifier).state = null;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.chatDeleted)),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
