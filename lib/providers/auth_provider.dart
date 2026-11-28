import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

/// Manages authentication state for the app (US04).
class AuthProvider extends ChangeNotifier {
  // ignore: prefer_initializing_formals
  AuthProvider({required AuthRepository repository}) : _repository = repository {
    // Sync current user on startup
    _currentUser = _repository.currentUser;
    // Listen to auth state changes (e.g. token refresh, sign-out from another tab)
    _authSub = _repository.onAuthStateChange.listen((event) {
      _currentUser = event.session?.user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthState> _authSub;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// The currently signed-in user, or `null` when nobody is signed in.
  User? get currentUser => _currentUser;

  /// Whether an auth operation (sign-in / sign-up / sign-out) is in progress.
  bool get isLoading => _isLoading;

  /// A user-friendly error message from the last failed auth operation, if any.
  String? get errorMessage => _errorMessage;

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Registers a new account. On success [currentUser] is set.
  /// Returns `true` on success, `false` on failure (error stored in [errorMessage]).
  Future<bool> signUp(String email, String password) async {
    return _run(() => _repository.signUp(email, password));
  }

  /// Signs in with email + password.
  /// Returns `true` on success, `false` on failure (error stored in [errorMessage]).
  Future<bool> signIn(String email, String password) async {
    return _run(() => _repository.signIn(email, password));
  }

  /// Signs out the current user. After this [currentUser] is `null`.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
      _currentUser = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal keluar. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Executes an auth [operation], updates state, and returns `true` on success.
  Future<bool> _run(Future<User?> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await operation();
      _currentUser = user;
      return true;
    } on AuthException catch (e) {
      // US04-AC3: friendly error for wrong credentials
      _errorMessage = _friendlyMessage(e);
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('email not confirmed') ||
        msg.contains('user not found')) {
      return 'Email atau kata sandi salah';
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered')) {
      return 'Email sudah terdaftar. Silakan masuk.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('password')) {
      return 'Kata sandi minimal 6 karakter.';
    }
    return e.message;
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
