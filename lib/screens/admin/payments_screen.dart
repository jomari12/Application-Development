import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/storage_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Payment> payments = [];
  List<Payment> filteredPayments = [];
  String selectedStatusFilter = 'All Status';
  String selectedMethodFilter = 'All Methods';

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _searchController.addListener(_filterPayments);
  }

  void _loadPayments() {
    final paymentsData = StorageService.getList('payments');
    setState(() {
      payments = paymentsData.map((data) => Payment.fromMap(data)).toList();
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      filteredPayments = List.from(payments);
    });
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPayments = payments.where((payment) {
        final matchesSearch =
            payment.bookingId.toLowerCase().contains(query) ||
            payment.referenceNumber?.toLowerCase().contains(query) == true;
        final matchesStatus =
            selectedStatusFilter == 'All Status' ||
            payment.status.toString().split('.').last ==
                selectedStatusFilter.toLowerCase();
        final matchesMethod =
            selectedMethodFilter == 'All Methods' ||
            payment.method.toString().split('.').last ==
                selectedMethodFilter.toLowerCase();
        return matchesSearch && matchesStatus && matchesMethod;
      }).toList();
    });
  }

  void _updatePaymentStatus(Payment payment, PaymentStatus newStatus) {
    final updatedPayment = Payment(
      id: payment.id,
      bookingId: payment.bookingId,
      userId: payment.userId,
      amount: payment.amount,
      method: payment.method,
      status: newStatus,
      createdAt: payment.createdAt,
      referenceNumber: payment.referenceNumber,
      notes: payment.notes,
      proofImageUrl: payment.proofImageUrl,
    );

    final paymentIndex = payments.indexWhere((p) => p.id == payment.id);
    if (paymentIndex != -1) {
      setState(() {
        payments[paymentIndex] = updatedPayment;
        StorageService.setList(
          'payments',
          payments.map((p) => p.toMap()).toList(),
        );
        _filterPayments();
      });
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.completed:
        return const Color(0xFF10B981);
      case PaymentStatus.failed:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  String _getMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }

  Widget _buildStatsCards() {
    final totalAmount = payments.where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
    final pendingCount = payments.where((p) => p.status == PaymentStatus.pending).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return Column(
            children: [
              // First row with two cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Revenue',
                      value: '₱${totalAmount.toStringAsFixed(0)}',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pending Payments',
                      value: '$pendingCount',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Full-width card
              _buildStatCard(
                title: 'Total Payments',
                value: '${payments.length}',
                color: const Color(0xFF1E293B),
              ),
            ],
          );
        } else {
          // Desktop: Original row layout
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Revenue',
                  value: '₱${totalAmount.toStringAsFixed(0)}',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Pending Payments',
                  value: '$pendingCount',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Payments',
                  value: '${payments.length}',
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ), 
            ),
            const SizedBox(height: 6), 
            Text(
              value,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          // Mobile layout: Stack filters vertically
          return Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search payments...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF64748B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedStatusFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'All Status',
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'Failed',
                          child: Text('Failed'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatusFilter = value!;
                          _filterPayments();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMethodFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'All Methods',
                          child: Text('All Methods'),
                        ),
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'Credit Card',
                          child: Text('Credit Card'),
                        ),
                        DropdownMenuItem(
                          value: 'PayPal',
                          child: Text('PayPal'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedMethodFilter = value!;
                          _filterPayments();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop layout: Single row
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF64748B),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatusFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'All Status',
                      child: Text('All Status'),
                    ),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(value: 'Failed', child: Text('Failed')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatusFilter = value!;
                      _filterPayments();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedMethodFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'All Methods',
                      child: Text('All Methods'),
                    ),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('Bank Transfer'),
                    ),
                    DropdownMenuItem(
                      value: 'Credit Card',
                      child: Text('Credit Card'),
                    ),
                    DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMethodFilter = value!;
                      _filterPayments();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment ID: ${payment.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(payment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking ID: ${payment.bookingId}'),
                      const SizedBox(height: 4),
                      Text('Amount: ₱${payment.amount.toStringAsFixed(0)}'),
                      const SizedBox(height: 4),
                      Text('Method: ${_getMethodText(payment.method)}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reference: ${payment.referenceNumber ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (payment.status == PaymentStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updatePaymentStatus(
                        payment,
                        PaymentStatus.completed,
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updatePaymentStatus(payment, PaymentStatus.failed),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          // Mobile: Card layout
          return ListView.builder(
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              return _buildPaymentCard(filteredPayments[index]);
            },
          );
        } else {
          // Desktop: Table layout
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(
                  label: Text(
                    'Payment ID',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Booking ID',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Method',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Reference',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: filteredPayments.map((payment) {
                return DataRow(
                  cells: [
                    DataCell(Text(payment.id)),
                    DataCell(Text(payment.bookingId)),
                    DataCell(Text('₱${payment.amount.toStringAsFixed(0)}')),
                    DataCell(Text(_getMethodText(payment.method))),
                    DataCell(Text(payment.referenceNumber ?? 'N/A')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(payment.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(payment.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                      ),
                    ),
                    DataCell(
                      payment.status == PaymentStatus.pending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Color(0xFF10B981),
                                  ),
                                  onPressed: () => _updatePaymentStatus(
                                    payment,
                                    PaymentStatus.completed,
                                  ),
                                  tooltip: 'Approve Payment',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFFEF4444),
                                  ),
                                  onPressed: () => _updatePaymentStatus(
                                    payment,
                                    PaymentStatus.failed,
                                  ),
                                  tooltip: 'Reject Payment',
                                ),
                              ],
                            )
                          : Text(_getStatusText(payment.status)),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payments Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          _buildStatsCards(),

          const SizedBox(height: 24),

          // Filters
          _buildFilters(),

          const SizedBox(height: 24),

          // Payments List/Table
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: filteredPayments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment,
                              size: 64,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No payments found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildPaymentsList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
