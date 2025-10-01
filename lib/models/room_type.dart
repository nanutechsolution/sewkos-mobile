import 'package:kossumba_app/models/facility.dart';
import 'package:kossumba_app/models/room.dart';
import 'package:kossumba_app/models/room_type_image.dart';
import 'package:kossumba_app/models/room_type_price.dart';
import 'package:kossumba_app/models/safe_parser.dart';

class RoomType {
  final int id;
  final int propertyId;
  final String name;
  final String? description;
  final double? sizeM2;
  final int totalRooms;
  final int availableRooms;

  // Relasi
  final List<RoomTypeImage> images;
  final List<Room> rooms;
  final List<Facility> facilities;
  final List<RoomTypePrice> prices;
  final List<RoomType>? roomTypes;

  RoomType({
    required this.id,
    required this.propertyId,
    required this.name,
    this.description,
    this.sizeM2,
    required this.totalRooms,
    required this.availableRooms,
    required this.images,
    required this.rooms,
    this.facilities = const [],
    this.prices = const [],
    this.roomTypes,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    // Lakukan konversi yang aman untuk field numerik
    int totalRooms = int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0;
    int availableRooms =
        int.tryParse(json['available_rooms']?.toString() ?? '0') ?? 0;

    return RoomType(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      sizeM2: parseDoubleSafely(json['size_m2']),
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      images: parseListMapSafely(json['images'])
          .map((i) => RoomTypeImage.fromJson(i))
          .toList(),
      rooms: parseListMapSafely(json['rooms'])
          .map((r) => Room.fromJson(r))
          .toList(),
      facilities: parseListMapSafely(json['facilities'])
          .map((f) => Facility.fromJson(f))
          .toList(),
      prices: parseListMapSafely(json['prices'])
          .map((p) => RoomTypePrice.fromJson(p))
          .toList(),
      roomTypes: (json['room_types'] as List<dynamic>?)
          ?.map((rtJson) => RoomType.fromJson(rtJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'name': name,
      'description': description,
      'size_m2': sizeM2,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'images': images.map((img) => img.toJson()).toList(),
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'facilities': facilities.map((f) => f.toJson()).toList(),
      'prices': prices.map((p) => p.toJson()).toList(),
    };
  }
}
