import '../models/booking.dart';
import 'storage_service.dart';

class BookingService {
  static List<Booking> getAllBookings() {
    final bookingsData = StorageService.getList('bookings');
    return bookingsData.map((data) => Booking.fromMap(data)).toList();
  }

  // Renamed and provided the implementation for getBookingsByUserId
  static List<Booking> getBookingsByUserId(String userId) {
    final bookings = getAllBookings();
    return bookings.where((booking) => booking.userId == userId).toList();
  }

  static void saveBooking(Booking booking) {
    final bookings = getAllBookings();
    final existingIndex = bookings.indexWhere((b) => b.id == booking.id);
    
    if (existingIndex != -1) {
      bookings[existingIndex] = booking;
    } else {
      bookings.add(booking);
    }

    final bookingsData = bookings.map((b) => b.toMap()).toList();
    StorageService.setList('bookings', bookingsData);

    // Update accommodation availability
    _updateAccommodationAvailability(booking.accommodationId, booking.status);
  }

  static void updateBookingStatus(String bookingId, BookingStatus status) {
    final bookings = getAllBookings();
    final bookingIndex = bookings.indexWhere((b) => b.id == bookingId);
    
    if (bookingIndex != -1) {
      final updatedBooking = bookings[bookingIndex].copyWith(status: status);
      bookings[bookingIndex] = updatedBooking;
      
      final bookingsData = bookings.map((b) => b.toMap()).toList();
      StorageService.setList('bookings', bookingsData);

      // Update accommodation availability
      _updateAccommodationAvailability(updatedBooking.accommodationId, status);
    }
  }

  static void _updateAccommodationAvailability(String accommodationId, BookingStatus status) {
    // Get rooms
    final rooms = StorageService.getList('rooms');
    final roomIndex = rooms.indexWhere((room) => room['id'] == accommodationId);
    
    if (roomIndex != -1) {
      rooms[roomIndex]['available'] = status == BookingStatus.cancelled || status == BookingStatus.completed;
      StorageService.setList('rooms', rooms);
      return;
    }

    // Get cottages
    final cottages = StorageService.getList('cottages');
    final cottageIndex = cottages.indexWhere((cottage) => cottage['id'] == accommodationId);
    
    if (cottageIndex != -1) {
      cottages[cottageIndex]['available'] = status == BookingStatus.cancelled || status == BookingStatus.completed;
      StorageService.setList('cottages', cottages);
    }
  }

  static String generateBookingId() {
    return 'B${DateTime.now().millisecondsSinceEpoch}';
  }
}
