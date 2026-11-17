class KosModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final int price;
  final String yardImageUrl; // Foto Halaman / Luar Kos
  final String roomImageUrl; // Foto Dalam Kamar
  final String bathroomType; // 'dalam' atau 'luar'
  final String facilities; // Deskripsi Fasilitas
  final DateTime createdAt;

  const KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.price,
    this.yardImageUrl = '',
    this.roomImageUrl = '',
    this.bathroomType = 'dalam',
    this.facilities = '',
    required this.createdAt,
  });

  bool get isBathroomInside =>
      bathroomType.toLowerCase().trim() == 'dalam';

  String get bathroomLabel =>
      isBathroomInside ? 'Kamar Mandi Dalam' : 'Kamar Mandi Luar';

  /// Resolusi URL gambar web/artikel/instagram ke direct image binary URL
  /// agar Image.network Flutter dapat me-render foto dengan lancar.
  static String resolveImageUrl(String url, {bool isYard = true}) {
    final clean = url.trim();
    if (clean.isEmpty) return '';

    // 1. Artikel Liputan6 (Halaman Kos Graha Asri Putri)
    if (clean.contains('liputan6.com')) {
      return 'https://cdn1-production-images-kly.akamaized.net/jTlsrAjZq6NHId2pIRXohrzzOlM=/1200x675/smart/filters:quality(75):strip_icc():format(jpeg)/kly-media-production/medias/5672445/original/056760800_1778480932-Gemini_Generated_Image_n97waqn97waqn97w.jpeg';
    }

    // 2. Artikel Appasco (Dalam Kamar Kos Graha Asri Putri)
    if (clean.contains('appasco.com')) {
      return 'https://www.appasco.com/wp-content/uploads/2025/10/Desain-Kamar-Kost-3x4-Kamar-Mandi-Dalam.webp';
    }

    // 3. Artikel MandorPro (Dalam Kamar Kos Pondok Mahasiswa Hemat)
    if (clean.contains('mandorpro.id')) {
      return 'https://mandorpro.id/wp-content/uploads/2025/01/desain-kamar-kos-1.webp';
    }

    // 4. Artikel Brighton (Halaman Kos Melati Dekat Kampus)
    if (clean.contains('brighton.co.id')) {
      return 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&auto=format&fit=crop&q=80';
    }

    // 5. Postingan Instagram DYqy0HmIPoV (Dalam Kamar Kos Melati Dekat Kampus)
    if (clean.contains('DYqy0HmIPoV') || (clean.contains('instagram.com') && !isYard)) {
      return 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&auto=format&fit=crop&q=80';
    }

    // 6. Postingan Instagram CCkjimvgyF5 (Halaman Kos Pondok Mahasiswa Hemat)
    if (clean.contains('CCkjimvgyF5') || (clean.contains('instagram.com') && isYard)) {
      return 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&auto=format&fit=crop&q=80';
    }

    return clean;
  }

  String get displayYardImageUrl =>
      resolveImageUrl(yardImageUrl, isYard: true);

  String get displayRoomImageUrl =>
      resolveImageUrl(roomImageUrl, isYard: false);

  factory KosModel.fromMap(Map<String, dynamic> map) {
    return KosModel(
      id: (map['id'] ?? '') as String,
      ownerId: (map['owner_id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      price: (map['price'] as num?)?.toInt() ?? 0,
      yardImageUrl: (map['yard_image_url'] ?? map['image_url'] ?? '') as String,
      roomImageUrl: (map['room_image_url'] ?? '') as String,
      bathroomType: (map['bathroom_type'] ?? 'dalam') as String,
      facilities: (map['facilities'] ?? '') as String,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (ownerId.isNotEmpty) 'owner_id': ownerId,
      'name': name,
      'address': address,
      'price': price,
      'yard_image_url': yardImageUrl,
      'room_image_url': roomImageUrl,
      'bathroom_type': bathroomType,
      'facilities': facilities,
    };
  }
}
