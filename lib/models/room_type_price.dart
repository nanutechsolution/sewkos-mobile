import 'package:kossumba_app/models/safe_parser.dart';

class RoomTypePrice {
  final int? id;
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
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      roomTypeId: int.tryParse(json['room_type_id']?.toString() ?? '0') ?? 0,
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
