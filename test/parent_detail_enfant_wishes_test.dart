import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/enfant/providers/enfant_state.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/parents/presentation/pages/detail_enfant.dart';
import 'package:eveilkid/features/parents/providers/parent_provider.dart';

class MockParentNotifier extends ParentNotifier {
  final EnfantModel testEnfant;
  MockParentNotifier(this.testEnfant);

  @override
  Future<Utilisateur> build() async {
    return Utilisateur(
      utilisateurId: 'parent_1',
      role: UserRole.parent,
      nom: 'Parent Test',
      enfants: [testEnfant],
    );
  }
}

class MockEnfantNotifier extends EnfantNotifier {
  final EnfantModel testEnfant;
  MockEnfantNotifier(this.testEnfant);

  @override
  EnfantState build() {
    return EnfantState(
      enfants: [testEnfant],
      enfantSelectionne: testEnfant,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testJouet = Jouet(
    jouetId: 'toy_100',
    categorieId: 'cat_tech',
    createurId: 'admin_1',
    nom: 'Super Robot Éducatif',
    description: 'Un robot interactif pour apprendre à coder',
    nomCategorieDenormalise: 'Technologie',
    images: [],
    imagePrincipaleUrl: '',
    ageMinimum: 4,
    ageMaximum: 8,
    prix: 15000,
    devise: 'FCFA',
    stock: 5,
    stockDisponible: 5,
    noteMoyenneDenormalise: 4.9,
    nombreAvisDenormalise: 12,
    nbTutorielsAssocies: 0,
    estActif: true,
    estPopulaire: true,
    dateCreation: Timestamp.now(),
    dateModification: Timestamp.now(),
  );

  testWidgets('DetailEnfantPage shows empty state when enfant has no wishes',
      (tester) async {
    final enfant = EnfantModel(
      enfantId: 'enf_empty',
      utilisateurId: 'parent_1',
      nom: 'Sami',
      genre: 'Garçon',
      dateNaissance: DateTime(2020, 1, 1),
      souhait: [],
      resultatsActivite: [],
      codeSecuriteHash: '',
      estActif: true,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jouetsProvider.overrideWith((ref) async => [testJouet]),
          parentNotifierProvider.overrideWith(() => MockParentNotifier(enfant)),
          enfantNotifierProvider.overrideWith(() => MockEnfantNotifier(enfant)),
        ],
        child: MaterialApp(
          home: DetailEnfantPage(enfant: enfant),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify TabBar has "Souhaits" tab
    expect(find.text('Souhaits'), findsOneWidget);

    // Tap on "Souhaits" tab
    await tester.tap(find.text('Souhaits'));
    await tester.pumpAndSettle();

    // Empty state should be visible
    expect(find.text('Aucun souhait pour le moment'), findsOneWidget);
    expect(
      find.textContaining('Quand Sami sélectionne des jouets'),
      findsOneWidget,
    );
  });

  testWidgets(
      'DetailEnfantPage displays toy card with badge and add to cart when enfant has wishes',
      (tester) async {
    final enfantWithWish = EnfantModel(
      enfantId: 'enf_wish',
      utilisateurId: 'parent_1',
      nom: 'Maya',
      genre: 'Fille',
      dateNaissance: DateTime(2019, 6, 1),
      souhait: ['toy_100'],
      resultatsActivite: [],
      codeSecuriteHash: '',
      estActif: true,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jouetsProvider.overrideWith((ref) async => [testJouet]),
          parentNotifierProvider
              .overrideWith(() => MockParentNotifier(enfantWithWish)),
          enfantNotifierProvider
              .overrideWith(() => MockEnfantNotifier(enfantWithWish)),
        ],
        child: MaterialApp(
          home: DetailEnfantPage(enfant: enfantWithWish),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify badge 1 exists
    expect(find.text('1'), findsWidgets);

    // Tap on "Souhaits" tab
    await tester.tap(find.text('Souhaits'));
    await tester.pumpAndSettle();

    // Toy should be visible
    expect(find.text('Super Robot Éducatif'), findsOneWidget);
    expect(find.text('Souhait de Maya'), findsOneWidget);
    expect(find.text('15000 FCFA'), findsOneWidget);
    expect(find.text('Ajouter au panier pour Maya'), findsOneWidget);
  });
}
