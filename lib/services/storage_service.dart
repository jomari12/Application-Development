import 'dart:convert';
import 'dart:html' as html;

class StorageService {
  static late html.Storage _localStorage;

  static Future<void> init() async {
    _localStorage = html.window.localStorage;
  }

  // Generic storage methods
  static void setString(String key, String value) {
    _localStorage[key] = value;
  }

  static String? getString(String key) {
    return _localStorage[key];
  }

  static void setObject(String key, Map<String, dynamic> object) {
    _localStorage[key] = jsonEncode(object);
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _localStorage[key];
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static void setList(String key, List<Map<String, dynamic>> list) {
    _localStorage[key] = jsonEncode(list);
  }

  static List<Map<String, dynamic>> getList(String key) {
    final jsonString = _localStorage[key];
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static void remove(String key) {
    _localStorage.remove(key);
  }

  static void clear() {
    _localStorage.clear();
  }

  // Initialize default data
  static void initializeDefaultData() {
    // Initialize rooms if not exists
    if (getList('rooms').isEmpty) {
      setList('rooms', [
        {
          'id': 'R001',
          'name': 'Air Conditioned Room',
          'image': '../assets/images/room.png',
          'price': 2500,
          'description': 'Luxurious room with stunning ocean views, air conditioning, and premium amenities.',
          'available': true,
          'amenities': [],
          'type': 'room'
        },
        {
          'id': 'R002',
          'name': 'Ventilated Room',
          'image': '../assets/images/room.png',
          'price': 4500,
          'description': 'Entrance fee for up to 3 persons with one small cottage',
          'amenities': [],
          'available': true,
          'type': 'room'
        },
        {
          'id': 'R003',
          'name': 'Deluxe Room',
          'image': '../assets/images/room.png',
          'price': 5500,
          'description': '',
          'amenities': [],
          'available': true,
          'type': 'room'
        },
      ]);
    }

    // Initialize cottages if not exists
    if (getList('cottages').isEmpty) {
      setList('cottages', [
        {
          'id': 'C002',
          'name': 'Big Cottage',
          'image': '../assets/images/cottage.png',
          'price': 800,
          'description': '',
          'amenities': [],
          'available': true,
          'type': 'cottage'
        },
        {
          'id': 'C003',
          'name': 'Small Cottage',
          'image': '../assets/images/cottage.png',
          'price': 8000,
          'description': '',
          'amenities': [],
          'available': true,
          'type': 'cottage'
        },
      ]);
    }

    // Initialize users if not exists
    if (getList('users').isEmpty) {
      setList('users', [
        {
          'id': '1',
          'email': 'admin@resort.com',
          'password': 'admin123',
          'name': 'Resort Admin',
          'role': 'admin',
          'phone': '+63 912 345 6789',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'email': 'customer@gmail.com',
          'password': 'customer123',
          'name': 'John Customer',
          'role': 'customer',
          'phone': '+63 987 654 3210',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]);
    }

    // Initialize empty lists for other data
    if (getList('bookings').isEmpty) {
      setList('bookings', []);
    }
    if (getList('payments').isEmpty) {
      setList('payments', []);
    }
    if (getList('reviews').isEmpty) {
      setList('reviews', []);
    }
  }
}
