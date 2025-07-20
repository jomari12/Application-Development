enum UserRole { admin, customer }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == UserRole.admin ? 'admin' : 'customer',
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
