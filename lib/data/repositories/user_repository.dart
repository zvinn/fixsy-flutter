import '../models/user.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// User Repository
/// Manages user data and profile operations
class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  static const String _collection = 'users';

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collection,
        docId: userId,
      );
      
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  /// Create or update user
  Future<void> saveUser(User user) async {
    try {
      await _firestoreService.createDocument(
        collection: _collection,
        docId: user.id,
        data: user.toJson(),
      );
    } catch (e) {
      throw Exception('خطأ في حفظ بيانات المستخدم: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collection,
        docId: userId,
        data: updates,
      );
    } catch (e) {
      throw Exception('خطأ في تحديث بيانات المستخدم: ${e.toString()}');
    }
  }

  /// Update user avatar
  Future<String> updateUserAvatar({
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      final imageUrl = await _storageService.pickAndUploadAvatar(
        userId: userId,
        onProgress: onProgress,
      );

      if (imageUrl == null) {
        throw Exception('لم يتم اختيار صورة');
      }

      await updateUser(userId, {'photoURL': imageUrl});
      return imageUrl;
    } catch (e) {
      throw Exception('خطأ في تحديث الصورة: ${e.toString()}');
    }
  }

  /// Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'role', 'operator': '==', 'value': role}
        ],
      );

      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب المستخدمين: ${e.toString()}');
    }
  }

  /// Search users by name
  Future<List<User>> searchUsersByName(String searchTerm) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {
            'field': 'displayName',
            'operator': '>=',
            'value': searchTerm,
          },
          {
            'field': 'displayName',
            'operator': '<=',
            'value': '$searchTerm\uf8ff',
          }
        ],
        limit: 20,
      );

      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        docId: userId,
      );
    } catch (e) {
      throw Exception('خطأ في حذف المستخدم: ${e.toString()}');
    }
  }

  /// Stream user data
  Stream<User?> streamUser(String userId) {
    return _firestoreService
        .streamDocument(collection: _collection, docId: userId)
        .map((data) => data != null ? User.fromJson(data) : null);
  }
}
