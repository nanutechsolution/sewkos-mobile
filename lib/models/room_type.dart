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
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    List<RoomTypeImage> parsedImages = [];
    if (json['images'] != null) {
      parsedImages = (json['images'] as List)
          .map((i) => RoomTypeImage.fromJson(i))
          .toList();
    }

    List<Room> parsedRooms = [];
    if (json['rooms'] != null) {
      parsedRooms =
          (json['rooms'] as List).map((r) => Room.fromJson(r)).toList();
    }

    List<Facility> parsedFacilities = [];
    if (json['facilities'] != null) {
      parsedFacilities = (json['facilities'] as List)
          .map((f) => Facility.fromJson(f))
          .toList();
    }

    List<RoomTypePrice> parsedPrices = [];
    if (json['prices'] != null) {
      parsedPrices = (json['prices'] as List)
          .map((p) => RoomTypePrice.fromJson(p))
          .toList();
    }

    return RoomType(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      sizeM2: parseDoubleSafely(json['size_m2']),
      totalRooms: json['total_rooms'] as int,
      availableRooms: json['available_rooms'] as int,
      images: parsedImages,
      rooms: parsedRooms,
      facilities: parsedFacilities,
      prices: parsedPrices,
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
