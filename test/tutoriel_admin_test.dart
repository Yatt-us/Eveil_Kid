import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/admin/formcontroller/tutoriel_form_controller.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/utils/duration_utils.dart';

void main() {
  group('TutorielFormController Unit Tests', () {
    test('Initializes with default empty values when initialTutoriel is null', () {
      final container = ProviderContainer();
      final controller = container.read(tutorielFormControllerProvider(null));

      expect(controller.titreController.text, isEmpty);
      expect(controller.descriptionController.text, isEmpty);
      expect(controller.statut, equals(TutorielStatus.publie));
    });

    test('Initializes with existing tutoriel data for edit mode', () {
      final sampleTutoriel = Tutoriel(
        tutorielId: 'tut-123',
        categorieId: 'cat-abc',
        createurId: 'admin-1',
        titre: 'Apprendre à compter',
        description: 'Tutoriel interactif avec des cubes',
        videoUrl: 'https://res.cloudinary.com/dcaoahlor/video/upload/v123456/tutoriels/videos/sample.mp4',
        miniatureUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        ageMinimum: 4,
        ageMaximum: 7,
        statut: TutorielStatus.publie,
        jouetsSuggeres: ['jouet-1', 'jouet-2'],
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );

      final container = ProviderContainer();
      final controller = container.read(tutorielFormControllerProvider(sampleTutoriel));

      expect(controller.titreController.text, equals('Apprendre à compter'));
      expect(controller.descriptionController.text, equals('Tutoriel interactif avec des cubes'));
      expect(controller.selectedCategorieId, equals('cat-abc'));
      expect(controller.selectedJouetsIds, containsAll(['jouet-1', 'jouet-2']));
      expect(controller.imageUrl, equals('https://res.cloudinary.com/demo/image/upload/sample.jpg'));
    });

    test('Validation fails when required fields are missing', () {
      final container = ProviderContainer();
      final controller = container.read(tutorielFormControllerProvider(null));

      final isValid = controller.validateForm();
      expect(isValid, isFalse);
      expect(controller.titreError, isNotNull);
      expect(controller.descriptionError, isNotNull);
    });

    test('Toggle jouet adds and removes correctly', () {
      final container = ProviderContainer();
      final controller = container.read(tutorielFormControllerProvider(null));

      controller.toggleJouet('jouet-42');
      expect(controller.selectedJouetsIds, contains('jouet-42'));

      controller.toggleJouet('jouet-42');
      expect(controller.selectedJouetsIds, isNot(contains('jouet-42')));
    });

    test('formatDurationSeconds formats time strings correctly', () {
      expect(formatDurationSeconds(0), equals('00:00'));
      expect(formatDurationSeconds(45), equals('00:45'));
      expect(formatDurationSeconds(125), equals('02:05'));
      expect(formatDurationSeconds(3665), equals('01:01:05'));
    });

    test('Tutoriel serializes duree to Firestore and formats duration', () {
      final tut = Tutoriel(
        categorieId: 'cat-1',
        createurId: 'admin',
        titre: 'Tuto test',
        description: 'Description longue',
        videoUrl: 'https://res.cloudinary.com/demo/video/upload/test.mp4',
        miniatureUrl: 'https://res.cloudinary.com/demo/image/upload/test.jpg',
        duree: 135,
        ageMinimum: 3,
        ageMaximum: 6,
        dateCreation: DateTime(2026, 1, 1),
        dateModification: DateTime(2026, 1, 1),
      );

      final firestoreMap = tut.toFirestore();
      expect(firestoreMap['duree'], equals(135));
      expect(tut.dureeFormatted, equals('02:15'));
    });
  });
}
