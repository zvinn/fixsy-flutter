import 'package:dio/dio.dart';
import '../../../core/config/env_config.dart';
import '../../models/ai_diagnosis.dart';

abstract class AiRemoteDataSource {
  Future<AiDiagnosis> analyzeProblem({
    required String description,
  });
  
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  });
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio _dio;
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  AiRemoteDataSourceImpl(this._dio);

  @override
  Future<AiDiagnosis> analyzeProblem({required String description}) async {
    final prompt = '''
أنت خبير في صيانة المنازل. قم بتحليل المشكلة التالية وقدم تشخيصاً دقيقاً:

الوصف: $description

قدم التحليل بصيغة JSON التالية:
{
  "problem": "وصف المشكلة بالتفصيل",
  "suggestedService": "نوع الخدمة المقترحة (سباكة/كهرباء/نجارة/أخرى)",
  "solution": "الحل المقترح",
  "estimatedPrice": رقم تقديري بالريال السعودي,
  "confidence": "عالي/متوسط/منخفض"
}

أجب فقط بـ JSON بدون أي نص إضافي.
''';

    final response = await _dio.post(
      _groqApiUrl,
      data: {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'system',
            'content': 'أنت خبير في صيانة المنازل ومتخصص في تشخيص المشاكل وتقديم الحلول.'
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      },
    );

    if (response.statusCode == 200) {
      final content = response.data['choices'][0]['message']['content'];
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        return AiDiagnosis.fromJson(json.decode(jsonStr));
      }
    }
    
    throw Exception('Failed to analyze: ${response.statusCode}');
  }

  @override
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  }) async {
    final prompt = '''
أنت مساعد ذكي متخصص في خدمات الصيانة المنزلية.
المستخدم يبحث عن خدمة: $serviceType
${problemDescription != null ? 'وصف المشكلة: $problemDescription' : ''}

قدم نصيحة قصيرة (جملتين فقط) للمستخدم حول كيفية اختيار الفني المناسب لهذه الخدمة.
''';

    final response = await _dio.post(
      _groqApiUrl,
      data: {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      },
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'];
    }
    
    throw Exception('API Error');
  }
}
