import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../models/commande_model.dart';
import '../widgets/checkout_stepper.dart';
import 'mes_commandes_page.dart';

class ConfirmationPage extends StatelessWidget {
  final CommandeModel commande;

  const ConfirmationPage({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    const Color successColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const CheckoutStepper(stepActuel: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Icône de succès
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: successColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 55,
                      color: successColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Merci pour votre commande !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre commande a été enregistrée avec succès.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informations récapitulatives de commande
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: dividerColor),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'N° DE COMMANDE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  commande.id.isNotEmpty
                                      ? '#${commande.id.length > 8 ? commande.id.substring(0, 8).toUpperCase() : commande.id.toUpperCase()}'
                                      : 'En cours',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 32, color: dividerColor),
                            Column(
                              children: [
                                Text(
                                  'STATUT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  commande.statut,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: successColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (commande.montantTotal > 0 || commande.articles.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: dividerColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${commande.articles.length} article(s)',
                                style: TextStyle(fontSize: 13, color: textSecondary),
                              ),
                              Text(
                                '${commande.montantTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]} ")} FCFA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton Voir mes commandes
                  AppButton(
                    text: 'Voir mes commandes',
                    icon: Icons.receipt_long_rounded,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MesCommandesPage(parentId: commande.parentId),
                        ),
                      );
                    },
                  ),
                  AppSpacing.verticalSm,

                  // Bouton Retour à l'accueil
                  AppButton(
                    text: 'Retour à l\'accueil',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.home_outlined,
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  AppSpacing.verticalMd,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}