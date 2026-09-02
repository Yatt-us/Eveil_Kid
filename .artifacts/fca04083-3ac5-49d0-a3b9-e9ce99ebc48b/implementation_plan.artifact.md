# Synchronisation des Profils Parent et Enfant

Ce plan vise à résoudre les problèmes de synchronisation des photos de profil et des données entre les différentes parties de l'application.

## User Review Required

> [!IMPORTANT]
> Les modifications centraliseront la gestion de l'état dans les Notifiers. Les widgets devront observer les providers recommandés pour voir les changements en temps réel.

## Proposed Changes

### [Component] Providers & State Management

#### [MODIFY] [parent_provider.dart](file:///C:/Users/Kalandew12/StudioProjects/Eveil_Kid/lib/features/parents/providers/parent_provider.dart)
- Mettre à jour `updateParentProfile` pour s'assurer que `authProvider` est notifié.
- Mettre à jour `ajouterEnfant`, `modifierEnfant` et `supprimerEnfant` pour qu'ils appellent également les méthodes correspondantes de `enfantNotifierProvider.notifier`. Cela garantira que tous les widgets écoutant l'un ou l'autre provider seront à jour.

#### [MODIFY] [enfant_providers.dart](file:///C:/Users/Kalandew12/StudioProjects/Eveil_Kid/lib/features/enfant/providers/enfant_providers.dart)
- S'assurer que les méthodes de modification mettent à jour correctement la liste locale des enfants.

### [Component] UI Consistency

#### [MODIFY] [detail_enfant.dart](file:///C:/Users/Kalandew12/StudioProjects/Eveil_Kid/lib/features/parents/presentation/pages/detail_enfant.dart)
- Remplacer `Image.network` par `AppAvatar` pour le support des images Base64.
- Utiliser `enfantNotifierProvider.notifier.modifierEnfant` pour la mise à jour de la photo afin de garantir une synchronisation immédiate.

#### [MODIFY] [liste_enfants.dart](file:///C:/Users/Kalandew12/StudioProjects/Eveil_Kid/lib/features/parents/presentation/pages/liste_enfants.dart)
- Utiliser `enfantNotifierProvider.notifier.modifierEnfant` pour la mise à jour de la photo.

#### [MODIFY] [modifier_enfant.dart](file:///C:/Users/Kalandew12/StudioProjects/Eveil_Kid/lib/features/parents/presentation/pages/modifier_enfant.dart)
- S'assurer que la sauvegarde utilise le notifier approprié.

## Verification Plan

### Automated Tests
- N/A (Tests manuels recommandés sur appareil/émulateur)

### Manual Verification
1.  **Changement photo Parent :** Aller dans le profil parent, changer la photo via galerie. Vérifier qu'elle change sur la page profil ET dans la page de modification.
2.  **Changement photo Enfant :** Aller dans `liste_enfants`, changer une photo. Vérifier qu'elle est à jour dans `detail_enfant` et `profil_enfant`.
3.  **Propagation :** Changer la photo dans `detail_enfant` et vérifier le retour dans `liste_enfants`.
