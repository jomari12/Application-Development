enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String accommodationId;
  final String accommodationName;
  final String accommodationType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final String? specialRequests;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationType,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.specialRequests,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      accommodationId: map['accommodationId'],
      accommodationName: map['accommodationName'],
      accommodationType: map['accommodationType'],
      checkIn: DateTime.parse(map['checkIn']),
      checkOut: DateTime.parse(map['checkOut']),
      guests: map['guests'],
      totalAmount: map['totalAmount'].toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      specialRequests: map['specialRequests'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'accommodationId': accommodationId,
      'accommodationName': accommodationName,
      'accommodationType': accommodationType,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'specialRequests': specialRequests,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? accommodationId,
    String? accommodationName,
    String? accommodationType,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    String? specialRequests,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      accommodationId: accommodationId ?? this.accommodationId,
      accommodationName: accommodationName ?? this.accommodationName,
      accommodationType: accommodationType ?? this.accommodationType,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }
}
