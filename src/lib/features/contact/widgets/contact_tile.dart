import 'package:flutter/material.dart';
import 'package:altoproject/core/models/contact.dart';
import '../../message/view/message_page.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE6D5F5),
        child: Text(
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Color(0xFF6B4FA0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Code: ${contact.relationCode.length > 8 ? contact.relationCode.substring(0, 8) : contact.relationCode}…',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessagePage(contact: contact),
          ),
        );
      },
    );
  }
}
