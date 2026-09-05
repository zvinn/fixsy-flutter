import '../entities/ai_diagnosis.dart';

abstract class AiRepository {
  Future<AiDiagnosis> analyzeProblem({
    required String description,
  });
  
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  });
}
