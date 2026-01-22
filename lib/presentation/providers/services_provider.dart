import 'package:flutter/material.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

/// Services Provider
/// Manages services state and operations
class ServicesProvider with ChangeNotifier {
  final ServiceRepository _serviceRepository = ServiceRepository();

  List<Service> _services = [];
  List<Service> _filteredServices = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  String _searchTerm = '';

  // Getters
  List<Service> get services => _filteredServices.isEmpty && _searchTerm.isEmpty
      ? _services
      : _filteredServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchTerm => _searchTerm;

  /// Load all services
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _serviceRepository.getAllServices();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Search services
  void searchServices(String searchTerm) {
    _searchTerm = searchTerm;
    _applyFilters();
    notifyListeners();
  }

  /// Apply filters and search
  void _applyFilters() {
    var filtered = _services;

    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered = filtered
          .where((service) => service.category == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchTerm.isNotEmpty) {
      final searchLower = _searchTerm.toLowerCase();
      filtered = filtered.where((service) {
        return service.name.toLowerCase().contains(searchLower) ||
            service.nameAr.toLowerCase().contains(searchLower) ||
            service.description.toLowerCase().contains(searchLower) ||
            service.descriptionAr.toLowerCase().contains(searchLower);
      }).toList();
    }

    _filteredServices = filtered;
  }

  /// Get service by ID
  Service? getServiceById(String serviceId) {
    try {
      return _services.firstWhere((service) => service.id == serviceId);
    } catch (e) {
      return null;
    }
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = 'all';
    _searchTerm = '';
    _filteredServices = [];
    notifyListeners();
  }

  /// Refresh services
  Future<void> refresh() async {
    await loadServices();
  }
}
