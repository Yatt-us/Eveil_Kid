import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eveilkid/features/admin/presentation/pages/commandes/admin_commandes_screen.dart';
import 'package:eveilkid/features/admin/presentation/pages/commandes/admin_detail_commande_page.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_commande_card.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/commandes/providers/commande_provider.dart';

void main() {
  group('Admin Commandes Tests', () {
    final sampleArticles = [
      ArticleCommandeModel(
        produitId: 'prod_1',
        titre: 'Jeu Éducatif Formes & Couleurs',
        quantite: 2,
        prix: 12000.0,
      ),
      ArticleCommandeModel(
        produitId: 'prod_2',
        titre: 'Livre Interactif des Animaux',
        quantite: 1,
        prix: 8000.0,
      ),
    ];

    final sampleCommande = CommandeModel(
      id: 'CMD12345678',
      parentId: 'parent_001',
      articles: sampleArticles,
      montantTotal: 32000.0,
      fraisLivraison: 0.0,
      statut: 'En cours',
      adresseLivraison: 'GPS: 5.359952°, 3.996144° (Cocody Riviera 3)',
      modePaiement: 'Mobile Money',
      dateCreation: DateTime(2026, 8, 29, 21, 30),
      numeroTelephone: '+225 07 12 34 56 78',
    );

    testWidgets('AdminCommandeCard displays short ID, status, items and phone', (tester) async {
      bool statusChanged = false;
      String changedTo = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminCommandeCard(
              commande: sampleCommande,
              onTap: () {},
              onStatusChanged: (newStatut) {
                statusChanged = true;
                changedTo = newStatut;
              },
            ),
          ),
        ),
      );

      expect(find.text('#CMD12345'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('+225 07 12 34 56 78'), findsOneWidget);
      expect(find.text('3 articles'), findsOneWidget);
      expect(find.text('32 000 FCFA'), findsOneWidget);
      expect(find.text('GPS: 5.359952°, 3.996144° (Cocody Riviera 3)'), findsOneWidget);
    });

    testWidgets('AdminCommandesScreen displays stats, filters and order items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminCommandesProvider.overrideWith((ref) async => [sampleCommande]),
          ],
          child: const MaterialApp(
            home: AdminCommandesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Commandes & Ventes'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('En cours'), findsNWidgets(3)); // Stat card + filter chip + card
      expect(find.text('Livrées'), findsNWidgets(2));
      expect(find.text('Chiffre d\'affaires global'), findsOneWidget);
      expect(find.text('32 000 FCFA'), findsNWidgets(2)); // CA + card
      expect(find.text('#CMD12345'), findsOneWidget);
    });

    testWidgets('AdminDetailCommandePage displays complete breakdown and action options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AdminDetailCommandePage(
              commandeId: sampleCommande.id,
              initialCommande: sampleCommande,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Commande #CMD12345'), findsOneWidget);
      expect(find.text('STATUT ACTUEL'), findsOneWidget);
      expect(find.text('En cours'), findsNWidgets(2)); // Status badge + ChoiceChip
      expect(find.text('Informations de livraison'), findsOneWidget);
      expect(find.text('+225 07 12 34 56 78'), findsOneWidget);
      expect(find.text('Jeu Éducatif Formes & Couleurs'), findsOneWidget);
      expect(find.text('Livre Interactif des Animaux'), findsOneWidget);
      expect(find.text('32 000 FCFA'), findsOneWidget);
      expect(find.text('Gratuite'), findsOneWidget);
      expect(find.text('Retour à la liste des commandes'), findsOneWidget);
    });
  });
}
