import 'package:kossumba_app/models/safe_parser.dart';

class RoomTypePrice {
  final int id;
  final int roomTypeId;
  final String periodType;
  final double price;

  RoomTypePrice({
    required this.id,
    required this.roomTypeId,
    required this.periodType,
    required this.price,
  });

  factory RoomTypePrice.fromJson(Map<String, dynamic> json) {
    return RoomTypePrice(
      id: json['id'] as int,
      roomTypeId: json['room_type_id'] as int,
      periodType: json['period_type'] as String,
      price: parseDoubleSafely(json['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_type_id': roomTypeId,
      'period_type': periodType,
      'price': price,
    };
  }
}
