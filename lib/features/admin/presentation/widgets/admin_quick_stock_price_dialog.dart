import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

class AdminQuickStockPriceDialog extends ConsumerStatefulWidget {
  final Jouet jouet;

  const AdminQuickStockPriceDialog({
    super.key,
    required this.jouet,
  });

  @override
  ConsumerState<AdminQuickStockPriceDialog> createState() =>
      _AdminQuickStockPriceDialogState();
}

class _AdminQuickStockPriceDialogState
    extends ConsumerState<AdminQuickStockPriceDialog> {
  late TextEditingController _prixController;
  late int _stock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prixController =
        TextEditingController(text: widget.jouet.prix.toStringAsFixed(0));
    _stock = widget.jouet.stockDisponible;
  }

  @override
  void dispose() {
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final double? nouveauPrix = double.tryParse(_prixController.text.trim());
    if (nouveauPrix == null || nouveauPrix < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir un prix valide.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(jouetRepositoryProvider);
      await repo.modifierPrixEtStock(
        widget.jouet.jouetId,
        prix: nouveauPrix,
        stock: _stock,
        stockDisponible: _stock,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text("Prix et stock mis à jour avec succès !"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text("Erreur lors de la mise à jour: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ajustement express",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.jouet.nom,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24, color: AppColors.border),
            // Modification du Prix
            AppTextField(
              controller: _prixController,
              label: "Prix (${widget.jouet.devise})",
              hintText: "ex: 15000",
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_outlined,
            ),
            AppSpacing.verticalMd,
            // Modification du Stock avec Stepper
            const Text(
              "Stock disponible",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                    onPressed: _stock > 0
                        ? () => setState(() => _stock--)
                        : null,
                  ),
                  Text(
                    "$_stock unités",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    onPressed: () => setState(() => _stock++),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLg,
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "Annuler",
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: "Enregistrer",
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
