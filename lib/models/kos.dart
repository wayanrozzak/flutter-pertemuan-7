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
