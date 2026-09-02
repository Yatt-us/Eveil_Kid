import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppDialogs.showConfirmDialog renders full-width buttons and handles clicks',
      (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await AppDialogs.showConfirmDialog(
                  context: context,
                  title: 'Déconnexion',
                  message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
                  confirmText: 'Se déconnecter',
                  cancelText: 'Annuler',
                  isDanger: true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Ouvrir la boîte de dialogue
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Vérifier les éléments
    expect(find.text('Déconnexion'), findsOneWidget);
    expect(find.text('Êtes-vous sûr de vouloir vous déconnecter ?'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Cliquer sur Annuler
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
