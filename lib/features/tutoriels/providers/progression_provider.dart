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

  /// Sauvegarde la position de lecture.
  /// [termine] doit être passé par l'appelant (issu de VideoPlayerController.value).
  Future<void> saveProgression({
    required String tutorielId,
    required num position,
    bool termine = false,
  }) async {
    final progression = Progression(
      tutorielId: tutorielId,
      position: position,
      termine: termine,
      dateDerniereLecture: DateTime.now(),
    );

    await _repository.saveProgression(progression);
  }
}
