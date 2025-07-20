import 'package:flutter/material.dart';

class CustomerRoomsScreen extends StatefulWidget {
  const CustomerRoomsScreen({super.key});

  @override
  State<CustomerRoomsScreen> createState() => _CustomerRoomsScreenState();
}

class _CustomerRoomsScreenState extends State<CustomerRoomsScreen> {
  final List<Map<String, dynamic>> rooms = [
    {
      'id': 'R001',
      'name': 'Airconditioned Room',
      'image': 'https://via.placeholder.com/300x200',
      'price': 4500,
      'description': 'Comfortable room with air conditioning, perfect for a relaxing stay.',
      'amenities': ['AC', 'WiFi', 'TV', 'Private Bath'],
      'available': true,
    },
    {
      'id': 'R002',
      'name': 'Ventilated Room',
      'image': 'https://via.placeholder.com/300x200',
      'price': 2500,
      'description': 'Budget-friendly room with natural ventilation and basic amenities.',
      'amenities': ['Fan', 'WiFi', 'Shared Bath'],
      'available': true,
    },
    {
      'id': 'R003',
      'name': 'Deluxe Room',
      'image': 'https://via.placeholder.com/300x200',
      'price': 5500,
      'description': 'Luxury room with premium amenities and ocean view.',
      'amenities': ['AC', 'WiFi', 'TV', 'Mini Bar', 'Ocean View', 'Private Bath'],
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Rooms',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        room['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  room['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: room['available'] ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    room['available'] ? 'Available' : 'Booked',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              room['description'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: (room['amenities'] as List<String>)
                                  .map((amenity) => Chip(
                                        label: Text(amenity),
                                        backgroundColor: Colors.blue.shade50,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₱${room['price']}/night',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: room['available']
                                      ? () => _showBookingDialog(room)
                                      : null,
                                  child: Text(room['available'] ? 'Book Now' : 'Not Available'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> room) {
    final checkInController = TextEditingController();
    final checkOutController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${room['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: checkInController,
              decoration: const InputDecoration(
                labelText: 'Check-in Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  checkInController.text = '${date.day}/${date.month}/${date.year}';
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: checkOutController,
              decoration: const InputDecoration(
                labelText: 'Check-out Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  checkOutController.text = '${date.day}/${date.month}/${date.year}';
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (checkInController.text.isNotEmpty && checkOutController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking request sent for ${room['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}
