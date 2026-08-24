// import 'package:eveilkid/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text("bonjour"));
//   }
// }

import 'package:eveilkid/core/router/app_router.dart';
<<<<<<< HEAD
import 'package:eveilkid/core/services/google_sign_in_service.dart';
import 'package:eveilkid/core/themes/AppTheme.dart';
import 'package:eveilkid/core/themes/theme_provider.dart';
=======

>>>>>>> 6be268406277bd1de148ce75bfb2d38529c524f0
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 // Importez le fichier où se trouve appRouterProvider
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
  // Initialise Google Sign-In v7+ une seule fois avant runApp.
  // Tente egalement une re-connexion legere (sans UI) si l'utilisateur
  // etait deja connecte precedemment.
  await GoogleSignInService.initialize();

  runApp(const ProviderScope(child: MyApp()));
=======
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
>>>>>>> 6be268406277bd1de148ce75bfb2d38529c524f0
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute de la configuration GoRouter
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'Éveil Kid',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
=======
      title: 'Eveil Kid',
      routerConfig: router, // Injecte la configuration des routes
    );
  }
}
>>>>>>> 6be268406277bd1de148ce75bfb2d38529c524f0
