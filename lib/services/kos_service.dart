import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;
  String get _uid => _client.auth.currentUser?.id ?? '';

  static bool isUsingFallback = false;

  // In-memory fallback dataset lengkap dengan foto halaman, foto kamar, kamar mandi, & fasilitas
  // menggunakan URL referensi yang diminta oleh pengguna
  static final List<KosModel> _fallbackKos = [
    KosModel(
      id: 'kos-demo-01',
      ownerId: 'owner-sample-01',
      name: 'Kos Melati Dekat Kampus',
      address: 'Jl. Udayana No. 12, Singaraja',
      price: 650000,
      yardImageUrl:
          'https://www.brighton.co.id/about/articles-all/10-desain-rumah-kos-kosan-yang-sehat',
      roomImageUrl:
          'https://www.instagram.com/p/DYqy0HmIPoV/',
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
          'https://www.liputan6.com/hot/read/6410118/7-contoh-3-kamar-kos-di-halaman-rumah-untuk-usaha-pensiunan-sederhana-dan-mudah-dikelola',
      roomImageUrl:
          'https://www.appasco.com/renovasi-kamar-kos-jadi-nyaman-instagramable/',
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
          'https://www.instagram.com/p/CCkjimvgyF5/',
      roomImageUrl:
          'https://mandorpro.id/desain-kamar-kos-yang-bikin-betah/',
      bathroomType: 'luar',
      facilities:
          'Kasur Busa Tebal, Lemari Pakaian, Kamar Mandi Luar Bersih, Tempat Jemuran Luas, Parkir Motor',
      createdAt: DateTime.now(),
    ),
  ];

  bool _isTableNotFound(Object e) {
    if (e is PostgrestException) {
      return true;
    }
    final msg = e.toString().toLowerCase();
    return msg.contains('pgrst205') ||
        msg.contains('public.kos') ||
        msg.contains('schema cache') ||
        msg.contains('relation') ||
        msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('network');
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
      debugPrint('[KosService] Supabase fetchAll error: $e. Menggunakan data fallback lokal.');
      isUsingFallback = true;
      return List.from(_fallbackKos);
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
      debugPrint('[KosService] Supabase fetchMyKos error: $e. Menggunakan data fallback lokal.');
      isUsingFallback = true;
      return _fallbackKos.where((k) => k.ownerId == _uid).toList();
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
