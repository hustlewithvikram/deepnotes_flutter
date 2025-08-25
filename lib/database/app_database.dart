import 'package:deepnotes_flutter/database/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton class to manage the local SQLite database
class AppDatabase {
  // Singleton instance
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  /// Get database instance, initialize if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      createdAt TEXT NOT NULL,
      isPinned INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  /// Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  /// Get all notes, ordered by newest first
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      orderBy: 'isPinned DESC, createdAt DESC', // pinned first
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }

  /// Update an existing note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note by id
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Close the database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
