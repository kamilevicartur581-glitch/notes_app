import 'note_dao.dart';       // было: '../data/local/dao/note_dao.dart'
import 'note.dart';           // было: '../data/local/entity/note.dart'

class NoteRepository {
  final NoteDao _dao;
  NoteRepository(this._dao);

  Future<List<Note>> getAllNotes() => _dao.getAllNotes();
  Future<List<Note>> searchNotes(String q) => _dao.searchNotes(q);
  Future<void> insert(Note note) async => _dao.insert(note);
  Future<void> delete(Note note) async => _dao.delete(note);
}