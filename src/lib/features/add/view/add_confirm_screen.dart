import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/models/pairing_data.dart';

/// Écran de confirmation pour ajouter un contact
class AddConfirmScreen extends ConsumerStatefulWidget {
  const AddConfirmScreen({super.key});

  @override
  ConsumerState<AddConfirmScreen> createState() => _AddConfirmScreenState();
}

class _AddConfirmScreenState extends ConsumerState<AddConfirmScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(addUserNotifierProvider.notifier).confirmAndSaveContact(
        _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Retour à l'écran principal
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairingState = ref.watch(addUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE6D5F5),
      appBar: AppBar(
        title: const Text('Confirmer l\'ajout'),
        backgroundColor: const Color(0xFFE6D5F5),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 60,
                  color: Color(0xFF6B4FA0),
                ),
              ),
              const SizedBox(height: 30),

              // État du pairing
              if (pairingState.status == PairingStatus.completed)
                const Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.green,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pairing réussi !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else if (pairingState.status == PairingStatus.finalized)
                const Column(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 60,
                      color: Colors.green,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Connexion établie !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else if (pairingState.status == PairingStatus.waiting)
                const Column(
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF6B4FA0),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'En attente de finalisation...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else if (pairingState.status == PairingStatus.error)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pairingState.errorMessage ?? 'Erreur inconnue',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Informations sur le partenaire
              if (pairingState.partnerData != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations du contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B4FA0),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.key, size: 20, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Code: ${pairingState.partnerData!.relationCode.substring(0, 8)}...',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.lock, size: 20, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Clé publique reçue',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              // Champ de saisie du nom
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nom du contact',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF6B4FA0)),
                ),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 30),

              // Bouton "Ajouter cette personne"
              ElevatedButton(
                onPressed: _isSaving ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4C5E8),
                  foregroundColor: const Color(0xFF6B4FA0),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6B4FA0),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text(
                            'Ajouter cette personne',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving
            ? null
            : () {
                ref.read(addUserNotifierProvider.notifier).cancel();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
        backgroundColor: const Color(0xFF6B4FA0),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


