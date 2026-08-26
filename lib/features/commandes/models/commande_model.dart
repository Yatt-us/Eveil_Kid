import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleCommandeModel {
  final String produitId;
  final String titre;
  final int quantite;
  final double prix;
  final String? urlImage;

  ArticleCommandeModel({
    required this.produitId,
    required this.titre,
    required this.quantite,
    required this.prix,
    this.urlImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'titre': titre,
      'quantite': quantite,
      'prix': prix,
      'urlImage': urlImage,
    };
  }

  factory ArticleCommandeModel.fromMap(Map<String, dynamic> map) {
    return ArticleCommandeModel(
      produitId: map['produitId'] ?? '',
      titre: map['titre'] ?? '',
      quantite: (map['quantite'] ?? 1) as int,
      prix: (map['prix'] ?? 0.0).toDouble(),
      urlImage: map['urlImage'],
    );
  }
}

class CommandeModel {
  final String id;
  final String parentId;
  final List<ArticleCommandeModel> articles;
  final double montantTotal;
  final double fraisLivraison;
  final String statut;
  final String adresseLivraison;
  final String modePaiement;
  final DateTime dateCreation;
  final String? numeroTelephone;

  CommandeModel({
    required this.id,
    required this.parentId,
    required this.articles,
    required this.montantTotal,
    this.fraisLivraison = 0.0,
    this.statut = 'En cours',
    required this.adresseLivraison,
    this.modePaiement = 'Mobile Money',
    required this.dateCreation,
    this.numeroTelephone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'articles': articles.map((x) => x.toMap()).toList(),
      'montantTotal': montantTotal,
      'fraisLivraison': fraisLivraison,
      'statut': statut,
      'adresseLivraison': adresseLivraison,
      'modePaiement': modePaiement,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'numeroTelephone': numeroTelephone,
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory CommandeModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommandeModel(
      id: docId,
      parentId: map['parentId'] ?? '',
      articles: map['articles'] != null
          ? List<ArticleCommandeModel>.from(
              (map['articles'] as List).map(
                (x) => ArticleCommandeModel.fromMap(Map<String, dynamic>.from(x)),
              ),
            )
          : [],
      montantTotal: (map['montantTotal'] ?? 0.0).toDouble(),
      fraisLivraison: (map['fraisLivraison'] ?? 0.0).toDouble(),
      statut: map['statut'] ?? 'En cours',
      adresseLivraison: map['adresseLivraison'] ?? '',
      modePaiement: map['modePaiement'] ?? 'Mobile Money',
      dateCreation: _parseDate(map['dateCreation']),
      numeroTelephone: map['numeroTelephone'],
    );
  }

  CommandeModel copyWith({
    String? id,
    String? parentId,
    List<ArticleCommandeModel>? articles,
    double? montantTotal,
    double? fraisLivraison,
    String? statut,
    String? adresseLivraison,
    String? modePaiement,
    DateTime? dateCreation,
    String? numeroTelephone,
  }) {
    return CommandeModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      articles: articles ?? this.articles,
      montantTotal: montantTotal ?? this.montantTotal,
      fraisLivraison: fraisLivraison ?? this.fraisLivraison,
      statut: statut ?? this.statut,
      adresseLivraison: adresseLivraison ?? this.adresseLivraison,
      modePaiement: modePaiement ?? this.modePaiement,
      dateCreation: dateCreation ?? this.dateCreation,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
    );
  }
}