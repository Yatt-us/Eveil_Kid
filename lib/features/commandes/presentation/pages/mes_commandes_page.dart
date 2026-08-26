import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/commande_provider.dart';
import '../../models/commande_model.dart';
import 'detail_commande_page.dart';

class MesCommandesPage extends ConsumerStatefulWidget {
  final String parentId;

  const MesCommandesPage({super.key, required this.parentId});

  @override
  ConsumerState<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends ConsumerState<MesCommandesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final commandeState = ref.watch(commandeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes commandes',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: isDark ? Colors.white54 : AppColors.textSecondary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: commandeState.estEnChargement
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(commandeState.commandes, theme, isDark),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'En cours').toList(), theme, isDark),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'Livrée').toList(), theme, isDark),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'Annulée' || c.statut == 'annulee').toList(), theme, isDark),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<CommandeModel> commandes, ThemeData theme, bool isDark) {
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    if (commandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune commande trouvée.',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final item = commandes[index];
        final bool isEnCours = item.statut == 'En cours';
        final bool isLivree = item.statut == 'Livrée' || item.statut == 'livree';

        final Color statusBg = isLivree
            ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12)
            : (isEnCours
                ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12)
                : theme.colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.12));

        final Color statusFg = isLivree
            ? const Color(0xFF10B981)
            : (isEnCours ? const Color(0xFFF59E0B) : theme.colorScheme.error);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.textPrimary)
                    .withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.textTheme.titleSmall?.color ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.statut,
                      style: TextStyle(
                        color: statusFg,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Montant total', style: TextStyle(fontSize: 12.5, color: textSecondary)),
                  Text(
                    _formatPrice(item.montantTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailCommandePage(commandeId: item.id),
                      ),
                    );
                  },
                  child: Text(
                    'Voir les détails',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}