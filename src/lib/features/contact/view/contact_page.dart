import 'package:flutter/material.dart';
import '../widgets/contact_tile.dart';
import '../providers/contact_provider.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contactList = ContactProvider().contacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alto Messages'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: ListView.separated(
        itemCount: contactList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ContactTile(contact: contactList[index]);
        },
      ),
    );
  }
}