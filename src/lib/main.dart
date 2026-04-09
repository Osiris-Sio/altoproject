import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/theme_provider.dart';
import 'features/creating/view/user_page.dart';
import 'features/home/view/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasProfile = (prefs.getString('user_firstName') ?? '').isNotEmpty;

  runApp(
    ProviderScope(
      child: MyApp(hasProfile: hasProfile),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool hasProfile;
  const MyApp({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Alto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4FA0)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4FA0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: hasProfile ? const MainScaffold() : const UserPage(),
    );
  }
}
