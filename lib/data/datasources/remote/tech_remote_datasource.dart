import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/tech_job_model.dart';

/// Contract for Remote Technician Data Source
abstract class ITechRemoteDataSource {
  Stream<List<TechJobModel>> streamRequests(String techEmail);
  Future<void> updateAvailability(String techEmail, bool isAvailable);
  Future<void> updateSchedule(
    String techEmail, {
    required String start,
    required String end,
    required List<String> offDays,
  });
  Future<void> updateRequestStatus(String jobId, String statusValue);
}

/// Firestore Implementation of TechRemoteDataSource
class TechRemoteDataSourceImpl implements ITechRemoteDataSource {
  final FirebaseFirestore _firestore;

  TechRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TechJobModel>> streamRequests(String techEmail) {
    try {
      return _firestore
          .collection('requests')
          .where('technician_email', isEqualTo: techEmail)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => TechJobModel.fromFirestore(doc))
            .toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      });
    } catch (e) {
      AppLogger.warn('Firestore streaming offline for tech: $e');
      return const Stream.empty();
    }
  }

  @override
  Future<void> updateAvailability(String techEmail, bool isAvailable) async {
    try {
      await _firestore.collection('technicians').doc(techEmail).set({
        'isAvailable': isAvailable,
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.warn('Failed to update availability in Firestore: $e');
    }
  }

  @override
  Future<void> updateSchedule(
    String techEmail, {
    required String start,
    required String end,
    required List<String> offDays,
  }) async {
    try {
      await _firestore.collection('technicians').doc(techEmail).set({
        'workingHours': {
          'start': start,
          'end': end,
          'offDays': offDays,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.warn('Failed to update schedule in Firestore: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(String jobId, String statusValue) async {
    try {
      await _firestore.collection('requests').doc(jobId).update({
        'status': statusValue,
      });
    } catch (e) {
      AppLogger.warn('Failed to update request status in Firestore: $e');
    }
  }
}
