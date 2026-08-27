import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/users/presentation/widgets/admin_staff_card.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

enum StaffSortOption {
  role,
  newestFirst,
  nameAsc,
  nameDesc,
}

/// Page d'administration dédiée exclusivement à l'Équipe & Staff (Admins & Managers).
class AdminStaffListPage extends ConsumerStatefulWidget {
  const AdminStaffListPage({super.key});

  @override
  ConsumerState<AdminStaffListPage> createState() => _AdminStaffListPageState();
}

class _AdminStaffListPageState extends ConsumerState<AdminStaffListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  StaffSortOption _sortOption = StaffSortOption.role;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters => _sortOption != StaffSortOption.role;



  void _showFilterBottomSheet(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trier l'équipe",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _sortOption = StaffSortOption.role;
                              });
                              setState(() {});
                            },
                            child: const Text("Réinitialiser"),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Text(
                      "ORDRE D'AFFICHAGE",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7) ??
                            AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: "Par Rôle (Admins puis Managers)",
                          isSelected: _sortOption == StaffSortOption.role,
                          theme: theme,
                          isDark: isDark,
                          onTap: () {
                            setModalState(
                                () => _sortOption = StaffSortOption.role);
                            setState(() {});
                          },
                        ),
                        _buildFilterChip(
                          label: "Plus récents d'abord",
                          isSelected:
                              _sortOption == StaffSortOption.newestFirst,
                          theme: theme,
                          isDark: isDark,
                          onTap: () {
                            setModalState(() =>
                                _sortOption = StaffSortOption.newestFirst);
                            setState(() {});
                          },
                        ),
                        _buildFilterChip(
                          label: "Nom (A - Z)",
                          isSelected: _sortOption == StaffSortOption.nameAsc,
                          theme: theme,
                          isDark: isDark,
                          onTap: () {
                            setModalState(
                                () => _sortOption = StaffSortOption.nameAsc);
                            setState(() {});
                          },
                        ),
                        _buildFilterChip(
                          label: "Nom (Z - A)",
                          isSelected: _sortOption == StaffSortOption.nameDesc,
                          theme: theme,
                          isDark: isDark,
                          onTap: () {
                            setModalState(
                                () => _sortOption = StaffSortOption.nameDesc);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          "Appliquer",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : (theme.textTheme.bodyMedium?.color ??
                    theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(adminRoleProvider);
    final usersAsync = ref.watch(adminUsersStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final titleColor =
        theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color
            ?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    if (!currentRole.canManageUsers) {
      return AdminScaffold(
        currentRoute: AdminNavRoute.staff,
        appBar: AppBar(
          title: Text("Accès restreint", style: TextStyle(color: titleColor)),
          backgroundColor: theme.colorScheme.surface,
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
                    color: theme.colorScheme.error
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline,
                      size: 48, color: theme.colorScheme.error),
                ),
                const SizedBox(height: 16),
                Text(
                  "Module réservé à l'Administrateur",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "En tant que Manager, vous êtes restreint à la gestion des produits, catégories et commandes.",
                  style: TextStyle(fontSize: 13, color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allUsers = usersAsync.value ?? [];
    // Filtration stricte du Staff uniquement (Admins & Managers)
    final staffUsers = allUsers.where((u) => u.isAdmin || u.isManager).toList();
    final totalStaff = staffUsers.length;
    final managerCount = staffUsers.where((u) => u.isManager).length;
    final adminCount = staffUsers.where((u) => u.isAdmin).length;

    return AdminScaffold(
      currentRoute: AdminNavRoute.staff,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminManagerForm),
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text(
          "Nouveau Manager",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Équipe & Staff",
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            tooltip: "Actualiser",
            onPressed: () => ref.invalidate(adminUsersStreamProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            padding: const EdgeInsets.all(3),
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dividerColor,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dividerColor,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Tous"),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? theme.colorScheme.primary.withValues(
                                  alpha: isDark ? 0.25 : 0.12)
                              : (isDark
                                  ? theme.colorScheme.surface
                                  : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$totalStaff",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 0
                                ? theme.colorScheme.primary
                                : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Managers"),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? const Color(0xFFD97706).withValues(
                                  alpha: isDark ? 0.25 : 0.12)
                              : (isDark
                                  ? theme.colorScheme.surface
                                  : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$managerCount",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 1
                                ? const Color(0xFFD97706)
                                : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Admins"),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _tabController.index == 2
                              ? theme.colorScheme.error.withValues(
                                  alpha: isDark ? 0.25 : 0.12)
                              : (isDark
                                  ? theme.colorScheme.surface
                                  : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$adminCount",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 2
                                ? theme.colorScheme.error
                                : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de Recherche + Bouton Filtres
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    hintText: "Rechercher un membre du staff...",
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showFilterBottomSheet(context, theme, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: _hasActiveFilters
                          ? theme.colorScheme.primary
                              .withValues(alpha: isDark ? 0.2 : 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasActiveFilters
                            ? theme.colorScheme.primary
                            : dividerColor,
                        width: _hasActiveFilters ? 1.2 : 1.0,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 19,
                          color: _hasActiveFilters
                              ? theme.colorScheme.primary
                              : (theme.iconTheme.color
                                      ?.withValues(alpha: 0.7) ??
                                  AppColors.icon),
                        ),
                        if (_hasActiveFilters)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des membres du Staff
          Expanded(
            child: usersAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary),
                ),
              ),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger le staff : $err",
                onRetry: () => ref.refresh(adminUsersStreamProvider),
              ),
              data: (users) {
                var list = users
                    .where((u) => u.isAdmin || u.isManager)
                    .toList();

                // Filtrage selon l'onglet actif (0: Tous, 1: Managers, 2: Admins)
                if (_tabController.index == 1) {
                  list = list.where((u) => u.isManager).toList();
                } else if (_tabController.index == 2) {
                  list = list.where((u) => u.isAdmin).toList();
                }

                // Filtrage recherche
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase().trim();
                  list = list.where((u) {
                    return u.nom.toLowerCase().contains(q) ||
                        u.email.toLowerCase().contains(q);
                  }).toList();
                }

                // Tri
                list.sort((a, b) {
                  switch (_sortOption) {
                    case StaffSortOption.role:
                      // Admins d'abord, puis Managers
                      if (a.isAdmin && !b.isAdmin) return -1;
                      if (!a.isAdmin && b.isAdmin) return 1;
                      return a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
                    case StaffSortOption.nameAsc:
                      return a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
                    case StaffSortOption.nameDesc:
                      return b.nom.toLowerCase().compareTo(a.nom.toLowerCase());
                    case StaffSortOption.newestFirst:
                      final aDate = a.dateCreation.toDate();
                      final bDate = b.dateCreation.toDate();
                      return bDate.compareTo(aDate);
                  }
                });

                if (list.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.shield_outlined,
                    title: _searchQuery.isNotEmpty
                        ? "Aucun membre correspondant"
                        : "Aucun membre dans cette catégorie",
                    description: _searchQuery.isNotEmpty
                        ? "Essayez d'autres mots-clés de recherche."
                        : "Les membres du staff apparaîtront ici.",
                  );
                }

                return RefreshIndicator(
                  color: theme.colorScheme.primary,
                  onRefresh: () async {
                    ref.invalidate(adminUsersStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final user = list[index];
                      return AdminStaffCard(user: user);
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
}
