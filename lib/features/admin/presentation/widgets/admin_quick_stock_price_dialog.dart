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
            backgroundColor: Color(0xFF10B981),
            content: Text("Prix et stock mis à jour avec succès !"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text("Erreur lors de la mise à jour: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ajustement express",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                        AppColors.icon,
                  ),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.jouet.nom,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7) ??
                    AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(height: 24, color: dividerColor),
            // Modification du Prix
            AppTextField(
              controller: _prixController,
              labelText: "Prix (${widget.jouet.devise})",
              hintText: "ex: 15000",
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_outlined,
            ),
            AppSpacing.verticalMd,
            // Modification du Stock avec Stepper
            Text(
              "Stock disponible",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(12),
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.surfaceVariant.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.primary),
                    onPressed: _stock > 0
                        ? () => setState(() => _stock--)
                        : null,
                  ),
                  Text(
                    "$_stock unités",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
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
