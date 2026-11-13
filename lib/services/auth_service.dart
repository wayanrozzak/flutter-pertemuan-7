
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Mengakses Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Register / membuat akun baru
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Login menggunakan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout dari akun
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Mengambil data pengguna yang sedang login
  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // Memantau perubahan status autentikasi
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Memeriksa apakah pengguna sudah login
  bool get isLoggedIn {
    return currentUser != null;
  }
}
