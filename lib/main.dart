import 'dart:ui';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_router.dart';
import 'package:eveilkid/core/provider/theme_provider.dart';
import 'package:eveilkid/core/services/google_sign_in_service.dart';
import 'package:eveilkid/core/themes/AppTheme.dart';
import 'package:eveilkid/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Indispensable pour ProviderScope et ConsumerWidget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise Google Sign-In v7+ une seule fois avant runApp.
  await GoogleSignInService.initialize();

  // On enveloppe bien l'application avec ProviderScope
  runApp(const ProviderScope(child: MonApp()));
}

// Changement de StatelessWidget vers ConsumerWidget pour pouvoir utiliser WidgetRef ref
class MonApp extends ConsumerWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute de la configuration GoRouter
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Eveil Kid',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              isDark ? AppColors.darkBackground : AppColors.background,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
    );
  }
}
