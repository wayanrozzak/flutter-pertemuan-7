import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String name = '',
    String role = 'seeker',
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String name = '',
    String role = 'seeker',
  }) =>
      signUp(email: email, password: password, name: name, role: role);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) =>
      signIn(email: email, password: password);

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> logout() => signOut();

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession => _supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  bool get isLoggedIn => currentUser != null;
}
