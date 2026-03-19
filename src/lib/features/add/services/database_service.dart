import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

/// Service de base de données locale pour les contacts
class DatabaseService {
  static Database? _database;

  /// Récupère l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'alto.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Crée les tables de la base de données
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        relationCode TEXT NOT NULL UNIQUE,
        publicKey TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Insère un nouveau contact
  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les contacts
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  /// Récupère un contact par son ID
  Future<Contact?> getContactById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }

  /// Récupère un contact par son relationCode
  Future<Contact?> getContactByRelationCode(String relationCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'relationCode = ?',
      whereArgs: [relationCode],
    );

    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }

  /// Met à jour un contact
  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// Supprime un contact
  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

