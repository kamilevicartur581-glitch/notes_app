import 'package:sqflite/sqflite.dart';
import 'note.dart';           // было: '../entity/note.dart'

class NoteDao {
  final Database _db;
  static const _table = 'notes_table';

  NoteDao(this._db);

  Future<List<Note>> getAllNotes() async {
    final result = await _db.query(_table, orderBy: 'timestamp DESC');
    return result.map(Note.fromMap).toList();
  }

  Future<int> insert(Note note) async {
    if (note.id != null) {
      // REPLACE-подобное поведение
      await _db.update(_table, note.toMap(),
          where: 'id = ?', whereArgs: [note.id]);
      return note.id!;
    }
    return await _db.insert(_table, note.toMap());
  }

  Future<int> delete(Note note) async {
    return await _db.delete(_table, where: 'id = ?', whereArgs: [note.id]);
  }

  Future<List<Note>> searchNotes(String query) async {
    final result = await _db.query(
      _table,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );
    return result.map(Note.fromMap).toList();
  }
}