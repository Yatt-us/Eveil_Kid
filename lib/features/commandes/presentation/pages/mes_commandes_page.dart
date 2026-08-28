// lib/features/commandes/presentation/pages/mes_commandes_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/commande_provider.dart';
import '../../models/commande_model.dart';
import 'detail_commande_page.dart';

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
                _buildOrderList(
                  commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'en cours' || s == 'en_cours' || s == 'pending';
                  }).toList(),
                ),
                _buildOrderList(
                  commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'livrée' || s == 'livree' || s == 'delivered';
                  }).toList(),
                ),
                _buildOrderList(
                  commandeState.commandes.where((c) {
                    final s = c.statut.trim().toLowerCase();
                    return s == 'annulée' || s == 'annulee' || s == 'cancelled';
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<CommandeModel> commandes) {
    if (commandes.isEmpty) {
      return const Center(
        child: Text(
          'Aucune commande trouvée.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final item = commandes[index];
        final statutLower = item.statut.trim().toLowerCase();
        
        bool isEnCours = statutLower == 'en cours' || statutLower == 'en_cours' || statutLower == 'pending';
        bool isLivree = statutLower == 'livrée' || statutLower == 'livree' || statutLower == 'delivered';
        
        Color badgeBg;
        Color badgeTxt;

        if (isEnCours) {
          badgeBg = const Color(0xFFFFF7E6);
          badgeTxt = const Color(0xFFFF9900);
        } else if (isLivree) {
          badgeBg = const Color(0xFFE6F7ED);
          badgeTxt = const Color(0xFF289F51);
        } else {
          // Pour les annulées ou autres statuts
          badgeBg = const Color(0xFFFFECEE);
          badgeTxt = const Color(0xFFE53935);
        }

        String displayId = item.id.isNotEmpty 
            ? '#CMD-${item.id.length > 6 ? item.id.substring(0, 6).toUpperCase() : item.id}' 
            : '#CMD-2025-000123';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.statut,
                        style: TextStyle(
                          color: badgeTxt,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '12-15 MAI 2025',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Aperçu horizontal des articles
                if (item.articles.isNotEmpty) ...[
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.articles.length > 3 ? 4 : item.articles.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, artIndex) {
                        if (artIndex == 3 && item.articles.length > 3) {
                          int reste = item.articles.length - 3;
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: Text(
                                '+$reste',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        final article = item.articles[artIndex];
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (article.urlImage != null && article.urlImage!.isNotEmpty)
                                ? Image.network(
                                    article.urlImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/commande.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => const Icon(Icons.image, color: Colors.grey),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/commande.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => const Icon(Icons.image, color: Colors.grey),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${item.montantTotal.toStringAsFixed(0)} XOF',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Livraison estimée', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('12-15 MAI 2025', style: TextStyle(fontSize: 11, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFE8F7),
                      foregroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailCommandePage(commandeId: item.id),
                        ),
                      );
                    },
                    child: const Text(
                      'Voir les détails',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
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