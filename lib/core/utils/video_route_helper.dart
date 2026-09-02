import 'package:flutter/material.dart';

/// Ouvre une page de lecture vidéo avec une transition en slide depuis le bas (style YouTube).
/// Une fois refermée, la vue et ses contrôleurs sont complètement libérés/disposed (pas de réduction PIP).
Future<T?> openYouTubeStyleVideo<T>(
  BuildContext context,
  Widget page,
) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
    ),
  );
}
