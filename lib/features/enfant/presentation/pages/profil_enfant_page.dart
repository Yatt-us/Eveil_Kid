import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProfilEnfantPage extends StatelessWidget {
  const ProfilEnfantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enfantProvider = context.watch<EnfantProvider>();
    final enfant = enfantProvider.enfantSelectionne;

    // Vérifier qu'un enfant est sélectionné.
    if (enfant == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Aucun enfant sélectionné',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==========================================
            // PHOTO DE PROFIL
            // ==========================================

            CircleAvatar(
              radius: 60,
              backgroundImage: enfant.avatarUrl != null
                  ? NetworkImage(enfant.avatarUrl!)
                  : null,
              child: enfant.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                    )
                  : null,
            ),

            const SizedBox(height: 20),

            // ==========================================
            // NOM DE L'ENFANT
            // ==========================================

            Text(
              enfant.nom,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ÂGE
            Text(
              '${enfant.age} ans',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            // ==========================================
            // INFORMATIONS
            // ==========================================

            _InformationCard(
              titre: 'Nom',
              valeur: enfant.nom,
              icone: Icons.person,
            ),

            _InformationCard(
              titre: 'Âge',
              valeur: '${enfant.age} ans',
              icone: Icons.cake,
            ),

            _InformationCard(
              titre: 'Genre',
              valeur: enfant.genre,
              icone: Icons.person_outline,
            ),

            _InformationCard(
              titre: 'Date de naissance',
              valeur: _formaterDate(
                enfant.dateNaissance,
              ),
              icone: Icons.calendar_month,
            ),

            const SizedBox(height: 20),

            // ==========================================
            // PROGRESSION
            // ==========================================

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ma progression',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 45,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Progression générale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const LinearProgressIndicator(
                      value: 0.0,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Les résultats seront affichés ici.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convertit la date de naissance en texte.
  static String _formaterDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Widget privé permettant d'afficher
/// une information de l'enfant.
class _InformationCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;

  const _InformationCard({
    required this.titre,
    required this.valeur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(icone),

        title: Text(
          titre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(valeur),
      ),
    );
  }
}