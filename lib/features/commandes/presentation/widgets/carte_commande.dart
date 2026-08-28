import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/commande_model.dart';
import 'statut_commande.dart';

class CarteCommande extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback surClic;

  const CarteCommande({
    Key? key,
    required this.commande,
    required this.surClic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final texteDate = DateFormat('dd/MM/yyyy').format(commande.dateCreation);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: surClic,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Commande #${commande.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            StatutCommandeWidget(statut: commande.statut),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date : $texteDate'),
              const SizedBox(height: 4),
              Text(
                'Total : ${commande.montantTotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}