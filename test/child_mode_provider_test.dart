import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChildModeProvider & Persistence Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state: starts with inactive child mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(childModeProvider);
      expect(state.isChildModeActive, isFalse);
      expect(state.activeChildId, isNull);
    });

    test('enterChildMode() activates child mode and persists in SharedPreferences',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final enfant = EnfantModel(
        enfantId: 'enfant_123',
        utilisateurId: 'parent_abc',
        nom: 'Leo',
        genre: 'Garçon',
        dateNaissance: DateTime(2021, 1, 1),
        souhait: [],
        resultatsActivite: [],
        codeSecuriteHash: '',
        estActif: true,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );

      await container.read(childModeProvider.notifier).enterChildMode(
            childId: 'enfant_123',
            child: enfant,
          );

      final state = container.read(childModeProvider);
      expect(state.isChildModeActive, isTrue);
      expect(state.activeChildId, equals('enfant_123'));
      expect(state.activeChild?.nom, equals('Leo'));

      // Vérification dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('child_mode_is_active'), isTrue);
      expect(prefs.getString('child_mode_active_child_id'), equals('enfant_123'));
    });

    test('exitChildMode() deactivates child mode and cleans SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        'child_mode_is_active': true,
        'child_mode_active_child_id': 'enfant_999',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // On laisse le notifier charger l'état initial
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await container.read(childModeProvider.notifier).exitChildMode();

      final state = container.read(childModeProvider);
      expect(state.isChildModeActive, isFalse);
      expect(state.activeChildId, isNull);
      expect(state.activeChild, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('child_mode_is_active'), isFalse);
      expect(prefs.getString('child_mode_active_child_id'), isNull);
    });

    test('switchChild() switches active child and updates persistence', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final enfantA = EnfantModel(
        enfantId: 'enfant_A',
        utilisateurId: 'parent_1',
        nom: 'Alice',
        genre: 'Fille',
        dateNaissance: DateTime(2022, 2, 2),
        souhait: [],
        resultatsActivite: [],
        codeSecuriteHash: '',
        estActif: true,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );

      final enfantB = EnfantModel(
        enfantId: 'enfant_B',
        utilisateurId: 'parent_1',
        nom: 'Bob',
        genre: 'Garçon',
        dateNaissance: DateTime(2020, 3, 3),
        souhait: [],
        resultatsActivite: [],
        codeSecuriteHash: '',
        estActif: true,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );

      await container.read(childModeProvider.notifier).enterChildMode(
            childId: 'enfant_A',
            child: enfantA,
          );

      await container.read(childModeProvider.notifier).switchChild(enfantB);

      final state = container.read(childModeProvider);
      expect(state.activeChildId, equals('enfant_B'));
      expect(state.activeChild?.nom, equals('Bob'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('child_mode_active_child_id'), equals('enfant_B'));
    });
  });
}
