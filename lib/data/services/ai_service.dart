import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/config/env_config.dart';

/// AI Diagnosis Result Model
class AiDiagnosis {
  final String problem;
  final String suggestedService;
  final String solution;
  final double estimatedPrice;
  final String confidence;

  AiDiagnosis({
    required this.problem,
    required this.suggestedService,
    required this.solution,
    required this.estimatedPrice,
    required this.confidence,
  });

  factory AiDiagnosis.fromJson(Map<String, dynamic> json) {
    return AiDiagnosis(
      problem: json['problem'] ?? '',
      suggestedService: json['suggestedService'] ?? '',
      solution: json['solution'] ?? '',
      estimatedPrice: (json['estimatedPrice'] ?? 0).toDouble(),
      confidence: json['confidence'] ?? 'متوسط',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,
      'suggestedService': suggestedService,
      'solution': solution,
      'estimatedPrice': estimatedPrice,
      'confidence': confidence,
    };
  }
}

/// AI Service for analyzing problems and suggesting solutions
class AiService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  final String _apiKey = EnvConfig.groqApiKey;

  /// Analyze problem from images and description
  Future<AiDiagnosis> analyzeProblem({
    required List<XFile> images,
    required String description,
  }) async {
    try {
      // For now, we'll use text-based analysis since vision models need base64 encoding
      // In production, you'd send images as base64
      
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

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Fast and efficient model
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
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final diagnosisData = jsonDecode(jsonStr);
          return AiDiagnosis.fromJson(diagnosisData);
        }
      }
      
      throw Exception('Failed to analyze problem: ${response.statusCode}');
    } catch (e) {
      // Fallback diagnosis
      return AiDiagnosis(
        problem: 'تعذر التحليل التلقائي. الرجاء اختيار نوع الخدمة يدوياً.',
        suggestedService: 'غير محدد',
        solution: 'يرجى إضافة المزيد من التفاصيل أو الاتصال بالدعم الفني.',
        estimatedPrice: 0,
        confidence: 'منخفض',
      );
    }
  }

  /// Analyze image using vision model (for future enhancement)
  Future<String> analyzeImage(File image) async {
    // TODO: Implement image analysis with vision model
    // This would require converting image to base64 and using a vision model
    return 'تحليل الصورة غير متوفر حالياً';
  }

  /// Get service category suggestions based on keywords
  String suggestServiceCategory(String description) {
    final keywords = {
      'سباكة': ['ماء', 'حنفية', 'مغسلة', 'خزان', 'صرف', 'تسريب', 'مواسير'],
      'كهرباء': ['كهرباء', 'مفتاح', 'لمبة', 'سلك', 'كابل', 'قاطع', 'فيوز', 'كهربائي'],
      'نجارة': ['باب', 'شباك', 'خزانة', 'خشب', 'نجارة', 'طاولة', 'كرسي'],
      'تكييف': ['مكيف', 'تكييف', 'تبريد', 'تسخين', 'هواء'],
      'دهان': ['دهان', 'طلاء', 'جدار', 'حائط', 'لون'],
    };

    final lowerDesc = description.toLowerCase();
    
    for (final entry in keywords.entries) {
      for (final keyword in entry.value) {
        if (lowerDesc.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'أخرى';
  }

  /// Estimate price based on service type and complexity
  double estimatePrice(String serviceType, String description) {
    final basePrices = {
      'سباكة': 150.0,
      'كهرباء': 120.0,
      'نجارة': 200.0,
      'تكييف': 180.0,
      'دهان': 250.0,
      'أخرى': 100.0,
    };

    double basePrice = basePrices[serviceType] ?? 100.0;
    
    // Adjust based on description length (complexity indicator)
    if (description.length > 200) {
      basePrice *= 1.5;
    } else if (description.length > 100) {
      basePrice *= 1.2;
    }
    
    return basePrice;
  }

  /// Get service recommendation for AI modal
  Future<String> getServiceRecommendation({
    required String serviceType,
    String? problemDescription,
  }) async {
    try {
      final prompt = '''
أنت مساعد ذكي متخصص في خدمات الصيانة المنزلية.
المستخدم يبحث عن خدمة: $serviceType
${problemDescription != null ? 'وصف المشكلة: $problemDescription' : ''}

قدم نصيحة قصيرة (جملتين فقط) للمستخدم حول كيفية اختيار الفني المناسب لهذه الخدمة.
''';

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      
      throw Exception('API Error');
    } catch (e) {
      // Fallback recommendations based on service type
      final recommendations = {
        'سباكة': 'اختر فني سباكة لديه خبرة في نوع المشكلة الخاصة بك. تأكد من سؤاله عن الضمان على العمل.',
        'كهرباء': 'الأمان أولاً! اختر فني كهرباء معتمد ولديه تقييمات عالية. لا تحاول إصلاح مشاكل الكهرباء بنفسك.',
        'نجارة': 'ابحث عن نجار متخصص في نوع الأثاث أو التركيب المطلوب. شاهد أعماله السابقة إن أمكن.',
        'تكييف': 'اختر فني تكييف لديه خبرة في ماركة جهازك. الصيانة الدورية توفر عليك الكثير.',
        'دهان': 'النتيجة النهائية تعتمد على جودة التحضير. اختر دهان يهتم بتجهيز الأسطح جيداً.',
      };
      
      return recommendations[serviceType] ?? 
          'اختر فني بتقييم عالٍ وتجارب إيجابية. لا تتردد في السؤال عن تفاصيل العمل والسعر مسبقاً.';
    }
  }
}

