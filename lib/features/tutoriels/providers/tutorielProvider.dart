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