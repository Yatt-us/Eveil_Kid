import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';

class AdminUserRepository {
  final FirebaseFirestore _firestore;

  AdminUserRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('utilisateurs');

  Future<List<AdminUserModel>> getAllUsers() async {
    final snapshot = await _usersCollection.get();
    return snapshot.docs
        .map((doc) => AdminUserModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<AdminUserModel>> streamUsers() {
    return _usersCollection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminUserModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _usersCollection.doc(userId).update({
      'role': newRole,
      'dateModification': Timestamp.now(),
    });
  }

  Future<void> toggleUserStatus(String userId, bool estActif, {String? motif}) async {
    final updateData = <String, dynamic>{
      'estActif': estActif,
      'dateModification': Timestamp.now(),
    };
    if (!estActif && motif != null && motif.trim().isNotEmpty) {
      updateData['motifBlocage'] = motif.trim();
    } else if (estActif) {
      updateData['motifBlocage'] = FieldValue.delete();
    }
    await _usersCollection.doc(userId).update(updateData);
  }

  Future<void> createManagerAccount({
    required String nom,
    required String email,
    String? telephone,
  }) async {
    final docRef = _usersCollection.doc();
    await docRef.set({
      'utilisateurId': docRef.id,
      'nom': nom.trim(),
      'email': email.trim().toLowerCase(),
      'telephone': telephone?.trim() ?? '',
      'role': 'MANAGER',
      'estActif': true,
      'dateCreation': Timestamp.now(),
      'dateModification': Timestamp.now(),
    });
  }
}
