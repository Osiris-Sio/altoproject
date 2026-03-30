import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

/// Service de stockage local pour les contacts.
/// Utilise shared_preferences pour une compatibilité web/mobile universelle
/// (remplace sqflite qui n'est pas supporté sur le web).
class DatabaseService {
  static const String _contactsKey = 'alto_contacts';

  /// Récupère tous les contacts depuis le stockage local.
  Future<List<Contact>> getAllContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contactsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Insère un contact (ou le remplace s'il existe déjà).
  Future<void> insertContact(Contact contact) async {
    final contacts = await getAllContacts();
    final index = contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      contacts[index] = contact;
    } else {
      contacts.add(contact);
    }
    await _save(contacts);
  }

  /// Récupère un contact par son ID.
  Future<Contact?> getContactById(String id) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Récupère un contact par son relationCode.
  Future<Contact?> getContactByRelationCode(String relationCode) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.relationCode == relationCode);
    } catch (_) {
      return null;
    }
  }

  /// Met à jour un contact existant.
  Future<void> updateContact(Contact contact) async {
    await insertContact(contact);
  }

  /// Supprime un contact par son ID.
  Future<void> deleteContact(String id) async {
    final contacts = await getAllContacts();
    contacts.removeWhere((c) => c.id == id);
    await _save(contacts);
  }

  /// No-op : aucune connexion à fermer avec shared_preferences.
  Future<void> close() async {}

  // ── Interne ──────────────────────────────────────────────────────────────

  Future<void> _save(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_contactsKey, json.encode(jsonList));
  }
}
