import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/commandes/providers/commande_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';
import '../widgets/adresse_livraison.dart';
import '../widgets/article_commande.dart';
import '../widgets/resume_commande.dart';
import '../widgets/statut_commande.dart';

class DetailCommandePage extends ConsumerStatefulWidget {
  final String commandeId;

  const DetailCommandePage({super.key, required this.commandeId});

  @override
  ConsumerState<DetailCommandePage> createState() => _DetailCommandePageState();
}

class _DetailCommandePageState extends ConsumerState<DetailCommandePage> {
  CommandeModel? _commandeDirecte;
  bool _estEnChargementDirect = false;
  String? _erreurChargement;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _verifierOuCharger());
  }

  Future<void> _verifierOuCharger() async {
    final state = ref.read(commandeProvider);
    final existe = state.commandes.any((c) => c.id == widget.commandeId);
    if (!existe) {
      setState(() {
        _estEnChargementDirect = true;
        _erreurChargement = null;
      });
      try {
        final repo = ref.read(commandeRepositoryProvider);
        final cmd = await repo.recupererCommande(widget.commandeId);
        if (mounted) {
          setState(() {
            _commandeDirecte = cmd;
            _estEnChargementDirect = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _erreurChargement = e.toString();
            _estEnChargementDirect = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    final commandeState = ref.watch(commandeProvider);

    CommandeModel? commande;
    try {
      commande = commandeState.commandes.firstWhere((c) => c.id == widget.commandeId);
    } catch (_) {
      commande = _commandeDirecte;
    }

    if (_estEnChargementDirect) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Détails de la commande',
            style: TextStyle(
              color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (commande == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Détails de la commande',
            style: TextStyle(
              color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: AppErrorState(
            title: 'Commande introuvable',
            message: _erreurChargement ?? 'La commande demandée est introuvable ou a été supprimée.',
            onRetry: _verifierOuCharger,
          ),
        ),
      );
    }

    final displayId = commande.id.isNotEmpty
        ? '#CMD-${commande.id.length > 6 ? commande.id.substring(0, 6).toUpperCase() : commande.id}'
        : '#CMD-000000';

    final dateFormatted = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(commande.dateCreation);
    final sousTotal = commande.montantTotal - commande.fraisLivraison;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Détails de la commande',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. CARTE EN-TÊTE DE COMMANDE ──
            _buildCard(
              theme: theme,
              isDark: isDark,
              dividerColor: dividerColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayId,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: commande!.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Identifiant de commande copié'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 15,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      StatutCommandeWidget(statut: commande.statut),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: TextStyle(fontSize: 12.5, color: textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.payment_rounded, size: 14, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Paiement : ${commande.modePaiement}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. SUIVI DE COMMANDE ──
            _buildSectionTitle('Suivi de votre livraison', theme),
            const SizedBox(height: 8),
            _buildCard(
              theme: theme,
              isDark: isDark,
              dividerColor: dividerColor,
              child: SuiviCommandeChronologie(statutActuel: commande.statut),
            ),

            const SizedBox(height: 16),

            // ── 3. ADRESSE DE LIVRAISON ──
            _buildSectionTitle('Informations de livraison', theme),
            const SizedBox(height: 8),
            AdresseLivraisonWidget(
              adresse: commande.adresseLivraison,
              telephone: commande.numeroTelephone ?? '',
            ),

            const SizedBox(height: 16),

            // ── 4. ARTICLES COMMANDÉS ──
            _buildSectionTitle(
              'Articles (${commande.articles.length})',
              theme,
            ),
            const SizedBox(height: 8),
            _buildCard(
              theme: theme,
              isDark: isDark,
              dividerColor: dividerColor,
              child: Column(
                children: [
                  for (int i = 0; i < commande.articles.length; i++) ...[
                    ArticleCommandeWidget(article: commande.articles[i]),
                    if (i < commande.articles.length - 1)
                      Divider(height: 1, color: dividerColor),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 5. RÉCAPITULATIF FINANCIER ──
            _buildSectionTitle('Récapitulatif du paiement', theme),
            const SizedBox(height: 8),
            _buildCard(
              theme: theme,
              isDark: isDark,
              dividerColor: dividerColor,
              child: ResumeCommandeWidget(
                sousTotal: sousTotal > 0 ? sousTotal : commande.montantTotal,
                fraisLivraison: commande.fraisLivraison,
                total: commande.montantTotal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14.5,
          color: theme.textTheme.titleSmall?.color ?? theme.colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required bool isDark,
    required Color dividerColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: dividerColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}