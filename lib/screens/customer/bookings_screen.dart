import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';
import 'payment_screen.dart';
import 'review_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _bookings = BookingService.getBookingsByUserId(currentUser.id);
      _bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _bookings = [];
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Booking> get _filteredBookings {
    if (_selectedFilter == 'all') return _bookings;
    return _bookings.where((booking) {
      switch (_selectedFilter) {
        case 'pending':
          return booking.status == BookingStatus.pending;
        case 'confirmed':
          return booking.status == BookingStatus.confirmed;
        case 'completed':
          return booking.status == BookingStatus.completed;
        case 'cancelled':
          return booking.status == BookingStatus.cancelled;
        default:
          return true;
      }
    }).toList();
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
      case BookingStatus.completed:
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Payment';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  bool _hasPaymentForBooking(String bookingId) {
    final payments = PaymentService.getPaymentsByBookingId(bookingId);
    return payments.isNotEmpty;
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All Bookings'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'confirmed', 'label': 'Confirmed'},
      {'key': 'completed', 'label': 'Completed'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter['key'];
        return FilterChip(
          label: Text(filter['label']!),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = filter['key']!;
            });
          },
          backgroundColor: Colors.grey[100],
          selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
          checkmarkColor: const Color(0xFF3B82F6),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'all' 
                ? 'Book a room or cottage to see your reservations here'
                : 'No ${_selectedFilter} bookings at the moment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final hasPayment = _hasPaymentForBooking(booking.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.accommodationName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking ID: ${booking.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Booking Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        _buildDetailItem(
                          Icons.calendar_today,
                          'Check-in',
                          booking.checkIn.toString().split(' ')[0],
                        ),
                        const SizedBox(width: 32),
                        _buildDetailItem(
                          Icons.calendar_today,
                          'Check-out',
                          booking.checkOut.toString().split(' ')[0],
                        ),
                        const SizedBox(width: 32),
                        _buildDetailItem(
                          Icons.group,
                          'Guests',
                          '${booking.guests}',
                        ),
                        const Spacer(),
                        _buildTotalAmount(booking.totalAmount),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                Icons.calendar_today,
                                'Check-in',
                                booking.checkIn.toString().split(' ')[0],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailItem(
                                Icons.calendar_today,
                                'Check-out',
                                booking.checkOut.toString().split(' ')[0],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                Icons.group,
                                'Guests',
                                '${booking.guests}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTotalAmount(booking.totalAmount),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (booking.status == BookingStatus.pending && !hasPayment)
                  _buildActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(booking: booking),
                        ),
                      );
                      _loadBookings();
                    },
                    icon: Icons.payment,
                    label: 'Pay Now',
                    color: const Color(0xFF3B82F6),
                  ),
                if (booking.status == BookingStatus.pending && hasPayment)
                  _buildActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(booking: booking),
                        ),
                      );
                      _loadBookings();
                    },
                    icon: Icons.rate_review,
                    label: 'Leave Feedback',
                    color: const Color(0xFFF59E0B),
                  ),
                if (booking.status == BookingStatus.completed)
                  _buildActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(booking: booking),
                        ),
                      );
                      _loadBookings();
                    },
                    icon: Icons.star,
                    label: 'Leave Review',
                    color: const Color(0xFFF59E0B),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount(double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₱${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final maxWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: isDesktop ? 32 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (!isDesktop) ...[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: isDesktop ? 32 : 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your reservations and payments',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadBookings,
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Filter Chips
              _buildFilterChips(),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      )
                    : _filteredBookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredBookings.length,
                            itemBuilder: (context, index) {
                              return _buildBookingCard(_filteredBookings[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}