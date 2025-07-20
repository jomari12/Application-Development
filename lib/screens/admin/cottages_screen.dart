import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class AdminCottagesScreen extends StatefulWidget {
  const AdminCottagesScreen({super.key});

  @override
  State<AdminCottagesScreen> createState() => _AdminCottagesScreenState();
}

class _AdminCottagesScreenState extends State<AdminCottagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> cottages = [];
  List<Map<String, dynamic>> filteredCottages = [];
  String selectedFilterStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _loadCottages();
    _searchController.addListener(_filterCottages);
  }

  void _loadCottages() {
    setState(() {
      cottages = StorageService.getList('cottages');
      filteredCottages = List.from(cottages);
    });
  }

  void _filterCottages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCottages = cottages.where((cottage) {
        final matchesSearch = cottage['id'].toLowerCase().contains(query) ||
            cottage['name'].toLowerCase().contains(query);
        final matchesStatus = selectedFilterStatus == 'All Status' ||
            (cottage['available'] ? 'Available' : 'Not Available') == selectedFilterStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _deleteCottage(String cottageId) {
    setState(() {
      cottages.removeWhere((cottage) => cottage['id'] == cottageId);
      StorageService.setList('cottages', cottages);
      _filterCottages();
    });
  }

  String _generateNextCottageId() {
    final ids = cottages.map((c) => c['id'].toString()).toList();
    final numbers = ids
        .map((id) => int.tryParse(id.replaceAll('C', '')) ?? 0)
        .toList()
      ..sort();
    final nextNumber = (numbers.isNotEmpty ? numbers.last + 1 : 1)
        .toString()
        .padLeft(3, '0');
    return 'C$nextNumber';
  }

  void _showAddCottageDialog() {
    final nameController = TextEditingController();
    final imageController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final amenitiesController = TextEditingController();
    bool isAvailable = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Cottage'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cottage ID: ${_generateNextCottageId()}'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Cottage Name'),
                  ),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'Leave empty for placeholder image',
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price per night'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: amenitiesController,
                    decoration: const InputDecoration(
                      labelText: 'Amenities (comma separated)',
                      hintText: 'AC, WiFi, Kitchen, etc.',
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Available'),
                    value: isAvailable,
                    onChanged: (value) {
                      setStateDialog(() {
                        isAvailable = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and Price are required.')),
                    );
                    return;
                  }

                  final amenitiesList = amenitiesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final newCottage = {
                    'id': _generateNextCottageId(),
                    'name': nameController.text.trim(),
                    'image': imageController.text.trim().isEmpty
                        ? 'https://via.placeholder.com/400x300?text=Cottage+Image+Placeholder'
                        : imageController.text.trim(),
                    'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                    'description': descriptionController.text.trim().isEmpty
                        ? 'Beautiful cottage for your perfect getaway.'
                        : descriptionController.text.trim(),
                    'amenities': amenitiesList.isEmpty ? ['WiFi', 'Kitchen'] : amenitiesList,
                    'available': isAvailable,
                    'type': 'cottage',
                  };

                  setState(() {
                    cottages.add(newCottage);
                    StorageService.setList('cottages', cottages);
                    _filterCottages();
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _statusChip(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Not Available',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Mobile Card Layout
  Widget _buildMobileCard(Map<String, dynamic> cottage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cottage['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.image_not_supported, color: Color(0xFF64748B)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cottage['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cottage['id'],
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${cottage['price'].toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ),
                _statusChip(cottage['available']),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                  onPressed: () => _deleteCottage(cottage['id']),
                  tooltip: 'Delete Cottage',
                ),
                IconButton(
                  icon: Icon(
                    cottage['available'] ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF2563EB),
                  ),
                  tooltip: cottage['available'] ? 'Mark Unavailable' : 'Mark Available',
                  onPressed: () {
                    setState(() {
                      cottage['available'] = !cottage['available'];
                      StorageService.setList('cottages', cottages);
                      _filterCottages();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Data Table
  Widget _buildDesktopTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text('Cottage ID', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Cottage Name', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
          ],
          rows: filteredCottages.map((cottage) {
            return DataRow(
              cells: [
                DataCell(Text(cottage['id'])),
                DataCell(Text(cottage['name'])),
                DataCell(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cottage['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image_not_supported, color: Color(0xFF64748B)),
                        );
                      },
                    ),
                  ),
                ),
                DataCell(Text('₱${cottage['price'].toStringAsFixed(0)}')),
                DataCell(_statusChip(cottage['available'])),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                        onPressed: () => _deleteCottage(cottage['id']),
                        tooltip: 'Delete Cottage',
                      ),
                      IconButton(
                        icon: Icon(
                          cottage['available'] ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF2563EB),
                        ),
                        tooltip: cottage['available'] ? 'Mark Unavailable' : 'Mark Available',
                        onPressed: () {
                          setState(() {
                            cottage['available'] = !cottage['available'];
                            StorageService.setList('cottages', cottages);
                            _filterCottages();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cottage Management',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF1E293B)
                ),
              ),
              const SizedBox(height: 24),
              
              // Search and Filter Controls
              if (isMobile) ...[
                // Mobile: Stack vertically
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cottage...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
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
                        value: selectedFilterStatus,
                        items: const [
                          DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                          DropdownMenuItem(value: 'Available', child: Text('Available')),
                          DropdownMenuItem(value: 'Not Available', child: Text('Not Available')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFilterStatus = value!;
                            _filterCottages();
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
                    ElevatedButton(
                      onPressed: _showAddCottageDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ] else ...[
                // Desktop: Keep original row layout
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search cottage...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
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
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedFilterStatus,
                        items: const [
                          DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                          DropdownMenuItem(value: 'Available', child: Text('Available')),
                          DropdownMenuItem(value: 'Not Available', child: Text('Not Available')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFilterStatus = value!;
                            _filterCottages();
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
                    ElevatedButton.icon(
                      onPressed: _showAddCottageDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Cottage'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Content Area
              Expanded(
                child: isMobile
                    ? ListView.builder(
                        itemCount: filteredCottages.length,
                        itemBuilder: (context, index) {
                          return _buildMobileCard(filteredCottages[index]);
                        },
                      )
                    : _buildDesktopTable(),
              ),
            ],
          ),
        );
      },
    );
  }
}