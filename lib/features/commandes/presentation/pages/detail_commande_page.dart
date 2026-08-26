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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Commande #${widget.commandeId}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
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
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations générales',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(height: 24),
                          Text('ID : ${widget.commandeId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 12),
                          if (commande != null) ...[
                            Text('Statut : ${commande.statut}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Text('Montant total : ${commande.montantTotal.toStringAsFixed(2)} XOF', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor)),
                          ] else ...[
                            const SizedBox(height: 8),
                            const Text('Aucune information supplémentaire trouvée pour cette commande.', style: TextStyle(color: Colors.grey)),
                          ],
                          if (commandeState.messageErreur != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Erreur : ${commandeState.messageErreur}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}