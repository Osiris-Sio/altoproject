import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/models/contact.dart';
import 'package:altoproject/core/providers/app_providers.dart';

/// Provider Riverpod pour la liste de contacts.
/// Lit depuis DatabaseService (SharedPreferences).
/// Supporte le rafraîchissement via [ContactsNotifier.refresh].
final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(
  ContactsNotifier.new,
);

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() {
    return ref.read(databaseServiceProvider).getAllContacts();
  }

  /// Recharge la liste depuis le stockage (à appeler après un ajout/suppression).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(databaseServiceProvider).getAllContacts(),
    );
  }

  /// Supprime un contact et nettoie toutes ses données (clés RSA, messages locaux).
  Future<void> deleteContact(Contact contact) async {
    try {
      // 1. Supprimer les clés RSA de cette relation
      await ref.read(keyStorageProvider).deleteKeyPair(contact.myRelationCode);
      // 2. Supprimer l'historique local des messages
      await ref
          .read(messageStorageServiceProvider)
          .clearMessages(contact.id);
      // 3. Supprimer le contact de la base
      await ref.read(databaseServiceProvider).deleteContact(contact.id);
      // 4. Rafraîchir la liste
      await refresh();
    } catch (_) {
      // En cas d'échec partiel, on rafraîchit quand même
      await refresh();
      rethrow;
    }
  }
}
