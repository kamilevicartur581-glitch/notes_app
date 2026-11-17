import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note_dao.dart';       // было: 'dao/note_dao.dart'

class NoteDatabase {
  NoteDatabase._();
  static final NoteDatabase instance = NoteDatabase._();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'note_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<NoteDao> get noteDao async => NoteDao(await database);
}