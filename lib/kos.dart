import 'dart:convert';

const String _baseUrl = 'http://16.170.187.126:8000';
const String _apiBaseUrl = 'http://16.170.187.126:8000/api';

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
  });

  factory Kos.fromJson(Map<String, dynamic> json) {
    List<String> facilitiesList = [];
    if (json['facilities'] != null) {
      // PERBAIKAN: Cek tipe data sebelum memproses
      if (json['facilities'] is String) {
        // Jika data adalah string JSON, dekode dulu
        facilitiesList = (jsonDecode(json['facilities'] as String) as List)
            .map((item) => item as String)
            .toList();
      } else if (json['facilities'] is List) {
        // Jika data sudah berupa list, langsung gunakan
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
