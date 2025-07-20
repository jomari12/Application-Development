import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'bookings_screen.dart';
import 'rooms_screen.dart';
import 'cottages_screen.dart';
import 'reviews_screen.dart';
import 'payments_screen.dart';
import 'messages_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isCollapsed = false;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminBookingsScreen(),
    const AdminRoomsScreen(),
    const AdminCottagesScreen(),
    const AdminReviewsScreen(),
    const AdminPaymentsScreen(),
    const AdminMessagesScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Bookings',
      'icon': Icons.calendar_today_outlined,
      'activeIcon': Icons.calendar_today,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Rooms',
      'icon': Icons.hotel_outlined,
      'activeIcon': Icons.hotel,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Cottages',
      'icon': Icons.cottage_outlined,
      'activeIcon': Icons.cottage,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'Reviews',
      'icon': Icons.star_outline,
      'activeIcon': Icons.star,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Payments',
      'icon': Icons.payment_outlined,
      'activeIcon': Icons.payment,
      'color': const Color(0xFF06B6D4),
    },
    {
      'title': 'Messages',
      'icon': Icons.message_outlined,
      'activeIcon': Icons.message,
      'color': const Color(0xFF84CC16),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isCollapsed ? 70 : 280,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png', // Corrected path
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (!_isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin Panel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Debbie & Krys Beach Resort',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Toggle Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _isCollapsed ? Icons.menu : Icons.menu_open,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];
                        final isSelected = _selectedIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                                _animationController.reset();
                                _animationController.forward();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? item['color'].withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: item['color'].withOpacity(0.3),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? item['activeIcon']
                                          : item['icon'],
                                      color: isSelected
                                          ? item['color']
                                          : Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    if (!_isCollapsed) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['title'],
                                          style: TextStyle(
                                            color: isSelected
                                                ? item['color']
                                                : Colors.white.withOpacity(0.9),
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // User Profile Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(
                            (_authService.currentUser?.name.substring(0, 1) ??
                                    'A')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (!_isCollapsed) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _authService.currentUser?.name ?? 'Admin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Administrator',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<int>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            color: Colors.white,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => _authService.logout(),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Color(0xFFEF4444),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar for Mobile
                if (isMobile)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _menuItems[_selectedIndex]['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        PopupMenuButton<int>(
                          icon: const Icon(Icons.account_circle),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(
                                'Welcome, ${_authService.currentUser?.name ?? 'Admin'}',
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              onTap: () => _authService.logout(),
                              child: const Row(
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Content Area
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation for Mobile - Now shows all 7 items
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF3B82F6),
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedFontSize: 10,
                unselectedFontSize: 10,
                items: _menuItems.map((item) {
                  return BottomNavigationBarItem(
                    icon: Icon(item['icon'], size: 20),
                    activeIcon: Icon(item['activeIcon'], size: 20),
                    label: item['title'],
                  );
                }).toList(),
              ),
            )
          : null,
    );
  }
}