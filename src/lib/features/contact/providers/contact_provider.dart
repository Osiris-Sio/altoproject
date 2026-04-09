import 'package:flutter/material.dart';
import '../models/contact.dart';

/// Provider de contacts — données de démonstration.
/// Sera remplacé à l'étape 5 par un provider basé sur DatabaseService.
class ContactProvider extends ChangeNotifier {
  final List<Contact> _contacts = [
    Contact(
      id: '1',
      name: 'Thomas Bernard',
      relationCode: 'demo-relation-1',
      myRelationCode: 'my-demo-relation-1',
      publicKey: '',
      createdAt: DateTime(2025, 1, 1),
    ),
    Contact(
      id: '2',
      name: 'Léa Petit',
      relationCode: 'demo-relation-2',
      myRelationCode: 'my-demo-relation-2',
      publicKey: '',
      createdAt: DateTime(2025, 1, 2),
    ),
    Contact(
      id: '3',
      name: 'Lucas Morel',
      relationCode: 'demo-relation-3',
      myRelationCode: 'my-demo-relation-3',
      publicKey: '',
      createdAt: DateTime(2025, 1, 3),
    ),
    Contact(
      id: '4',
      name: 'Emma Lefebvre',
      relationCode: 'demo-relation-4',
      myRelationCode: 'my-demo-relation-4',
      publicKey: '',
      createdAt: DateTime(2025, 1, 4),
    ),
    Contact(
      id: '5',
      name: 'Hugo Cigare',
      relationCode: 'demo-relation-5',
      myRelationCode: 'my-demo-relation-5',
      publicKey: '',
      createdAt: DateTime(2025, 1, 5),
    ),
    Contact(
      id: '6',
      name: 'Alice Roux',
      relationCode: 'demo-relation-6',
      myRelationCode: 'my-demo-relation-6',
      publicKey: '',
      createdAt: DateTime(2025, 1, 6),
    ),
  ];

  List<Contact> get contacts => _contacts;
}