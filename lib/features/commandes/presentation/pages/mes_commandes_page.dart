import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';
import '../../models/commande_model.dart';
import '../../providers/commande_provider.dart';
import '../widgets/statut_commande.dart';
import 'detail_commande_page.dart';

class MesCommandesPage extends ConsumerStatefulWidget {
  final String parentId;
  const MesCommandesPage({super.key, required this.parentId});

  @override
  ConsumerState<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends ConsumerState<MesCommandesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.microtask(() {
      if (mounted) {
        ref.read(commandeProvider.notifier).chargerCommandes(widget.parentId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final commandeState = ref.watch(commandeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes commandes',
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          tooltip: 'Retour',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.read(commandeProvider.notifier).chargerCommandes(widget.parentId);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(3),
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: dividerColor, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'En cours'),
                Tab(text: 'Livrées'),
                Tab(text: 'Annulées'),
              ],
            ),
          ),
        ),
      ),
      body: commandeState.estEnChargement
          ? Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                  commandes: commandeState.commandes,
                  emptyMessage: 'Aucune commande enregistrée pour le moment.',
                  theme: theme,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  textSecondary: textSecondary,
                ),
                _buildOrderList(
                  commandes: commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'en cours' ||
                        s == 'en_cours' ||
                        s == 'en attente' ||
                        s == 'en_attente' ||
                        s == 'pending' ||
                        s == 'confirmee' ||
                        s == 'confirmée' ||
                        s == 'en preparation' ||
                        s == 'en préparation' ||
                        s == 'expediee' ||
                        s == 'expédiée';
                  }).toList(),
                  emptyMessage: 'Aucune commande en cours.',
                  theme: theme,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  textSecondary: textSecondary,
                ),
                _buildOrderList(
                  commandes: commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'livrée' || s == 'livree' || s == 'delivered';
                  }).toList(),
                  emptyMessage: 'Aucune commande livrée pour le moment.',
                  theme: theme,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  textSecondary: textSecondary,
                ),
                _buildOrderList(
                  commandes: commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'annulée' || s == 'annulee' || s == 'cancelled';
                  }).toList(),
                  emptyMessage: 'Aucune commande annulée.',
                  theme: theme,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  textSecondary: textSecondary,
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList({
    required List<CommandeModel> commandes,
    required String emptyMessage,
    required ThemeData theme,
    required bool isDark,
    required Color dividerColor,
    required Color textSecondary,
  }) {
    if (commandes.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Aucune commande',
          description: emptyMessage,
          actionText: 'Découvrir la boutique',
          onActionPressed: () => context.go(AppRoutes.jouetscreen),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(commandeProvider.notifier).chargerCommandes(widget.parentId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: commandes.length,
        itemBuilder: (context, index) {
          final item = commandes[index];
          return _buildOrderCard(
            item: item,
            theme: theme,
            isDark: isDark,
            dividerColor: dividerColor,
            textSecondary: textSecondary,
          );
        },
      ),
    );
  }

  Widget _buildOrderCard({
    required CommandeModel item,
    required ThemeData theme,
    required bool isDark,
    required Color dividerColor,
    required Color textSecondary,
  }) {
    final String displayId = item.id.isNotEmpty
        ? '#CMD-${item.id.length > 6 ? item.id.substring(0, 6).toUpperCase() : item.id}'
        : '#CMD-000000';

    final String dateFormatted = DateFormat('dd/MM/yyyy à HH:mm').format(item.dateCreation);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: dividerColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête : Référence + Statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayId,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                StatutCommandeWidget(statut: item.statut),
              ],
            ),
            const SizedBox(height: 4),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  dateFormatted,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Aperçu horizontal des articles
            if (item.articles.isNotEmpty) ...[
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.articles.length > 3 ? 4 : item.articles.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, artIndex) {
                    if (artIndex == 3 && item.articles.length > 3) {
                      final int reste = item.articles.length - 3;
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : const Color(0xFFF1EEFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Center(
                          child: Text(
                            '+$reste',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    final article = item.articles[artIndex];
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dividerColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: article.urlImage != null && article.urlImage!.isNotEmpty
                            ? Image.network(
                                article.urlImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.toys_rounded,
                                  color: textSecondary,
                                  size: 22,
                                ),
                              )
                            : Icon(
                                Icons.toys_rounded,
                                color: textSecondary,
                                size: 22,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 3. Ligne de Séparation
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 10),

            // 4. Détail Montant & Mode de Paiement
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.articles.length} article(s)',
                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                ),
                Text(
                  _formatPrice(item.montantTotal),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Bouton d'action "Voir les détails"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.25),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onPressed: () {
                  context.push(AppRoutes.parentDetailCommandePath(item.id));
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 16),
                label: const Text(
                  'Voir les détails de la commande',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}