import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notifColl(String utilisateurId) {
    return _firestore
        .collection('utilisateurs')
        .doc(utilisateurId)
        .collection('notifications');
  }

  /// Écoute en temps réel les notifications d'un utilisateur (les 50 plus récentes)
  Stream<List<NotificationModel>> streamNotifications(String utilisateurId) {
    return _notifColl(utilisateurId)
        .orderBy('dateCreation', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList());
  }

  /// Compte les notifications non lues
  Stream<int> streamNonLuesCount(String utilisateurId) {
    return _notifColl(utilisateurId)
        .where('estLue', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Marque une notification comme lue
  Future<void> marquerCommeLue(String utilisateurId, String notificationId) async {
    try {
      await _notifColl(utilisateurId).doc(notificationId).update({
        'estLue': true,
        'dateLecture': Timestamp.now(),
      });
    } catch (_) {}
  }

  /// Marque toutes les notifications comme lues
  Future<void> marquerToutesCommeLues(String utilisateurId) async {
    final batch = _firestore.batch();
    try {
      final snap = await _notifColl(utilisateurId)
          .where('estLue', isEqualTo: false)
          .get();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {
          'estLue': true,
          'dateLecture': Timestamp.now(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Supprime une notification
  Future<void> supprimerNotification(
      String utilisateurId, String notificationId) async {
    try {
      await _notifColl(utilisateurId).doc(notificationId).delete();
    } catch (_) {}
  }

  /// Supprime toutes les notifications lues
  Future<void> supprimerToutesLesLues(String utilisateurId) async {
    final batch = _firestore.batch();
    try {
      final snap = await _notifColl(utilisateurId)
          .where('estLue', isEqualTo: true)
          .get();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Crée une notification (utile pour tests ou envois manuels depuis l'admin)
  Future<void> creerNotification(NotificationModel notif) async {
    final docRef = notif.notificationId.isNotEmpty
        ? _notifColl(notif.utilisateurId).doc(notif.notificationId)
        : _notifColl(notif.utilisateurId).doc();

    final notifFinal = notif.copyWith(notificationId: docRef.id);
    await docRef.set(notifFinal.toMap());
  }
}
