// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altoproject/main.dart';

void main() {
  testWidgets('Alto smoke test — affiche UserPage quand pas de profil', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp(hasProfile: false)),
    );
    await tester.pump();

    // UserPage doit afficher le bouton de création de compte
    expect(find.text('Créer son compte'), findsOneWidget);
  });
}
