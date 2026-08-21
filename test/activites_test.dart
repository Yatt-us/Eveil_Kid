import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eveilkid/features/activites/enums/activite_enums.dart';
import 'package:eveilkid/features/activites/models/activite.dart';
import 'package:eveilkid/features/activites/models/activite_resultat.dart';
import 'package:eveilkid/features/activites/models/question.dart';
import 'package:eveilkid/features/activites/providers/activite_game_provider.dart';
import 'package:eveilkid/features/activites/providers/activites_provider.dart';
import 'package:eveilkid/features/activites/repository/activite_repository.dart';

class FakeActiviteRepository extends ActiviteRepository {
  FakeActiviteRepository() : super();

  @override
  Future<List<Activite>> getAllActivites({StatutPublication? statut}) async {
    return getFallbackActivities();
  }

  @override
  Future<void> saveResult(ActivityResult result) async {}

  @override
  Future<void> updateProgression(String activityId, double progression, StatutActivite statut) async {}
}

void main() {
  group('Activites Models Tests', () {
    test('Question et OptionQuestion fromMap et toMap', () {
      final json = {
        'id': 'q_test',
        'enonce': 'Combien font 2 + 2 ?',
        'idReponseCorrecte': 'opt_4',
        'typeAffichage': 'grille',
        'type': 'choix_multiple',
        'points': 15,
        'options': [
          {'id': 'opt_3', 'texte': '3'},
          {'id': 'opt_4', 'texte': '4'},
        ],
      };

      final question = Question.fromMap(json);

      expect(question.id, equals('q_test'));
      expect(question.enonce, equals('Combien font 2 + 2 ?'));
      expect(question.idReponseCorrecte, equals('opt_4'));
      expect(question.typeAffichage, equals(TypeAffichageQuestion.grille));
      expect(question.points, equals(15));
      expect(question.options.length, equals(2));
      expect(question.options[1].texte, equals('4'));

      final mapped = question.toMap();
      expect(mapped['id'], equals('q_test'));
      expect(mapped['idReponseCorrecte'], equals('opt_4'));
    });

    test('ActivityResult calcul de ratio et serialization', () {
      final result = ActivityResult(
        activityId: 'act_1',
        childId: 'enfant_1',
        score: 30,
        totalQuestions: 4,
        bonnesReponses: 3,
        reponses: {'q1': 'opt_a', 'q2': 'opt_b'},
        date: DateTime(2026, 8, 19),
      );

      expect(result.mauvaisesReponses, equals(1));
      expect(result.ratio, equals(0.75));

      final map = result.toMap();
      expect(map['activityId'], equals('act_1'));
      expect(map['score'], equals(30));

      final parsed = ActivityResult.fromMap(map);
      expect(parsed.activityId, equals('act_1'));
      expect(parsed.bonnesReponses, equals(3));
      expect(parsed.mauvaisesReponses, equals(1));
    });
  });

  group('Activites Riverpod Game Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          activiteRepositoryProvider.overrideWithValue(FakeActiviteRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Déroulement complet du gameplay Quiz avec score et validation', () {
      final testActivite = Activite(
        id: 'act_unit_test',
        titre: 'Test Calcul',
        description: 'Description test',
        totalQuestions: 2,
        dateCreation: DateTime(2026, 8, 19),
        dateModification: DateTime(2026, 8, 19),
        questions: [
          Question(
            id: 'q1',
            enonce: '1 + 1 ?',
            idReponseCorrecte: 'opt_2',
            options: [
              OptionQuestion(id: 'opt_1', texte: '1'),
              OptionQuestion(id: 'opt_2', texte: '2'),
            ],
          ),
          Question(
            id: 'q2',
            enonce: '2 + 2 ?',
            idReponseCorrecte: 'opt_4',
            options: [
              OptionQuestion(id: 'opt_3', texte: '3'),
              OptionQuestion(id: 'opt_4', texte: '4'),
            ],
          ),
        ],
      );

      final gameNotifier = container.read(activiteGameProvider.notifier);

      // 1. Démarrage de l'activité
      gameNotifier.demarrerActivite(testActivite, childId: 'enfant_test');
      var state = container.read(activiteGameProvider);

      expect(state.activiteEnCours?.id, equals('act_unit_test'));
      expect(state.indexQuestionActuelle, equals(0));
      expect(state.questionActuelle?.id, equals('q1'));
      expect(state.estQuizTermine, isFalse);

      // 2. Répondre correctement à Q1
      gameNotifier.selectionnerOption('opt_2');
      state = container.read(activiteGameProvider);
      expect(state.optionSelectionneeId, equals('opt_2'));

      final isFinishedQ1 = gameNotifier.validerReponse();
      expect(isFinishedQ1, isFalse);

      state = container.read(activiteGameProvider);
      expect(state.indexQuestionActuelle, equals(1));
      expect(state.questionActuelle?.id, equals('q2'));
      expect(state.reponsesJoueur['q1'], equals('opt_2'));

      // 3. Répondre incorrectement à Q2
      gameNotifier.selectionnerOption('opt_3');
      final isFinishedQ2 = gameNotifier.validerReponse();
      expect(isFinishedQ2, isTrue);

      state = container.read(activiteGameProvider);
      expect(state.estQuizTermine, isTrue);
      expect(state.nombreBonnesReponses, equals(1));
      expect(state.nombreMauvaisesReponses, equals(1));
      expect(state.pointsGagnes, equals(10));
      expect(state.scoreRatio, equals(0.5));
    });

    test('Filtrage par statut dans ActivitesNotifier', () {
      final notifier = container.read(activitesProvider.notifier);
      expect(container.read(activitesProvider).filtreStatut, equals(StatutActivite.toutes));

      notifier.changerFiltreStatut(StatutActivite.terminees);
      expect(container.read(activitesProvider).filtreStatut, equals(StatutActivite.terminees));

      notifier.changerFiltreStatut(StatutActivite.enCours);
      expect(container.read(activitesProvider).filtreStatut, equals(StatutActivite.enCours));
    });
  });
}
