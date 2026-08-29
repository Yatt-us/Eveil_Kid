import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/presentation/pages/add_question_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/edit_question_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/question_detail_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/questions_list_screen.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:eveilkid/features/questions/repository/question_repository.dart';

class FakeQuestionRepository extends QuestionRepository {
  List<Question> questions;
  Question? lastCreatedQuestion;
  Question? lastUpdatedQuestion;
  String? lastArchivedQuestionId;

  FakeQuestionRepository(this.questions);

  @override
  Future<List<Question>> getQuestionsByActivite(String activiteId) async {
    return questions.where((q) => !q.estArchive).toList();
  }

  @override
  Future<Question?> getQuestionById(String activiteId, String questionId) async {
    return questions.firstWhere((q) => q.id == questionId);
  }

  @override
  Future<Question> createQuestion(String activiteId, Question question) async {
    lastCreatedQuestion = question.copyWith(id: 'new_q_id');
    questions.add(lastCreatedQuestion!);
    return lastCreatedQuestion!;
  }

  @override
  Future<Question> updateQuestion(String activiteId, Question question) async {
    lastUpdatedQuestion = question;
    final idx = questions.indexWhere((q) => q.id == question.id);
    if (idx != -1) {
      questions[idx] = question;
    }
    return question;
  }

  @override
  Future<void> archiveQuestion(String activiteId, String questionId) async {
    lastArchivedQuestionId = questionId;
    questions.removeWhere((q) => q.id == questionId);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final adminUser = Utilisateur(
    utilisateurId: 'admin_1',
    role: UserRole.admin,
    email: 'admin@eveilkid.com',
    nom: 'Admin Test',
    estActif: true,
  );

  final dummyActivity = Activite(
    id: 'act_100',
    titre: 'Découverte des Formes',
    description: 'Identifier les formes géométriques',
    categorieId: 'cat_maths',
    difficulte: 'facile',
    ageMinimum: 3,
    ageMaximum: 6,
    dureeEnMinutes: 10,
    points: 25,
    dateCreation: DateTime(2026, 1, 1),
    dateModification: DateTime(2026, 1, 1),
  );

  final dummyQuestions = [
    Question(
      id: 'q_1',
      activiteId: 'act_100',
      enonce: 'Quelle forme a 3 côtés ?',
      type: QuestionType.choixMultiple,
      options: const [
        OptionQuestion(id: 'opt_1', texte: 'Carré'),
        OptionQuestion(id: 'opt_2', texte: 'Triangle'),
        OptionQuestion(id: 'opt_3', texte: 'Cercle'),
      ],
      idReponseCorrecte: 'opt_2',
      points: 15,
      ordre: 0,
    ),
    Question(
      id: 'q_2',
      activiteId: 'act_100',
      enonce: 'Le soleil est-il rond ?',
      type: QuestionType.vraiFaux,
      options: const [
        OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
        OptionQuestion(id: 'opt_faux', texte: 'Faux'),
      ],
      idReponseCorrecte: 'opt_vrai',
      points: 10,
      ordre: 1,
    ),
  ];

  testWidgets('QuestionsListScreen renders question cards and handles deletion', (tester) async {
    final fakeRepo = FakeQuestionRepository(List.from(dummyQuestions));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activiteByIdProvider('act_100').overrideWith((ref) => Future.value(dummyActivity)),
          questionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: QuestionsListScreen(activityId: 'act_100'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Découverte des Formes'), findsOneWidget);
    expect(find.text('Quelle forme a 3 côtés ?'), findsOneWidget);
    expect(find.text('Le soleil est-il rond ?'), findsOneWidget);
    expect(find.text('15 pts'), findsOneWidget);

    // Supprimer la première question
    final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
    expect(deleteIcons, findsNWidgets(2));
    await tester.tap(deleteIcons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Supprimer la question'), findsOneWidget);
    final confirmDeleteButton = find.widgetWithText(ElevatedButton, 'Supprimer');
    await tester.tap(confirmDeleteButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.lastArchivedQuestionId, 'q_1');
  });

  testWidgets('QuestionDetailScreen displays full question information and correct response', (tester) async {
    final fakeRepo = FakeQuestionRepository(List.from(dummyQuestions));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activiteByIdProvider('act_100').overrideWith((ref) => Future.value(dummyActivity)),
          questionByIdProvider((activiteId: 'act_100', questionId: 'q_1')).overrideWith((ref) => Future.value(dummyQuestions.first)),
          questionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: QuestionDetailScreen(activityId: 'act_100', questionId: 'q_1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Quelle forme a 3 côtés ?'), findsOneWidget);
    expect(find.text('Choix multiple'), findsOneWidget);
    expect(find.text('15 étoiles ⭐'), findsOneWidget);
    expect(find.text('Triangle'), findsOneWidget);
    expect(find.text('Correcte'), findsOneWidget);
  });

  testWidgets('EditQuestionScreen pre-fills data and saves changes', (tester) async {
    final fakeRepo = FakeQuestionRepository(List.from(dummyQuestions));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activiteByIdProvider('act_100').overrideWith((ref) => Future.value(dummyActivity)),
          questionByIdProvider((activiteId: 'act_100', questionId: 'q_1')).overrideWith((ref) => Future.value(dummyQuestions.first)),
          questionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: EditQuestionScreen(activityId: 'act_100', questionId: 'q_1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Quelle forme a 3 côtés ?'), findsOneWidget);
    expect(find.text('Carré'), findsOneWidget);
    expect(find.text('Triangle'), findsOneWidget);

    // Modifier le texte de la question
    final questionField = find.widgetWithText(TextField, 'Quelle forme a 3 côtés ?');
    await tester.enterText(questionField, 'Quelle forme géométrique possède 3 sommets ?');
    await tester.pump();

    // Enregistrer
    final saveButton = find.text('Enregistrer les modifications');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.lastUpdatedQuestion, isNotNull);
    expect(fakeRepo.lastUpdatedQuestion?.enonce, 'Quelle forme géométrique possède 3 sommets ?');
  });

  testWidgets('AddQuestionScreen validates and creates a new question', (tester) async {
    final fakeRepo = FakeQuestionRepository(List.from(dummyQuestions));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
          activiteByIdProvider('act_100').overrideWith((ref) => Future.value(dummyActivity)),
          questionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: AddQuestionScreen(activityId: 'act_100', type: QuestionType.vraiFaux),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Remplir l'énoncé
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'Les chats ont-ils des moustaches ?');
    await tester.pump();

    // Sélectionner Vrai
    final vraiButton = find.text('Vrai');
    await tester.ensureVisible(vraiButton);
    await tester.tap(vraiButton);
    await tester.pump();

    // Enregistrer la question
    final saveButton = find.text('Enregistrer la question');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.lastCreatedQuestion, isNotNull);
    expect(fakeRepo.lastCreatedQuestion?.enonce, 'Les chats ont-ils des moustaches ?');
    expect(fakeRepo.lastCreatedQuestion?.idReponseCorrecte, 'opt_vrai');
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
