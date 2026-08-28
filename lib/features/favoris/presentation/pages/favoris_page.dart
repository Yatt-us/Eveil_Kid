import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';
import 'package:eveilkid/features/favoris/providers/favoris_providers.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_detail_screen.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_app_bar_action.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_floating_button.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_detail_page.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class FavorisPage extends ConsumerStatefulWidget {
  const FavorisPage({super.key});

  @override
  ConsumerState<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends ConsumerState<FavorisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Favori> _filterFavoris(List<Favori> list, int tabIndex) {
    final query = _searchQuery.trim().toLowerCase();

    return list.where((f) {
      final matchesQuery = query.isEmpty || f.titre.toLowerCase().contains(query);

      final matchesTab = switch (tabIndex) {
        1 => f.typeElement == TypeElement.jouet,
        2 => f.typeElement == TypeElement.tutoriel,
        _ => true,
      };

      return matchesQuery && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.utilisateur?.utilisateurId ?? '';
    final favorisAsync = ref.watch(currentUserFavorisProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final allFavoris = favorisAsync.value ?? [];
    final jouetsCount = allFavoris.where((f) => f.typeElement == TypeElement.jouet).length;
    final tutorielsCount = allFavoris.where((f) => f.typeElement == TypeElement.tutoriel).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          tooltip: 'Retour',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
        title: Text(
          'Mes Favoris',
          style: AppTextStyles.headingSmall.copyWith(
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: const [
          PanierAppBarAction(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── BARRE DE RECHERCHE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Rechercher dans mes favoris...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // ── SÉLECTEUR D'ONGLETS (TOUS / JOUETS / TUTORIELS) ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(3),
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(9),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tous'),
                        const SizedBox(width: 5),
                        _buildTabBadge(context, '${allFavoris.length}', _tabController.index == 0),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Jouets'),
                        const SizedBox(width: 5),
                        _buildTabBadge(context, '$jouetsCount', _tabController.index == 1),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tutoriels'),
                        const SizedBox(width: 5),
                        _buildTabBadge(context, '$tutorielsCount', _tabController.index == 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENU DES FAVORIS ──
            Expanded(
              child: favorisAsync.when(
                data: (favorisList) {
                  final filtered = _filterFavoris(favorisList, _tabController.index);

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: _searchQuery.isNotEmpty
                          ? 'Aucun résultat trouvé'
                          : 'Aucun favori enregistré',
                      description: _searchQuery.isNotEmpty
                          ? 'Aucun favori ne correspond à votre recherche.'
                          : 'Explorez nos jouets et tutoriels et ajoutez vos coups de cœur avec le bouton cœur !',
                      icon: Icons.favorite_border_rounded,
                      actionText: _searchQuery.isNotEmpty ? 'Effacer la recherche' : null,
                      onActionPressed: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          : null,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildFavoriCard(context, item, userId);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) => const AppSkeletonLoader(height: 95, borderRadius: 16),
                ),
                error: (error, _) => AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(currentUserFavorisProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const PanierFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildTabBadge(BuildContext context, String count, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
            : (isDark ? theme.colorScheme.surface : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        count,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFavoriCard(BuildContext context, Favori favori, String userId) {
    final theme = Theme.of(context);
    final isJouet = favori.typeElement == TypeElement.jouet;

    return AppCard(
      onTap: () => _openDetail(context, favori),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Miniature
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 75,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  favori.miniatureUrl.isNotEmpty
                      ? Image.network(
                          favori.miniatureUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(context, isJouet),
                        )
                      : _buildPlaceholder(context, isJouet),
                  if (!isJouet)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Détails textuels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isJouet
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isJouet ? 'Jouet' : 'Tutoriel Vidéo',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isJouet
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  favori.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                  ),
                ),
                if (isJouet && favori.prix > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${favori.prix.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bouton suppression favori
          IconButton(
            icon: const Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            tooltip: 'Retirer des favoris',
            onPressed: () => _removeFavori(context, favori, userId),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isJouet) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          isJouet ? Icons.toys_rounded : Icons.video_library_rounded,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Future<void> _removeFavori(BuildContext context, Favori favori, String userId) async {
    try {
      await ref.read(favoriServiceProvider).supprimerFavori(
            favori.favoriId,
            utilisateurId: userId,
          );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('« ${favori.titre} » retiré des favoris'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () {
              ref.read(favoriServiceProvider).ajouterFavori(favori);
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _openDetail(BuildContext context, Favori favori) async {
    if (favori.typeElement == TypeElement.jouet) {
      final userId = ref.read(authProvider).utilisateur?.utilisateurId ?? '';
      final jouet = await ref.read(jouetByIdProvider(favori.elementId).future);
      if (!context.mounted) return;

      if (jouet != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JouetDetailScreen(
              jouet: jouet,
              utilisateurId: userId,
            ),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TutorielDetailPage(tutorielId: favori.elementId),
        ),
      );
    }
  }
}
