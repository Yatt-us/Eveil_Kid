import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';

/// Provider qui récupère la durée (en secondes) d'une vidéo Cloudinary
/// directement via l'API metadata, sans télécharger la vidéo.
///
/// Utilisation :
///   final duration = await ref.watch(cloudinaryVideoDurationProvider(videoUrl).future);
///
/// Le résultat est automatiquement mis en cache par Riverpod tant que le
/// provider reste vivant. Retourne 0.0 si l'URL est vide ou en cas d'erreur.
final cloudinaryVideoDurationProvider =
    FutureProvider.family.autoDispose<double, String>((ref, videoUrl) async {
  if (videoUrl.trim().isEmpty) return 0.0;
  final service = ref.read(cloudinaryServiceProvider);
  return service.getVideoDuration(videoUrl);
});
