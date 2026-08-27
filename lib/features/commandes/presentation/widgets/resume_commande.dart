import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ResumeCommandeWidget extends StatelessWidget {
  final double sousTotal;
  final double fraisLivraison;
  final double total;

  const ResumeCommandeWidget({
    Key? key,
    required this.sousTotal,
    required this.fraisLivraison,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sous-total'),
            Text('${sousTotal.toStringAsFixed(0)} FCFA'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Livraison'),
            Text('${fraisLivraison.toStringAsFixed(0)} FCFA'),
          ],
        ),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${total.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}