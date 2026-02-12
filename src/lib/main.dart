import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/profile/view/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...profileFeatureProviders,
      ],
      child: MaterialApp(
        title: 'Alto - QR Code Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProfileScreen(),
      ),
    );
  }
}
