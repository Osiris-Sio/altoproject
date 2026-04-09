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
}

