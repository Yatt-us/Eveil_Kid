import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/users/presentation/widgets/admin_user_card.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/shared/widgets/app_chip.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class AdminUserListPage extends ConsumerStatefulWidget {
  const AdminUserListPage({super.key});

  @override
  ConsumerState<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends ConsumerState<AdminUserListPage> {
  String _searchQuery = '';
  String _roleFilter = 'ALL'; // 'ALL', 'PARENT', 'MANAGER', 'ADMIN', 'INACTIVE'

  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(adminRoleProvider);
    final usersAsync = ref.watch(adminUsersStreamProvider);
    final stats = ref.watch(adminUserStatsProvider);

    // Protection d'accès pour le rôle Manager
    if (!currentRole.canManageUsers) {
      return AdminScaffold(
        currentRoute: AdminNavRoute.utilisateurs,
        appBar: AppBar(
          title: const Text("Accès restreint"),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 48, color: AppColors.danger),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Module réservé à l'Administrateur",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "En tant que Manager, vous êtes restreint à la gestion des produits, catégories et commandes.",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AdminScaffold(
      currentRoute: AdminNavRoute.utilisateurs,
      appBar: AppBar(
        title: const Text(
          "Gestion des Utilisateurs",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Actualiser",
            onPressed: () => ref.invalidate(adminUsersStreamProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                _buildKpiBadge("Total", "${stats.totalUsers}", AppColors.primary),
                const SizedBox(width: 8),
                _buildKpiBadge("Parents", "${stats.totalParents}", AppColors.teal),
                const SizedBox(width: 8),
                _buildKpiBadge("Managers", "${stats.totalManagers}", AppColors.primaryLight),
                const SizedBox(width: 8),
                _buildKpiBadge("Admins", "${stats.totalAdmins}", AppColors.danger),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              hintText: "Rechercher un utilisateur (nom, email)...",
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filtres par Rôles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                AppChip(
                  label: "Tous (${stats.totalUsers})",
                  variant: _roleFilter == 'ALL'
                      ? AppChipVariant.primary
                      : AppChipVariant.neutral,
                  onTap: () => setState(() => _roleFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: "Parents (${stats.totalParents})",
                  variant: _roleFilter == 'PARENT'
                      ? AppChipVariant.primary
                      : AppChipVariant.neutral,
                  onTap: () => setState(() => _roleFilter = 'PARENT'),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: "Managers (${stats.totalManagers})",
                  variant: _roleFilter == 'MANAGER'
                      ? AppChipVariant.warning
                      : AppChipVariant.neutral,
                  onTap: () => setState(() => _roleFilter = 'MANAGER'),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: "Admins (${stats.totalAdmins})",
                  variant: _roleFilter == 'ADMIN'
                      ? AppChipVariant.danger
                      : AppChipVariant.neutral,
                  onTap: () => setState(() => _roleFilter = 'ADMIN'),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: "Inactifs",
                  variant: _roleFilter == 'INACTIVE'
                      ? AppChipVariant.danger
                      : AppChipVariant.neutral,
                  onTap: () => setState(() => _roleFilter = 'INACTIVE'),
                ),
              ],
            ),
          ),

          AppSpacing.verticalSm,

          // Liste des utilisateurs
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger les utilisateurs : $err",
                onRetry: () => ref.refresh(adminUsersStreamProvider),
              ),
              data: (users) {
                var filtered = users.where((u) {
                  // Filtre recherche
                  if (_searchQuery.trim().isNotEmpty) {
                    final q = _searchQuery.toLowerCase().trim();
                    if (!u.nom.toLowerCase().contains(q) &&
                        !u.email.toLowerCase().contains(q)) {
                      return false;
                    }
                  }
                  // Filtre rôle
                  switch (_roleFilter) {
                    case 'PARENT':
                      if (!u.isParent) return false;
                      break;
                    case 'MANAGER':
                      if (!u.isManager) return false;
                      break;
                    case 'ADMIN':
                      if (!u.isAdmin) return false;
                      break;
                    case 'INACTIVE':
                      if (u.estActif) return false;
                      break;
                    case 'ALL':
                    default:
                      break;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.people_outline,
                    title: "Aucun utilisateur trouvé",
                    description: _searchQuery.isNotEmpty || _roleFilter != 'ALL'
                        ? "Aucun compte ne correspond à vos filtres actuels."
                        : "Aucun utilisateur dans la base de données.",
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminUsersStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return AdminUserCard(user: user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
