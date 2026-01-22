import '../models/service_model.dart';
import '../services/firestore_service.dart';

/// Service Repository
/// Manages service data operations
class ServiceRepository {
  final FirestoreService _firestoreService = FirestoreService();

  static const String _collection = 'services';

  /// Get all services
  Future<List<Service>> getAllServices() async {
    try {
      final data = await _firestoreService.getCollection(
        collection: _collection,
        queryBuilder: (query) => query.where('isActive', isEqualTo: true),
      );

      return data.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الخدمات: ${e.toString()}');
    }
  }

  /// Get service by ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collection,
        docId: serviceId,
      );

      if (data != null) {
        return Service.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب الخدمة: ${e.toString()}');
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'category', 'operator': '==', 'value': category},
          {'field': 'isActive', 'operator': '==', 'value': true},
        ],
      );

      return data.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الخدمات: ${e.toString()}');
    }
  }

  /// Search services
  Future<List<Service>> searchServices(String searchTerm) async {
    try {
      // Get all active services
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'isActive', 'operator': '==', 'value': true},
        ],
      );

      final services = data.map((json) => Service.fromJson(json)).toList();

      // Filter by search term locally (Firestore doesn't support full-text search)
      final searchLower = searchTerm.toLowerCase();
      return services.where((service) {
        return service.name.toLowerCase().contains(searchLower) ||
            service.nameAr.toLowerCase().contains(searchLower) ||
            service.description.toLowerCase().contains(searchLower) ||
            service.descriptionAr.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  /// Create new service (admin only)
  Future<String> createService(Service service) async {
    try {
      return await _firestoreService.createDocument(
        collection: _collection,
        data: service.toJson(),
      );
    } catch (e) {
      throw Exception('خطأ في إنشاء الخدمة: ${e.toString()}');
    }
  }

  /// Update service
  Future<void> updateService(String serviceId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collection,
        docId: serviceId,
        data: updates,
      );
    } catch (e) {
      throw Exception('خطأ في تحديث الخدمة: ${e.toString()}');
    }
  }

  /// Delete service (soft delete)
  Future<void> deleteService(String serviceId) async {
    try {
      await updateService(serviceId, {'isActive': false});
    } catch (e) {
      throw Exception('خطأ في حذف الخدمة: ${e.toString()}');
    }
  }

  /// Stream all services
  Stream<List<Service>> streamServices() {
    return _firestoreService
        .streamCollection(
          collection: _collection,
          queryBuilder: (query) => query.where('isActive', isEqualTo: true),
        )
        .map((data) => data.map((json) => Service.fromJson(json)).toList());
  }

  /// Stream services by category
  Stream<List<Service>> streamServicesByCategory(String category) {
    return _firestoreService
        .streamCollection(
          collection: _collection,
          queryBuilder: (query) => query
              .where('category', isEqualTo: category)
              .where('isActive', isEqualTo: true),
        )
        .map((data) => data.map((json) => Service.fromJson(json)).toList());
  }
}
