import '../models/accommodation.dart';
import 'storage_service.dart';

class AccommodationService {
  static List<Accommodation> getAllRooms() {
    final roomsData = StorageService.getList('rooms');
    return roomsData.map((data) => Accommodation.fromMap(data)).toList();
  }

  static List<Accommodation> getAllCottages() {
    final cottagesData = StorageService.getList('cottages');
    return cottagesData.map((data) => Accommodation.fromMap(data)).toList();
  }

  static List<Accommodation> getAllAccommodations() {
    return [...getAllRooms(), ...getAllCottages()];
  }

  // New method to get only available rooms for customer view
  static List<Accommodation> getAvailableRoomsForCustomer() {
    return getAllRooms().where((room) => room.available).toList();
  }

  // New method to get only available cottages for customer view
  static List<Accommodation> getAvailableCottagesForCustomer() {
    return getAllCottages().where((cottage) => cottage.available).toList();
  }

  static Accommodation? getAccommodationById(String id) {
    final accommodations = getAllAccommodations();
    try {
      return accommodations.firstWhere((acc) => acc.id == id);
    } catch (e) {
      return null;
    }
  }

  static void updateAccommodation(Accommodation accommodation) {
    if (accommodation.type == 'room') {
      final rooms = StorageService.getList('rooms');
      final index = rooms.indexWhere((room) => room['id'] == accommodation.id);
      if (index != -1) {
        rooms[index] = accommodation.toMap();
        StorageService.setList('rooms', rooms);
      }
    } else {
      final cottages = StorageService.getList('cottages');
      final index = cottages.indexWhere((cottage) => cottage['id'] == accommodation.id);
      if (index != -1) {
        cottages[index] = accommodation.toMap();
        StorageService.setList('cottages', cottages);
      }
    }
  }
}
