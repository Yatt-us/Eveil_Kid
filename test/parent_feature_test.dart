import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/parent/models/parent_model.dart';

void main() {
  group('Firestore Models Alignment Tests', () {
    test('UtilisateurModel (utilisateurs collection) serialization and copyWith', () {
      final user = UtilisateurModel(
        utilisateurId: 'user_123',
        role: UserRole.PARENT,
        email: 'parent@example.com',
        nom: 'Awa Diarra',
        telephone: '+221770000000',
        nombreFavoris: 5,
        nombreEnfants: 2,
        estActif: true,
      );

      final map = user.toFirestore();
      expect(map['utilisateurId'], 'user_123');
      expect(map['role'], 'PARENT');
      expect(map['nom'], 'Awa Diarra');
      expect(map['email'], 'parent@example.com');
      expect(map['telephone'], '+221770000000');
      expect(map['estActif'], isTrue);
      expect(map['nombreFavoris'], 5);

      final fromMap = UtilisateurModel.fromFirestore(map, 'user_123');
      expect(fromMap.utilisateurId, 'user_123');
      expect(fromMap.nom, 'Awa Diarra');
      expect(fromMap.role, UserRole.PARENT);
    });

    test('EnfantModel (enfants collection) serialization and copyWith', () {
      final birthDate = DateTime(2020, 5, 15);
      final child = EnfantModel(
        enfantId: 'enf_01',
        utilisateurId: 'user_123',
        nom: 'Nour',
        dateNaissance: birthDate,
        genre: 'FILLE',
        souhait: ['Poupée', 'Puzzle'],
        estActif: true,
      );

      final map = child.toFirestore();
      expect(map['enfantId'], 'enf_01');
      expect(map['utilisateurId'], 'user_123');
      expect(map['nom'], 'Nour');
      expect(map['genre'], 'FILLE');
      expect(map['souhait'], ['Poupée', 'Puzzle']);
      expect(map['dateNaissance'], isA<Timestamp>());

      final fromMap = EnfantModel.fromFirestore(map, 'enf_01');
      expect(fromMap.enfantId, 'enf_01');
      expect(fromMap.nom, 'Nour');
      expect(fromMap.genre, 'FILLE');
      expect(fromMap.souhait.length, 2);
    });

    test('CommandeModel (commandes collection) serialization', () {
      final order = CommandeModel(
        commandeId: 'cmd_999',
        utilisateurId: 'user_123',
        nomClient: 'Awa Diarra',
        emailClient: 'parent@example.com',
        articles: [
          {'jouetId': 'j1', 'nomJouet': 'Robot', 'prix': 5000, 'quantite': 1}
        ],
        montantTotal: 5000.0,
        statut: 'LIVREE',
        statutPaiement: 'PAYE',
      );

      final map = order.toFirestore();
      expect(map['commandeId'], 'cmd_999');
      expect(map['montantTotal'], 5000.0);
      expect(map['statut'], 'LIVREE');

      final fromMap = CommandeModel.fromFirestore(map, 'cmd_999');
      expect(fromMap.commandeId, 'cmd_999');
      expect(fromMap.articles.length, 1);
    });

    test('FavoriModel (favoris collection) serialization', () {
      final fav = FavoriModel(
        favoriId: 'fav_1',
        utilisateurId: 'user_123',
        elementId: 'jouet_10',
        typeElement: ElementFavoriType.JOUET,
        titre: 'Planche Montessori',
        prix: 10000.0,
      );

      final map = fav.toFirestore();
      expect(map['favoriId'], 'fav_1');
      expect(map['typeElement'], 'JOUET');
      expect(map['titre'], 'Planche Montessori');

      final fromMap = FavoriModel.fromFirestore(map, 'fav_1');
      expect(fromMap.typeElement, ElementFavoriType.JOUET);
      expect(fromMap.titre, 'Planche Montessori');
    });

    test('ArticlePanierModel (panier collection) serialization', () {
      final cartItem = ArticlePanierModel(
        articlePanierId: 'panier_1',
        utilisateurId: 'user_123',
        jouetId: 'jouet_10',
        nomJouet: 'Planche Montessori',
        prixUnitaire: 10000.0,
        stockDispo: 5,
      );

      final map = cartItem.toFirestore();
      expect(map['articlePanierId'], 'panier_1');
      expect(map['prixUnitaire'], 10000.0);
      expect(map['stockDispo'], 5);

      final fromMap = ArticlePanierModel.fromFirestore(map, 'panier_1');
      expect(fromMap.articlePanierId, 'panier_1');
      expect(fromMap.nomJouet, 'Planche Montessori');
    });
  });
}
