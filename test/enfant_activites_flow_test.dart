import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/activites/repository/admin/activity_repository.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/activites_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/questions_enfant_page.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:eveilkid/features/questions/repository/question_repository.dart';

class FakeActivityRepository extends ActivityRepository {
  final List<Activite> activitesList;
  FakeActivityRepository(this.activitesList);

  @override
  Future<List<Activite>> getAllActivites() async => activitesList;
}

class FakeQuestionRepository extends QuestionRepository {
  final Map<String, List<Question>> questionsMap;
  FakeQuestionRepository(this.questionsMap);

  @override
  Future<List<Question>> getQuestionsByActivite(String activiteId) async {
    return questionsMap[activiteId] ?? [];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final dummyEnfant = EnfantModel(
    enfantId: 'enf_1',
    utilisateurId: 'parent_1',
    nom: 'Lucas',
    dateNaissance: DateTime(2019, 5, 10),
    souhait: [],
    resultatsActivite: [
      {
        'activiteId': 'act_1',
        'activiteTitre': 'Le Safari des Animaux',
        'score': 2,
        'totalQuestions': 2,
        'pointsGagnes': 20,
        'termine': true,
      }
    ],
    codeSecuriteHash: '',
    estActif: true,
    genre: 'Garçon',
    dateCreation: DateTime(2026, 1, 1),
    dateModification: DateTime(2026, 1, 1),
  );

  final dummyCategories = [
    Categorie(
      categorieId: 'cat_animaux',
      nom: 'Animaux',
      nombreJouetsDenormalise: 5,
      nbTutoriels: 2,
      estActive: true,
      dateCreation: Timestamp.fromDate(DateTime(2026, 1, 1)),
      dateModification: Timestamp.fromDate(DateTime(2026, 1, 1)),
    ),
    Categorie(
      categorieId: 'cat_maths',
      nom: 'Mathématiques',
      nombreJouetsDenormalise: 3,
      nbTutoriels: 1,
      estActive: true,
      dateCreation: Timestamp.fromDate(DateTime(2026, 1, 1)),
      dateModification: Timestamp.fromDate(DateTime(2026, 1, 1)),
    ),
  ];

  final dummyActivities = [
    Activite(
      id: 'act_1',
      titre: 'Le Safari des Animaux',
      description: 'Découvre les cris et habitats des animaux.',
      categorieId: 'cat_animaux',
      difficulte: 'facile',
      ageMinimum: 3,
      ageMaximum: 6,
      dureeEnMinutes: 10,
      points: 20,
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
    Activite(
      id: 'act_2',
      titre: 'Calcul et Nombres',
      description: 'Apprends à compter jusqu’à 10.',
      categorieId: 'cat_maths',
      difficulte: 'moyen',
      ageMinimum: 4,
      ageMaximum: 7,
      dureeEnMinutes: 12,
      points: 25,
      dateCreation: DateTime(2026, 1, 1),
      dateModification: DateTime(2026, 1, 1),
    ),
  ];

  final dummyQuestions = [
    Question(
      id: 'q_1',
      activiteId: 'act_2',
      enonce: 'Combien font 2 plus 3 ?',
      type: QuestionType.choixMultiple,
      options: const [
        OptionQuestion(id: 'opt_1', texte: '4'),
        OptionQuestion(id: 'opt_2', texte: '5'),
        OptionQuestion(id: 'opt_3', texte: '6'),
      ],
      idReponseCorrecte: 'opt_2',
      points: 15,
    ),
    Question(
      id: 'q_2',
      activiteId: 'act_2',
      enonce: 'Le chiffre 8 vient après le 7.',
      type: QuestionType.vraiFaux,
      options: const [
        OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
        OptionQuestion(id: 'opt_faux', texte: 'Faux'),
      ],
      idReponseCorrecte: 'opt_vrai',
      points: 10,
    ),
  ];

  testWidgets('ActivitesEnfantPage displays database activities without emojis and filters correctly', (tester) async {
    final activityRepo = FakeActivityRepository(dummyActivities);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          childModeProvider.overrideWith(() => ChildModeNotifierMock(dummyEnfant)),
          activitesProvider.overrideWith((ref) => Future.value(dummyActivities)),
          categoriesProvider.overrideWith((ref) => Future.value(dummyCategories)),
          activityRepositoryProvider.overrideWithValue(activityRepo),
        ],
        child: const MaterialApp(
          home: ActivitesEnfantPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Vérifier les titres
    expect(find.text('Jeux et Activités'), findsOneWidget);
    expect(find.text('Le Safari des Animaux'), findsOneWidget);
    expect(find.text('Calcul et Nombres'), findsOneWidget);
    expect(find.text('+20 pts'), findsOneWidget);
    expect(find.text('+25 pts'), findsOneWidget);

    // Filtrer par catégorie "Mathématiques"
    final mathsFilter = find.text('Mathématiques').first;
    expect(mathsFilter, findsOneWidget);
    await tester.tap(mathsFilter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Calcul et Nombres'), findsOneWidget);
    expect(find.text('Le Safari des Animaux'), findsNothing);

    // Ouvrir la feuille de détails
    await tester.tap(find.text('Calcul et Nombres'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Commencer le défi'), findsOneWidget);
  });

  testWidgets('QuestionsEnfantPage plays quiz with database questions and completes successfully', (tester) async {
    final questionRepo = FakeQuestionRepository({'act_2': dummyQuestions});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          childModeProvider.overrideWith(() => ChildModeNotifierMock(dummyEnfant)),
          questionsByActiviteProvider('act_2').overrideWith((ref) => Future.value(dummyQuestions)),
          questionRepositoryProvider.overrideWithValue(questionRepo),
        ],
        child: MaterialApp(
          home: QuestionsEnfantPage(activite: dummyActivities[1]),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Combien font 2 plus 3 ?'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // Répondre à la 1ère question (bonne réponse: 5)
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    // 2ème question
    expect(find.text('Le chiffre 8 vient après le 7.'), findsOneWidget);
    await tester.tap(find.text('Vrai'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    // Dialogue de victoire
    expect(find.text('Défi Terminé !'), findsOneWidget);
    expect(find.text('Tu as obtenu 2 sur 2 bonnes réponses.'), findsOneWidget);
    expect(find.text('Terminer'), findsOneWidget);
  });
}

class ChildModeNotifierMock extends ChildModeNotifier {
  final EnfantModel mockEnfant;
  ChildModeNotifierMock(this.mockEnfant);

  @override
  ChildModeState build() {
    return ChildModeState(
      isChildModeActive: true,
      activeChildId: mockEnfant.enfantId,
      activeChild: mockEnfant,
      isInitialized: true,
    );
  }
}
