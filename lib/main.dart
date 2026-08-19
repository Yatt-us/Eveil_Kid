import 'package:eveilkid/core/constants/AppPadding.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_card.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouets_screen.dart';
import 'package:eveilkid/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child:  MyApp()));

}

class MyApp extends StatelessWidget {
   MyApp({super.key});


  

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Eveil Kid',
      routerConfig: _router,
    );
  }
  final GoRouter _router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const JouetsScreen()),
]);
}
