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

final tutorielsRechercheProvider = FutureProvider.family<List<Tutoriel>, String>(
  (ref, query) async {
    final repository = ref.read(tutorielRepositoryProvider);
    return repository.searchTutoriels(query);
  },
);