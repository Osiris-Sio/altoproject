import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  final List<Contact> _contacts = [
    Contact(id: '1', name: 'Thomas Bernard'),
    Contact(id: '2', name: 'Léa Petit'),
    Contact(id: '3', name: 'Lucas Morel'),
    Contact(id: '4', name: 'Emma Lefebvre'),
    Contact(id: '5', name: 'Hugo Cigare'),
    Contact(id: '6', name: 'Alice Roux'),
  ];

  List<Contact> get contacts => _contacts;
}