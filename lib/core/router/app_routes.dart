/// Définition centralisée des chemins et noms des routes de l'application.
class AppRoutes {
  AppRoutes._();

  // Racine & Démarrage
  static const String splash = '/splash';
  static const String home = '/';

  // Authentification & Deep Links
  static const String login = '/login';
  static const String register = '/register';
  static const String authAction = '/auth/action';
  static const String resetPassword = '/reset-password';

  // Fonctionnalités Générales
  static const String tutoriels = '/tutoriels';
  static const String activites = '/activites';
  static const String jouets = '/jouets';
  static const String panier = '/panier';
  static const String profile = '/profile';
  static const String activitesPlay = '/activites/play';
  static const String activitesResultat = '/activites/resultat';
  static const String activitesCorrige = '/activites/corrige';

  // Espace Administration
  static const String admin = '/admin';
  static const String adminProfile = '/admin/profile';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminUsers = '/admin/users';
  static const String adminStaff = '/admin/staff';
  static const String adminCatalog = '/admin/catalog';
  static const String adminProductForm = '/admin/product-form';
  static const String adminActivites= '/admin/activites';
  static const String adminAddActivity= '/admin/activites/add';
  static const String adminEditActivity = '/admin/activites/edit/:activityId';
  static const String adminActivityQuestions = '/admin/activites/:activityId/questions';
  static const String adminActivityTypeQuestions = '/admin/activites/:activityId/questions/choose-type';
  static const String adminActivityAddQuestions = '/admin/activites/:activityId/questions/add';
  static const String adminActivityEditQuestions = '/admin/activites/:activityId/questions/edit/:questionId';
  static const String adminActivityDetailQuestions = '/admin/activites/:activityId/questions/detail/:questionId';
  static const String adminTutoriels = '/admin/tutoriels';

  
  static const String adminCategoryForm = '/admin/category-form';
  static const String adminManagerForm = '/admin/manager-form';

  // Espace Jouets
  static const String jouetdetail = '/jouet-detail';
  static const String jouetscreen = '/jouets-screen';

  // Espace Enfant & Parents
  static const String enfantDetail = '/enfant-detail';
  static const String espaceEnfant = '/espace-enfant';
  static String espaceEnfantFor(String enfantId) => '$espaceEnfant/$enfantId';
  static const String aideSupport = '/aide-support';
}
