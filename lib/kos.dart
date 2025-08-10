import 'dart:convert';
import 'config.dart';

const String _baseUrl = '$baseUrl';
const String _apiBaseUrl = '$baseUrl/api';

class Kos {
  final int id;
  final String name;
  final String location;
  final String price;
  final String description;
  final String imageUrl;
  final List<String> facilities;
  final List<Review> reviews;
  final String status;
  final double? latitude;
  final double? longitude;
  final double? distance; // tambahan

  Kos({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.facilities,
    required this.reviews,
    required this.status,
    this.latitude,
    this.longitude,
    this.distance,
  });

  Kos copyWith({
    int? id,
    String? name,
    String? location,
    String? price,
    String? description,
    String? imageUrl,
    List<String>? facilities,
    List<Review>? reviews,
    String? status,
    double? latitude,
    double? longitude,
    double? distance,
  }) {
    return Kos(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      facilities: facilities ?? this.facilities,
      reviews: reviews ?? this.reviews,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
    );
  }

  factory Kos.fromJson(Map<String, dynamic> json) {
    List<String> facilitiesList = [];
    if (json['facilities'] != null) {
      if (json['facilities'] is String) {
        facilitiesList = (jsonDecode(json['facilities'] as String) as List)
            .map((item) => item as String)
            .toList();
      } else if (json['facilities'] is List) {
        facilitiesList =
            (json['facilities'] as List).map((item) => item as String).toList();
      }
    }

    List<Review> reviewsList = [];
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    String imageUrlFromApi = json['image_url'] as String;
    String fullImageUrl;
    if (imageUrlFromApi.startsWith('http')) {
      fullImageUrl = imageUrlFromApi;
    } else {
      fullImageUrl = '$_baseUrl$imageUrlFromApi';
    }

    return Kos(
      id: json['id'],
      name: json['name'] as String,
      location: json['location'] as String,
      price: json['price'] as String,
      description: json['description'] as String,
      imageUrl: fullImageUrl,
      facilities: facilitiesList,
      reviews: reviewsList,
      status: json['status'] as String,
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
    );
  }
}

class Review {
  final String authorName;
  final String comment;
  final int rating;

  Review({
    required this.authorName,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] as String,
      comment: json['comment'] as String,
      rating: json['rating'] as int,
    );
  }
}
