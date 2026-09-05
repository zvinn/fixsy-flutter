import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/env_config.dart';
import '../../../domain/entities/ai_diagnosis.dart';

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
Analyze problem:
Description: 

Respond with JSON only:
{
  "problem": "Problem name",
  "suggestedService": "Service type",
  "solution": "Solution steps",
  "estimatedPrice": 150.0,
  "confidence": "high"
}
''';

    final response = await _dio.post(
      _groqApiUrl,
      data: {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a home maintenance expert assistant.'
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
    
    throw Exception('Failed to analyze: ');
  }

  @override
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  }) async {
    final prompt = '''
Recommend quick safety advice for .

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
