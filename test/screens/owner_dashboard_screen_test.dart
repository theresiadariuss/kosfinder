import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';

class _FakeUser implements User {
  _FakeUser(this.id, this.email);
  @override
  final String id;
  @override
  final String? email;
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _MockAuthRepository implements AuthRepository {
  _MockAuthRepository({User? initialUser}) : _currentUser = initialUser;

  User? _currentUser;
  final _controller = StreamController<AuthState>.broadcast();
  int signOutCallCount = 0;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User?> signIn(String email, String password) async => _currentUser;

  @override
  Future<User?> signUp(String email, String password) async => _currentUser;

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    _currentUser = null;
  }

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;
}

Widget _wrap(Widget child, AuthRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(repository: repo)),
    ],
    child: child,
  );
}

void main() {
  group('OwnerDashboardScreen Tests (US04)', () {
    testWidgets('US04-AC2: Menampilkan judul dashboard dan email pemilik', (tester) async {
      final user = _FakeUser('uid-123', 'owner@example.com');
      final repo = _MockAuthRepository(initialUser: user);

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(const OwnerDashboardScreen(), repo),
        ),
      );

      expect(find.text('Dashboard Pemilik'), findsOneWidget);
      expect(find.textContaining('owner@example.com'), findsOneWidget);
      expect(find.byKey(const Key('logout_button')), findsOneWidget);
    });

    testWidgets('US04-AC4: Logout mengakhiri sesi dan kembali ke status pencari', (tester) async {
      final user = _FakeUser('uid-123', 'owner@example.com');
      final repo = _MockAuthRepository(initialUser: user);

      await tester.pumpWidget(
        _wrap(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const OwnerDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text('Open Dashboard'),
                ),
              ),
            ),
          ),
          repo,
        ),
      );

      // Open dashboard
      await tester.tap(find.text('Open Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Pemilik'), findsOneWidget);

      // Press logout
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Verify signOut was called and returned to previous screen
      expect(repo.signOutCallCount, 1);
      expect(repo.currentUser, isNull);
      expect(find.text('Dashboard Pemilik'), findsNothing);
      expect(find.text('Open Dashboard'), findsOneWidget);
    });
  });

  group('OwnerDashboardScreen Tests (US07 Hapus Kos)', () {
    const sampleKos = Kos(
      id: 'kos-del-1',
      ownerId: 'uid-123',
      name: 'Kos Bintang',
      area: 'Singaraja',
      address: 'Jl. Ahmad Yani',
      description: 'Deskripsi',
      pricePerMonth: 900000,
      genderType: 'campur',
      whatsappNumber: '0812345678',
    );

    testWidgets('US07-AC1: Tombol hapus memunculkan dialog konfirmasi', (tester) async {
      final user = _FakeUser('uid-123', 'owner@example.com');
      final authRepo = _MockAuthRepository(initialUser: user);
      final kosRepo = KosRepository();
      kosRepo.setCrudHandlers(
        fetchByOwner: (ownerId) async => [sampleKos],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo)),
            ChangeNotifierProvider(create: (_) => OwnerKosProvider(repository: kosRepo)),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find delete button
      final deleteBtn = find.byKey(const Key('delete_kos_kos-del-1'));
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Verify dialog
      expect(
        find.text('Apakah Anda yakin ingin menghapus kos ini secara permanen?'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('cancel_delete_button')), findsOneWidget);
      expect(find.byKey(const Key('confirm_delete_button')), findsOneWidget);
    });

    testWidgets('US07-AC1: Memilih Batal menutup dialog dan tidak menghapus kos', (tester) async {
      final user = _FakeUser('uid-123', 'owner@example.com');
      final authRepo = _MockAuthRepository(initialUser: user);
      final kosRepo = KosRepository();
      int deleteCalls = 0;
      kosRepo.setCrudHandlers(
        fetchByOwner: (ownerId) async => [sampleKos],
        delete: (id) async => deleteCalls++,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo)),
            ChangeNotifierProvider(create: (_) => OwnerKosProvider(repository: kosRepo)),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.byKey(const Key('delete_kos_kos-del-1')));
      await tester.pumpAndSettle();

      // Tap Batal
      await tester.tap(find.byKey(const Key('cancel_delete_button')));
      await tester.pumpAndSettle();

      // Dialog closed and delete not called
      expect(
        find.text('Apakah Anda yakin ingin menghapus kos ini secara permanen?'),
        findsNothing,
      );
      expect(deleteCalls, 0);
      expect(find.text('Kos Bintang'), findsOneWidget);
    });

    testWidgets('US07-AC2: Memilih Hapus menghapus kos secara permanen dari repository dan tampilan', (tester) async {
      final user = _FakeUser('uid-123', 'owner@example.com');
      final authRepo = _MockAuthRepository(initialUser: user);
      final kosRepo = KosRepository();
      String? deletedId;
      kosRepo.setCrudHandlers(
        fetchByOwner: (ownerId) async => [sampleKos],
        delete: (id) async => deletedId = id,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo)),
            ChangeNotifierProvider(create: (_) => OwnerKosProvider(repository: kosRepo)),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Bintang'), findsOneWidget);

      // Tap delete
      await tester.tap(find.byKey(const Key('delete_kos_kos-del-1')));
      await tester.pumpAndSettle();

      // Tap Hapus
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(deletedId, 'kos-del-1');
      expect(find.text('Kos Bintang'), findsNothing);
      expect(find.text('Belum ada kos yang Anda daftarkan.'), findsOneWidget);
    });
  });
}
