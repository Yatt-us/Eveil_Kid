import 'package:flutter/material.dart';

class AdresseLivraisonWidget extends StatelessWidget {
  final String adresse;
  final String telephone;
  final VoidCallback? surModification;

  const AdresseLivraisonWidget({
    Key? key,
    required this.adresse,
    required this.telephone,
    this.surModification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
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