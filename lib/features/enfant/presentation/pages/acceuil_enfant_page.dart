import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AccueilEnfantPage extends StatelessWidget {
  const AccueilEnfantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enfantProvider =
        context.watch<EnfantProvider>();

    final enfant =
        enfantProvider.enfantSelectionne;

    // Aucun enfant sélectionné.
    if (enfant == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Aucun enfant sélectionné',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bonjour ${enfant.nom} 👋',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // PHOTO + INFORMATIONS
            // =========================

            Row(
              children: [
                CircleAvatar(
                  radius: 40,

                  backgroundImage:
                      enfant.avatarUrl != null
                          ? NetworkImage(
                              enfant.avatarUrl!,
                            )
                          : null,

                  child:
                      enfant.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                            )
                          : null,
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      enfant.nom,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${enfant.age} ans',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =========================
            // PROGRESSION
            // =========================

            const Text(
              'Ma progression',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Progression générale',
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: 0.0,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Progression bientôt disponible',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // ACTIVITÉS
            // =========================

            const Text(
              'Activités recommandées 🎮',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  'Les activités adaptées à l’âge '
                  'de l’enfant seront affichées ici.',
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // TUTORIELS
            // =========================

            const Text(
              'Mes tutoriels 📺',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  'Les tutoriels adaptés à l’âge '
                  'de l’enfant seront affichés ici.',
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // PRODUITS
            // =========================

            const Text(
              'Produits suggérés 🛍️',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  'Les produits adaptés à l’âge '
                  'de l’enfant seront affichés ici.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}