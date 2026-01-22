import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore Service
/// Provides CRUD operations for Firestore collections
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a single document
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب البيانات: ${e.toString()}');
    }
  }

  /// Get all documents in a collection
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    Query Function(Query)? queryBuilder,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب البيانات: ${e.toString()}');
    }
  }

  /// Stream a single document
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    });
  }

  /// Stream a collection
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query Function(Query)? queryBuilder,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);
    
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  /// Create a new document
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      if (docId != null) {
        await _firestore.collection(collection).doc(docId).set(data);
        return docId;
      } else {
        final doc = await _firestore.collection(collection).add(data);
        return doc.id;
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء البيانات: ${e.toString()}');
    }
  }

  /// Update a document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: ${e.toString()}');
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('خطأ في حذف البيانات: ${e.toString()}');
    }
  }

  /// Batch write operations
  Future<void> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final type = op['type'] as String;
        final collection = op['collection'] as String;
        final docId = op['docId'] as String?;
        final data = op['data'] as Map<String, dynamic>?;

        switch (type) {
          case 'set':
            if (docId != null && data != null) {
              batch.set(
                _firestore.collection(collection).doc(docId),
                data,
              );
            }
            break;
          case 'update':
            if (docId != null && data != null) {
              batch.update(
                _firestore.collection(collection).doc(docId),
                data,
              );
            }
            break;
          case 'delete':
            if (docId != null) {
              batch.delete(_firestore.collection(collection).doc(docId));
            }
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('خطأ في العمليات المجمعة: ${e.toString()}');
    }
  }

  /// Query with multiple filters
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collection,
    List<Map<String, dynamic>>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          final field = filter['field'] as String;
          final operator = filter['operator'] as String;
          final value = filter['value'];

          switch (operator) {
            case '==':
              query = query.where(field, isEqualTo: value);
              break;
            case '!=':
              query = query.where(field, isNotEqualTo: value);
              break;
            case '<':
              query = query.where(field, isLessThan: value);
              break;
            case '<=':
              query = query.where(field, isLessThanOrEqualTo: value);
              break;
            case '>':
              query = query.where(field, isGreaterThan: value);
              break;
            case '>=':
              query = query.where(field, isGreaterThanOrEqualTo: value);
              break;
            case 'array-contains':
              query = query.where(field, arrayContains: value);
              break;
            case 'in':
              query = query.where(field, whereIn: value);
              break;
          }
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }
}
