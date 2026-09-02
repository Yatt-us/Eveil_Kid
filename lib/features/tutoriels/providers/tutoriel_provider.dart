import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/repository/tutoriel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorielRepositoryProvider = Provider<TutorielRepository>((ref) {
  return TutorielRepository();
});

final tutorielsProvider = FutureProvider<List<Tutoriel>>((ref) async {
  final repository = ref.read(tutorielRepositoryProvider);
  return repository.getTutoriels();
});

final tutorielByIdProvider = FutureProvider.family<Tutoriel?, String>(
  (ref, tutorielId) async {
    final repository = ref.read(tutorielRepositoryProvider);
    return repository.getTutorielById(tutorielId);
  },
);

final tutorielStreamByIdProvider = StreamProvider.family<Tutoriel?, String>(
  (ref, tutorielId) {
    final repository = ref.read(tutorielRepositoryProvider);
    return repository.streamTutorielById(tutorielId);
  },
);

final tutorielsRechercheProvider = FutureProvider.family<List<Tutoriel>, String>(
  (ref, query) async {
    final repository = ref.read(tutorielRepositoryProvider);
    return repository.searchTutoriels(query);
  },
);

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