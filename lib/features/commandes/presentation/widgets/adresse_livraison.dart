import 'package:flutter/material.dart';

class AdresseLivraisonWidget extends StatelessWidget {
  final String adresse;
  final String telephone;
  final VoidCallback? surModification;

  const AdresseLivraisonWidget({
    super.key,
    required this.adresse,
    required this.telephone,
    this.surModification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Adresse de livraison',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (surModification != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: surModification,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(adresse),
            const SizedBox(height: 4),
            Text('Téléphone : $telephone'),
          ],
        ),
      ),
    );
  }
}