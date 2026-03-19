import 'package:flutter/material.dart';

@immutable
class User {
  final String firstName, lastName; // prénom et nom

  const User({required this.firstName, required this.lastName});

  User copyWith({String? firstName, lastName}) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}
