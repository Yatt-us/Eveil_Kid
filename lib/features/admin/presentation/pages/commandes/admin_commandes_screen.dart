import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_commande_card.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/commandes/providers/commande_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

enum AdminCommandeSortOption {
  newest,
  oldest,
  priceDesc,
  priceAsc,
}

class AdminCommandesScreen extends ConsumerStatefulWidget {
  const AdminCommandesScreen({super.key});

  @override
  ConsumerState<AdminCommandesScreen> createState() => _AdminCommandesScreenState();
}

class _AdminCommandesScreenState extends ConsumerState<AdminCommandesScreen> {
  String _searchQuery = '';
  String? _selectedStatus; // null = Toutes, 'En cours', 'En livraison', 'Livrée', 'Annulée'
  AdminCommandeSortOption _sortOption = AdminCommandeSortOption.newest;

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      _sortOption != AdminCommandeSortOption.newest ||
      _searchQuery.isNotEmpty;

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  List<CommandeModel> _applyFilters(List<CommandeModel> orders) {
    var result = orders.where((cmd) {
      // Filtre de statut
      if (_selectedStatus != null) {
        final st = cmd.statut.toLowerCase();
        final sel = _selectedStatus!.toLowerCase();
        if (sel == 'en cours') {
          if (st != 'en cours' && st != 'en attente' && st != 'confirmee' && st != 'confirmée') {
            return false;
          }
        } else if (sel == 'en livraison') {
          if (st != 'en livraison' && st != 'expédiée' && st != 'expediee') {
            return false;
          }
        } else if (sel == 'livree' || sel == 'livrée') {
          if (st != 'livree' && st != 'livrée') {
            return false;
          }
        } else if (sel == 'annulee' || sel == 'annulée') {
          if (st != 'annulee' && st != 'annulée') {
            return false;
          }
        } else if (st != sel) {
          return false;
        }
      }

      // Recherche textuelle
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final idMatch = cmd.id.toLowerCase().contains(query);
        final phoneMatch = cmd.numeroTelephone?.toLowerCase().contains(query) ?? false;
        final addressMatch = cmd.adresseLivraison.toLowerCase().contains(query);
        final articlesMatch = cmd.articles.any((a) => a.titre.toLowerCase().contains(query));

        if (!idMatch && !phoneMatch && !addressMatch && !articlesMatch) {
          return false;
        }
      }

      return true;
    }).toList();

    // Tri
    switch (_sortOption) {
      case AdminCommandeSortOption.newest:
        result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case AdminCommandeSortOption.oldest:
        result.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case AdminCommandeSortOption.priceDesc:
        result.sort((a, b) => b.montantTotal.compareTo(a.montantTotal));
        break;
      case AdminCommandeSortOption.priceAsc:
        result.sort((a, b) => a.montantTotal.compareTo(b.montantTotal));
        break;
    }

    return result;
  }

  Future<void> _updateStatus(String commandeId, String nouveauStatut) async {
    try {
      final repo = ref.read(commandeRepositoryProvider);
      await repo.modifierStatutCommande(commandeId, nouveauStatut);
      ref.invalidate(adminCommandesProvider);

      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Statut de la commande mis à jour : $nouveauStatut',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur lors de la mise à jour : $e',
          isError: true,
        );
      }
    }
  }

  void _showSortModal(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trier les commandes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSortTile('Plus récentes en premier', AdminCommandeSortOption.newest, theme),
                _buildSortTile('Plus anciennes en premier', AdminCommandeSortOption.oldest, theme),
                _buildSortTile('Montant décroissant', AdminCommandeSortOption.priceDesc, theme),
                _buildSortTile('Montant croissant', AdminCommandeSortOption.priceAsc, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String label, AdminCommandeSortOption opt, ThemeData theme) {
    final isSelected = _sortOption == opt;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() => _sortOption = opt);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final commandesAsync = ref.watch(adminCommandesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    return AdminScaffold(
      currentRoute: AdminNavRoute.commandes,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Commandes & Ventes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminCommandesProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser les commandes',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminCommandesProvider),
        child: commandesAsync.when(
          loading: () => _buildSkeletonList(theme, isDark, dividerColor),
          error: (err, _) => AppErrorState(
            message: 'Erreur lors du chargement des commandes: $err',
            onRetry: () => ref.invalidate(adminCommandesProvider),
          ),
          data: (allCommandes) {
            final totalCount = allCommandes.length;
            final enCoursCount = allCommandes.where((c) {
              final s = c.statut.toLowerCase();
              return s == 'en cours' || s == 'en attente' || s == 'confirmee' || s == 'confirmée';
            }).length;
            final livreesCount = allCommandes.where((c) {
              final s = c.statut.toLowerCase();
              return s == 'livree' || s == 'livrée';
            }).length;
            final caTotal = allCommandes.fold<double>(0.0, (sum, c) => sum + c.montantTotal);

            final filteredList = _applyFilters(allCommandes);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
                final horizontalPadding = isWide ? 28.0 : (isTablet ? 20.0 : 16.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: CustomScrollView(
                      slivers: [
                        // 1. STATS CARDS
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              12,
                              horizontalPadding,
                              14,
                            ),
                            child: isWide
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: AdminStatCard(
                                          title: 'Chiffre d\'affaires global',
                                          value: _formatPrice(caTotal),
                                          subtitle: 'Total cumulé des ventes',
                                          icon: Icons.payments_rounded,
                                          color: const Color(0xFF3B82F6),
                                          onTap: () {},
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AdminStatCard(
                                          title: 'Total',
                                          value: '$totalCount',
                                          icon: Icons.shopping_bag_rounded,
                                          color: theme.colorScheme.primary,
                                          onTap: () => setState(() => _selectedStatus = null),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AdminStatCard(
                                          title: 'En cours',
                                          value: '$enCoursCount',
                                          icon: Icons.pending_actions_rounded,
                                          color: const Color(0xFFF59E0B),
                                          onTap: () => setState(() => _selectedStatus = 'En cours'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AdminStatCard(
                                          title: 'Livrées',
                                          value: '$livreesCount',
                                          icon: Icons.check_circle_rounded,
                                          color: AppColors.success,
                                          onTap: () => setState(() => _selectedStatus = 'Livrée'),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      AdminStatCard(
                                        title: 'Chiffre d\'affaires global',
                                        value: _formatPrice(caTotal),
                                        subtitle: 'Total cumulé des ventes de la boutique',
                                        icon: Icons.payments_rounded,
                                        color: const Color(0xFF3B82F6),
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AdminStatCard(
                                              title: 'Total',
                                              value: '$totalCount',
                                              icon: Icons.shopping_bag_rounded,
                                              color: theme.colorScheme.primary,
                                              onTap: () => setState(() => _selectedStatus = null),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: AdminStatCard(
                                              title: 'En cours',
                                              value: '$enCoursCount',
                                              icon: Icons.pending_actions_rounded,
                                              color: const Color(0xFFF59E0B),
                                              onTap: () => setState(() => _selectedStatus = 'En cours'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: AdminStatCard(
                                              title: 'Livrées',
                                              value: '$livreesCount',
                                              icon: Icons.check_circle_rounded,
                                              color: AppColors.success,
                                              onTap: () => setState(() => _selectedStatus = 'Livrée'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // 2. BARRE DE RECHERCHE & FILTRES
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppSearchBar(
                                        hintText: 'Rechercher par ID, contact, adresse...',
                                        onChanged: (q) => setState(() => _searchQuery = q),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _showSortModal(context, theme, isDark),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 44,
                                        width: 44,
                                        decoration: BoxDecoration(
                                          color: _hasActiveFilters
                                              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.12)
                                              : theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _hasActiveFilters
                                                ? theme.colorScheme.primary
                                                : dividerColor,
                                            width: _hasActiveFilters ? 1.4 : 1.0,
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.tune_rounded,
                                              color: _hasActiveFilters
                                                  ? theme.colorScheme.primary
                                                  : (isDark ? Colors.white70 : AppColors.textPrimary),
                                              size: 20,
                                            ),
                                            if (_hasActiveFilters)
                                              Positioned(
                                                top: 9,
                                                right: 9,
                                                child: Container(
                                                  width: 7,
                                                  height: 7,
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
                                const SizedBox(height: 10),

                                // Chips de filtrage par statut
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip('Toutes', null, theme, isDark, dividerColor),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('En cours', 'En cours', theme, isDark, dividerColor),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('En livraison', 'En livraison', theme, isDark, dividerColor),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('Livrées', 'Livrée', theme, isDark, dividerColor),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('Annulées', 'Annulée', theme, isDark, dividerColor),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Compteur de résultats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${filteredList.length} commande(s) trouvée(s)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textSecondary,
                                      ),
                                    ),
                                    if (_hasActiveFilters)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _searchQuery = '';
                                            _selectedStatus = null;
                                            _sortOption = AdminCommandeSortOption.newest;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          foregroundColor: AppColors.danger,
                                        ),
                                        child: const Text(
                                          'Réinitialiser',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),

                        // 3. LISTE DES COMMANDES (Grille sur écran large, Liste sur mobile)
                        if (filteredList.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: AppEmptyState(
                                title: 'Aucune commande trouvée',
                                description: _hasActiveFilters
                                    ? 'Aucune commande ne correspond à vos filtres de recherche.'
                                    : 'Aucune commande n\'a encore été enregistrée dans la boutique.',
                              ),
                            ),
                          )
                        else if (isWide || isTablet)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              24,
                            ),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 175,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, idx) {
                                  final cmd = filteredList[idx];
                                  return AdminCommandeCard(
                                    commande: cmd,
                                    onTap: () {
                                      context.push(
                                        AppRoutes.adminDetailCommandePath(cmd.id),
                                        extra: cmd,
                                      );
                                    },
                                    onStatusChanged: (newStatut) => _updateStatus(cmd.id, newStatut),
                                  );
                                },
                                childCount: filteredList.length,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              24,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, idx) {
                                  final cmd = filteredList[idx];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: AdminCommandeCard(
                                      commande: cmd,
                                      onTap: () {
                                        context.push(
                                          AppRoutes.adminDetailCommandePath(cmd.id),
                                          extra: cmd,
                                        );
                                      },
                                      onStatusChanged: (newStatut) => _updateStatus(cmd.id, newStatut),
                                    ),
                                  );
                                },
                                childCount: filteredList.length,
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
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? statusValue,
    ThemeData theme,
    bool isDark,
    Color dividerColor,
  ) {
    final isSelected = _selectedStatus == statusValue;
    final primaryColor = theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? primaryColor : dividerColor,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? primaryColor : theme.colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (sel) {
        setState(() {
          _selectedStatus = sel ? statusValue : null;
        });
      },
    );
  }

  Widget _buildSkeletonList(ThemeData theme, bool isDark, Color dividerColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, _) => Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 160,
                height: 14,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
