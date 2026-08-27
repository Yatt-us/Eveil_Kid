import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/commande_provider.dart';

class DetailCommandePage extends ConsumerStatefulWidget {
  final String commandeId;

  const DetailCommandePage({super.key, required this.commandeId});

  @override
  ConsumerState<DetailCommandePage> createState() => _DetailCommandePageState();
}

class _DetailCommandePageState extends ConsumerState<DetailCommandePage> {
  static const Color primaryColor = Color(0xFF7E3DBE);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(commandeProvider.notifier).chargerDetailCommande(widget.commandeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final commandeState = ref.watch(commandeProvider);
    final commande = commandeState.commandeSelectionnee;

    // Numéro de commande formaté
    String numeroCommandeAffiche = widget.commandeId.isNotEmpty
        ? '#CMD-${widget.commandeId.substring(0, widget.commandeId.length > 6 ? 6 : widget.commandeId.length).toUpperCase()}'
        : '#CMD-2026-000123';

    // Gestion du statut et des couleurs des badges
    String statut = commande?.statut ?? 'En cours';
    bool estEnCours = statut == 'En cours' || statut.isEmpty;
    Color couleurBadgeBg = estEnCours ? const Color(0xFFFFF3CD) : const Color(0xFFD4EDDA);
    Color couleurBadgeTxt = estEnCours ? const Color(0xFF856404) : const Color(0xFF155724);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Détails commandes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: commandeState.estEnChargement
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              numeroCommandeAffiche,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: couleurBadgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statut,
                                style: TextStyle(
                                  color: couleurBadgeTxt,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12-15 MAI 2026',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Colors.black12),
                        ),

                        // Liste des articles s'ils existent
                        if (commande != null && commande.articles.isNotEmpty) ...[
                          const Text(
                            'Articles commandés',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commande.articles.length,
                            itemBuilder: (context, index) {
                              final article = commande.articles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: (article.urlImage != null && article.urlImage!.isNotEmpty)
                                            ? Image.network(article.urlImage!, fit: BoxFit.cover)
                                            : const Icon(Icons.shopping_bag, size: 20, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.titre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Qté : ${article.quantite}',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(article.prix * article.quantite).toStringAsFixed(2)} XOF',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Colors.black12),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Totaux et livraison
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              commande != null
                                  ? '${commande.montantTotal.toStringAsFixed(2)} XOF'
                                  : '0.00 XOF',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Livraison estimée', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            Text(
                              '12-15 MAI 2026',
                              style: TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Message d'erreur éventuel
                  if (commandeState.messageErreur != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Erreur : ${commandeState.messageErreur}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}