import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eveilkid/features/admin/users/models/admin_user_model.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_user_list_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_staff_list_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_manager_form_page.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/features/admin/users/repository/admin_user_repository.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/core/models/admin_role.dart';

class MockAdminUserRepository implements AdminUserRepository {
  @override
  Future<List<AdminUserModel>> getAllUsers() async => [];

  @override
  Stream<List<AdminUserModel>> streamUsers() => const Stream.empty();

  @override
  Future<void> updateUserRole(String userId, String newRole) async {}

  @override
  Future<void> toggleUserStatus(String userId, bool estActif, {String? motif}) async {}

  @override
  Future<void> createManagerAccount({
    required String nom,
    required String email,
    String? telephone,
  }) async {}
}

void main() {
  final mockUsers = [
    AdminUserModel(
      utilisateurId: 'u1',
      email: 'alice@example.com',
      nom: 'Alice Parent',
      role: 'PARENT',
      estActif: true,
      nombreEnfants: 2,
      nombreFavoris: 3,
      dateCreation: Timestamp.now(),
      dateModification: Timestamp.now(),
    ),
    AdminUserModel(
      utilisateurId: 'u2',
      email: 'bob@example.com',
      nom: 'Bob Manager',
      role: 'MANAGER',
      estActif: true,
      dateCreation: Timestamp.now(),
      dateModification: Timestamp.now(),
    ),
    AdminUserModel(
      utilisateurId: 'u3',
      email: 'carol@example.com',
      nom: 'Carol Inactive',
      role: 'PARENT',
      estActif: false,
      dateCreation: Timestamp.now(),
      dateModification: Timestamp.now(),
    ),
    AdminUserModel(
      utilisateurId: 'u4',
      email: 'dave@example.com',
      nom: 'Dave Admin',
      role: 'ADMIN',
      estActif: true,
      dateCreation: Timestamp.now(),
      dateModification: Timestamp.now(),
    ),
  ];

  testWidgets('Test AdminUserListPage lists ONLY Parents & shows deactivation modal', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminRoleProvider.overrideWith((ref) => AdminRole.admin),
          adminUserRepositoryProvider.overrideWithValue(MockAdminUserRepository()),
          adminUsersStreamProvider.overrideWith((ref) => Stream.value(mockUsers)),
        ],
        child: const MaterialApp(
          home: AdminUserListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab bar exists
    expect(find.text('Actifs'), findsOneWidget);
    expect(find.text('Inactifs'), findsOneWidget);
    expect(find.text('Alice Parent'), findsOneWidget);
    expect(find.text('Bob Manager'), findsNothing);
    expect(find.text('Dave Admin'), findsNothing);

    // Tap switch to deactivate
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify confirmation modal appears
    expect(find.text('Désactiver ce compte ?'), findsOneWidget);
    expect(find.text('MOTIF DU BLOCAGE'), findsOneWidget);
    expect(find.text('Désactiver le compte'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Cancel modal
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
  });

  testWidgets('Test AdminStaffListPage lists ONLY Staff & shows deactivation modal', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminRoleProvider.overrideWith((ref) => AdminRole.admin),
          adminUserRepositoryProvider.overrideWithValue(MockAdminUserRepository()),
          adminUsersStreamProvider.overrideWith((ref) => Stream.value(mockUsers)),
        ],
        child: const MaterialApp(
          home: AdminStaffListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Staff Tabs exist
    expect(find.text('Tous'), findsOneWidget);
    expect(find.text('Managers'), findsOneWidget);
    expect(find.text('Admins'), findsOneWidget);

    expect(find.text('Bob Manager'), findsOneWidget);
    expect(find.text('Dave Admin'), findsOneWidget);
    expect(find.text('Alice Parent'), findsNothing);

    // Switch for Manager deactivation
    final managerSwitch = find.byType(Switch);
    expect(managerSwitch, findsOneWidget);
    await tester.tap(managerSwitch);
    await tester.pumpAndSettle();

    // Verify confirmation modal appears
    expect(find.text('Désactiver ce manager ?'), findsOneWidget);
    expect(find.text('Désactiver le compte'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Enter DESACTIVER in confirmation field
    await tester.enterText(find.byType(TextField).first, 'DESACTIVER');
    await tester.pumpAndSettle();

    // Tap Désactiver le compte
    await tester.tap(find.text('Désactiver le compte'));
    await tester.pumpAndSettle();
  });

  testWidgets('Test AdminManagerFormPage renders and validates fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminRoleProvider.overrideWith((ref) => AdminRole.admin),
          adminUserRepositoryProvider.overrideWithValue(MockAdminUserRepository()),
        ],
        child: const MaterialApp(
          home: AdminManagerFormPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nouveau Manager'), findsOneWidget);
    expect(find.text('Nom complet *'), findsOneWidget);
    expect(find.text('Adresse email professionnelle *'), findsOneWidget);
    expect(find.text('Créer le compte Manager'), findsOneWidget);

    // Tap submit with empty fields -> should show validation errors
    await tester.tap(find.text('Créer le compte Manager'));
    await tester.pumpAndSettle();

    expect(find.text('Le nom complet est obligatoire'), findsOneWidget);
    expect(find.text("L'adresse email est obligatoire"), findsOneWidget);
  });
}
