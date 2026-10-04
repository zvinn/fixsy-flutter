import 'package:fixsy_flutter/data/models/tech_job_model.dart';
import 'package:fixsy_flutter/domain/repositories/tech_repository.dart';

/// Offline fake of [ITechRepository] for tests.
/// Never touches Firebase. The empty job stream keeps the provider's
/// built-in fallback jobs.
class FakeTechRepository implements ITechRepository {
  @override
  Stream<List<TechJobModel>> streamTechJobs(String techEmail) =>
      const Stream<List<TechJobModel>>.empty();

  @override
  Future<void> updateAvailability(String techEmail, bool isAvailable) async {}

  @override
  Future<void> updateSchedule(
    String techEmail, {
    required String start,
    required String end,
    required List<String> offDays,
  }) async {}

  @override
  Future<void> updateJobStatus(String jobId, TechJobStatus newStatus) async {}
}
