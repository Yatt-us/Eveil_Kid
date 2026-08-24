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
  static const String jouets = '/jouets';
  static const String profile = '/profile';
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
  static const String adminActivites= '/admin/activites';
  static const String adminAddActivity= '/admin/activites/add';
  static const String adminActivityQuestions = '/admin/activites/:activityId/questions';
  static const String adminActivityTypeQuestions = '/admin/activites/:activityId/questions/choose-type';
  static const String adminActivityAddQuestions = '/admin/activites/:activityId/questions/add';
  static const String adminActivityEditQuestions = '/admin/activites/:activityId/questions/edit/:questionId';
  static const String adminActivityDetailQuestions = '/admin/activites/:activityId/questions/detail/:questionId';
  

  // Espace Jouets
  static const String jouetdetail = '/jouet-detail';
  static const String jouetscreen = '/jouets-screen';
}
 