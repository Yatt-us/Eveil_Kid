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
import 'package:eveilkid/core/services/google_sign_in_service.dart';
import 'package:eveilkid/core/themes/AppTheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise Google Sign-In v7+ une seule fois avant runApp.
  // Tente egalement une re-connexion legere (sans UI) si l utilisateur
  // etait deja connecte precedemment.
  await GoogleSignInService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Éveil Kid',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
