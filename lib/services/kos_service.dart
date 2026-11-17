import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;
  String get _uid => _client.auth.currentUser?.id ?? '';

  static bool isUsingFallback = false;

  // In-memory fallback dataset lengkap dengan foto halaman, foto kamar, kamar mandi, & fasilitas
  static final List<KosModel> _fallbackKos = [
    KosModel(
      id: 'kos-demo-01',
      ownerId: 'owner-sample-01',
      name: 'Kos Melati Dekat Kampus',
      address: 'Jl. Udayana No. 12, Singaraja',
      price: 650000,
      yardImageUrl:
          'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&auto=format&fit=crop&q=60',
      roomImageUrl:
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=600&auto=format&fit=crop&q=60',
      bathroomType: 'dalam',
      facilities:
          'WiFi 50 Mbps, Kasur Springbed, Lemari 2 Pintu, Meja Belajar, Parkir Motor Aman, Listrik Token',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    KosModel(
      id: 'kos-demo-02',
      ownerId: 'owner-sample-02',
      name: 'Kos Graha Asri Putri',
      address: 'Jl. Ahmad Yani Gg. 3 No. 5, Singaraja',
      price: 850000,
      yardImageUrl:
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600&auto=format&fit=crop&q=60',
      roomImageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&auto=format&fit=crop&q=60',
      bathroomType: 'dalam',
      facilities:
          'AC Dingin, Kamar Mandi Dalam (Shower & Kloset Duduk), Dapur Bersama, Kulkas Bersama, CCTV 24 Jam',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    KosModel(
      id: 'kos-demo-03',
      ownerId: 'owner-sample-01',
      name: 'Kos Pondok Mahasiswa Hemat',
      address: 'Jl. Ngurah Rai No. 45, Singaraja',
      price: 450000,
      yardImageUrl:
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&auto=format&fit=crop&q=60',
      roomImageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600&auto=format&fit=crop&q=60',
      bathroomType: 'luar',
      facilities:
          'Kasur Busa Tebal, Lemari Pakaian, Kamar Mandi Luar Bersih, Tempat Jemuran Luas, Parkir Motor',
      createdAt: DateTime.now(),
    ),
  ];

  bool _isTableNotFound(Object e) {
    if (e is PostgrestException) {
      return e.code == 'PGRST205' ||
          e.message.toLowerCase().contains("could not find the table 'public.kos'") ||
          e.message.toLowerCase().contains("relation \"public.kos\" does not exist") ||
          e.message.toLowerCase().contains("column");
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
        debugPrint('[KosService] Menggunakan data simulasi lokal kos.');
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
    String yardImageUrl = '',
    String roomImageUrl = '',
    String bathroomType = 'dalam',
    String facilities = '',
  }) async {
    try {
      await _client.from('kos').insert({
        'owner_id': _uid,
        'name': name,
        'address': address,
        'price': price,
        'yard_image_url': yardImageUrl,
        'room_image_url': roomImageUrl,
        'bathroom_type': bathroomType,
        'facilities': facilities,
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
            yardImageUrl: yardImageUrl,
            roomImageUrl: roomImageUrl,
            bathroomType: bathroomType,
            facilities: facilities,
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
            yardImageUrl: values['yard_image_url'] as String? ?? old.yardImageUrl,
            roomImageUrl: values['room_image_url'] as String? ?? old.roomImageUrl,
            bathroomType: values['bathroom_type'] as String? ?? old.bathroomType,
            facilities: values['facilities'] as String? ?? old.facilities,
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
