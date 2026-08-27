import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/admin/formcontroller/tutoriel_form_controller.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';

void main() {
  group('TutorielFormController Unit Tests', () {
    test('Initializes with default empty values when initialTutoriel is null', () {
      final container = ProviderContainer();
      final controller = container.read(tutorielFormControllerProvider(null));

      expect(controller.titreController.text, isEmpty);
      expect(controller.descriptionController.text, isEmpty);
      expect(controller.statut, equals(TutorielStatus.publie));
      expect(controller.videoSourceType, equals(VideoSourceType.url));
    });

    test('Initializes with existing tutoriel data for edit mode', () {
      final sampleTutoriel = Tutoriel(
        tutorielId: 'tut-123',
        categorieId: 'cat-abc',
        createurId: 'admin-1',
        titre: 'Apprendre à compter',
        description: 'Tutoriel interactif avec des cubes',
        videoUrl: 'https://www.youtube.com/watch?v=sample',
        miniatureUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        duree: 330, // 5m 30s
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
      expect(controller.dureeController.text, equals('05:30'));
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
  });
}
