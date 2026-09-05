import '../../domain/entities/ai_diagnosis.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/remote/ai_remote_data_source.dart';
import '../../core/error/error_logger.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepositoryImpl(this._remoteDataSource);

  @override
  Future<AiDiagnosis> analyzeProblem({required String description}) async {
    try {
      return await _remoteDataSource.analyzeProblem(description: description);
    } catch (e, stack) {
      ErrorLogger.logError(e, stack, reason: 'AI Repository analyzeProblem failed');
      
      // Fallback entity
      return AiDiagnosis(
        problem: 'تعذر التحليل حالياً. يرجى الاختيار يدوياً.',
        suggestedService: 'غير محدد',
        solution: 'سجل طلبك وسنتواصل معك.',
        estimatedPrice: 0,
        confidence: 'منخفض',
      );
    }
  }

  @override
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  }) async {
    try {
      return await _remoteDataSource.getServiceRecommendation(
        serviceType: serviceType,
        problemDescription: problemDescription,
      );
    } catch (e, stack) {
      ErrorLogger.logError(e, stack, reason: 'AI Repository getRecommendation failed');
      return 'تأكد من اختيار فني ذو خبرة وتقييمات جيدة.';
    }
  }
}
