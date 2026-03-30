import 'package:altoproject/features/creating/providers/user_provider.dart';
import 'package:altoproject/features/home/view/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late bool _isInitialized;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _isInitialized = false;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirmPressed() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    // Sauvegarder le profil
    await ref.read(userProvider.notifier).setNames(firstName, lastName);

    // Naviguer vers l'écran principal (remplacement complet de la pile)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le provider pour l'utilisateur :

    final userAsync = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Alto\nAlways together')),
      body: userAsync.when(
        // Quand la donnée est chargée (depuis SharedPreferences)
        data: (user) {
          // On remplit les champs une seule fois à la réception des données
          if (!_isInitialized) {
            _firstNameCtrl.text = user.firstName;
            _lastNameCtrl.text = user.lastName;
            _isInitialized = true;
          }

          return Column(
            children: [
              TextField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom de famille'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onConfirmPressed,
                child: const Text('Créer son compte'),
              ),
            ],
          );
        },
        // Pendant le chargement des SharedPreferences
        loading: () => const Center(child: CircularProgressIndicator()),
        // En cas d'erreur
        error: (err, stack) => Center(child: Text('Erreur : $err')),
      ),
    );
  }
}