import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/repository/tutorielRpository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository Provider
final tutorielRepositoryProvider = Provider<TutorielRepository>((ref) {
  return TutorielRepository();
});


/// Provider pour récupérer la liste des tutoriels
final tutorielsProvider = FutureProvider<List<Tutoriel>>((ref) async {
  final repository = ref.read(tutorielRepositoryProvider);

  return repository.getTutoriels();
});

/// Provider pour récupérer un tutoriel par son ID
final tutorielByIdProvider =
    FutureProvider.family<Tutoriel?, String>((ref, tutorielId) async {
  final repository = ref.read(tutorielRepositoryProvider);

  return repository.getTutorielById(tutorielId);
});



final adminTutorielsProvider = FutureProvider<List<Tutoriel>>((ref) async {
  final repository = ref.read(tutorielRepositoryProvider);
  return repository.getAllTutorielsForAdmin();
});



class TutorielNotifier extends AsyncNotifier<Tutoriel?> {
  late final TutorielRepository _repository;

  @override
  Future<Tutoriel?> build() async {
    _repository = ref.read(tutorielRepositoryProvider);
    return null;
  }

  Future<void> deleteTutoriel(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTutoriel(id);
      state = const AsyncValue.data(null);
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final tutorielNotifierProvider = AsyncNotifierProvider<TutorielNotifier, Tutoriel?>(() {
  return TutorielNotifier();
});