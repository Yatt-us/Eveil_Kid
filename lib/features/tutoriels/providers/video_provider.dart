import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/tutoriel.dart';

final videoProvider = Provider.family<VideoController, Tutoriel>(
  (ref, tutoriel) {
    final controller = VideoController(tutoriel);

    ref.onDispose(() {
      controller.dispose();
    });

    return controller;
  },
);

class VideoController {
  final Tutoriel tutoriel;

  late final VideoPlayerController _controller;

  VideoController(this.tutoriel) {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(tutoriel.videoUrl),
    );
  }

  VideoPlayerController get controller => _controller;

  Future<void> initialize() async {
    await _controller.initialize();
  }

  Future<void> play() async {
    await _controller.play();
  }

  Future<void> pause() async {
    await _controller.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _controller.seekTo(position);
  }

  bool get isPlaying => _controller.value.isPlaying;

  Duration get position => _controller.value.position;

  Duration get duration => _controller.value.duration;

  double get progress {
    if (duration.inMilliseconds == 0) {
      return 0;
    }

    return position.inMilliseconds /
        duration.inMilliseconds;
  }

  void dispose() {
    _controller.dispose();
  }
}