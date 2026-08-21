import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_role.dart';

class AdminRoleNotifier extends Notifier<AdminRole> {
  @override
  AdminRole build() {
    // Par défaut, nous démarrons en Administrateur (ou Manager selon configuration)
    return AdminRole.admin;
  }

  void setRole(AdminRole role) {
    state = role;
  }

  void toggleRole() {
    state = state == AdminRole.admin ? AdminRole.manager : AdminRole.admin;
  }
}

final adminRoleProvider = NotifierProvider<AdminRoleNotifier, AdminRole>(
  AdminRoleNotifier.new,
);
