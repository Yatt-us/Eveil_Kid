import 'package:eveilkid/core/constants/AppPadding.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eveil Kid',
      home: Scaffold(
        appBar: AppBar(title: const Text('Eveil Kid')),
        body: Padding(
          padding: AppPadding.screenLarge,
          child: SafeArea(
            child: Column(
              children: [Text('Bonjour', style: AppTextStyles.headingLarge)],
            ),
          ),
        ),
      ),
    );
  }
}
