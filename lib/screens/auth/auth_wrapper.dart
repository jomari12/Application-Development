import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user.dart';
import 'login_screen.dart';
import '../admin/admin_main.dart';
import '../customer/customer_main.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize default data
    StorageService.initializeDefaultData();
    
    // Check auth state
    await _authService.checkAuthState();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.userStream,
      initialData: _authService.currentUser,
      builder: (context, snapshot) {
        // If we have a user, route to appropriate screen
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (user.role == UserRole.admin) {
            return const AdminMainScreen();
          } else {
            return const CustomerMainScreen();
          }
        }

        // No user, show login screen
        return const LoginScreen();
      },
    );
  }
}
