import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/service_request.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/analytics_service.dart';

class ServiceRequestProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  
  // Form state
  String _selectedServiceType = '';
  String _description = '';
  String _address = '';
  DateTime? _scheduledDate;
  List<XFile> _images = [];
  
  // AI Diagnosis
  AiDiagnosis? _aiDiagnosis;
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  
  // Getters
  String get selectedServiceType => _selectedServiceType;
  String get description => _description;
  String get address => _address;
  DateTime? get scheduledDate => _scheduledDate;
  List<XFile> get images => _images;
  AiDiagnosis? get aiDiagnosis => _aiDiagnosis;
  bool get isAnalyzing => _isAnalyzing;
  bool get isSubmitting => _isSubmitting;
  
  // Setters
  void setServiceType(String type) {
    _selectedServiceType = type;
    notifyListeners();
  }
  
  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }
  
  void setAddress(String addr) {
    _address = addr;
    notifyListeners();
  }
  
  void setScheduledDate(DateTime? date) {
    _scheduledDate = date;
    notifyListeners();
  }
  
  void addImage(XFile image) {
    _images.add(image);
    notifyListeners();
  }
  
  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }
  
  void clearImages() {
    _images.clear();
    notifyListeners();
  }
  
  /// Analyze problem with AI
  Future<void> analyzeWithAI() async {
    if (_description.isEmpty) {
      throw Exception('الرجاء إدخال وصف المشكلة أولاً');
    }
    
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      _aiDiagnosis = await _aiService.analyzeProblem(
        images: _images,
        description: _description,
      );
      
      // Auto-set service type from AI suggestion
      if (_selectedServiceType.isEmpty && _aiDiagnosis!.suggestedService.isNotEmpty) {
        _selectedServiceType = _aiDiagnosis!.suggestedService;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
  
  /// Submit service request
  Future<String> submitRequest(String userId) async {
    // Validation
    if (_selectedServiceType.isEmpty) {
      throw Exception('الرجاء اختيار نوع الخدمة');
    }
    
    if (_description.isEmpty) {
      throw Exception('الرجاء إدخال وصف المشكلة');
    }
    
    if (_address.isEmpty) {
      throw Exception('الرجاء إدخال العنوان');
    }
    
    _isSubmitting = true;
    notifyListeners();
    
    try {
      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (var image in _images) {
        final url = await _storageService.uploadFile(
          file: image,
          path: 'service_requests/$userId/${DateTime.now().millisecondsSinceEpoch}',
        );
        imageUrls.add(url);
      }
      
      // Create service request object
      final request = ServiceRequest(
        id: '', // Will be set by Firestore
        userId: userId,
        category: _selectedServiceType,
        description: _description,
        status: 'pending',
        createdAt: DateTime.now(),
        scheduledFor: _scheduledDate,
        imageUrls: imageUrls,
        estimatedPrice: _aiDiagnosis?.estimatedPrice ?? 0,
        aiDiagnosis: _aiDiagnosis != null ? _aiDiagnosis!.problem : null,
      );
      
      // Save to Firestore
      final docId = await _firestoreService.createDocument(
        collection: 'serviceRequests',
        data: request.toJson(),
      );
      
      // Log Analytics
      await AnalyticsService.logBookingRequest(
        serviceType: _selectedServiceType,
        price: _aiDiagnosis?.estimatedPrice ?? 0,
      );
      
      // Clear form after successful submission
      reset();
      
      return docId;
    } catch (e) {
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
  
  /// Reset form
  void reset() {
    _selectedServiceType = '';
    _description = '';
    _address = '';
    _scheduledDate = null;
    _images.clear();
    _aiDiagnosis = null;
    _isAnalyzing = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
