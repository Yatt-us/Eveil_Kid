import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/parent/models/parent_model.dart';
import 'package:eveilkid/features/parent/repository/parent_repository.dart';
import 'package:eveilkid/features/parent/providers/parent_provider.dart';
import 'package:eveilkid/features/parent/presentation/pages/parent_main_scaffold.dart';

class MockParentRepository implements ParentRepository {
  final UtilisateurModel _mockUser = UtilisateurModel(
    utilisateurId: 'test_parent',
    nom: 'Aissata Traoré',
    email: 'aissata@example.com',
    enfants: [
      EnfantModel(
        enfantId: '1',
        utilisateurId: 'test_parent',
        nom: 'Nour',
        dateNaissance: DateTime(DateTime.now().year - 5, 1, 1),
      ),
      EnfantModel(
        enfantId: '2',
        utilisateurId: 'test_parent',
        nom: 'Ilyas',
        dateNaissance: DateTime(DateTime.now().year - 7, 1, 1),
      ),
    ],
  );

  @override
  Future<UtilisateurModel> fetchParentProfile(String utilisateurId) async => _mockUser;

  @override
  Stream<UtilisateurModel> watchParentProfile(String utilisateurId) => Stream.value(_mockUser);

  @override
  Future<UtilisateurModel> updateParentProfile(UtilisateurModel parent) async => parent;

  @override
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId) async => _mockUser.enfants;

  @override
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId) => Stream.value(_mockUser.enfants);

  @override
  Future<void> ajouterEnfant(EnfantModel enfant) async {}

  @override
  Future<void> modifierEnfant(EnfantModel enfant) async {}

  @override
  Future<void> supprimerEnfant(String enfantId, String utilisateurId) async {}
}

void main() {
  testWidgets('ParentMainScaffold renders navigation items with mock repository', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('test_parent'),
          parentRepositoryProvider.overrideWithValue(MockParentRepository()),
        ],
        child: const MaterialApp(
          home: ParentMainScaffold(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Jouets'), findsOneWidget);
    expect(find.text('Activités'), findsOneWidget);
    expect(find.text('Tutoriels'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Bonjour, Aissata Traoré'), findsOneWidget);
  });
}
