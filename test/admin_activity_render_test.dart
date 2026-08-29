import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/presentation/pages/admin/activites_liste.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final dummyActivities = [
    Activite(
      id: 'act_1',
      titre: 'Découverte des animaux',
      description: 'Une super activité de découverte',
      categorieId: 'cat_animaux',
      difficulte: 'facile',
      ageMinimum: 3,
      ageMaximum: 6,
      dureeEnMinutes: 10,
      points: 20,
      statut: PublicationStatus.publie,
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
    Activite(
      id: 'act_2',
      titre: 'Quiz des couleurs',
      description: 'Apprendre les couleurs',
      categorieId: 'cat_art',
      difficulte: 'moyen',
      ageMinimum: 4,
      ageMaximum: 7,
      dureeEnMinutes: 15,
      points: 30,
      statut: PublicationStatus.brouillon,
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
  ];

  final dummyCategories = [
    ActiviteCategorie(
      id: 'cat_animaux',
      nom: 'Animaux',
      description: 'Monde animal',
      icon: 'science',
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
    ActiviteCategorie(
      id: 'cat_art',
      nom: 'Arts',
      description: 'Créativité et dessin',
      icon: 'art_track',
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

  testWidgets('ActivitiesListScreen renders clean tabs without numbers, filter button and items on Mobile', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          adminActivitesProvider.overrideWith((ref) => Future.value(dummyActivities)),
          categoriesActivesProvider.overrideWith((ref) => Future.value(dummyCategories)),
        ],
        child: const MaterialApp(
          home: ActivitiesListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Vérification des onglets sans chiffres
    expect(find.widgetWithText(Tab, 'Toutes'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Publiées'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Brouillons'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Archivées'), findsOneWidget);

    // Vérification du bouton de filtre à côté de la recherche
    final filterIcon = find.byIcon(Icons.tune_rounded);
    expect(filterIcon, findsOneWidget);

    // Vérification de l'activité
    expect(find.text('Découverte des animaux'), findsOneWidget);

    // Ouverture et vérification du BottomSheet de filtres
    await tester.tap(filterIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Filtres des Activités'), findsOneWidget);
    expect(find.text('Catégorie d\'univers'), findsOneWidget);
    expect(find.text('Niveau de difficulté'), findsOneWidget);
    expect(find.text('Tranche d\'âge'), findsOneWidget);
  });

  testWidgets('ActivitiesListScreen renders responsively on Tablet and Desktop without overflow', (tester) async {
    for (final size in [
      const Size(768, 1024), // Tablet
      const Size(1200, 900), // Desktop
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
            adminActivitesProvider.overrideWith((ref) => Future.value(dummyActivities)),
            categoriesActivesProvider.overrideWith((ref) => Future.value(dummyCategories)),
          ],
          child: const MaterialApp(
            home: ActivitiesListScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.widgetWithText(Tab, 'Toutes'), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.text('Découverte des animaux'), findsOneWidget);
    }
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
