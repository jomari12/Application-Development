class Review {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String accommodationId;
  final String accommodationName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.accommodationId,
    required this.accommodationName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      bookingId: map['bookingId'],
      userId: map['userId'],
      userName: map['userName'],
      accommodationId: map['accommodationId'],
      accommodationName: map['accommodationName'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'accommodationId': accommodationId,
      'accommodationName': accommodationName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
