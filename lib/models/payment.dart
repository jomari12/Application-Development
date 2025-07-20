enum PaymentStatus { pending, completed, failed }
enum PaymentMethod { cash, creditCard, bankTransfer, gcash, paypal }

class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? referenceNumber;
  final String? notes;
  final String? proofImageUrl;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.referenceNumber,
    this.notes,
    this.proofImageUrl,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      bookingId: map['bookingId'],
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['method'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      referenceNumber: map['referenceNumber'],
      notes: map['notes'],
      proofImageUrl: map['proofImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'referenceNumber': referenceNumber,
      'notes': notes,
      'proofImageUrl': proofImageUrl,
    };
  }
}
