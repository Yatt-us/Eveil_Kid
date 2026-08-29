import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/core/models/admin_role.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_logo.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Routes du menu d'administration
// ──────────────────────────────────────────────────────────────────────────────

enum AdminNavRoute {
  dashboard,
  products,
  categories,
  commandes,
  tutoriels,
  activites,
  utilisateurs,
  staff,
  profile,
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
  final VoidCallback onTap;

  const _AdminNavItemData({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.82).clamp(260.0, 300.0);
    final theme = Theme.of(context);

    return Drawer(
      width: drawerWidth,
      backgroundColor: theme.colorScheme.surface,
      elevation: 2,
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isTablet ? 72 : 260,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxWidth < 140;
          return ClipRect(
            child: _AdminNavigationContent(
              currentRoute: currentRoute,
              isCollapsed: isCollapsed,
              isDrawer: false,
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Contenu interne unifié
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
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

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
        onTap: () => _navigate(context, AdminNavRoute.products),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.categories,
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        label: 'Catégories',
        onTap: () => _navigate(context, AdminNavRoute.categories),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.commandes,
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'Commandes',
        onTap: () => _navigate(context, AdminNavRoute.commandes),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.tutoriels,
        icon: Icons.video_library_outlined,
        activeIcon: Icons.video_library_rounded,
        label: 'Tutoriels',
        onTap: () => _navigate(context, AdminNavRoute.tutoriels),
      ),
      _AdminNavItemData(
        route: AdminNavRoute.activites,
        icon: Icons.local_activity,
        activeIcon: Icons.local_activity_outlined,
        label: 'Activités',
        onTap: () => _navigate(context, AdminNavRoute.activites),
      ),
    ];

    final adminItems = <_AdminNavItemData>[
      if (role.canManageUsers) ...[
        _AdminNavItemData(
          route: AdminNavRoute.utilisateurs,
          icon: Icons.family_restroom_outlined,
          activeIcon: Icons.family_restroom_rounded,
          label: 'Parents',
          onTap: () => _navigate(context, AdminNavRoute.utilisateurs),
        ),
        _AdminNavItemData(
          route: AdminNavRoute.staff,
          icon: Icons.shield_outlined,
          activeIcon: Icons.shield_rounded,
          label: 'Équipe & Staff',
          onTap: () => _navigate(context, AdminNavRoute.staff),
        ),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: dividerColor, width: 1),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: dividerColor, thickness: 1),
                    ),
                  ...operationalItems.map(
                    (item) => _AdminNavTile(
                      item: item,
                      isSelected: currentRoute == item.route,
                      isCollapsed: isCollapsed,
                    ),
                  ),
                  if (role.canManageUsers && adminItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    if (!isCollapsed)
                      const _AdminSectionLabel(label: 'ADMINISTRATION GLOBALE')
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Divider(color: dividerColor, thickness: 1),
                      ),
                    ...adminItems.map(
                      (item) => _AdminNavTile(
                        item: item,
                        isSelected: currentRoute == item.route,
                        isCollapsed: isCollapsed,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  if (!isCollapsed)
                    const _AdminSectionLabel(label: 'MON COMPTE')
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: dividerColor, thickness: 1),
                    ),
                  _AdminNavTile(
                    item: _AdminNavItemData(
                      route: AdminNavRoute.profile,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profil',
                      onTap: () => _navigate(context, AdminNavRoute.profile),
                    ),
                    isSelected: currentRoute == AdminNavRoute.profile,
                    isCollapsed: isCollapsed,
                  ),
                ],
              ),
            ),

            // Footer
            _AdminNavFooter(
              role: role,
              isCollapsed: isCollapsed,
              isDrawer: isDrawer,
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
      case AdminNavRoute.commandes:
        context.go(AppRoutes.adminCommandes);
        break;
      case AdminNavRoute.tutoriels:
        context.go(AppRoutes.adminTutoriels);
        break;
      case AdminNavRoute.activites:
        context.go(AppRoutes.adminActivites);
        break;
      case AdminNavRoute.utilisateurs:
        context.go(AppRoutes.adminUsers);
        break;
      case AdminNavRoute.staff:
        context.go(AppRoutes.adminStaff);
        break;
      case AdminNavRoute.profile:
        context.go(AppRoutes.adminProfile);
        break;
    }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = role == AdminRole.admin;
    final roleColor = isAdmin ? theme.colorScheme.error : theme.colorScheme.primary;
    final roleIcon =
        isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    if (isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Column(
          children: [
            Tooltip(
              message: "Éveil Kid — Administration",
              child: Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const AppLogo(size: 28, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 10),
            Tooltip(
              message: "Compte : ${role.label}",
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(roleIcon, size: 16, color: roleColor),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const AppLogo(size: 28, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Éveil Kid',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color ??
                            theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Administration',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                            AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isDrawer)
                IconButton(
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                        AppColors.icon,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  tooltip: 'Fermer',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: roleColor.withValues(alpha: 0.25)),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6) ??
              AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tuile de Navigation
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
    final isCollapsed = widget.isCollapsed;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                    : _hovered
                        ? (isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.background)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: isCollapsed
                  ? _buildCollapsedContent(context, item, selected)
                  : _buildExpandedContent(context, item, selected),
            ),
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: item.label,
        waitDuration: const Duration(milliseconds: 200),
        child: content,
      );
    }

    return content;
  }

  Widget _buildCollapsedContent(BuildContext context, _AdminNavItemData item, bool selected) {
    final theme = Theme.of(context);

    return Center(
      child: Icon(
        selected ? item.activeIcon : item.icon,
        size: 20,
        color: selected
            ? theme.colorScheme.primary
            : (theme.iconTheme.color?.withValues(alpha: 0.6) ?? AppColors.icon),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, _AdminNavItemData item, bool selected) {
    final theme = Theme.of(context);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 3,
          height: selected ? 16 : 0,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: selected ? 8 : 0,
        ),
        Icon(
          selected ? item.activeIcon : item.icon,
          size: 19,
          color: selected
              ? theme.colorScheme.primary
              : (theme.iconTheme.color?.withValues(alpha: 0.6) ?? AppColors.icon),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? theme.colorScheme.primary
                  : (theme.textTheme.bodyMedium?.color ??
                      theme.colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Footer
// ──────────────────────────────────────────────────────────────────────────────

class _AdminNavFooter extends ConsumerWidget {
  final AdminRole role;
  final bool isCollapsed;
  final bool isDrawer;

  const _AdminNavFooter({
    required this.role,
    required this.isCollapsed,
    this.isDrawer = false,
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
    final theme = Theme.of(context);
    final isAdmin = role == AdminRole.admin;
    final roleColor = isAdmin ? theme.colorScheme.error : theme.colorScheme.primary;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    final name = authUser?.nom.isNotEmpty == true
        ? authUser!.nom
        : (isAdmin ? 'Super Administrateur' : 'Manager Opérationnel');
    final sub = authUser?.email.isNotEmpty == true
        ? authUser!.email
        : (isAdmin ? 'Accès complet' : 'Catalogue & Commandes');

    if (isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor)),
        ),
        child: Tooltip(
          message: "$name\n$sub\n(Cliquer pour voir le profil)",
          child: InkWell(
            onTap: () {
              if (isDrawer && context.canPop()) context.pop();
              context.go(AppRoutes.adminProfile);
            },
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (isDrawer && context.canPop()) context.pop();
                context.go(AppRoutes.adminProfile);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color ??
                                  theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Profil • $sub',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: Icon(
              Icons.logout_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AdminShellScaffold — Wrapper Persistant StatefulShellRoute
// ──────────────────────────────────────────────────────────────────────────────

class AdminShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShellScaffold({
    super.key,
    required this.navigationShell,
  });

  AdminNavRoute _getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.adminProfile)) {
      return AdminNavRoute.profile;
    } else if (location.startsWith(AppRoutes.adminProducts)) {
      return AdminNavRoute.products;
    } else if (location.startsWith(AppRoutes.adminCategories)) {
      return AdminNavRoute.categories;
    } else if (location.startsWith(AppRoutes.adminActivites)) {
      return AdminNavRoute.activites;
    } else if (location.startsWith(AppRoutes.adminTutoriels)) {
      return AdminNavRoute.tutoriels;
    } else if (location.startsWith(AppRoutes.adminUsers)) {
      return AdminNavRoute.utilisateurs;
    } else if (location.startsWith(AppRoutes.adminStaff)) {
      return AdminNavRoute.staff;
    } else if (location.startsWith(AppRoutes.adminCatalog)) {
      return AdminNavRoute.products;
    }
    return AdminNavRoute.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AdminBreakpoints.isMobile(context);
    final currentRoute = _getCurrentRoute(context);
    final theme = Theme.of(context);

    final widgetContent = isMobile
        ? navigationShell
        : Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Row(
              children: [
                AdminSidebar(currentRoute: currentRoute),
                Expanded(
                  child: navigationShell,
                ),
              ],
            ),
          );

    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: widgetContent,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AdminScaffold — Wrapper Responsive Global pour les pages
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
    final theme = Theme.of(context);

    final widgetContent = isMobile
        ? Scaffold(
            backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
            appBar: appBar,
            drawer: AdminDrawer(currentRoute: currentRoute),
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            body: body,
          )
        : Scaffold(
            backgroundColor: backgroundColor ?? Colors.transparent,
            appBar: appBar != null
                ? _sanitizeDesktopAppBar(context, appBar!)
                : null,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            body: body,
          );

    return PopScope(
      canPop: currentRoute == AdminNavRoute.dashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted && currentRoute != AdminNavRoute.dashboard) {
          context.go(AppRoutes.admin);
        }
      },
      child: widgetContent,
    );
  }

  PreferredSizeWidget _sanitizeDesktopAppBar(
    BuildContext context,
    PreferredSizeWidget originalAppBar,
  ) {
    final theme = Theme.of(context);

    if (originalAppBar is AppBar) {
      return AppBar(
        title: originalAppBar.title,
        actions: originalAppBar.actions,
        bottom: originalAppBar.bottom,
        backgroundColor: originalAppBar.backgroundColor ?? theme.colorScheme.surface,
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
