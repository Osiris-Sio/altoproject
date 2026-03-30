import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/creating/view/user_page.dart';
import 'features/home/view/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Vérifier si l'utilisateur a déjà créé son profil
  final prefs = await SharedPreferences.getInstance();
  final hasProfile = (prefs.getString('user_firstName') ?? '').isNotEmpty;

  runApp(
    ProviderScope(
      child: MyApp(hasProfile: hasProfile),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasProfile;

  const MyApp({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4FA0)),
        useMaterial3: true,
      ),
      // Si profil existant → écran principal, sinon → création de profil
      home: hasProfile ? const MainScaffold() : const UserPage(),
    );
  }
}
