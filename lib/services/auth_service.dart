import 'dart:async';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  User? _currentUser;

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    final users = StorageService.getList('users');
    
    final userData = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => <String, dynamic>{},
    );

    if (userData.isNotEmpty) {
      _currentUser = User.fromMap(userData);
      _userController.add(_currentUser);
      StorageService.setString('currentUserId', _currentUser!.id);
      return true;
    }

    return false;
  }

  Future<bool> register(String email, String password, String name, String phone, UserRole role) async {
    final users = StorageService.getList('users');
    
    // Check if email already exists
    final existingUser = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => <String, dynamic>{},
    );

    if (existingUser.isNotEmpty) {
      return false; // Email already exists
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      phone: phone,
      createdAt: DateTime.now(),
    );

    users.add({
      ...newUser.toMap(),
      'password': password,
    });

    StorageService.setList('users', users);
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _userController.add(null);
    StorageService.remove('currentUserId');
  }

  Future<void> checkAuthState() async {
    final userId = StorageService.getString('currentUserId');
    if (userId != null) {
      final users = StorageService.getList('users');
      final userData = users.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      if (userData.isNotEmpty) {
        _currentUser = User.fromMap(userData);
        _userController.add(_currentUser);
      } else {
        // Invalid stored user ID, clear it
        StorageService.remove('currentUserId');
        _currentUser = null;
        _userController.add(null);
      }
    } else {
      // No stored user, ensure we emit null
      _currentUser = null;
      _userController.add(null);
    }
  }

  void dispose() {
    _userController.close();
  }
}
