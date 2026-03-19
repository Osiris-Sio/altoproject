import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.stars_outlined), // L'étoile à gauche
      title: Text(contact.name),
      trailing: const Wrap(
        spacing: 12,
        children: [
          Icon(Icons.comment), // Symbole Message
          Icon(Icons.chevron_right), // Flèche
        ],
      ),
      onTap: () {
        print("Aller vers la discussion avec ${contact.name}");
      },
    );
  }
}