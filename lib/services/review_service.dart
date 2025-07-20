import '../models/review.dart';
import 'storage_service.dart';

class ReviewService {
  static List<Review> getAllReviews() {
    final reviewsData = StorageService.getList('reviews');
    return reviewsData.map((data) => Review.fromMap(data)).toList();
  }

  static void saveReview(Review review) {
    final reviews = getAllReviews();
    final existingIndex = reviews.indexWhere((r) => r.id == review.id);

    if (existingIndex != -1) {
      reviews[existingIndex] = review;
    } else {
      reviews.add(review);
    }

    final reviewsData = reviews.map((r) => r.toMap()).toList();
    StorageService.setList('reviews', reviewsData);
  }

  static String generateReviewId() {
    return 'R${DateTime.now().millisecondsSinceEpoch}';
  }
}
