import 'dart:async';

import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/suggestion_provider.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/tutoriels/models/suggestion.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
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

  // Suggestions pendant la lecture
  List<Suggestion> _suggestions = [];
  final Set<int> _shownSuggestionTimes = {};
  Suggestion? _activeSuggestion;
  Jouet? _activeSuggestionJouet;
  // Indique si la vidéo était en lecture juste avant l'apparition d'une suggestion
  bool _wasPlayingBeforeSuggestion = false;

  // Sauvegarde / reprise
  bool _hasSavedPosition = false;
  int _savedPositionSeconds = 0;

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
  try {
    final videoUrl = widget.tutoriel.videoUrl.trim();

    debugPrint('==============================');
    debugPrint('URL VIDEO : $videoUrl');
    debugPrint('==============================');

    if (videoUrl.isEmpty) {
      throw Exception('L\'URL de la vidéo est vide.');
    }

    // Vérifier que l'URL est valide
    final uri = Uri.tryParse(videoUrl);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw Exception(
        'URL vidéo invalide : $videoUrl',
      );
    }

    _videoController = VideoPlayerController.networkUrl(
      uri,
    );

    await _videoController.initialize();

    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });

    // Charger la progression sauvegardée si elle existe
    await _loadSavedProgression();

    // Charger les suggestions
    _suggestions = await ref
        .read(
          suggestionsProvider(
            widget.tutoriel.tutorielId,
          ).future,
        );

    // Écouter la vidéo
    _videoController.addListener(_videoListener);

    // Sauvegarde automatique toutes les 15 secondes
    _progressTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        _saveProgression();
      },
    );
  } catch (e, stackTrace) {
    debugPrint('================================');
    debugPrint('ERREUR INITIALISATION VIDEO');
    debugPrint('URL : ${widget.tutoriel.videoUrl}');
    debugPrint('ERREUR : $e');
    debugPrint('STACK : $stackTrace');
    debugPrint('================================');

    if (!mounted) return;

    setState(() {
      _isInitialized = false;
    });
  }
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

    // Vérifier les suggestions à afficher
    final posSeconds = _videoController.value.position.inSeconds;
    for (final suggestion in _suggestions) {
      final sTime = suggestion.temps;
      if (sTime == posSeconds && !_shownSuggestionTimes.contains(sTime)) {
        _shownSuggestionTimes.add(sTime);
        _showSuggestion(suggestion);
        break;
      }
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
    final position = _videoController.value.position.inSeconds;

    // Récupérer la durée totale
    // de la vidéo en secondes
    final duree = _videoController.value.duration.inSeconds;

    // Appeler le Controller du Provider
    // pour sauvegarder la progression
    await ref.read(
      progressionControllerProvider,
    ).saveProgression(
      tutorielId: widget.tutoriel.tutorielId,
      position: position,
      duree: duree,
    );
  }

  Future<void> _loadSavedProgression() async {
    try {
      final progression = await ref
          .read(
            progressionProvider(widget.tutoriel.tutorielId).future,
          );

      if (progression == null) return;

      final pos = progression.position.toInt();
      if (pos > 0) {
        _savedPositionSeconds = pos;
        _hasSavedPosition = true;
        // Positionner la vidéo mais ne pas lancer la lecture automatiquement
        await _videoController.seekTo(Duration(seconds: pos));
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Erreur chargement progression: $e');
    }
  }

  Future<void> _showSuggestion(Suggestion suggestion) async {
    // Mémoriser si la vidéo était en cours de lecture
    _wasPlayingBeforeSuggestion = _videoController.value.isPlaying;

    // Si elle était en lecture, on met en pause automatiquement
    if (_wasPlayingBeforeSuggestion) {
      _videoController.pause();
    }

    setState(() {
      _activeSuggestion = suggestion;
      _activeSuggestionJouet = null;
    });

    // Charger le jouet lié si présent
    if (suggestion.jouetId.isNotEmpty) {
      final jouet = await ref.read(jouetByIdProvider(suggestion.jouetId).future);
      setState(() => _activeSuggestionJouet = jouet);
    }

    // Fermer la suggestion après 6 secondes et reprendre la lecture si nécessaire
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() => _activeSuggestion = null);
      if (_wasPlayingBeforeSuggestion) {
        _videoController.play();
      }
    });
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

  Widget _buildSuggestionCard() {
    final suggestion = _activeSuggestion!;
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            if (_activeSuggestionJouet != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    _activeSuggestionJouet!.imagePrincipaleUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(suggestion.message, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (_activeSuggestionJouet != null) Text(_activeSuggestionJouet!.nom, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _activeSuggestion = null)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "00:00";
    final d = Duration(seconds: seconds);
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final secs = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$secs';
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

          GestureDetector(
            onTap: () {
              // Toggler play/pause en tapant sur la zone vidéo
              if (!_isInitialized) return;
              setState(() {
                if (_videoController.value.isPlaying) {
                  _videoController.pause();
                } else {
                  _videoController.play();
                }
              });
            },
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_videoController),
                  if (_activeSuggestion != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 80,
                      child: _buildSuggestionCard(),
                    ),
                  if (!_videoController.value.isPlaying)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(Icons.play_circle_fill_rounded, size: 80, color: Colors.white70),
                      ),
                    ),
                ],
              ),
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

          // Si une position sauvegardée existe, afficher un bouton "Reprendre la lecture"
          if (_hasSavedPosition && !_videoController.value.isPlaying)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Reprendre la lecture depuis la position sauvegardée
                    _videoController.play();
                    setState(() {
                      _hasSavedPosition = false;
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Reprendre la lecture à ${_formatDuration(_savedPositionSeconds)}'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ),
            ),

          // =========================================
          // CONTROLES + MEMORISATION
          // =========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_videoController.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      if (_videoController.value.isPlaying) {
                        _videoController.pause();
                      } else {
                        _videoController.play();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(_formatDuration(_videoController.value.position.inSeconds)),
                const SizedBox(width: 8),
                Expanded(child: Container()),
                Text(_formatDuration(_videoController.value.duration.inSeconds)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Mémoriser le tutoriel en cours',
                  onPressed: () async {
                    await _saveProgression();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutoriel mémorisé')));
                  },
                ),
              ],
            ),
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