class Room {
  final int id;
  final int roomTypeId;
  final String roomNumber;
  final int? floor;
  final String status;

  Room({
    required this.id,
    required this.roomTypeId,
    required this.roomNumber,
    this.floor,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      roomTypeId: json['room_type_id'] as int,
      roomNumber: json['room_number'] as String,
      floor: json['floor'] as int?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_type_id': roomTypeId,
      'room_number': roomNumber,
      'floor': floor,
      'status': status,
    };
  }
}
