
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isSeeker => role == 'seeker';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: (map['email'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      role: (map['role'] ?? 'seeker') as String,
    );
  }
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // Mengambil pengguna yang sedang login
  User? get currentUser => _client.auth.currentUser;

  // Mengambil profil pengguna dari tabel profiles
  Future<UserProfile?> getMyProfile() async {
    final user = currentUser;

    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    return UserProfile.fromMap(data);
  }

  // Mengambil role pengguna yang sedang login
  Future<String?> get currentUserRole async {
    final profile = await getMyProfile();
    return profile?.role;
  }
}
