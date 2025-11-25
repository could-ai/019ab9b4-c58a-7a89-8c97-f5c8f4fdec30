import 'package:flutter/material.dart';
import '../models/drug.dart';
import '../models/pharmacy.dart';
import '../services/mock_service.dart';
import 'request_confirmation_screen.dart';

class PharmacyResultsScreen extends StatefulWidget {
  final Drug selectedDrug;

  const PharmacyResultsScreen({super.key, required this.selectedDrug});

  @override
  State<PharmacyResultsScreen> createState() => _PharmacyResultsScreenState();
}

class _PharmacyResultsScreenState extends State<PharmacyResultsScreen> {
  final MockService _mockService = MockService();
  List<Pharmacy> _pharmacies = [];
  final Set<String> _selectedPharmacyIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _findPharmacies();
  }

  void _findPharmacies() async {
    try {
      final results = await _mockService.findNearbyPharmacies(widget.selectedDrug.id, 5.0);
      if (mounted) {
        setState(() {
          _pharmacies = results;
          _isLoading = false;
          // Select all available pharmacies by default
          _selectedPharmacyIds.addAll(
            results.where((p) => p.isOpen).map((p) => p.id)
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error finding pharmacies')),
        );
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedPharmacyIds.contains(id)) {
        _selectedPharmacyIds.remove(id);
      } else {
        _selectedPharmacyIds.add(id);
      }
    });
  }

  void _sendRequest() async {
    if (_selectedPharmacyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one pharmacy')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _mockService.sendRequest(widget.selectedDrug.id, _selectedPharmacyIds.toList());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RequestConfirmationScreen(
              drugName: widget.selectedDrug.name,
              pharmacyCount: _selectedPharmacyIds.length,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pharmacies'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Searching for: ${widget.selectedDrug.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Within 5km radius'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pharmacies.isEmpty
                    ? const Center(child: Text('No nearby pharmacies found.'))
                    : ListView.builder(
                        itemCount: _pharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacy = _pharmacies[index];
                          final isSelected = _selectedPharmacyIds.contains(pharmacy.id);
                          
                          return Opacity(
                            opacity: pharmacy.isOpen ? 1.0 : 0.5,
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: pharmacy.isOpen 
                                  ? (bool? value) => _toggleSelection(pharmacy.id)
                                  : null,
                                title: Text(pharmacy.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pharmacy.address),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_walk, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text('${pharmacy.distanceKm} km'),
                                        const SizedBox(width: 12),
                                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                        const SizedBox(width: 4),
                                        Text(pharmacy.rating.toString()),
                                        const Spacer(),
                                        Text(
                                          pharmacy.isOpen ? 'OPEN' : 'CLOSED',
                                          style: TextStyle(
                                            color: pharmacy.isOpen ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(Icons.store, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || _pharmacies.isEmpty ? null : _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Send Request to (${_selectedPharmacyIds.length}) Pharmacies'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
