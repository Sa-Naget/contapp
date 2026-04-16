import 'package:path/path.dart';
import '../models/contact.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> _openDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'contacts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, photoPath TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE contacts ADD COLUMN photoPath TEXT');
        }
      },
      version: 2,
    );
  }

  // Insert a new contact
  static Future<int> insertContact(Contact contact) async {
    final db = await _openDB();
    return await db.insert('contacts', contact.toMap());
  }

  // Get all contacts
  static Future<List<Contact>> getContacts() async {
    final db = await _openDB();
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  // Update an existing contact
  static Future<int> updateContact(Contact contact) async {
    final db = await _openDB();
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete a contact
  static Future<int> deleteContact(int id) async {
    final db = await _openDB();
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
