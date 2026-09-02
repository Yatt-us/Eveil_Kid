import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avis_model.dart';
import '../repository/avis_repository.dart';

final avisRepositoryProvider = Provider<AvisRepository>((ref) {
  return AvisRepository();
});

/// Stream en temps réel des avis d'un jouet
final avisJouetStreamProvider =
    StreamProvider.family<List<AvisModel>, String>((ref, jouetId) {
  final repo = ref.watch(avisRepositoryProvider);
  return repo.streamAvis(jouetId);
});

/// FutureProvider des avis d'un jouet
final avisJouetProvider =
    FutureProvider.family<List<AvisModel>, String>((ref, jouetId) async {
  final repo = ref.watch(avisRepositoryProvider);
  return repo.recupererAvis(jouetId);
});
