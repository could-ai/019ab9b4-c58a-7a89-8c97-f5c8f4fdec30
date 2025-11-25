import 'dart:math';
import '../models/drug.dart';
import '../models/pharmacy.dart';

class MockService {
  // Singleton pattern
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;
  MockService._internal();

  final List<Drug> _allDrugs = [
    Drug(id: '1', name: 'Paracetamol', dosage: '500mg', category: 'Pain Relief'),
    Drug(id: '2', name: 'Ibuprofen', dosage: '400mg', category: 'Anti-inflammatory'),
    Drug(id: '3', name: 'Amoxicillin', dosage: '500mg', category: 'Antibiotic'),
    Drug(id: '4', name: 'Cetirizine', dosage: '10mg', category: 'Allergy'),
    Drug(id: '5', name: 'Aspirin', dosage: '81mg', category: 'Blood Thinner'),
    Drug(id: '6', name: 'Metformin', dosage: '500mg', category: 'Diabetes'),
    Drug(id: '7', name: 'Atorvastatin', dosage: '20mg', category: 'Cholesterol'),
    Drug(id: '8', name: 'Omeprazole', dosage: '20mg', category: 'Acid Reflux'),
    Drug(id: '9', name: 'Loratadine', dosage: '10mg', category: 'Allergy'),
    Drug(id: '10', name: 'Vitamin C', dosage: '1000mg', category: 'Supplement'),
  ];

  final List<Pharmacy> _pharmacies = [
    Pharmacy(id: 'p1', name: 'City Health Pharmacy', address: '123 Main St, Downtown', distanceKm: 0.5, rating: 4.5, isOpen: true),
    Pharmacy(id: 'p2', name: 'Green Cross Chemist', address: '456 Oak Ave, Westside', distanceKm: 1.2, rating: 4.8, isOpen: true),
    Pharmacy(id: 'p3', name: 'Night & Day Pharma', address: '789 Pine Rd, North', distanceKm: 2.5, rating: 3.9, isOpen: false),
    Pharmacy(id: 'p4', name: 'Community Care', address: '321 Elm St, Eastside', distanceKm: 0.8, rating: 4.2, isOpen: true),
    Pharmacy(id: 'p5', name: 'MediPlus Drugstore', address: '555 Maple Dr, Suburbs', distanceKm: 3.1, rating: 4.6, isOpen: true),
  ];

  Future<List<Drug>> searchDrugs(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    if (query.isEmpty) return [];
    
    return _allDrugs.where((d) => 
      d.name.toLowerCase().contains(query.toLowerCase()) || 
      d.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<Pharmacy>> findNearbyPharmacies(String drugId, double radiusKm) async {
    // Simulate finding pharmacies that might have the drug
    await Future.delayed(const Duration(seconds: 2));
    
    // Randomly filter pharmacies to simulate stock availability
    final random = Random();
    return _pharmacies.where((p) => p.distanceKm <= radiusKm && (random.nextBool() || p.isOpen)).toList();
  }

  Future<bool> sendRequest(String drugId, List<String> pharmacyIds) async {
    // Simulate sending request to pharmacies
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
