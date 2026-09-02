import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/core/router/app_router.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Test various user states and screen sizes for AdminProfilePage', (tester) async {
    final minimalUser = Utilisateur(
      utilisateurId: 'admin_min',
      role: UserRole.admin,
      email: '',
      nom: '',
      estActif: true,
    );

    for (final size in [
      const Size(320, 600),
      const Size(360, 800),
      const Size(412, 915),
      const Size(800, 1280),
      const Size(1920, 1080),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(minimalUser)),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              testRef = ref;
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final router = testRef.read(appRouterProvider);
      router.go(AppRoutes.adminProfile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Profil Administrateur'), findsWidgets);
    }
  });

  testWidgets('Navigation from Dashboard AppBar profile icon', (tester) async {
    final adminUser = Utilisateur(
      utilisateurId: 'admin_test_123',
      role: UserRole.admin,
      email: 'admin@eveilkid.com',
      nom: 'Super Admin',
      estActif: true,
    );

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(adminUser)),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final profileIcon = find.byIcon(Icons.admin_panel_settings_rounded);
    expect(profileIcon, findsOneWidget);
    await tester.tap(profileIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Profil Administrateur'), findsWidgets);
  });
}

class MockAuthNotifier extends AuthNotifier {
  final Utilisateur _user;
  MockAuthNotifier(this._user);

  @override
  AuthState build() {
    return AuthState(
      utilisateur: _user,
      isInitialized: true,
      isEmailVerified: true,
    );
  }
}
