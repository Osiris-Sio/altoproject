import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserNotifiers extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final prefs = await SharedPreferences.getInstance();

    final firstName = prefs.getString('user_firstName') ?? '';
    final lastName = prefs.getString('user_lastName') ?? '';

    return User(firstName: firstName, lastName: lastName);
  }

  // Fonction pour setter et sauvegarder le prénom et le nom
  Future<void> setNames(String firstName, String lastName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = AsyncData(User(firstName: firstName, lastName: lastName));
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AsyncData(User(firstName: '', lastName: ''));
  }
}
