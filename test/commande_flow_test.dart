import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/commandes/presentation/pages/adresse_page.dart';
import 'package:eveilkid/features/commandes/presentation/pages/confirmation_page.dart';
import 'package:eveilkid/features/commandes/presentation/widgets/checkout_stepper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Commande Flow, Stepper & Confirmation Tests', () {
    test('CommandeModel and ArticleCommandeModel serialization and deserialization', () {
      final article = ArticleCommandeModel(
        produitId: 'prod_123',
        titre: 'Jeu de construction en bois',
        quantite: 2,
        prix: 15000.0,
        urlImage: 'https://example.com/toy.jpg',
      );

      final mapArticle = article.toMap();
      expect(mapArticle['produitId'], 'prod_123');
      expect(mapArticle['titre'], 'Jeu de construction en bois');
      expect(mapArticle['quantite'], 2);
      expect(mapArticle['prix'], 15000.0);

      final fromMapArticle = ArticleCommandeModel.fromMap(mapArticle);
      expect(fromMapArticle.produitId, 'prod_123');
      expect(fromMapArticle.titre, 'Jeu de construction en bois');
      expect(fromMapArticle.quantite, 2);
      expect(fromMapArticle.prix, 15000.0);

      final commande = CommandeModel(
        id: 'cmd_987654321',
        parentId: 'parent_456',
        articles: [article],
        montantTotal: 30000.0,
        fraisLivraison: 0.0,
        statut: 'En cours',
        adresseLivraison: 'Cocody Riviera 3, Abidjan',
        modePaiement: 'Mobile Money',
        dateCreation: DateTime(2026, 8, 29, 21, 0),
        numeroTelephone: '+22507000000',
      );

      final mapCommande = commande.toMap();
      expect(mapCommande['id'], 'cmd_987654321');
      expect(mapCommande['parentId'], 'parent_456');
      expect(mapCommande['montantTotal'], 30000.0);
      expect(mapCommande['statut'], 'En cours');
      expect(mapCommande['adresseLivraison'], 'Cocody Riviera 3, Abidjan');

      final fromMapCommande = CommandeModel.fromMap(mapCommande, 'cmd_987654321');
      expect(fromMapCommande.id, 'cmd_987654321');
      expect(fromMapCommande.parentId, 'parent_456');
      expect(fromMapCommande.articles.length, 1);
      expect(fromMapCommande.articles.first.titre, 'Jeu de construction en bois');
      expect(fromMapCommande.montantTotal, 30000.0);
    });

    testWidgets('CheckoutStepper renders steps and active state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CheckoutStepper(stepActuel: 1),
          ),
        ),
      );

      expect(find.text('Adresse'), findsOneWidget);
      expect(find.text('Paiement'), findsOneWidget);
      expect(find.text('Confirmation'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('AdressePage defaults to GPS and displays 2 manual fields with required phone and remember checkbox', (tester) async {
      final commande = CommandeModel(
        id: '',
        parentId: 'parent_456',
        articles: [],
        montantTotal: 15000.0,
        fraisLivraison: 0.0,
        statut: 'En cours',
        adresseLivraison: '',
        modePaiement: 'Mobile Money',
        dateCreation: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AdressePage(brouillonCommande: commande),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Options de localisation (GPS par défaut)
      expect(find.text('Localisation GPS'), findsOneWidget);
      expect(find.text('Localisation GPS exacte'), findsOneWidget);
      expect(find.text('Saisie manuelle'), findsOneWidget);
      expect(find.text('Détecter ma position exacte'), findsOneWidget);

      // Téléphone de livraison obligatoire
      expect(find.text('Numéro de téléphone *'), findsOneWidget);
      expect(find.text('Téléphone de contact *'), findsOneWidget);

      // Case à cocher enregistrer contact
      expect(
        find.text('Enregistrer ce contact pour de prochaines commandes'),
        findsOneWidget,
      );

      // Basculer vers la saisie manuelle (2 champs : Adresse & Téléphone)
      await tester.tap(find.text('Saisie manuelle'));
      await tester.pumpAndSettle();

      expect(find.text('Adresse de livraison'), findsNWidgets(2)); // AppBar + section
      expect(find.text('Adresse complète *'), findsOneWidget);
      expect(find.text('Téléphone de contact *'), findsOneWidget);
    });

    testWidgets('ConfirmationPage renders correctly with order details', (tester) async {
      final article = ArticleCommandeModel(
        produitId: 'prod_123',
        titre: 'Puzzle Animaux',
        quantite: 1,
        prix: 10000.0,
      );

      final commande = CommandeModel(
        id: 'CMD99887766',
        parentId: 'parent_456',
        articles: [article],
        montantTotal: 10000.0,
        fraisLivraison: 0.0,
        statut: 'En cours',
        adresseLivraison: 'Marcory Zone 4',
        modePaiement: 'Mobile Money',
        dateCreation: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConfirmationPage(commande: commande),
        ),
      );

      expect(find.widgetWithText(AppBar, 'Confirmation'), findsOneWidget);
      expect(find.text('Merci pour votre commande !'), findsOneWidget);
      expect(find.text('#CMD99887'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Voir mes commandes'), findsOneWidget);
      expect(find.text('Retour à l\'accueil'), findsOneWidget);
    });
  });
}
