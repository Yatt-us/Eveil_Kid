// lib/features/panier/presentation/pages/panier_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../commandes/models/commande_model.dart';
import '../../../commandes/presentation/pages/adresse_page.dart';
import '../../../../core/provider/bottom_nav_bar_provider.dart';
import '../../models/panier.dart';
import '../../providers/panier_provider.dart';

class PanierPage extends ConsumerWidget {
  const PanierPage({super.key});

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  void _passerCommande(
    BuildContext context,
    WidgetRef ref,
    List<ArticlePanier> articles,
    String userId,
  ) {
    if (articles.isEmpty) return;

    final panierService = ref.read(panierServiceProvider);
    final total = panierService.calculerTotal(articles);

    final articlesCommande = articles
        .map(
          (a) => ArticleCommandeModel(
            produitId: a.jouetId,
            titre: a.nomJouet,
            quantite: a.quantite,
            prix: a.prixUnitaire,
            urlImage: a.miniatureUrl,
          ),
        )
        .toList();

    final brouillon = CommandeModel(
      id: '',
      parentId: userId,
      articles: articlesCommande,
      montantTotal: total,
      adresseLivraison: '',
      dateCreation: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdressePage(brouillonCommande: brouillon),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final userId = authState.utilisateur?.utilisateurId ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Mon Panier',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (userId.isNotEmpty)
            Consumer(
              builder: (context, ref, _) {
                final panierAsync = ref.watch(panierProvider(userId));
                final hasArticles = panierAsync.when(
                  data: (list) => list.isNotEmpty,
                  loading: () => false,
                  error: (_, _) => false,
                );

                if (!hasArticles) return const SizedBox.shrink();

                return IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Vider le panier',
                  onPressed: () async {
                    final confirmed = await AppDialogs.showConfirmDialog(
                      context: context,
                      title: 'Vider le panier',
                      message:
                          'Voulez-vous retirer tous les articles de votre panier ?',
                      confirmText: 'Vider',
                      cancelText: 'Annuler',
                      isDanger: true,
                    );
                    if (confirmed == true) {
                      await ref
                          .read(panierServiceProvider)
                          .viderPanier(userId);
                      if (context.mounted) {
                        AppDialogs.showSnackBar(
                          context: context,
                          message: 'Panier vidé.',
                        );
                      }
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: userId.isEmpty
          ? _buildUnauthenticatedState(context, theme)
          : ref.watch(panierProvider(userId)).when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return _buildEmptyState(context, ref, theme);
                  }

                  final total = ref
                      .read(panierServiceProvider)
                      .calculerTotal(articles);
                  final totalQuantite = articles.fold<int>(
                    0,
                    (sum, item) => sum + item.quantite,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: AppPadding.screenLarge,
                          itemCount: articles.length,
                          separatorBuilder: (_, _) =>
                              AppSpacing.verticalSm,
                          itemBuilder: (context, index) {
                            final item = articles[index];
                            return _buildCartItemCard(
                              context,
                              ref,
                              item,
                              theme,
                              isDark,
                            );
                          },
                        ),
                      ),

                      // ── BARRE INFERIEURE RÉCAPITULATIF & COMMANDE ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : AppColors.textPrimary)
                                  .withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total ($totalQuantite article${totalQuantite > 1 ? 's' : ''})',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.8) ??
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _formatPrice(total),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.verticalMd,
                              AppButton(
                                text: 'Passer la commande',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: () => _passerCommande(
                                  context,
                                  ref,
                                  articles,
                                  userId,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Erreur de chargement du panier : $err',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    WidgetRef ref,
    ArticlePanier item,
    ThemeData theme,
    bool isDark,
  ) {
    final panierService = ref.read(panierServiceProvider);

    return Dismissible(
      key: Key(item.articlePanierId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        panierService.supprimerProduit(item.articlePanierId);
        AppDialogs.showSnackBar(
          context: context,
          message: '${item.nomJouet} retiré du panier.',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.textPrimary)
                  .withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 75,
                height: 75,
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.surfaceVariant,
                child: item.miniatureUrl.isNotEmpty
                    ? Image.network(
                        item.miniatureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.toys_outlined,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.toys_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),
            AppSpacing.horizontalMd,

            // Infos & Contrôle quantité
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nomJouet,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleSmall?.color ??
                          theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(item.prixUnitaire),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ligne quantité & suppression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Boutons - / +
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: item.quantite > 1
                                  ? () => panierService.diminuerQuantite(item)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${item.quantite}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyMedium?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: item.quantite < item.stockDispo
                                  ? () => panierService.augmenterQuantite(item)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // Sous-total item
                      Text(
                        _formatPrice(item.sousTotal),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: AppPadding.screenLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            AppSpacing.verticalLg,
            Text(
              'Votre panier est vide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              'Découvrez nos jeux éducatifs et jouets d\'éveil pour remplir votre panier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.7) ??
                    theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            AppSpacing.verticalXl,
            ElevatedButton.icon(
              onPressed: () {
                ref.read(bottomIndexProvider.notifier).setIndex(1);
                context.go(AppRoutes.jouetscreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              icon: const Icon(Icons.storefront_rounded),
              label: const Text(
                'Explorer la boutique',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: AppPadding.screenLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 54,
                color: theme.colorScheme.primary,
              ),
            ),
            AppSpacing.verticalLg,
            Text(
              'Connexion requise',
              style: AppTextStyles.headingMedium.copyWith(
                color: theme.textTheme.titleLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            Text(
              'Connectez-vous pour ajouter des articles et consulter votre panier.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.7) ??
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalXl,
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text(
                'Se connecter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
