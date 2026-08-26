import 'dart:async';

import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';


/// Page permettant de lire la vidéo d'un tutoriel
///
/// Cette page gère :
/// - la lecture de la vidéo
/// - la pause
/// - la reprise
/// - la progression
/// - la sauvegarde de la progression dans Firebase
/// - la reprise de la vidéo à la dernière position
class VideoPlayerPage extends ConsumerStatefulWidget {
  /// Tutoriel dont on veut lire la vidéo
  final Tutoriel tutoriel;

  const VideoPlayerPage({
    super.key,
    required this.tutoriel,
  });

  @override
  ConsumerState<VideoPlayerPage> createState() =>
      _VideoPlayerPageState();
}


/// État de la page VideoPlayerPage
class _VideoPlayerPageState
    extends ConsumerState<VideoPlayerPage> {

  /// Contrôleur permettant de contrôler la vidéo
  ///
  /// Il permet notamment de :
  /// - lire la vidéo
  /// - mettre en pause
  /// - récupérer la position
  /// - récupérer la durée
  /// - déplacer la position
  late VideoPlayerController _videoController;


  /// Timer utilisé pour sauvegarder
  /// régulièrement la progression
  ///
  /// Exemple :
  /// toutes les 15 secondes
  Timer? _progressTimer;


  /// Indique si le contrôleur vidéo
  /// a terminé son initialisation
  bool _isInitialized = false;


  /// Initialisation de la page
  @override
  void initState() {
    super.initState();

    // Initialiser le lecteur vidéo
    _initializeVideo();
  }


  /// Initialise le lecteur vidéo
  ///
  /// Cette méthode :
  /// 1. crée le contrôleur vidéo
  /// 2. initialise la vidéo
  /// 3. récupère la progression précédente
  /// 4. écoute les changements de la vidéo
  /// 5. démarre la sauvegarde automatique
  Future<void> _initializeVideo() async {

    // Création du contrôleur à partir de l'URL
    // présente dans le modèle Tutoriel
    _videoController =
        VideoPlayerController.networkUrl(
      Uri.parse(widget.tutoriel.videoUrl),
    );


    // Initialisation du lecteur vidéo
    await _videoController.initialize();


    // Informer Flutter que la vidéo est prête
    setState(() {
      _isInitialized = true;
    });


    // Charger la dernière progression
    await _loadProgression();


    // Ajouter un listener pour surveiller
    // l'état et la position de la vidéo
    _videoController.addListener(_videoListener);


    // Sauvegarder automatiquement la progression
    // toutes les 15 secondes
    _progressTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        _saveProgression();
      },
    );
  }


  /// Récupère la dernière progression
  /// enregistrée dans Firebase
  Future<void> _loadProgression() async {

    // Appeler le Provider avec l'ID du tutoriel
    final progression = await ref.read(
      progressionProvider(
        widget.tutoriel.tutorielId!,
      ).future,
    );


    // Si aucune progression n'existe,
    // on laisse la vidéo commencer au début
    if (progression == null) {
      return;
    }


    // Convertir la position enregistrée
    // en Duration
    final position = Duration(
      seconds: progression.position.toInt(),
    );


    // Positionner la vidéo à la dernière position
    await _videoController.seekTo(position);
  }


  /// Écoute les changements de la vidéo
  ///
  /// Cette méthode permet notamment de détecter
  /// lorsque la vidéo arrive à la fin.
  void _videoListener() {

    // Vérifier que le lecteur est bien initialisé
    if (!_videoController.value.isInitialized) {
      return;
    }


    // Vérifier si la vidéo est terminée
    if (_videoController.value.position >=
        _videoController.value.duration) {

      // Sauvegarder la progression finale
      _saveProgression();
    }
  }


  /// Sauvegarde la progression actuelle
  /// dans Firebase
  Future<void> _saveProgression() async {

    // Si la vidéo n'est pas encore initialisée,
    // on ne fait rien
    if (!_isInitialized) {
      return;
    }


    // Récupérer la position actuelle
    // de la vidéo en secondes
    final position =
        _videoController.value.position.inSeconds;


    // Récupérer la durée totale
    // de la vidéo en secondes
    final duree =
        _videoController.value.duration.inSeconds;


    // Appeler le Controller du Provider
    // pour sauvegarder la progression
    await ref.read(
      progressionControllerProvider,
    ).saveProgression(
      tutorielId: widget.tutoriel.tutorielId!,
      position: position,
      duree: duree,
    );
  }


  /// Libération des ressources
  ///
  /// Cette méthode est appelée lorsque
  /// l'utilisateur quitte la page.
  @override
  void dispose() {

    // Arrêter le Timer
    _progressTimer?.cancel();


    // Sauvegarder une dernière fois
    // la position actuelle
    _saveProgression();


    // Supprimer le listener
    _videoController.removeListener(
      _videoListener,
    );


    // Libérer le contrôleur vidéo
    _videoController.dispose();


    // Appeler dispose() du parent
    super.dispose();
  }


  /// Construction de l'interface
  @override
  Widget build(BuildContext context) {

    // Si la vidéo n'est pas encore prête,
    // afficher un indicateur de chargement
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    // Interface principale
    return Scaffold(

      // Barre supérieure
      appBar: AppBar(
        title: Text(
          widget.tutoriel.titre,
        ),
      ),


      // Contenu de la page
      body: Column(
        children: [

          // =========================================
          // LECTEUR VIDÉO
          // =========================================

          AspectRatio(
            // Conserver les proportions originales
            // de la vidéo
            aspectRatio:
                _videoController.value.aspectRatio,

            // Widget permettant d'afficher la vidéo
            child: VideoPlayer(
              _videoController,
            ),
          ),


          // =========================================
          // BARRE DE PROGRESSION
          // =========================================

          VideoProgressIndicator(
            _videoController,

            // Autoriser l'utilisateur à déplacer
            // manuellement la position de la vidéo
            allowScrubbing: true,

            // Espacement autour de la barre
            padding: const EdgeInsets.all(16),
          ),


          // =========================================
          // BOUTON PLAY / PAUSE
          // =========================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              IconButton(

                // Changer l'icône selon l'état
                // actuel de la vidéo
                icon: Icon(
                  _videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),

                // Action lorsqu'on appuie
                onPressed: () {

                  setState(() {

                    // Si la vidéo est en lecture
                    if (_videoController
                        .value
                        .isPlaying) {

                      // Mettre en pause
                      _videoController.pause();

                    } else {

                      // Sinon démarrer/reprendre
                      // la lecture
                      _videoController.play();
                    }
                  });
                },
              ),
            ],
          ),


          // =========================================
          // DESCRIPTION DU TUTORIEL
          // =========================================

          Padding(
            padding: const EdgeInsets.all(16),

            child: Text(
              widget.tutoriel.description,
            ),
          ),
        ],
      ),
    );
  }
}