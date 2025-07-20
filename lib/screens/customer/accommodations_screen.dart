import 'package:flutter/material.dart';
import '../../models/accommodation.dart';
import '../../services/accommodation_service.dart';
import 'booking_form_screen.dart';

class CustomerAccommodationsScreen extends StatefulWidget {
  const CustomerAccommodationsScreen({super.key});

  @override
  State<CustomerAccommodationsScreen> createState() => _CustomerAccommodationsScreenState();
}

class _CustomerAccommodationsScreenState extends State<CustomerAccommodationsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Accommodation> rooms = [];
  List<Accommodation> cottages = [];
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _showAvailableOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
    _loadAccommodations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAccommodations() {
    setState(() {
      rooms = AccommodationService.getAllRooms();
      cottages = AccommodationService.getAllCottages();
    });
  }

  List<Accommodation> _getFilteredAccommodations(List<Accommodation> accommodations) {
    var filtered = accommodations.where((accommodation) {
      final matchesSearch = accommodation.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          accommodation.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesAvailability = !_showAvailableOnly || accommodation.available;
      return matchesSearch && matchesAvailability;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'availability':
        filtered.sort((a, b) => b.available.toString().compareTo(a.available.toString()));
        break;
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildNavigationSection(isDesktop),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAccommodationSection(_getFilteredAccommodations(rooms), isDesktop, isTablet),
                _buildAccommodationSection(_getFilteredAccommodations(cottages), isDesktop, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 600 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search accommodations...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isDesktop ? 16 : 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 20,
                  vertical: isDesktop ? 16 : 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
              iconSize: isDesktop ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 24,
              vertical: isDesktop ? 24 : 16,
            ),
            child: _buildSearchBar(isDesktop),
          ),
          
          // Navigation Controls Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 24,
              vertical: isDesktop ? 16 : 12,
            ),
            child: isMobile 
                ? _buildMobileNavigation(isDesktop)
                : _buildDesktopNavigation(isDesktop),
          ),
          
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabButtons(isDesktop),
        _buildFilterControls(isDesktop),
      ],
    );
  }

  Widget _buildMobileNavigation(bool isDesktop) {
    return Column(
      children: [
        // Tab buttons at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton(
              'Rooms',
              Icons.hotel_outlined,
              Icons.hotel,
              0,
              isDesktop,
            ),
            const SizedBox(width: 16),
            _buildTabButton(
              'Cottages',
              Icons.cottage_outlined,
              Icons.cottage,
              1,
              isDesktop,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Filter controls below tabs
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(isDesktop),
            ),
            const SizedBox(width: 12),
            _buildAvailabilityFilter(isDesktop),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButtons(bool isDesktop) {
    return Row(
      children: [
        _buildTabButton(
          'Rooms',
          Icons.hotel_outlined,
          Icons.hotel,
          0,
          isDesktop,
        ),
        const SizedBox(width: 24),
        _buildTabButton(
          'Cottages',
          Icons.cottage_outlined,
          Icons.cottage,
          1,
          isDesktop,
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, IconData outlinedIcon, IconData filledIcon, int index, bool isDesktop) {
    final isSelected = _tabController.index == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : (isDesktop ? 24 : 16),
          vertical: isMobile ? 8 : (isDesktop ? 12 : 8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: isMobile ? 16 : (isDesktop ? 20 : 18),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: isMobile ? 12 : (isDesktop ? 16 : 14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls(bool isDesktop) {
    return Row(
      children: [
        _buildDropdownFilter(isDesktop),
        const SizedBox(width: 16),
        _buildAvailabilityFilter(isDesktop),
      ],
    );
  }

  Widget _buildDropdownFilter(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        onChanged: (value) => setState(() => _sortBy = value!),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : (isDesktop ? 16 : 12),
          vertical: isMobile ? 6 : (isDesktop ? 8 : 6),
        ),
        style: TextStyle(
          fontSize: isMobile ? 12 : (isDesktop ? 14 : 13),
          color: Colors.grey.shade700,
        ),
        items: [
          DropdownMenuItem(
            value: 'name', 
            child: Text(isMobile ? 'Name' : 'Sort by Name')
          ),
          DropdownMenuItem(
            value: 'price_low', 
            child: Text(isMobile ? 'Price ↑' : 'Price: Low to High')
          ),
          DropdownMenuItem(
            value: 'price_high', 
            child: Text(isMobile ? 'Price ↓' : 'Price: High to Low')
          ),
          DropdownMenuItem(
            value: 'availability', 
            child: Text(isMobile ? 'Available' : 'Availability')
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityFilter(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return GestureDetector(
      onTap: () => setState(() => _showAvailableOnly = !_showAvailableOnly),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : (isDesktop ? 16 : 12),
          vertical: isMobile ? 10 : (isDesktop ? 12 : 10),
        ),
        decoration: BoxDecoration(
          color: _showAvailableOnly ? const Color(0xFF3B82F6) : Colors.white,
          border: Border.all(
            color: _showAvailableOnly ? const Color(0xFF3B82F6) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showAvailableOnly ? Icons.check_circle : Icons.circle_outlined,
              color: _showAvailableOnly ? Colors.white : Colors.grey.shade600,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              isMobile ? 'Available' : 'Available Only',
              style: TextStyle(
                color: _showAvailableOnly ? Colors.white : Colors.grey.shade600,
                fontSize: isMobile ? 11 : (isDesktop ? 14 : 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationSection(List<Accommodation> accommodations, bool isDesktop, bool isTablet) {
    if (accommodations.isEmpty) {
      return _buildEmptyState(isDesktop);
    }

    int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    double childAspectRatio = isDesktop ? 0.75 : (isTablet ? 0.8 : 0.85);

    // Get the correct type name based on current tab
    String accommodationType = _tabController.index == 0 ? 'Rooms' : 'Cottages';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 48 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${accommodations.length} $accommodationType Found',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isDesktop ? 32 : 16,
                mainAxisSpacing: isDesktop ? 32 : 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: accommodations.length,
              itemBuilder: (context, index) {
                return _buildAccommodationCard(accommodations[index], isDesktop);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: isDesktop ? 80 : 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No accommodations found',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      accommodation.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: isDesktop ? 48 : 32,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: isDesktop ? 12 : 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accommodation.available 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      accommodation.available ? 'Available' : 'Booked',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accommodation.name,
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      accommodation.description,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (accommodation.amenities.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: accommodation.amenities.take(3).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenity,
                            style: TextStyle(
                              color: const Color(0xFF3B82F6),
                              fontSize: isDesktop ? 11 : 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₱${accommodation.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: accommodation.available
                            ? () => _navigateToBookingForm(accommodation)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accommodation.available 
                              ? const Color(0xFF3B82F6) 
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24 : 16,
                            vertical: isDesktop ? 12 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          accommodation.available ? 'Book Now' : 'Unavailable',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBookingForm(Accommodation accommodation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(accommodation: accommodation),
      ),
    ).then((_) => _loadAccommodations());
  }
}