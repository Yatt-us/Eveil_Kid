import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/presentation/pages/admin/edit_activity_screen.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/activites/repository/admin/activity_repository.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';

class FakeActivityRepository extends ActivityRepository {
  Activite? updatedActivity;
  String? deletedActivityId;

  @override
  Future<Activite> updateActivite(Activite activite) async {
    updatedActivity = activite;
    return activite;
  }

  @override
  Future<void> deleteActivite(String id) async {
    deletedActivityId = id;
  }

  @override
  Future<List<Activite>> getAllActivitesForAdmin() async {
    return [];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final dummyActivity = Activite(
    id: 'act_test_123',
    titre: 'Peinture Magique',
    description: 'Une activité pour apprendre à mélanger les couleurs',
    categorieId: 'cat_art',
    difficulte: 'moyen',
    ageMinimum: 4,
    ageMaximum: 7,
    dureeEnMinutes: 20,
    points: 45,
    statut: PublicationStatus.publie,
    dateCreation: DateTime(2026, 1, 1),
    dateModification: DateTime(2026, 1, 1),
  );

  final dummyCategories = [
    ActiviteCategorie(
      id: 'cat_art',
      nom: 'Arts Plastiques',
      description: 'Créativité et dessin',
      icon: 'art_track',
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
    ActiviteCategorie(
      id: 'cat_sciences',
      nom: 'Sciences',
      description: 'Découvertes et expériences',
      icon: 'science',
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
  ];

  final adminUser = Utilisateur(
    utilisateurId: 'admin_1',
    role: UserRole.admin,
    email: 'admin@eveilkid.com',
    nom: 'Admin Test',
    estActif: true,
  );

  testWidgets('EditActivityScreen loads and pre-populates all existing data', (tester) async {
    final fakeRepo = FakeActivityRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activityRepositoryProvider.overrideWithValue(fakeRepo),
          categoriesActivesProvider.overrideWith((ref) => Future.value(dummyCategories)),
        ],
        child: MaterialApp(
          home: EditActivityScreen(activite: dummyActivity),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Vérification du pré-remplissage des champs texte
    expect(find.text('Peinture Magique'), findsOneWidget);
    expect(find.text('Une activité pour apprendre à mélanger les couleurs'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    // Vérification des sélecteurs (statut et catégories)
    expect(find.text('Publiée'), findsOneWidget);
    expect(find.text('Brouillon'), findsOneWidget);
    expect(find.text('Archivée'), findsOneWidget);
    expect(find.text('Enregistrer les modifications'), findsOneWidget);
  });

  testWidgets('EditActivityScreen allows updating title and saving successfully', (tester) async {
    final fakeRepo = FakeActivityRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activityRepositoryProvider.overrideWithValue(fakeRepo),
          categoriesActivesProvider.overrideWith((ref) => Future.value(dummyCategories)),
        ],
        child: MaterialApp(
          home: EditActivityScreen(activite: dummyActivity),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Modification du titre
    final titleField = find.widgetWithText(TextField, 'Peinture Magique');
    await tester.enterText(titleField, 'Peinture Magique 2.0');
    await tester.pump();

    // Changement de statut vers Brouillon
    final draftButton = find.text('Brouillon');
    await tester.ensureVisible(draftButton);
    await tester.tap(draftButton);
    await tester.pump();

    // Soumission du formulaire
    final saveButton = find.text('Enregistrer les modifications');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Vérification que le repository a reçu la mise à jour
    expect(fakeRepo.updatedActivity, isNotNull);
    expect(fakeRepo.updatedActivity?.titre, 'Peinture Magique 2.0');
    expect(fakeRepo.updatedActivity?.statut, PublicationStatus.brouillon);
    expect(fakeRepo.updatedActivity?.id, 'act_test_123');
  });

  testWidgets('EditActivityScreen triggers deletion dialog and deletes', (tester) async {
    final fakeRepo = FakeActivityRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activityRepositoryProvider.overrideWithValue(fakeRepo),
          categoriesActivesProvider.overrideWith((ref) => Future.value(dummyCategories)),
        ],
        child: MaterialApp(
          home: EditActivityScreen(activite: dummyActivity),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Appui sur l'icône de suppression
    final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
    expect(deleteIcon, findsOneWidget);
    await tester.tap(deleteIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Modal de confirmation
    expect(find.text('Supprimer l\'activité'), findsOneWidget);
    final confirmDeleteButton = find.widgetWithText(ElevatedButton, 'Supprimer');
    await tester.tap(confirmDeleteButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.deletedActivityId, 'act_test_123');
  });
}

class MockAuthNotifier extends AuthNotifier {
  final Utilisateur _user;
  MockAuthNotifier(this._user);

  @override
  AuthState build() {
    return AuthState(
      utilisateur: _user,
      isInitialized: true,
      isEmailVerified: true,
    );
  }
}
