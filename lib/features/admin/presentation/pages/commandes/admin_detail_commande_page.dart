import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/commandes/providers/commande_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class AdminDetailCommandePage extends ConsumerStatefulWidget {
  final String commandeId;
  final CommandeModel? initialCommande;

  const AdminDetailCommandePage({
    super.key,
    required this.commandeId,
    this.initialCommande,
  });

  @override
  ConsumerState<AdminDetailCommandePage> createState() => _AdminDetailCommandePageState();
}

class _AdminDetailCommandePageState extends ConsumerState<AdminDetailCommandePage> {
  CommandeModel? _commande;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _commande = widget.initialCommande;
    if (_commande == null) {
      _chargerDetails();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _chargerDetails() async {
    if (_commande == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final repo = ref.read(commandeRepositoryProvider);
      final cmd = await repo.recupererCommande(widget.commandeId);
      if (mounted && cmd != null) {
        setState(() {
          _commande = cmd;
          _isLoading = false;
        });
      } else if (mounted && _commande == null) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _commande == null) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'livree':
      case 'livrée':
        return AppColors.success;
      case 'en livraison':
      case 'expédiée':
      case 'expediee':
        return const Color(0xFF3B82F6);
      case 'en cours':
      case 'en attente':
      case 'confirmee':
      case 'confirmée':
        return const Color(0xFFF59E0B);
      case 'annulee':
      case 'annulée':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _changerStatut(String nouveauStatut) async {
    if (_commande == null) return;
    try {
      final repo = ref.read(commandeRepositoryProvider);
      await repo.modifierStatutCommande(_commande!.id, nouveauStatut);

      setState(() {
        _commande = _commande!.copyWith(statut: nouveauStatut);
      });

      ref.invalidate(adminCommandesProvider);

      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Statut mis à jour : $nouveauStatut',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur lors de la modification : $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _supprimerCommande() async {
    if (_commande == null) return;

    final confirme = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer la commande ?',
      message: 'Voulez-vous vraiment supprimer définitivement cette commande ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirme == true && mounted) {
      try {
        final repo = ref.read(commandeRepositoryProvider);
        await repo.supprimerCommande(_commande!.id);
        ref.invalidate(adminCommandesProvider);

        if (mounted) {
          context.pop();
          AppDialogs.showSnackBar(
            context: context,
            message: 'Commande supprimée avec succès.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Erreur lors de la suppression : $e',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final shortId = widget.commandeId.length > 8
        ? widget.commandeId.substring(0, 8).toUpperCase()
        : widget.commandeId.toUpperCase();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Commande #$shortId',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _chargerDetails,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
          ),
          IconButton(
            onPressed: _supprimerCommande,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            tooltip: 'Supprimer',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _commande == null
              ? AppErrorState(
                  message: 'Erreur : $_errorMessage',
                  onRetry: _chargerDetails,
                )
              : _commande == null
                  ? const AppEmptyState(
                      title: 'Commande introuvable',
                      description: 'Cette commande n\'existe plus ou a été supprimée.',
                    )
                  : _buildContent(_commande!, theme, isDark, dividerColor, textSecondary),
    );
  }

  Widget _buildContent(
    CommandeModel cmd,
    ThemeData theme,
    bool isDark,
    Color dividerColor,
    Color textSecondary,
  ) {
    final statusColor = _getStatusColor(cmd.statut);
    final dateStr = DateFormat('dd/MM/yyyy à HH:mm').format(cmd.dateCreation);
    final isGps = cmd.adresseLivraison.startsWith('GPS:');

    final statuts = ['En cours', 'En livraison', 'Livrée', 'Annulée'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;
        final padding = isWide ? 28.0 : 16.0;

        final statusCard = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STATUT ACTUEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cmd.statut,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Passée le $dateStr',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 14),
              Text(
                'Modifier le statut :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuts.map((s) {
                  final isSelected = cmd.statut.toLowerCase() == s.toLowerCase();
                  final color = _getStatusColor(s);

                  return ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: isDark ? 0.3 : 0.2),
                    side: BorderSide(
                      color: isSelected ? color : dividerColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                    onSelected: (sel) {
                      if (sel && !isSelected) {
                        _changerStatut(s);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

        final deliveryCard = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isGps ? Icons.gps_fixed_rounded : Icons.location_on_outlined,
                    size: 20,
                    color: isGps ? const Color(0xFF10B981) : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informations de livraison',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: dividerColor),
              ),
              Text(
                'Adresse :',
                style: TextStyle(fontSize: 11.5, color: textSecondary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              SelectableText(
                cmd.adresseLivraison.isNotEmpty
                    ? cmd.adresseLivraison
                    : 'Non spécifiée',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (cmd.numeroTelephone != null && cmd.numeroTelephone!.isNotEmpty) ...[
                Text(
                  'Téléphone du client :',
                  style: TextStyle(fontSize: 11.5, color: textSecondary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    SelectableText(
                      cmd.numeroTelephone!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.copy_rounded, size: 16, color: theme.colorScheme.primary),
                      tooltip: 'Copier le numéro',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: cmd.numeroTelephone!));
                        AppDialogs.showSnackBar(context: context, message: 'Numéro copié !');
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

        final articlesCard = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ARTICLES COMMANDÉS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    '${cmd.articles.length} article(s)',
                    style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: dividerColor),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cmd.articles.length,
                separatorBuilder: (_, _) => Divider(height: 16, color: dividerColor.withValues(alpha: 0.5)),
                itemBuilder: (ctx, idx) {
                  final art = cmd.articles[idx];
                  final ligneTotal = art.prix * art.quantite;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: art.urlImage != null && art.urlImage!.isNotEmpty
                              ? Image.network(
                                  art.urlImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(Icons.toys_outlined, size: 24),
                                )
                              : const Icon(Icons.toys_outlined, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              art.titre,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${art.quantite} x ${_formatPrice(art.prix)}',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatPrice(ligneTotal),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );

        final paymentCard = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAIEMENT & TOTAL',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: textSecondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: dividerColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mode de paiement', style: TextStyle(fontSize: 13, color: textSecondary)),
                  Text(
                    cmd.modePaiement,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Frais de livraison', style: TextStyle(fontSize: 13, color: textSecondary)),
                  Text(
                    cmd.fraisLivraison == 0 ? 'Gratuite' : _formatPrice(cmd.fraisLivraison),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: dividerColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant Total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _formatPrice(cmd.montantTotal),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              statusCard,
                              const SizedBox(height: 16),
                              articlesCard,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              deliveryCard,
                              const SizedBox(height: 16),
                              paymentCard,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    statusCard,
                    const SizedBox(height: 16),
                    deliveryCard,
                    const SizedBox(height: 16),
                    articlesCard,
                    const SizedBox(height: 16),
                    paymentCard,
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Retour à la liste des commandes',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.arrow_back_rounded,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.adminCommandes);
                      }
                    },
                  ),
                  AppSpacing.verticalLg,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
