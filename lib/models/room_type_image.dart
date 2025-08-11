class RoomTypeImage {
  final int id;
  final int roomTypeId;
  final String imageUrl;
  final String type;

  RoomTypeImage({
    required this.id,
    required this.roomTypeId,
    required this.imageUrl,
    required this.type,
  });

  factory RoomTypeImage.fromJson(Map<String, dynamic> json) {
    return RoomTypeImage(
      id: json['id'] as int,
      roomTypeId: json['room_type_id'] as int,
      imageUrl: json['image_url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_type_id': roomTypeId,
      'image_url': imageUrl,
      'type': type,
    };
  }
}
