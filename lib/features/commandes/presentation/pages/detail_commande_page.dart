import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/commande_provider.dart';

class DetailCommandePage extends ConsumerStatefulWidget {
  final String commandeId;

  const DetailCommandePage({super.key, required this.commandeId});

  @override
  ConsumerState<DetailCommandePage> createState() => _DetailCommandePageState();
}

class _DetailCommandePageState extends ConsumerState<DetailCommandePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(commandeProvider.notifier).chargerDetailCommande(widget.commandeId);
      }
    });
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
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final commandeState = ref.watch(commandeProvider);
    final commande = commandeState.commandeSelectionnee;

    // Numéro de commande formaté
    String numeroCommandeAffiche = widget.commandeId.isNotEmpty
        ? '#CMD-${widget.commandeId.substring(0, widget.commandeId.length > 6 ? 6 : widget.commandeId.length).toUpperCase()}'
        : '#CMD-2026-000123';

    // Gestion du statut et des couleurs des badges
    String statut = commande?.statut ?? 'En cours';
    bool estEnCours = statut == 'En cours' || statut.isEmpty;
    Color couleurBadgeBg = estEnCours ? const Color(0xFFFFF3CD) : const Color(0xFFD4EDDA);
    Color couleurBadgeTxt = estEnCours ? const Color(0xFF856404) : const Color(0xFF155724);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Détails Commande',
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
      ),
      body: commandeState.estEnChargement
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations générales',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: dividerColor),
                        ),
                        Text(
                          'ID Commande : #${widget.commandeId}',
                          style: TextStyle(color: textSecondary, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        if (commande != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Statut :', style: TextStyle(color: textSecondary, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  commande.statut,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Montant total :', style: TextStyle(color: textSecondary, fontSize: 13)),
                              Text(
                                _formatPrice(commande.montantTotal),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (commande.adresseLivraison.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Adresse :', style: TextStyle(color: textSecondary, fontSize: 13)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    commande.adresseLivraison,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'Aucune information supplémentaire trouvée pour cette commande.',
                            style: TextStyle(color: textSecondary),
                          ),
                        ],
                        if (commandeState.messageErreur != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Erreur : ${commandeState.messageErreur}',
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Message d'erreur éventuel
                  if (commandeState.messageErreur != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Erreur : ${commandeState.messageErreur}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}