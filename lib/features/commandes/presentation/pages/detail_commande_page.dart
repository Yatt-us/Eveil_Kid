import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/commande_provider.dart';

class DetailCommandePage extends ConsumerWidget {
  final String commandeId;
  static const Color primaryColor = Color(0xFF7E3DBE);

  const DetailCommandePage({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandeState = ref.watch(commandeProvider);
    
    final commande = commandeState.commandes.firstWhere(
      (c) => c.id == commandeId,
      orElse: () => throw Exception("Commande introuvable"),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Détails de la commande', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commande #${commande.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Articles commandés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commande.articles.length,
              itemBuilder: (context, index) {
                final article = commande.articles[index];
                return ListTile(
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: article.urlImage != null && article.urlImage!.isNotEmpty
                          ? Image.network(article.urlImage!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Image.asset('assets/images/commande.png', fit: BoxFit.cover))
                          : Image.asset('assets/images/commande.png', fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(article.titre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('Quantité : ${article.quantite}', style: const TextStyle(fontSize: 11)),
                  trailing: Text('${article.prix.toStringAsFixed(0)} XOF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                );
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('${commande.montantTotal.toStringAsFixed(0)} XOF', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Livraison', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('Gratuite', style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${commande.montantTotal.toStringAsFixed(0)} XOF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}