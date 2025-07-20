class Accommodation {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;
  final List<String> amenities;
  final bool available;
  final String type; // 'room' or 'cottage'

  Accommodation({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.amenities,
    required this.available,
    required this.type,
  });

  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'].toDouble(),
      description: map['description'],
      amenities: List<String>.from(map['amenities']),
      available: map['available'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'amenities': amenities,
      'available': available,
      'type': type,
    };
  }

  Accommodation copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    String? description,
    List<String>? amenities,
    bool? available,
    String? type,
  }) {
    return Accommodation(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      available: available ?? this.available,
      type: type ?? this.type,
    );
  }
}
