class Review {
  final int id;
  final int propertyId;
  final int? userId;
  final String authorName;
  final String comment;
  final int rating;

  Review({
    required this.id,
    required this.propertyId,
    this.userId,
    required this.authorName,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      userId: json['user_id'] as int?,
      authorName: json['author_name'] as String,
      comment: json['comment'] as String,
      rating: json['rating'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'user_id': userId,
      'author_name': authorName,
      'comment': comment,
      'rating': rating,
    };
  }
}
