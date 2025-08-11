class PropertyImage {
  final int id;
  final int propertyId;
  final String imageUrl;
  final String type;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.type,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      imageUrl: json['image_url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'image_url': imageUrl,
      'type': type,
    };
  }
}
