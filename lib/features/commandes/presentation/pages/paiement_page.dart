import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../models/commande_model.dart';
import '../../providers/commande_provider.dart';
import '../widgets/checkout_stepper.dart';
import 'confirmation_page.dart';

class PaiementPage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;

  const PaiementPage({super.key, required this.brouillonCommande});

  @override
  ConsumerState<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends ConsumerState<PaiementPage> {
  String modePaiementSelectionne = 'Mobile Money';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Paiement',
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
      body: Column(
        children: [
          const CheckoutStepper(stepActuel: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MÉTHODE DE PAIEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    'Mobile Money',
                    Icons.phone_android_rounded,
                    'Wave, Orange Money, MTN, Moov',
                    theme,
                    isDark,
                  ),
                  _buildPaymentOption(
                    'Carte bancaire',
                    Icons.credit_card_rounded,
                    'Visa, Mastercard sécurisé',
                    theme,
                    isDark,
                  ),
                  _buildPaymentOption(
                    'Paiement à la livraison',
                    Icons.local_shipping_outlined,
                    'Payez en espèces ou par Wave à la réception',
                    theme,
                    isDark,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'RÉSUMÉ DU MONTANT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sous-total articles', style: TextStyle(color: textSecondary, fontSize: 13.5)),
                            Text(
                              _formatPrice(widget.brouillonCommande.montantTotal - widget.brouillonCommande.fraisLivraison),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Frais de livraison', style: TextStyle(color: textSecondary, fontSize: 13.5)),
                            Text(
                              widget.brouillonCommande.fraisLivraison == 0
                                  ? 'Gratuite'
                                  : _formatPrice(widget.brouillonCommande.fraisLivraison),
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: dividerColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total à payer',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _formatPrice(widget.brouillonCommande.montantTotal),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: 'Payer ${_formatPrice(widget.brouillonCommande.montantTotal)}',
                    icon: Icons.lock_outline_rounded,
                    isLoading: commandeState.estEnChargement,
                    onPressed: commandeState.estEnChargement
                        ? null
                        : () async {
                            final authUser = ref.read(authProvider).utilisateur;
                            final parentId = widget.brouillonCommande.parentId.isNotEmpty
                                ? widget.brouillonCommande.parentId
                                : (authUser?.utilisateurId ?? '');

                            final commandeFinale = widget.brouillonCommande.copyWith(
                              parentId: parentId,
                              modePaiement: modePaiementSelectionne,
                              dateCreation: DateTime.now(),
                            );

                            final commandeCreee = await ref
                                .read(commandeProvider.notifier)
                                .passerCommande(commandeFinale);

                            if (!context.mounted) return;

                            if (commandeCreee != null) {
                              if (parentId.isNotEmpty) {
                                try {
                                  await ref
                                      .read(panierServiceProvider)
                                      .viderPanier(parentId);
                                } catch (_) {}
                              }

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfirmationPage(commande: commandeCreee),
                                  ),
                                  (route) => route.isFirst,
                                );
                              }
                            } else {
                              final errorMsg = ref.read(commandeProvider).messageErreur ??
                                  'Impossible d\'enregistrer la commande. Veuillez réessayer.';
                              AppDialogs.showSnackBar(
                                context: context,
                                message: errorMsg,
                                isError: true,
                              );
                            }
                          },
                  ),
                  AppSpacing.verticalLg,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String subtitle,
    ThemeData theme,
    bool isDark,
  ) {
    final bool isSelected = modePaiementSelectionne == title;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => modePaiementSelectionne = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? primaryColor : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.8 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.1)
                    : (isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : AppColors.surfaceVariant.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : (theme.iconTheme.color ?? theme.colorScheme.onSurfaceVariant),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? primaryColor
                          : (theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                          (isDark ? Colors.white60 : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryColor : (isDark ? Colors.white30 : Colors.grey.shade400),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
