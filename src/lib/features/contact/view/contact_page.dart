import 'package:flutter/material.dart';
import '../widgets/contact_tile.dart';
import '../providers/contact_provider.dart';
import '../../add/view/add_screen.dart';
import '../../profile/view/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../profile/notifiers/profile_notifier.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: Utilisation simple de ContactProvider pour la démo
    final contactList = ContactProvider().contacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alto Messages'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // Navigation vers le profil (nécessite Provider)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => ProfileNotifier(),
                  child: const ProfileScreen(),
                ),
              ),
            );
          },
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ListView.separated(
        itemCount: contactList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ContactTile(contact: contactList[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        backgroundColor: const Color(0xFF6B4FA0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
