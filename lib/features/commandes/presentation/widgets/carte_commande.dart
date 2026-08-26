import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/commande_model.dart';
import 'statut_commande.dart';

class CarteCommande extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback surClic;

  const CarteCommande({
    super.key,
    required this.commande,
    required this.surClic,
  });

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
    final texteDate = DateFormat('dd/MM/yyyy').format(commande.dateCreation);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: surClic,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Commande #${commande.id.length > 8 ? commande.id.substring(0, 8) : commande.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            StatutCommandeWidget(statut: commande.statut),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date : $texteDate',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total : ${_formatPrice(commande.montantTotal)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDark ? Colors.white38 : Colors.grey.shade400,
        ),
      ),
    );
  }
}