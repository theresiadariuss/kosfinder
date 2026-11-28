import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/login_screen.dart';
import 'package:kosfinder/screens/register_screen.dart';

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
  _MockAuthRepository({this.shouldFail = false, this.errorMessage = 'Invalid login credentials'});

  bool shouldFail;
  String errorMessage;
  final _controller = StreamController<AuthState>.broadcast();

  @override
  User? currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    if (shouldFail) {
      throw AuthException(errorMessage);
    }
    currentUser = _FakeUser('user-1', email);
    return currentUser;
  }

  @override
  Future<User?> signUp(String email, String password) async {
    if (shouldFail) {
      throw AuthException(errorMessage);
    }
    currentUser = _FakeUser('user-1', email);
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;
}

Widget _wrap(Widget child, AuthRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(repository: repo)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('LoginScreen & RegisterScreen Tests', () {
    testWidgets('US04-AC3: Login Gagal menampilkan pesan error ketika kredensial salah', (tester) async {
      final repo = _MockAuthRepository(shouldFail: true, errorMessage: 'Invalid login credentials');
      await tester.pumpWidget(_wrap(const LoginScreen(), repo));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'wrong@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_error_text')), findsOneWidget);
      expect(find.text('Email atau kata sandi salah'), findsOneWidget);
    });

    testWidgets('US04-AC3: Validasi form login untuk email kosong dan format tidak valid', (tester) async {
      final repo = _MockAuthRepository();
      await tester.pumpWidget(_wrap(const LoginScreen(), repo));

      // Submit empty
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();
      expect(find.text('Email wajib diisi'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byKey(const Key('login_email_field')), 'invalid-email');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();
      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('US04-AC3: Validasi form login untuk password kurang dari 6 karakter', (tester) async {
      final repo = _MockAuthRepository();
      await tester.pumpWidget(_wrap(const LoginScreen(), repo));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'user@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), '12345');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Kata sandi minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('US04-AC2: Login Berhasil memanggil signIn dengan email dan kata sandi benar', (tester) async {
      final repo = _MockAuthRepository();
      await tester.pumpWidget(_wrap(const LoginScreen(), repo));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'pemilik@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(repo.currentUser, isNotNull);
      expect(repo.currentUser!.email, 'pemilik@example.com');
    });

    testWidgets('US04-AC1: Register Berhasil memanggil signUp dengan email dan kata sandi valid', (tester) async {
      final repo = _MockAuthRepository();
      await tester.pumpWidget(_wrap(const RegisterScreen(), repo));

      await tester.enterText(find.byKey(const Key('register_email_field')), 'baru@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'secret123');
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(repo.currentUser, isNotNull);
      expect(repo.currentUser!.email, 'baru@example.com');
    });

    testWidgets('US04-AC1: Navigasi dari LoginScreen ke RegisterScreen', (tester) async {
      final repo = _MockAuthRepository();
      await tester.pumpWidget(_wrap(const LoginScreen(), repo));

      await tester.tap(find.byKey(const Key('go_to_register_button')));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}
