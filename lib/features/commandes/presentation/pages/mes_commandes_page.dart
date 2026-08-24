import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/commande_provider.dart';
import '../../models/commande_model.dart';
import 'detail_commande_page.dart'; // Assure-toi que ce chemin correspond à ton arborescence

class MesCommandesPage extends ConsumerStatefulWidget {
  final String parentId;

  const MesCommandesPage({super.key, required this.parentId});

  @override
  ConsumerState<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends ConsumerState<MesCommandesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color primaryColor = Color(0xFF7E3DBE);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      if (mounted) {
        ref.read(commandeProvider.notifier).chargerCommandes(widget.parentId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandeState = ref.watch(commandeProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes commandes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: commandeState.estEnChargement
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(commandeState.commandes),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'En cours').toList()),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'Livrée').toList()),
                _buildOrderList(commandeState.commandes.where((c) => c.statut == 'Annulée' || c.statut == 'annulee').toList()),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<CommandeModel> commandes) {
    if (commandes.isEmpty) {
      return const Center(child: Text('Aucune commande trouvée.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final item = commandes[index];
        bool isEnCours = item.statut == 'En cours';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${item.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEnCours ? const Color(0xFFFFF7E6) : const Color(0xFFE6F7ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.statut,
                        style: TextStyle(
                          color: isEnCours ? const Color(0xFFFF9900) : const Color(0xFF289F51),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${item.montantTotal.toStringAsFixed(2)} XOF', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      // 🚀 Le bouton est cliquable et transmet l'ID réel de la commande
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailCommandePage(commandeId: item.id),
                        ),
                      );
                    },
                    child: const Text('Voir les détails', style: TextStyle(color: primaryColor, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}