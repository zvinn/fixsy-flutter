import '../../data/models/tech_job_model.dart';

/// Technician Repository Contract
/// Complies with Fixsy Constitution Principle I (Clean Architecture)
/// Zero dependencies on Flutter UI or Firebase.
abstract class ITechRepository {
  /// Stream assigned jobs for a technician by email
  Stream<List<TechJobModel>> streamTechJobs(String techEmail);

  /// Toggle technician real-time availability
  Future<void> updateAvailability(String techEmail, bool isAvailable);

  /// Update technician weekly schedule and working hours
  Future<void> updateSchedule(
    String techEmail, {
    required String start,
    required String end,
    required List<String> offDays,
  });

  /// Update the status of a specific job request
  Future<void> updateJobStatus(String jobId, TechJobStatus newStatus);
}
