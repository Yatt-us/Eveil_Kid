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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 24),
                  Text(
                    'Merci pour votre commande !',
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
                  const SizedBox(height: 28),

                  // Informations récapitulatives de commande
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'N° DE COMMANDE',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commande.id.isNotEmpty
                                  ? '#${commande.id.length > 8 ? commande.id.substring(0, 8) : commande.id}'
                                  : 'En cours',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commande.statut,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

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