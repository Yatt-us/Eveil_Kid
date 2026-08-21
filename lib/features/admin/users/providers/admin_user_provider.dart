import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user_model.dart';
import '../repository/admin_user_repository.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserRepository(FirebaseFirestore.instance);
});

final adminUsersStreamProvider = StreamProvider<List<AdminUserModel>>((ref) {
  final repo = ref.read(adminUserRepositoryProvider);
  return repo.streamUsers();
});

class AdminUserStats {
  final int totalUsers;
  final int totalParents;
  final int totalManagers;
  final int totalAdmins;
  final int activeUsers;

  const AdminUserStats({
    this.totalUsers = 0,
    this.totalParents = 0,
    this.totalManagers = 0,
    this.totalAdmins = 0,
    this.activeUsers = 0,
  });
}

final adminUserStatsProvider = Provider<AdminUserStats>((ref) {
  final users = ref.watch(adminUsersStreamProvider).value ?? [];

  int parents = 0;
  int managers = 0;
  int admins = 0;
  int active = 0;

  for (final u in users) {
    if (u.estActif) active++;
    if (u.isAdmin) {
      admins++;
    } else if (u.isManager) {
      managers++;
    } else {
      parents++;
    }
  }

  return AdminUserStats(
    totalUsers: users.length,
    totalParents: parents,
    totalManagers: managers,
    totalAdmins: admins,
    activeUsers: active,
  );
});
