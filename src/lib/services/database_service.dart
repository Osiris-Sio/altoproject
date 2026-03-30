import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/contact.dart';

/// Stockage local des contacts via shared_preferences.
///
/// Compatible web, Android et iOS (contrairement à sqflite).
/// Les contacts sont sérialisés en JSON dans une liste.
class DatabaseService {
  static const String _contactsKey = 'alto_contacts';

  // ── Lecture ──────────────────────────────────────────────────────────────

  Future<List<Contact>> getAllContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contactsKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Contact?> getContactById(String id) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Contact?> getContactByRelationCode(String relationCode) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.relationCode == relationCode);
    } catch (_) {
      return null;
    }
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Insère ou remplace un contact (match sur l'id).
  Future<void> insertContact(Contact contact) async {
    final contacts = await getAllContacts();
    final idx = contacts.indexWhere((c) => c.id == contact.id);
    if (idx >= 0) {
      contacts[idx] = contact;
    } else {
      contacts.add(contact);
    }
    await _save(contacts);
  }

  Future<void> updateContact(Contact contact) => insertContact(contact);

  Future<void> deleteContact(String id) async {
    final contacts = await getAllContacts();
    contacts.removeWhere((c) => c.id == id);
    await _save(contacts);
  }

  /// Supprime tous les contacts (réinitialisation compte).
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contactsKey);
  }

  // ── Interne ──────────────────────────────────────────────────────────────

  Future<void> _save(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _contactsKey,
      jsonEncode(contacts.map((c) => c.toJson()).toList()),
    );
  }
}

