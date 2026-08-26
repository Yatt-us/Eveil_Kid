# Templates d'e-mails Firebase Auth - Éveil Kid

Ce dossier contient les templates HTML personnalisés, responsives et alignés sur le **Design System** de l'application Éveil Kid pour les e-mails envoyés par **Firebase Authentication**.

---

## 🎨 Spécifications du Design System appliquées

- **Couleur primaire (Violet Éveil Kid)** : `#763CD1`
- **Indigo sombre** : `#422B95`
- **Accent (Jaune/Or)** : `#F8B727`
- **Fond d'écran (Background)** : `#F8F7FC`
- **Carte / Conteneur (Surface)** : `#FFFFFF` (Bordure `#E6E2F2`, rayon `20px`, ombre douce)
- **Boîte de lien de secours (Surface Variant)** : `#F1EEFA`
- **Typographie & Couleurs de texte** :
  - Titres et signature : `#1E1B2E` (Text Primary)
  - Corps du message et sous-titres : `#6C687D` (Text Secondary)
  - Mentions et sécurité : `#94A3B8`
- **Logo de l'application** : SVG officiel vectoriel intégré au sein d'un badge blanc aux coins arrondis.

---

## 📁 Fichiers disponibles

1. **[`email_verification.html`](./email_verification.html)** : Modèle pour la validation et confirmation de l'adresse e-mail après inscription.
2. **[`password_reset.html`](./password_reset.html)** : Modèle pour la réinitialisation de mot de passe oublié.

---

## 🚀 Comment les intégrer dans la console Firebase

1. Rendez-vous sur la [Console Firebase](https://console.firebase.google.com/).
2. Sélectionnez votre projet **Éveil Kid**.
3. Dans le menu de gauche, allez dans **Authentication** > onglet **Templates** (ou **Modèles d'e-mail**).
4. Cliquez sur l'icône de modification ✏️ en face de :
   - **Vérification de l'adresse e-mail** (pour `email_verification.html`)
   - **Réinitialisation du mot de passe** (pour `password_reset.html`)
5. Cliquez sur **Personnaliser le message** (ou activez l'éditeur HTML).
6. Copiez-collez le code contenu dans le fichier HTML correspondant.
7. Cliquez sur **Enregistrer**.

---

## 🏷️ Variables supportées par Firebase Auth

- `%APP_NAME%` : Nom de l'application configuré dans Firebase (ex: *Éveil Kid*).
- `%EMAIL%` : Adresse e-mail du destinataire.
- `%LINK%` : Lien sécurisé généré par Firebase pour valider l'action.
- `%DISPLAY_NAME%` : Nom d'affichage de l'utilisateur (si renseigné).
