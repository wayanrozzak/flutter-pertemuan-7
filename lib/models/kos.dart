class KosModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final int price;
  final DateTime createdAt;

  const KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.price,
    required this.createdAt,
  });

  factory KosModel.fromMap(Map<String, dynamic> map) {
    return KosModel(
      id: (map['id'] ?? '') as String,
      ownerId: (map['owner_id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      price: (map['price'] as num?)?.toInt() ?? 0,
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
    };
  }
}
