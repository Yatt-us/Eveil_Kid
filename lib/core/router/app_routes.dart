/// Définition centralisée des chemins et noms des routes de l'application.
class AppRoutes {
  AppRoutes._();

  // Racine & Démarrage
  static const String splash = '/splash';
  static const String home = '/';

  // Authentification
  static const String login = '/login';
  static const String register = '/register';

  // Fonctionnalités Générales
  static const String tutoriels = '/tutoriels';
  static const String activites = '/activites';
  static const String activitesPlay = '/activites/play';
  static const String activitesResultat = '/activites/resultat';
  static const String activitesCorrige = '/activites/corrige';

  // Espace Administration
  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminUsers = '/admin/users';
  static const String adminCatalog = '/admin/catalog';
  static const String adminProductForm = '/admin/product-form';

  // Espace Jouets
  static const String jouetdetail = '/jouet-detail';
  static const String jouetscreen = '/jouets-screen';
}
 