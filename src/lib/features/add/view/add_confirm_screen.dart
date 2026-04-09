import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/models/pairing_data.dart';
import 'package:altoproject/features/contact/providers/contacts_provider.dart';

/// Écran de confirmation pour nommer et sauvegarder un nouveau contact
class AddConfirmScreen extends ConsumerStatefulWidget {
  const AddConfirmScreen({super.key});

  @override
  ConsumerState<AddConfirmScreen> createState() => _AddConfirmScreenState();
}

class _AddConfirmScreenState extends ConsumerState<AddConfirmScreen> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Sauvegarde ──────────────────────────────────────────────────────────────

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom pour ce contact.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(addUserNotifierProvider.notifier)
          .confirmAndSaveContact(name);

      // Rafraîchir la liste de contacts
      await ref.read(contactsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contact ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Retour au MainScaffold
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pairingState = ref.watch(addUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE6F5),
      appBar: AppBar(
        title: const Text('Confirmer l\'ajout'),
        backgroundColor: const Color(0xFFEDE6F5),
        elevation: 0,
        foregroundColor: const Color(0xFF2D1B4E),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Avatar ────────────────────────────────────────────────────
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    size: 52, color: Color(0xFF6B4FA0)),
              ),
              const SizedBox(height: 24),

              // ── État du pairing ───────────────────────────────────────────
              _buildStatusWidget(pairingState),
              const SizedBox(height: 24),

              // ── Champ nom (visible uniquement si pairing OK) ──────────────
              if (pairingState.status == PairingStatus.completed ||
                  pairingState.status == PairingStatus.finalized) ...[
                _buildPartnerInfo(pairingState),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Nom du contact',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person,
                        color: Color(0xFF6B4FA0)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4FA0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFAA90CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_outlined),
                              SizedBox(width: 10),
                              Text('Ajouter ce contact',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // Bouton retour / annuler
      floatingActionButton: _isSaving
          ? null
          : FloatingActionButton(
              onPressed: () {
                ref.read(addUserNotifierProvider.notifier).cancel();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              backgroundColor: const Color(0xFF6B4FA0),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Widget état du pairing ──────────────────────────────────────────────────

  Widget _buildStatusWidget(PairingState state) {
    switch (state.status) {
      case PairingStatus.waiting:
        return const Column(children: [
          CircularProgressIndicator(color: Color(0xFF6B4FA0)),
          SizedBox(height: 14),
          Text('Connexion en cours…',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B4FA0))),
        ]);

      case PairingStatus.completed:
        return const _StatusBadge(
          icon: Icons.check_circle_outline,
          color: Colors.green,
          text: 'Pairing réussi !',
        );

      case PairingStatus.finalized:
        return const _StatusBadge(
          icon: Icons.verified_outlined,
          color: Colors.green,
          text: 'Connexion établie !',
        );

      case PairingStatus.timeout:
        return Column(children: [
          const _StatusBadge(
            icon: Icons.timer_off_outlined,
            color: Colors.orange,
            text: 'Délai expiré',
          ),
          const SizedBox(height: 10),
          const Text(
            'Le délai de 2 minutes s\'est écoulé.\nRetournez en arrière et réessayez.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ]);

      case PairingStatus.error:
        return Column(children: [
          const _StatusBadge(
            icon: Icons.error_outline,
            color: Colors.red,
            text: 'Erreur',
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Une erreur est survenue.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ]);
    }
  }

  // ── Informations partenaire ─────────────────────────────────────────────────

  Widget _buildPartnerInfo(PairingState state) {
    if (state.partnerData == null) return const SizedBox.shrink();

    final code = state.partnerData!.relationCode;
    final shortCode =
        code.length > 8 ? '${code.substring(0, 8)}…' : code;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du contact',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B4FA0),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.key, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Code : $shortCode',
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87)),
          ]),
          const SizedBox(height: 6),
          Row(children: const [
            Icon(Icons.lock_outline, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text('Clé publique reçue ✓',
                style: TextStyle(fontSize: 13, color: Colors.black87)),
          ]),
        ],
      ),
    );
  }
}

// ── Widget badge statut ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 56, color: color),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
