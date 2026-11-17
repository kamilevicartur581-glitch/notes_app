import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/note.dart';
import 'package:notes_app/note_dao.dart';
import 'package:notes_app/note_repository.dart';
import 'package:notes_app/note_viewmodel.dart';

class _FakeNoteDao implements NoteDao {
  final List<Note> _store = [];

  @override
  Future<List<Note>> getAllNotes() async =>
      List.of(_store)..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  @override
  Future<int> insert(Note note) async {
    if (note.id == null) {
      final id = _store.length + 1;
      _store.add(note.copyWith(id: id));
      return id;
    } else {
      final i = _store.indexWhere((n) => n.id == note.id);
      if (i >= 0) _store[i] = note;
      return note.id!;
    }
  }

  @override
  Future<int> delete(Note note) async {
    _store.removeWhere((n) => n.id == note.id);
    return 1;
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final q = query.toLowerCase();
    return _store
        .where((n) =>
    n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q))
        .toList();
  }
}

void main() {
  group('NoteViewModel', () {
    late NoteViewModel vm;

    setUp(() {
      vm = NoteViewModel(NoteRepository(_FakeNoteDao()));
    });

    test('empty draft is invalid', () {
      vm.updateDraftTitle('   ');
      vm.updateDraftContent('');
      expect(vm.isDraftValid, isFalse);
    });

    test('saveDraft on empty sets error', () async {
      final ok = await vm.saveDraft();
      expect(ok, isFalse);
      expect(vm.errorMessage, isNotNull);
    });

    test('saveDraft inserts note and refreshes list', () async {
      vm.updateDraftTitle('Заголовок');
      vm.updateDraftContent('Текст');
      final ok = await vm.saveDraft();
      expect(ok, isTrue);
      await vm.loadNotes();
      expect(vm.notes.length, 1);
      expect(vm.notes.first.title, 'Заголовок');
    });

    test('search filters notes', () async {
      vm.updateDraftTitle('Kotlin');
      vm.updateDraftContent('about Android');
      await vm.saveDraft();

      vm.updateDraftTitle('Flutter');
      vm.updateDraftContent('about Dart');
      await vm.saveDraft();

      await vm.setSearchQuery('flutter');
      expect(vm.notes.length, 1);
      expect(vm.notes.first.title, 'Flutter');
    });
  });
}