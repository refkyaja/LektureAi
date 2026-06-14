import 'package:flutter_test/flutter_test.dart';
import 'package:lekture_ai/features/notes/domain/note_model.dart';

void main() {
  group('Note Model Tests', () {
    test('toJson and fromJson should be symmetric', () {
      final note = Note(
        id: 'test-id-123',
        title: 'Study Flutter',
        body: 'Learn about Riverpod and GoRouter.',
        tag: 'Flutter',
        createdAt: 1623580000000,
        updatedAt: 1623580000000,
      );

      final json = note.toJson();
      final decodedNote = Note.fromJson(json);

      expect(decodedNote.id, note.id);
      expect(decodedNote.title, note.title);
      expect(decodedNote.body, note.body);
      expect(decodedNote.tag, note.tag);
      expect(decodedNote.createdAt, note.createdAt);
      expect(decodedNote.updatedAt, note.updatedAt);
    });

    test('copyWith should copy properties correctly', () {
      final note = Note(
        id: 'test-id-123',
        title: 'Study Flutter',
        body: 'Original content.',
        tag: 'Flutter',
        createdAt: 1623580000000,
        updatedAt: 1623580000000,
      );

      final updated = note.copyWith(
        title: 'New Title',
        body: 'Updated content.',
        tag: 'Study',
        updatedAt: 1623590000000,
      );

      expect(updated.id, note.id); // id should remain the same
      expect(updated.title, 'New Title');
      expect(updated.body, 'Updated content.');
      expect(updated.tag, 'Study');
      expect(updated.createdAt, note.createdAt); // createdAt should remain the same
      expect(updated.updatedAt, 1623590000000);
    });
  });
}
