import 'package:kossumba_app/models/review.dart';
import 'package:kossumba_app/models/safe_parser.dart';
import 'package:kossumba_app/models/property_image.dart';
import 'package:kossumba_app/models/room_type.dart';
import 'package:kossumba_app/models/facility.dart';

class Property {
  final int id;
  final int userId;
  final String name;
  final String genderPreference;
  final String description;
  final String? rules;
  final String? rulesFileUrl;
  final int? yearBuilt;
  final String? managerName;
  final String? managerPhone;
  final String? notes;
  final String addressStreet;
  final String addressCity;
  final String addressProvince;
  final String? addressZipCode;
  final double? latitude;
  final double? longitude;
  final int totalRooms;
  final int availableRooms;

  // Relasi
  final List<PropertyImage> images;
  final List<RoomType> roomTypes;
  final List<Facility> facilities;
  final List<Review> reviews;

  Property({
    required this.id,
    required this.userId,
    required this.name,
    required this.genderPreference,
    required this.description,
    this.rules,
    this.rulesFileUrl,
    this.yearBuilt,
    this.managerName,
    this.managerPhone,
    this.notes,
    required this.addressStreet,
    required this.addressCity,
    required this.addressProvince,
    this.addressZipCode,
    this.latitude,
    this.longitude,
    this.totalRooms = 0,
    this.availableRooms = 0,
    this.images = const [],
    this.roomTypes = const [],
    this.facilities = const [],
    this.reviews = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    List<PropertyImage> parsedImages = [];
    if (json['images'] != null) {
      parsedImages = (json['images'] as List)
          .map((i) => PropertyImage.fromJson(i))
          .toList();
    }

    List<RoomType> parsedRoomTypes = [];
    if (json['room_types'] != null) {
      parsedRoomTypes = (json['room_types'] as List)
          .map((rt) => RoomType.fromJson(rt))
          .toList();
    }

    int calculatedTotalRooms = 0;
    int calculatedAvailableRooms = 0;
    for (var rt in parsedRoomTypes) {
      calculatedTotalRooms += rt.totalRooms;
      calculatedAvailableRooms += rt.availableRooms;
    }

    List<Facility> parsedFacilities = [];
    if (json['facilities'] != null) {
      parsedFacilities = (json['facilities'] as List)
          .map((f) => Facility.fromJson(f))
          .toList();
    }

    List<Review> parsedReviews = [];
    if (json['reviews'] != null) {
      parsedReviews =
          (json['reviews'] as List).map((r) => Review.fromJson(r)).toList();
    }

    return Property(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      genderPreference: json['gender_preference'] as String,
      description: json['description'] as String,
      rules: json['rules'] as String?,
      rulesFileUrl: json['rules_file_url'] as String?,
      yearBuilt: json['year_built'] as int?,
      managerName: json['manager_name'] as String?,
      managerPhone: json['manager_phone'] as String?,
      notes: json['notes'] as String?,
      addressStreet: json['address_street'] as String,
      addressCity: json['address_city'] as String,
      addressProvince: json['address_province'] as String,
      addressZipCode: json['address_zip_code'] as String?,
      latitude: parseDoubleSafely(json['latitude']),
      longitude: parseDoubleSafely(json['longitude']),
      totalRooms: calculatedTotalRooms,
      availableRooms: calculatedAvailableRooms,
      images: parsedImages,
      roomTypes: parsedRoomTypes,
      facilities: parsedFacilities,
      reviews: parsedReviews,
    );
  }
}
