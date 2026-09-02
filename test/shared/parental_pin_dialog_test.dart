import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/core/services/parental_pin_service.dart';
import 'package:eveilkid/shared/widgets/parental_pin_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestDialog({
    required ParentalPinMode mode,
    String? title,
    String? subtitle,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ParentalPinDialog(
            mode: mode,
            title: title,
            subtitle: subtitle,
          ),
        ),
      ),
    );
  }

  group('ParentalPinDialog UI & Flow Tests', () {
    testWidgets('Renders keypad digits and setup step indicator properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestDialog(mode: ParentalPinMode.setup),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du titre et sous-titre
      expect(find.text('Créer le code parental'), findsOneWidget);
      expect(
        find.text('Définissez 4 chiffres pour sécuriser l\'accès parent.'),
        findsOneWidget,
      );

      // Vérifier la présence des chiffres du pavé
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      // Vérifier les sous-titres de dialer
      expect(find.text('ABC'), findsOneWidget);
      expect(find.text('DEF'), findsOneWidget);
      expect(find.text('WXYZ'), findsOneWidget);
    });

    testWidgets('Setup mode: Entering first PIN and confirming matching PIN',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestDialog(mode: ParentalPinMode.setup),
      );
      await tester.pumpAndSettle();

      // Saisie de l'étape 1: "1234"
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Doit maintenant afficher l'étape 2 (Confirmation)
      expect(find.text('Confirmer le code'), findsOneWidget);
      expect(
        find.text('Saisissez à nouveau le code pour confirmer.'),
        findsOneWidget,
      );

      // Saisie de la confirmation: "1234"
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Le code doit être sauvegardé dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('parental_pin_code'), equals('1234'));
    });

    testWidgets('Setup mode: Mismatched PIN shows error banner and resets to step 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestDialog(mode: ParentalPinMode.setup),
      );
      await tester.pumpAndSettle();

      // Saisie étape 1: "1234"
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Saisie étape 2 différente: "1239"
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9'));
      await tester.pumpAndSettle();

      // Message d'erreur
      expect(
        find.text('Les codes ne correspondent pas. Recommencez.'),
        findsOneWidget,
      );
      // Retour à l'étape 1
      expect(find.text('Créer le code parental'), findsOneWidget);
    });

    testWidgets('Verify mode: Incorrect PIN increments failed attempts and displays error',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'parental_pin_code': '5678'});

      await tester.pumpWidget(
        buildTestDialog(mode: ParentalPinMode.verify),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contrôle Parental'), findsOneWidget);

      // Entrer un mauvais code "1111"
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(
        find.text('Code PIN incorrect (2 tentatives restantes).'),
        findsOneWidget,
      );
    });

    testWidgets('Backspace and Clear functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestDialog(mode: ParentalPinMode.setup),
      );
      await tester.pumpAndSettle();

      // Taper 2 chiffres
      await tester.tap(find.text('7'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      // Appui sur backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pumpAndSettle();

      // Appui sur clear all
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();
    });
  });
}
