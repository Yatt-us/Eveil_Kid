/// Rôles disponibles dans l'espace administration / back-office
enum AdminRole {
  /// Super Administrateur : a accès à absolument tout, y compris la gestion des utilisateurs et permissions
  admin,

  /// Manager : gère les produits, catégories, stocks, prix, commandes, tutoriels, mais n'a PAS accès à la gestion des utilisateurs
  manager;

  String get label {
    switch (this) {
      case AdminRole.admin:
        return 'Administrateur';
      case AdminRole.manager:
        return 'Manager';
    }
  }

  String get description {
    switch (this) {
      case AdminRole.admin:
        return 'Accès complet (Utilisateurs, Catalogue, Commandes, Paramètres)';
      case AdminRole.manager:
        return 'Accès opérationnel (Catalogue, Stocks, Prix, Commandes)';
    }
  }

  /// Permissions du rôle
  bool get canManageUsers => this == AdminRole.admin;
  bool get canAssignRoles => this == AdminRole.admin;
  bool get canManageCatalog => true;
  bool get canManageOrders => true;
  bool get canManageTutorials => true;
}
