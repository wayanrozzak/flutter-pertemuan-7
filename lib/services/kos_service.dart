import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;
  String get _uid => _client.auth.currentUser?.id ?? '';

  static bool isUsingFallback = false;

  // In-memory fallback dataset jika tabel 'kos' belum dibuat di Supabase
  static final List<KosModel> _fallbackKos = [
    KosModel(
      id: 'kos-demo-01',
      ownerId: 'owner-sample-01',
      name: 'Kos Melati Dekat Kampus',
      address: 'Jl. Udayana No. 12, Singaraja',
      price: 650000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    KosModel(
      id: 'kos-demo-02',
      ownerId: 'owner-sample-02',
      name: 'Kos Graha Asri Putri',
      address: 'Jl. Ahmad Yani Gg. 3 No. 5, Singaraja',
      price: 800000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    KosModel(
      id: 'kos-demo-03',
      ownerId: 'owner-sample-01',
      name: 'Kos Pondok Mahasiswa Eksklusif',
      address: 'Jl. Ngurah Rai No. 45, Singaraja',
      price: 1200000,
      createdAt: DateTime.now(),
    ),
  ];

  bool _isTableNotFound(Object e) {
    if (e is PostgrestException) {
      return e.code == 'PGRST205' ||
          e.message.toLowerCase().contains("could not find the table 'public.kos'") ||
          e.message.toLowerCase().contains("relation \"public.kos\" does not exist");
    }
    return false;
  }

  Future<List<KosModel>> fetchAll() async {
    try {
      final data = await _client
          .from('kos')
          .select()
          .order('created_at', ascending: false);
      isUsingFallback = false;
      return (data as List).map((e) => KosModel.fromMap(e)).toList();
    } catch (e) {
      if (_isTableNotFound(e)) {
        debugPrint('[KosService] Tabel public.kos belum dibuat di Supabase. Menggunakan data demo lokal.');
        isUsingFallback = true;
        return List.from(_fallbackKos);
      }
      rethrow;
    }
  }

  Future<List<KosModel>> fetchMyKos() async {
    try {
      if (_uid.isEmpty) return [];
      final data = await _client
          .from('kos')
          .select()
          .eq('owner_id', _uid)
          .order('created_at', ascending: false);
      isUsingFallback = false;
      return (data as List).map((e) => KosModel.fromMap(e)).toList();
    } catch (e) {
      if (_isTableNotFound(e)) {
        isUsingFallback = true;
        return _fallbackKos.where((k) => k.ownerId == _uid).toList();
      }
      rethrow;
    }
  }

  Future<void> add({
    required String name,
    required String address,
    required int price,
  }) async {
    try {
      await _client.from('kos').insert({
        'owner_id': _uid,
        'name': name,
        'address': address,
        'price': price,
      });
      isUsingFallback = false;
    } catch (e) {
      if (_isTableNotFound(e)) {
        isUsingFallback = true;
        _fallbackKos.insert(
          0,
          KosModel(
            id: 'kos-${DateTime.now().millisecondsSinceEpoch}',
            ownerId: _uid,
            name: name,
            address: address,
            price: price,
            createdAt: DateTime.now(),
          ),
        );
        return;
      }
      rethrow;
    }
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> update(String id, Map<String, dynamic> values) async {
    try {
      final rows = await _client.from('kos').update(values).eq('id', id).select();
      isUsingFallback = false;
      return rows.isNotEmpty;
    } catch (e) {
      if (_isTableNotFound(e)) {
        isUsingFallback = true;
        final idx = _fallbackKos.indexWhere((k) => k.id == id);
        if (idx != -1) {
          final old = _fallbackKos[idx];
          _fallbackKos[idx] = KosModel(
            id: old.id,
            ownerId: old.ownerId,
            name: values['name'] as String? ?? old.name,
            address: values['address'] as String? ?? old.address,
            price: (values['price'] as num?)?.toInt() ?? old.price,
            createdAt: old.createdAt,
          );
          return true;
        }
        return false;
      }
      rethrow;
    }
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> delete(String id) async {
    try {
      final rows = await _client.from('kos').delete().eq('id', id).select();
      isUsingFallback = false;
      return rows.isNotEmpty;
    } catch (e) {
      if (_isTableNotFound(e)) {
        isUsingFallback = true;
        final countBefore = _fallbackKos.length;
        _fallbackKos.removeWhere((k) => k.id == id);
        return _fallbackKos.length < countBefore;
      }
      rethrow;
    }
  }
}
