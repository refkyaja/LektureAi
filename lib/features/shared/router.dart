import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/presentation/home_screen.dart';
import '../notes/presentation/notes_screen.dart';
import '../notes/presentation/note_editor_screen.dart';
import '../capture/presentation/capture_screen.dart';
import '../study/presentation/study_screen.dart';
import '../study/presentation/quiz_runner_screen.dart';
import '../study/presentation/flash_runner_screen.dart';
import '../chat/presentation/chat_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../settings/presentation/settings_screen.dart';
import 'shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/capture',
                builder: (context, state) => const CaptureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const StudyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full screen routes pushed on top of the tab shell
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notes/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final prefillTitle = state.uri.queryParameters['prefillTitle'];
          final prefillBody = state.uri.queryParameters['prefillBody'];
          final prefillTag = state.uri.queryParameters['prefillTag'];
          return NoteEditorScreen(
            noteId: id,
            prefillTitle: prefillTitle,
            prefillBody: prefillBody,
            prefillTag: prefillTag,
          );
        },
      ),
      GoRoute(
        path: '/study/quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final noteId = state.uri.queryParameters['noteId']!;
          final historyId = state.uri.queryParameters['historyId'];
          final count = int.tryParse(state.uri.queryParameters['count'] ?? '') ?? 5;
          final difficulty = state.uri.queryParameters['difficulty'] ?? 'medium';
          return QuizRunnerScreen(
            noteId: noteId,
            historyId: historyId,
            count: count,
            difficulty: difficulty,
          );
        },
      ),
      GoRoute(
        path: '/study/flashcard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final noteId = state.uri.queryParameters['noteId']!;
          final historyId = state.uri.queryParameters['historyId'];
          final count = int.tryParse(state.uri.queryParameters['count'] ?? '') ?? 10;
          return FlashRunnerScreen(
            noteId: noteId,
            historyId: historyId,
            count: count,
          );
        },
      ),
    ],
  );
});
