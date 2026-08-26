import 'package:flutter/material.dart';

class StatutCommandeWidget extends StatelessWidget {
  final String statut;

  const StatutCommandeWidget({Key? key, required this.statut}) : super(key: key);

  static const Map<String, Map<String, dynamic>> _infoStatut = {
    'en_attente': {'libelle': 'En attente', 'couleur': Colors.orange},
    'confirmee': {'libelle': 'Confirmée', 'couleur': Colors.blue},
    'en_preparation': {'libelle': 'En préparation', 'couleur': Colors.purple},
    'expediee': {'libelle': 'Expédiée', 'couleur': Colors.indigo},
    'livree': {'libelle': 'Livrée', 'couleur': Colors.green},
    'annulee': {'libelle': 'Annulée', 'couleur': Colors.red},
  };

  @override
  Widget build(BuildContext context) {
    final info = _infoStatut[statut] ?? {'libelle': statut, 'couleur': Colors.grey};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (info['couleur'] as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info['couleur'] as Color),
      ),
      child: Text(
        info['libelle'] as String,
        style: TextStyle(
          color: info['couleur'] as Color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SuiviCommandeChronologie extends StatelessWidget {
  final String statutActuel;

  const SuiviCommandeChronologie({Key? key, required this.statutActuel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final etapes = [
      {'cle': 'en_attente', 'libelle': 'Commandée'},
      {'cle': 'confirmee', 'libelle': 'Confirmée'},
      {'cle': 'en_preparation', 'libelle': 'En préparation'},
      {'cle': 'expediee', 'libelle': 'Expédiée'},
      {'cle': 'livree', 'libelle': 'Livrée'},
    ];

    int indexActuel = etapes.indexWhere((e) => e['cle'] == statutActuel);
    if (indexActuel == -1 && statutActuel == 'annulee') {
      return const Center(
        child: Text(
          'Cette commande a été annulée.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: List.generate(etapes.length, (index) {
        bool estFait = index <= indexActuel;
        bool estEnCours = index == indexActuel;

        return Row(
          children: [
            Column(
              children: [
                Icon(
                  estFait ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: estFait ? Colors.green : Colors.grey,
                  size: 24,
                ),
                if (index < etapes.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: index < indexActuel ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              etapes[index]['libelle']!,
              style: TextStyle(
                fontWeight: estEnCours ? FontWeight.bold : FontWeight.normal,
                color: estFait ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}