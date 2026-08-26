import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/commande_model.dart';
import '../widgets/checkout_stepper.dart';
import 'paiement_page.dart';

class AdressePage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;

  const AdressePage({super.key, required this.brouillonCommande});

  @override
  ConsumerState<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends ConsumerState<AdressePage> {
  // État local pour stocker l'adresse modifiable
  late String adresseActuelle;

  @override
  void initState() {
    super.initState();
    adresseActuelle = widget.brouillonCommande.adresseLivraison.isNotEmpty
        ? widget.brouillonCommande.adresseLivraison
        : 'Cocody Riviera 2, Abidjan, Côte d\'Ivoire';
  }

  void _afficherDialogueModification() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController controller = TextEditingController(text: adresseActuelle);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 22),
              SizedBox(width: 8),
              Text(
                'Modifier l\'adresse',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Entrez la nouvelle adresse de livraison...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    adresseActuelle = controller.text.trim();
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final userName = authState.utilisateur?.nom ?? 'Client';
    final userPhone = authState.utilisateur?.telephone ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Adresse de livraison',
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
          const CheckoutStepper(stepActuel: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADRESSE SÉLECTIONNÉE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                          (isDark ? Colors.white60 : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : theme.colorScheme.primary)
                              .withValues(alpha: isDark ? 0.2 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: theme.textTheme.titleMedium?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                adresseActuelle,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75) ??
                                      (isDark ? Colors.white70 : AppColors.textSecondary),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              if (userPhone.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Tél : $userPhone',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color ??
                                        (isDark ? Colors.white54 : AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _afficherDialogueModification,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  'Modifier',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'Continuer vers le paiement',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      final commandeMiseAJour = widget.brouillonCommande.copyWith(
                        adresseLivraison: adresseActuelle,
                        numeroTelephone: userPhone,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaiementPage(brouillonCommande: commandeMiseAJour),
                        ),
                      );
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
}