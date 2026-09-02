import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Stream des notifications en temps réel pour un utilisateur donné
final notificationsStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, utilisateurId) {
  if (utilisateurId.isEmpty) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).streamNotifications(utilisateurId);
});

/// Stream du compteur de notifications non lues
final notifNonLuesCountProvider =
    StreamProvider.family<int, String>((ref, utilisateurId) {
  if (utilisateurId.isEmpty) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).streamNonLuesCount(utilisateurId);
});
