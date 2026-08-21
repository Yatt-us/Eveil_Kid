import 'package:eveilkid/features/enfant/presentation/pages/acceuil_enfant_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_page.dart';
import 'package:eveilkid/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
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
