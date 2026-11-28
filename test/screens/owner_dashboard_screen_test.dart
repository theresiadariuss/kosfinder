import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
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
}
