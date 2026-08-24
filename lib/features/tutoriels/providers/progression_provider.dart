import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/progression.dart';
import '../repository/progression_repository.dart';

/// Repository Provider
final progressionRepositoryProvider =
    Provider<ProgressionRepository>((ref) {
  return ProgressionRepository();
});

/// Récupérer la progression d'un tutoriel
final progressionProvider =
    FutureProvider.family<Progression?, String>(
  (ref, tutorielId) async {
    final repository =
        ref.read(progressionRepositoryProvider);

    return repository.getProgression(tutorielId);
  },
);


final progressionControllerProvider =
    Provider<ProgressionController>((ref) {
  return ProgressionController(
    ref.read(progressionRepositoryProvider),
  );
});

class ProgressionController {
  final ProgressionRepository _repository;

  ProgressionController(this._repository);

  Future<void> saveProgression({
    required String tutorielId,
    required num position,
    required num duree,
  }) async {
    final termine = position >= duree;

    final progression = Progression(
      tutorielId: tutorielId,
      position: position,
      duree: duree,
      termine: termine,
      dateDerniereLecture: DateTime.now(),
    );

    await _repository.saveProgression(progression);
  }
}