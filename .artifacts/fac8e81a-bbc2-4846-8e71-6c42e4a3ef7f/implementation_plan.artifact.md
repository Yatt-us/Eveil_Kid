# Plan de Fusion et d'Amélioration de la Section Parent

Ce plan vise à fusionner les dossiers `/parent` et `/parents`, à mettre à jour la barre de navigation, à rendre les listes interactives et à compléter le formulaire d'ajout d'enfant.

## User Review Required

> [!IMPORTANT]
> Je vais consolider tout le code dans le dossier `lib/features/parent` et supprimer `lib/features/parents`. Assurez-vous d'avoir une sauvegarde si vous avez des changements non commités dans `/parents`.

## Proposed Changes

### 1. Composants Partagés
#### [MODIFY] [app_bottom_nav_bar.dart](file:///C:/Users/DIAGANA/StudioProjects/Eveil_Kid/lib/shared/widgets/app_bottom_nav_bar.dart)
- Rendre le composant plus flexible en acceptant un `currentIndex` et un `onTap` optionnels, tout en conservant le comportement par défaut basé sur le provider si ces derniers ne sont pas fournis.

### 2. Fusion des Dossiers Parent/Parents
#### [DELETE] Dossier `lib/features/parents`
- Supprimer le dossier redondant après avoir vérifié que toutes les fonctionnalités sont présentes dans `lib/features/parent`.
- Mettre à jour les imports dans le projet pour pointer vers `lib/features/parent`.

### 3. Améliorations de l'Accueil Parent
#### [MODIFY] [accueil_parent.dart](file:///C:/Users/DIAGANA/StudioProjects/Eveil_Kid/lib/features/parent/presentation/pages/accueil_parent.dart)
- **Interactivité** : Rendre les cartes d'enfants dans `_buildChildrenHorizontalList` cliquables.
- **Interactivité** : Rendre les cartes de jouets dans `_buildPopularToysList` cliquables vers le détail.
- **Layout** : Ajuster la largeur des cartes de jouets et les espacements pour éviter le débordement horizontal (réduction de la largeur de 175 à ~160).
- **Navigation** : Utiliser `AppBottomNavBar` de manière cohérente.

### 4. Formulaire d'Ajout d'Enfant
#### [MODIFY] [ajouter_enfant.dart](file:///C:/Users/DIAGANA/StudioProjects/Eveil_Kid/lib/features/parent/presentation/pages/ajouter_enfant.dart)
- Compléter le formulaire en utilisant tous les champs du `EnfantModel` présent dans `parent_model.dart` (nom, date de naissance, genre, avatar, etc.).
- Améliorer la validation et l'expérience utilisateur.

## Verification Plan

### Manual Verification
- Vérifier que la barre de navigation fonctionne correctement et change d'onglet.
- Cliquer sur un enfant dans la liste et vérifier que l'action est déclenchée.
- Cliquer sur un jouet populaire et vérifier l'affichage du SnackBar (en attendant la page détail).
- Vérifier visuellement qu'il n'y a plus de débordement sur la liste des jouets populaires.
- Tester le formulaire d'ajout d'enfant complet.
