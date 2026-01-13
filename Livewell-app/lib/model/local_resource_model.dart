class LocalResource {
  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final String postcode;
  final String contactInfo;

  LocalResource({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.postcode,
    required this.contactInfo,
  });

  factory LocalResource.fromMap(Map<String, dynamic> map) {
    return LocalResource(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      postcode: map['postcode'] ?? '',
      contactInfo: map['contact_info'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'address': address,
      'postcode': postcode,
      'contact_info': contactInfo,
    };
  }

  LocalResource copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? address,
    String? postcode,
    String? contactInfo,
  }) {
    return LocalResource(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      postcode: postcode ?? this.postcode,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}
