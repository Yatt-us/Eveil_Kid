import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/core/models/admin_role.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Routes du menu d'administration
// ──────────────────────────────────────────────────────────────────────────────

enum AdminNavRoute {
  dashboard,
  products,
  categories,
  commandes,
  tutoriels,
  utilisateurs,
}

// ──────────────────────────────────────────────────────────────────────────────
// Détecteur de Breakpoints Responsifs
// ──────────────────────────────────────────────────────────────────────────────

class AdminBreakpoints {
  AdminBreakpoints._();

  /// Mobile : < 768px (Drawer rétractable)
  static const double mobileBreakpoint = 768;

  /// Tablette : 768px – 1099px (Sidebar contracté 72px)
  /// Desktop : ≥ 1100px (Sidebar ouvert 260px)
  static const double desktopBreakpoint = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;
}

// ──────────────────────────────────────────────────────────────────────────────
// Modèle de données d'un item de navigation
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavItemData {
  final AdminNavRoute route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;
  final bool locked;
  final VoidCallback onTap;

  const _AdminNavItemData({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
    this.locked = false,
    required this.onTap,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
// AdminDrawer — Composant Drawer Standard (Mobile)
// ──────────────────────────────────────────────────────────────────────────────

class AdminDrawer extends ConsumerWidget {
  final AdminNavRoute currentRoute;

  const AdminDrawer({
    super.key,
    this.currentRoute = AdminNavRoute.dashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 285,
      backgroundColor: AppColors.surface,
      elevation: 1,
      child: _AdminNavigationContent(
        currentRoute: currentRoute,
        isCollapsed: false,
        isDrawer: true,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AdminSidebar — Composant Sidebar Fixe (Tablette & Desktop)
// ──────────────────────────────────────────────────────────────────────────────

class AdminSidebar extends ConsumerWidget {
  final AdminNavRoute currentRoute;

  const AdminSidebar({
    super.key,
    this.currentRoute = AdminNavRoute.dashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = AdminBreakpoints.isTablet(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: isTablet ? 72 : 260,
      child: _AdminNavigationContent(
        currentRoute: currentRoute,
        isCollapsed: isTablet,
        isDrawer: false,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Contenu interne unifié (Fond Blanc & Design Épuré)
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavigationContent extends ConsumerWidget {
  final AdminNavRoute currentRoute;
  final bool isCollapsed;
  final bool isDrawer;

  const _AdminNavigationContent({
    required this.currentRoute,
    required this.isCollapsed,
    required this.isDrawer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(adminRoleProvider);
    final catalogStats = ref.watch(adminCatalogStatsProvider);
    final userStats = ref.watch(adminUserStatsProvider);

    final operationalItems = <_AdminNavItemData>[
      _AdminNavItemData(
        route: AdminNavRoute.dashboard,
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Tableau de bord',
        onTap: () => _navigate(context, AdminNavRoute.dashboard),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.products,
        icon: Icons.toys_outlined,
        activeIcon: Icons.toys_rounded,
        label: 'Produits',
        badge: '${catalogStats.totalProducts}',
        onTap: () => _navigate(context, AdminNavRoute.products),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.categories,
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        label: 'Catégories',
        badge: '${catalogStats.totalCategories}',
        onTap: () => _navigate(context, AdminNavRoute.categories),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.commandes,
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'Commandes',
        badge: 'Bientôt',
        onTap: () => _showComingSoon(context, 'Commandes'),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.tutoriels,
        icon: Icons.video_library_outlined,
        activeIcon: Icons.video_library_rounded,
        label: 'Tutoriels',
        badge: 'Bientôt',
        onTap: () => _showComingSoon(context, 'Tutoriels'),
      ),
    ];

    final adminItems = <_AdminNavItemData>[
      _AdminNavItemData(
        route: AdminNavRoute.utilisateurs,
        icon: role.canManageUsers ? Icons.people_outline : Icons.lock_outline,
        activeIcon: role.canManageUsers ? Icons.people_rounded : Icons.lock_outline,
        label: role.canManageUsers ? 'Utilisateurs' : 'Utilisateurs (Admin)',
        badge: role.canManageUsers ? '${userStats.totalUsers}' : null,
        locked: !role.canManageUsers,
        onTap: () {
          if (!role.canManageUsers) {
            _showAccessDenied(context);
            return;
          }
          _navigate(context, AdminNavRoute.utilisateurs);
        },
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _AdminNavHeader(
              role: role,
              ref: ref,
              isCollapsed: isCollapsed,
              isDrawer: isDrawer,
            ),

            // Liste de navigation
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 8 : 12,
                  vertical: 10,
                ),
                children: [
                  if (!isCollapsed)
                    const _AdminSectionLabel(label: 'ESPACE OPÉRATIONNEL')
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: AppColors.border, thickness: 1),
                    ),
                  ...operationalItems.map(
                    (item) => _AdminNavTile(
                      item: item,
                      isSelected: currentRoute == item.route,
                      isCollapsed: isCollapsed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isCollapsed)
                    const _AdminSectionLabel(label: 'ADMINISTRATION GLOBALE')
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: AppColors.border, thickness: 1),
                    ),
                  ...adminItems.map(
                    (item) => _AdminNavTile(
                      item: item,
                      isSelected: currentRoute == item.route,
                      isCollapsed: isCollapsed,
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            _AdminNavFooter(
              role: role,
              isCollapsed: isCollapsed,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, AdminNavRoute route) {
    if (currentRoute == route) {
      if (isDrawer && context.canPop()) context.pop();
      return;
    }
    if (isDrawer && context.canPop()) context.pop();

    switch (route) {
      case AdminNavRoute.dashboard:
        context.go(AppRoutes.admin);
        break;
      case AdminNavRoute.products:
        context.go(AppRoutes.adminProducts);
        break;
      case AdminNavRoute.categories:
        context.go(AppRoutes.adminCategories);
        break;
      case AdminNavRoute.utilisateurs:
        context.go(AppRoutes.adminUsers);
        break;
      default:
        return;
    }
  }

  void _showComingSoon(BuildContext context, String module) {
    if (isDrawer && context.canPop()) context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          '$module — Module bientôt disponible',
          style: const TextStyle(color: AppColors.white, fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAccessDenied(BuildContext context) {
    if (isDrawer && context.canPop()) context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.white, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Accès restreint : réservé au Super Administrateur.",
                style: TextStyle(color: AppColors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header (Logo, Titre & Badge Rôle Épuré)
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavHeader extends StatelessWidget {
  final AdminRole role;
  final WidgetRef ref;
  final bool isCollapsed;
  final bool isDrawer;

  const _AdminNavHeader({
    required this.role,
    required this.ref,
    required this.isCollapsed,
    required this.isDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == AdminRole.admin;
    final roleColor = isAdmin ? AppColors.danger : AppColors.primary;
    final roleIcon = isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded;

    if (isCollapsed) {
      // Tablette (Contracté)
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            // Logo épuré
            Tooltip(
              message: "Éveil Kid Administration",
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            // Switcher rôle compact
            Tooltip(
              message: "Rôle actif : ${role.label}\nCliquez pour basculer",
              child: InkWell(
                onTap: () => ref.read(adminRoleProvider.notifier).toggleRole(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: roleColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(roleIcon, size: 16, color: roleColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop & Mobile Drawer (Ouvert)
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Éveil Kid',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Administration',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDrawer)
                IconButton(
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.icon),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Badge Rôle & Switcher épuré
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(roleIcon, size: 14, color: roleColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    role.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => ref.read(adminRoleProvider.notifier).toggleRole(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Changer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Label de Section Épuré
// ──────────────────────────────────────────────────────────────────────────────

class _AdminSectionLabel extends StatelessWidget {
  final String label;

  const _AdminSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tuile de Navigation Épurée
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavTile extends StatefulWidget {
  final _AdminNavItemData item;
  final bool isSelected;
  final bool isCollapsed;

  const _AdminNavTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
  });

  @override
  State<_AdminNavTile> createState() => _AdminNavTileState();
}

class _AdminNavTileState extends State<_AdminNavTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final selected = widget.isSelected;
    final locked = item.locked;
    final isCollapsed = widget.isCollapsed;

    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => _ctrl.forward(),
          onTapUp: (_) {
            _ctrl.reverse();
            item.onTap();
          },
          onTapCancel: () => _ctrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              padding: isCollapsed
                  ? const EdgeInsets.symmetric(vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : _hovered
                        ? AppColors.background
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: isCollapsed
                  ? _buildCollapsedContent(item, selected, locked)
                  : _buildExpandedContent(item, selected, locked),
            ),
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: item.badge != null && !locked
            ? "${item.label} (${item.badge})"
            : item.label,
        waitDuration: const Duration(milliseconds: 200),
        child: content,
      );
    }

    return content;
  }

  Widget _buildCollapsedContent(_AdminNavItemData item, bool selected, bool locked) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: locked ? 0.4 : 1.0,
            child: Icon(
              selected ? item.activeIcon : item.icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.icon,
            ),
          ),
          if (item.badge != null && !locked)
            Positioned(
              top: -4,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.badge!,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (locked)
            const Positioned(
              bottom: -4,
              right: -6,
              child: Icon(
                Icons.lock_rounded,
                size: 11,
                color: AppColors.disabled,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(_AdminNavItemData item, bool selected, bool locked) {
    return Row(
      children: [
        // Indicateur actif à gauche
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 3,
          height: selected ? 16 : 0,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: selected ? 8 : 0,
        ),

        // Icône
        Opacity(
          opacity: locked ? 0.4 : 1.0,
          child: Icon(
            selected ? item.activeIcon : item.icon,
            size: 19,
            color: selected ? AppColors.primary : AppColors.icon,
          ),
        ),
        const SizedBox(width: 10),

        // Label
        Expanded(
          child: Opacity(
            opacity: locked ? 0.4 : 1.0,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Badge épuré
        if (item.badge != null && !locked) ...[
          const SizedBox(width: 6),
          _AdminBadge(
            label: item.badge!,
            isSelected: selected,
          ),
        ],

        // Cadenas
        if (locked) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.lock_rounded,
            size: 13,
            color: AppColors.disabled,
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Badge Compteur Épuré
// ──────────────────────────────────────────────────────────────────────────────

class _AdminBadge extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _AdminBadge({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Footer Épuré
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavFooter extends ConsumerWidget {
  final AdminRole role;
  final bool isCollapsed;

  const _AdminNavFooter({
    required this.role,
    required this.isCollapsed,
  });

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Déconnexion Admin',
      message: 'Êtes-vous sûr de vouloir vous déconnecter de la session administration ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).utilisateur;
    final isAdmin = role == AdminRole.admin;
    final roleColor = isAdmin ? AppColors.danger : AppColors.primary;
    final name = authUser?.nom.isNotEmpty == true
        ? authUser!.nom
        : (isAdmin ? 'Super Administrateur' : 'Manager Opérationnel');
    final sub = authUser?.email.isNotEmpty == true
        ? authUser!.email
        : (isAdmin ? 'Accès complet' : 'Catalogue & Commandes');

    if (isCollapsed) {
      // Tablette (Contracté)
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Tooltip(
          message: "$name\n$sub\n(Cliquer pour déconnecter)",
          child: InkWell(
            onTap: () => _logout(context, ref),
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.person_rounded, size: 18, color: roleColor),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Desktop & Mobile Drawer (Ouvert)
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: roleColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(Icons.person_rounded, size: 18, color: roleColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: AppColors.danger,
            ),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AdminScaffold — Wrapper Responsive Global
// ──────────────────────────────────────────────────────────────────────────────

class AdminScaffold extends StatelessWidget {
  final AdminNavRoute currentRoute;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AdminBreakpoints.isMobile(context);

    if (isMobile) {
      // Mobile : Drawer classique
      return Scaffold(
        backgroundColor: backgroundColor ?? AppColors.background,
        appBar: appBar,
        drawer: AdminDrawer(currentRoute: currentRoute),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: body,
      );
    }

    // Tablette & Desktop : Sidebar persistant (contracté 72px ou ouvert 260px)
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [
          AdminSidebar(currentRoute: currentRoute),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: appBar != null ? _sanitizeDesktopAppBar(appBar!) : null,
              body: body,
            ),
          ),
        ],
      ),
    );
  }

  /// Retire le bouton hamburger d'ouverture de drawer quand la sidebar est déjà affichée
  PreferredSizeWidget _sanitizeDesktopAppBar(PreferredSizeWidget originalAppBar) {
    if (originalAppBar is AppBar) {
      return AppBar(
        title: originalAppBar.title,
        actions: originalAppBar.actions,
        bottom: originalAppBar.bottom,
        backgroundColor: originalAppBar.backgroundColor ?? AppColors.surface,
        elevation: originalAppBar.elevation ?? 0,
        automaticallyImplyLeading: false,
        leading: null,
        centerTitle: originalAppBar.centerTitle,
        titleTextStyle: originalAppBar.titleTextStyle,
        iconTheme: originalAppBar.iconTheme,
        actionsIconTheme: originalAppBar.actionsIconTheme,
      );
    }
    return originalAppBar;
  }
}
