import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Fake repository helpers
// ---------------------------------------------------------------------------

class _FakeUser implements User {
  _FakeUser(this.id, this.email);
  @override
  final String id;
  @override
  final String? email;
  // Provide stubs for all other getters (not used in tests)
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _SuccessAuthRepository implements AuthRepository {
  _SuccessAuthRepository() : _controller = StreamController.broadcast();

  final StreamController<AuthState> _controller;

  @override
  User? currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    currentUser = _FakeUser('uid-1', email);
    return currentUser;
  }

  @override
  Future<User?> signUp(String email, String password) async {
    currentUser = _FakeUser('uid-2', email);
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;
}

class _FailAuthRepository implements AuthRepository {
  _FailAuthRepository({required this.message})
      : _controller = StreamController.broadcast();

  final String message;
  final StreamController<AuthState> _controller;

  @override
  User? currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    throw AuthException(message);
  }

  @override
  Future<User?> signUp(String email, String password) async {
    throw AuthException(message);
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthProvider – signIn success', () {
    test('currentUser set and no error', () async {
      final provider = AuthProvider(repository: _SuccessAuthRepository());
      final ok = await provider.signIn('a@b.com', 'pass123');

      expect(ok, isTrue);
      expect(provider.currentUser, isNotNull);
      expect(provider.currentUser!.email, 'a@b.com');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider – signUp success', () {
    test('currentUser set after sign-up', () async {
      final provider = AuthProvider(repository: _SuccessAuthRepository());
      final ok = await provider.signUp('new@b.com', 'pass123');

      expect(ok, isTrue);
      expect(provider.currentUser, isNotNull);
      expect(provider.errorMessage, isNull);
    });
  });

  group('AuthProvider – signIn failure (US04-AC3)', () {
    test('shows friendly message for wrong credentials', () async {
      final repo = _FailAuthRepository(message: 'Invalid login credentials');
      final provider = AuthProvider(repository: repo);
      final ok = await provider.signIn('x@y.com', 'wrongpass');

      expect(ok, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Email atau kata sandi salah');
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider – signOut (US04-AC4)', () {
    test('currentUser becomes null after signOut', () async {
      final repo = _SuccessAuthRepository();
      final provider = AuthProvider(repository: repo);
      await provider.signIn('a@b.com', 'pass123');
      expect(provider.currentUser, isNotNull);

      await provider.signOut();
      expect(provider.currentUser, isNull);
    });
  });

  group('AuthProvider – clearError', () {
    test('clears errorMessage', () async {
      final repo = _FailAuthRepository(message: 'Invalid login credentials');
      final provider = AuthProvider(repository: repo);
      await provider.signIn('x@y.com', 'bad');

      expect(provider.errorMessage, isNotNull);
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });
  });

  group('AuthProvider – loading state', () {
    test('isLoading is false before and after operation', () async {
      final provider = AuthProvider(repository: _SuccessAuthRepository());
      expect(provider.isLoading, isFalse);
      await provider.signIn('a@b.com', 'pass');
      expect(provider.isLoading, isFalse);
    });
  });
}
