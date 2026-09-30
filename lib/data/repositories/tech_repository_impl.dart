import 'dart:async';
import '../../domain/repositories/tech_repository.dart';
import '../datasources/remote/tech_remote_datasource.dart';
import '../models/tech_job_model.dart';

/// Concrete Implementation of ITechRepository
class TechRepositoryImpl implements ITechRepository {
  final ITechRemoteDataSource _remoteDataSource;

  TechRepositoryImpl({ITechRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TechRemoteDataSourceImpl();

  @override
  Stream<List<TechJobModel>> streamTechJobs(String techEmail) {
    return _remoteDataSource.streamRequests(techEmail);
  }

  @override
  Future<void> updateAvailability(String techEmail, bool isAvailable) {
    return _remoteDataSource.updateAvailability(techEmail, isAvailable);
  }

  @override
  Future<void> updateSchedule(
    String techEmail, {
    required String start,
    required String end,
    required List<String> offDays,
  }) {
    return _remoteDataSource.updateSchedule(
      techEmail,
      start: start,
      end: end,
      offDays: offDays,
    );
  }

  @override
  Future<void> updateJobStatus(String jobId, TechJobStatus newStatus) {
    return _remoteDataSource.updateRequestStatus(jobId, newStatus.toValueString());
  }
}
