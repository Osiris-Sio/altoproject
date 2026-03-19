import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/features/add/models/contact.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/view/add_screen.dart';
import 'package:altoproject/features/add/view/scan_pairing_screen.dart';
import 'package:altoproject/features/add/view/show_qr_screen.dart';

// Exemple d'utilisation de la feature Add dans votre application

/// Exemple 1 : Navigation simple vers l'écran d'ajout
class ExampleUsage1 extends StatelessWidget {
  const ExampleUsage1({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigation vers l'écran d'ajout
        Navigator.pushNamed(context, '/add');
      },
      child: const Text('Ajouter un contact'),
    );
  }
}

/// Exemple 2 : Bouton d'ajout avec callback
class ExampleUsage2 extends ConsumerWidget {
  const ExampleUsage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        // Navigation et attente du résultat
        final result = await Navigator.pushNamed(context, '/add');

        if (result == true && context.mounted) {
          // Contact ajouté avec succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact ajouté avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: const Icon(Icons.person_add),
    );
  }
}

/// Exemple 3 : Accès direct à la liste des contacts
class ExampleUsage3 extends ConsumerWidget {
  const ExampleUsage3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbService = ref.watch(databaseServiceProvider);

    return FutureBuilder<List<Contact>>(
      future: dbService.getAllContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        final contacts = snapshot.data ?? <Contact>[];

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(contact.name),
              subtitle: Text('Ajouté le ${contact.createdAt.day}/${contact.createdAt.month}'),
            );
          },
        );
      },
    );
  }
}

/// Exemple 4 : Widget personnalisé pour l'ajout de contact
class CustomAddContactButton extends ConsumerWidget {
  final VoidCallback? onContactAdded;

  const CustomAddContactButton({
    super.key,
    this.onContactAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4FA0), Color(0xFF9B7FC5)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');

          if (result == true) {
            onContactAdded?.call();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 15,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 10),
            Text('Scanner un contact'),
          ],
        ),
      ),
    );
  }
}

/// Exemple 5 : Configuration des routes
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/add':
        return MaterialPageRoute(
          builder: (_) => const AddScreen(),
        );

      case '/add/scan':
        return MaterialPageRoute(
          builder: (_) => const ScanPairingScreen(),
        );

      case '/add/show-qr':
        return MaterialPageRoute(
          builder: (_) => const ShowQrScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(child: Text('Page non trouvée')),
          ),
        );
    }
  }
}

/// Exemple 6 : Utilisation dans le main.dart
class MyAppExample extends StatelessWidget {
  const MyAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Alto',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B4FA0),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
        home: const HomePagePlaceholder(),
      ),
    );
  }
}

/// Placeholder pour la HomePage (à remplacer par votre vraie HomePage)
class HomePagePlaceholder extends StatelessWidget {
  const HomePagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alto')),
      body: const Center(child: Text('Home Page')),
    );
  }
}

