import 'package:altoproject/features/creating/providers/user_provider.dart';
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

  void _onConfirmPressed() {
    if (_firstNameCtrl.text.isNotEmpty && _lastNameCtrl.text.isNotEmpty) {
      // On appelle le notifier pour sauvegarder
      ref.read(userProvider.notifier).setNames(
        _firstNameCtrl.text,
        _lastNameCtrl.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données sauvegardées !')),
      );
    }
  }

  /*
  void _adjustKg(double offset) {
    double current = double.tryParse(_txtKgCtrl.text) ?? 0;
    _txtKgCtrl.text = (current + offset).toString();
  }

  void _adjustCm(double offset) {
    double current = double.tryParse(_txtCmCtrl.text) ?? 0;
    _txtCmCtrl.text = (current + offset).toString();
  }

  void _reset() {
    ref.read(bodyMetricsProvider.notifier).reset();
    final resetState = ref.read(bodyMetricsProvider);
    _txtKgCtrl.text = resetState.kg.toString();
    _txtCmCtrl.text = resetState.cm.toString();
  }
*/
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
                decoration: const InputDecoration(labelText: 'NOM de famille'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onConfirmPressed,
                child: const Text('Confirmer'),
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