import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract for authentication operations (Supabase Auth).
abstract class AuthRepository {
  /// Returns the currently signed-in [User], or `null` if nobody is signed in.
  User? get currentUser;

  /// Registers a new account with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<User?> signUp(String email, String password);

  /// Signs in an existing account with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<User?> signIn(String email, String password);

  /// Signs out the current user.
  Future<void> signOut();

  /// Stream of auth state changes (session created / destroyed).
  Stream<AuthState> get onAuthStateChange;
}

/// Supabase-backed implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<User?> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
