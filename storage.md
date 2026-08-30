# 📦 Guide du Système de Stockage & Intégration Cloudinary — Éveil Kid

Ce document détaille de manière exhaustive l'architecture, la configuration et l'implémentation du système de stockage de fichiers (images et vidéos) mis en place au sein du projet mobile **Éveil Kid**, de la configuration Cloudinary jusqu'à l'intégration dans les contrôleurs et repositories Flutter.

---

## 📑 Table des Matières
1. [Vue d'Ensemble & Choix d'Architecture](#1-vue-densemble--choix-darchitecture)
2. [Configuration de l'Environnement Cloudinary](#2-configuration-de-lenvironnement-cloudinary)
3. [Dépendances Flutter (`pubspec.yaml`)](#3-dépendances-flutter-pubspecyaml)
4. [Couche Core : Configuration & Service Cloudinary](#4-couche-core--configuration--service-cloudinary)
5. [Intégration Métier : Repositories & State Management](#5-intégration-métier--repositories--state-management)
   - [A. Gestion des Tutoriels (Images & Vidéos)](#a-gestion-des-tutoriels-images--vidéos)
   - [B. Gestion des Activités (Images)](#b-gestion-des-activités-images)
   - [C. Gestion des Questions / Quiz (Images)](#c-gestion-des-questions--quiz-images)
6. [Composants UI & Sélecteurs de Médias](#6-composants-ui--sélecteurs-de-médias)
7. [Sécurité, Performance & Bonnes Pratiques](#7-sécurité-performance--bonnes-pratiques)
8. [Guide Pratique : Ajouter un Nouveau Téléversement](#8-guide-pratique--ajouter-un-nouveau-téléversement)

---

## 1. Vue d'Ensemble & Choix d'Architecture

Dans **Éveil Kid**, les données textuelles et relationnelles sont stockées sur **Cloud Firestore**, tandis que l'ensemble des médias riches (photos de couverture, miniatures, vidéos de démonstration de tutoriels, illustrations de questions) est délégué à **Cloudinary**.

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Mobile                       │
│  (UI / FormControllers: ImagePicker, VideoPicker, etc.)     │
└───────────────┬─────────────────────────────┬───────────────┘
                │                             │
       1. Upload Fichier             2. Enregistrement URL
       (Bytes / Multipart)            + Métadonnées JSON
                │                             │
                ▼                             ▼
   ┌───────────────────────────┐ ┌───────────────────────────┐
   │        Cloudinary         │ │      Cloud Firestore      │
   │ (Stockage & CDN Médias)   │ │  (Base de données NoSQL)  │
   │  - images / miniatures    │ │  - Collection activites   │
   │  - vidéos tutoriels       │ │  - Collection tutoriels   │
   │  - illustrations quiz     │ │  - Collection questions   │
   └───────────────────────────┘ └───────────────────────────┘
```

### Pourquoi Cloudinary ?
- **Optimisation dynamique des médias** : Compression intelligente, adaptation automatique des résolutions (`f_auto`, `q_auto`), formats modernes (WebP, AVIF, HLS/DASH pour la vidéo).
- **CDN mondial haute performance** : Temps de chargement réduits pour les enfants et les parents.
- **Upload Unsigned côté client** : Téléversement direct depuis le terminal mobile sans transiter par un serveur intermédiaire et sans exposer de clé secrète (`API_SECRET`).

---

## 2. Configuration de l'Environnement Cloudinary

### A. Création du compte et récupération des identifiants
1. Créer un compte sur [Cloudinary Console](https://cloudinary.com/).
2. Sur le Dashboard principal, noter le **Cloud Name** du projet (ex. `dcaoahlor`).

### B. Configuration d'un Upload Preset Unsigned
Pour permettre à l'application mobile d'uploader des images et vidéos sans exposer la clé secrète d'API :

1. Aller dans **Settings (Paramètres)** > **Upload** > **Upload presets**.
2. Cliquer sur **Add Upload Preset**.
3. Configurer les paramètres :
   - **Preset name** : `eveilkid` (identifiant utilisé par l'application).
   - **Signing Mode** : **Unsigned** (*Obligatoire pour les uploads directs depuis l'app*).
   - **Folder** : Laisser vide par défaut (le dossier est spécifié dynamiquement par code).
   - **Media analysis / Transformations** (optionnel) : Activer la détection automatique de qualité (`Quality: auto`) et de format (`Format: auto`).
4. Cliquer sur **Save**.

---

## 3. Dépendances Flutter (`pubspec.yaml`)

Les packages suivants sont intégrés dans le fichier [`pubspec.yaml`](file:///home/morbin/src/projects/mobile/eveilkid/pubspec.yaml) :

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Requêtes HTTP directes vers l'API REST Cloudinary
  http: ^1.2.2

  # Sélection d'images et vidéos depuis la galerie / caméra
  image_picker: ^1.1.2

  # SDKs officiels Cloudinary (analyse & URLs)
  cloudinary_api: ^1.1.1
  cloudinary_url_gen: ^1.1.1

  # Gestion d'état et injection de dépendances
  flutter_riverpod: ^3.4.2
```

---

## 4. Couche Core : Configuration & Service Cloudinary

L'architecture isole l'infrastructure Cloudinary dans le dossier `lib/core/cloudinary/` :

```
lib/core/cloudinary/
├── cloudinary_config.dart   # Constantes et identifiants publics
└── cloudinary_service.dart  # Service HTTP d'upload et Provider Riverpod
```

### A. Configuration statique ([`cloudinary_config.dart`](file:///home/morbin/src/projects/mobile/eveilkid/lib/core/cloudinary/cloudinary_config.dart))

```dart
class CloudinaryConfig {
  static const String cloudName = 'dcaoahlor';
  static const String uploadPreset = 'eveilkid';
}
```

### B. Service d'upload REST Unsigned ([`cloudinary_service.dart`](file:///home/morbin/src/projects/mobile/eveilkid/lib/core/cloudinary/cloudinary_service.dart))

Le service utilise des requêtes `MultipartRequest` POST directement vers l'API v1_1 de Cloudinary :
`https://api.cloudinary.com/v1_1/<cloud_name>/<resource_type>/upload`

#### Points techniques clés :
1. **Lecture binaire sécurisée** : Les fichiers sont convertis en octets via `file.readAsBytes()` pour garantir la portabilité multiplateforme (iOS, Android, Web) sans dépendance aux chemins de fichiers absolus temporaires.
2. **Support multi-ressources** : Méthodes dédiées pour `image`, `video` et générique `auto`.
3. **Organisation hiérarchique des dossiers** : Paramètre optionnel `folder` pour classer les médias (`activites/`, `tutoriels/`, `questions/`).
4. **Gestion d'erreur robuste** : Extraction des messages d'erreur au format JSON renvoyés par Cloudinary en cas d'échec HTTP.
5. **Injection Riverpod** : Exposition du service via `cloudinaryServiceProvider`.

```dart
class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
  })  : cloudName = cloudName ?? CloudinaryConfig.cloudName,
        uploadPreset = uploadPreset ?? CloudinaryConfig.uploadPreset;

  /// Upload d'une image
  Future<String> uploadImage(File file, {String? folder, String? publicId}) async {
    return _uploadDirect(
      file: file,
      resourceType: 'image',
      folder: folder,
      publicId: publicId,
    );
  }

  /// Upload d'une vidéo
  Future<String> uploadVideo(File file, {String? folder, String? publicId}) async {
    return _uploadDirect(
      file: file,
      resourceType: 'video',
      folder: folder,
      publicId: publicId,
    );
  }

  /// Implémentation REST Multipart Unsigned
  Future<String> _uploadDirect({
    required File file,
    required String resourceType,
    String? folder,
    String? publicId,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;
    if (folder != null && folder.trim().isNotEmpty) {
      request.fields['folder'] = folder.trim();
    }
    if (publicId != null && publicId.trim().isNotEmpty) {
      request.fields['public_id'] = publicId.trim();
    }

    final bytes = await file.readAsBytes();
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'upload_${DateTime.now().millisecondsSinceEpoch}';

    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body);
      return responseData['secure_url'] as String;
    } else {
      throw Exception('Échec upload Cloudinary (${response.statusCode}): ${response.body}');
    }
  }
}

/// Provider Riverpod global
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
```

---

## 5. Intégration Métier : Repositories & State Management

### A. Gestion des Tutoriels (Images & Vidéos)
Dans [`TutorielRepository`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/tutoriels/repository/tutoriel_repository.dart) et [`TutorielFormController`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/admin/formcontroller/tutoriel_form_controller.dart) :

- **Miniatures** : envoyées dans le dossier `tutoriels/<id>` ou `tutoriels/miniatures`.
- **Fichiers Vidéo** : envoyés dans `tutoriels/<id>` ou `tutoriels/videos`.
- **Upload Direct découplé** : Les méthodes `uploadMiniatureDirect` et `uploadVideoDirect` permettent d'uploader les médias avant la création effective du document Firestore, évitant les enregistrements orphelins ou corrompus.

```dart
// Exemple dans TutorielFormController.save()
if (selectedImage != null) {
  uploadStatusText = 'Téléversement de la miniature sur Cloudinary...';
  notifyListeners();
  finalMiniatureUrl = await repository.uploadMiniatureDirect(selectedImage!, tutorielId: id);
}

if (videoSourceType == VideoSourceType.file && selectedVideoFile != null) {
  uploadStatusText = 'Téléversement de la vidéo sur Cloudinary...';
  notifyListeners();
  finalVideoUrl = await repository.uploadVideoDirect(selectedVideoFile!, tutorielId: id);
}

// Enregistrement final Firestore uniquement après succès des uploads
await repository.createTutoriel(nouveauTutoriel);
```

### B. Gestion des Activités (Images)
Dans [`ActivityRepository`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/activites/repository/admin/activity_repository.dart) et [`ActivityFormController`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/activites/formController/activity_form_controller.dart) :

- Les images d'activités sont téléversées dans le dossier `activites/<activityId>`.
- Le lien `secure_url` retourné est directement stocké dans le champ `imageUrl` du document Firestore associé.

```dart
Future<String> uploadImage(String activityId, File imageFile) async {
  final downloadUrl = await _cloudinary.uploadImage(
    imageFile,
    folder: 'activites/$activityId',
  );
  
  await _activitesRef.doc(activityId).update({
    'imageUrl': downloadUrl,
    'dateModification': Timestamp.now(),
  });
  
  return downloadUrl;
}
```

### C. Gestion des Questions / Quiz (Images)
Dans [`AddQuestionController`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/questions/formcontroller/add_question_controller.dart) :

- Utilisation directe du `cloudinaryServiceProvider` via `ref.read`.
- Les illustrations sont enregistrées sous `questions/<activityId>`.

```dart
if (selectedImage != null) {
  final cloudinary = ref.read(cloudinaryServiceProvider);
  imageUrl = await cloudinary.uploadImage(
    selectedImage!,
    folder: 'questions/$activityId',
  );
}
```

---

## 6. Composants UI & Sélecteurs de Médias

Des widgets spécialisés fournissent une interface soignée pour la prévisualisation et la sélection :

1. **[`TutorielImagePicker`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/admin/presentation/widgets/tutoriel_image_picker.dart)** :
   - Sélection via Galerie ou Appareil Photo (`ImagePicker`).
   - Prévisualisation instantanée du fichier local (`Image.file`).
   - Affichage de l'image distante Cloudinary (`Image.network`) si aucun nouveau fichier n'est sélectionné.
   - Bouton de suppression et indicateurs d'état d'erreur.

2. **[`TutorielVideoPicker`](file:///home/morbin/src/projects/mobile/eveilkid/lib/features/admin/presentation/widgets/tutoriel_video_picker.dart)** :
   - Prise en charge des formats MP4, MOV, MKV, WebM.
   - Prévisualisation du lecteur vidéo local via `video_player`.
   - Indicateurs d'information indiquant à l'administrateur que le fichier sera hébergé sur Cloudinary.

---

## 7. Sécurité, Performance & Bonnes Pratiques

### 🔒 Sécurité
- **Pas d'`API_SECRET` dans le client** : L'utilisation exclusive d'un **Upload Preset Unsigned** garantit qu'aucun secret sensible n'est présent dans le code source décompilé ou l'APK/IPA.
- **Dossiers partitionnés** : Chaque fonctionnalité écrit dans un sous-dossier dédié (`activites/`, `tutoriels/`, `questions/`).

### ⚡ Performance & Optimisation
- **Optimisation des URLs Cloudinary** : Les URLs retournées (`res.cloudinary.com/...`) peuvent être agrémentées de paramètres de transformation à la volée (ex: `c_fill,w_400,h_300,q_auto,f_auto`).
- **Gestion asynchrone des flux** : L'interface affiche un indicateur de chargement (`uploadStatusText`) pendant les uploads de fichiers lourds (vidéos).

---

## 8. Guide Pratique : Ajouter un Nouveau Téléversement

Pour intégrer un nouvel upload dans une nouvelle fonctionnalité (ex. avatar utilisateur ou document) :

1. **Injecter le service** dans le repository ou le controller :
   ```dart
   final cloudinary = ref.read(cloudinaryServiceProvider);
   ```

2. **Appeler la méthode d'upload appropriée** :
   ```dart
   final String fileUrl = await cloudinary.uploadImage(
     monFichier,
     folder: 'avatars/$userId',
   );
   ```

3. **Sauvegarder l'URL obtenue dans Firestore** :
   ```dart
   await firestore.collection('users').doc(userId).update({
     'photoUrl': fileUrl,
   });
   ```
