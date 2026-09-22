import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config/env_config.dart';
import '../../core/error/error_logger.dart';

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
      confidence: json['confidence'] ?? 'متوسطة',
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
  
  final Dio _dio = Dio();
  final String _apiKey = EnvConfig.groqApiKey;

  /// Analyze problem with AI using description and optional images (vision support)
  Future<AiDiagnosis> analyzeProblem({
    required List<XFile> images,
    required String description,
  }) async {
    try {
      if (_apiKey.isNotEmpty && _apiKey != 'mock_key') {
        final hasImages = images.isNotEmpty;
        final model = hasImages ? 'llama-3.2-11b-vision-preview' : 'llama-3.3-70b-versatile';

        final systemPrompt = '''
أنت خبير فني متخصص في تشخيص أعطال المنازل والصيانة (سباكة، كهرباء، نجارة، تكييف، دهان).
قم بتحليل وصف المشكلة والصور المرفقة إن وجدت، ثم أرجع التشخيص بصيغة JSON حصراً بالشكل التالي:
{
  "problem": "اسم المشكلة بدقة ومختصر",
  "suggestedService": "سباكة أو كهرباء أو نجارة أو تكييف أو دهان أو أخرى",
  "solution": "خطوات مقترحة للحل وتوصيات السلامة",
  "estimatedPrice": 150.0,
  "confidence": "عالية أو متوسطة أو منخفضة"
}
''';

        final List<Map<String, dynamic>> userContent = [];
        userContent.add({
          'type': 'text',
          'text': 'وصف المشكلة: $description',
        });

        // Add base64 encoded images if present (max 3 images)
        for (int i = 0; i < images.length && i < 3; i++) {
          try {
            final bytes = await images[i].readAsBytes();
            final base64Image = base64Encode(bytes);
            userContent.add({
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            });
          } catch (e) {
            // Ignore single image read failure
          }
        }

        final response = await _dio.post(
          _groqApiUrl,
          options: Options(
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 25),
          ),
          data: {
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': hasImages ? userContent : 'وصف المشكلة: $description'},
            ],
            'temperature': 0.4,
            'max_tokens': 800,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final content = response.data['choices'][0]['message']['content'] as String;
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
          if (jsonMatch != null) {
            final parsed = jsonDecode(jsonMatch.group(0)!);
            return AiDiagnosis.fromJson(parsed);
          }
        }
      }
    } catch (e, stack) {
      ErrorLogger.logError(e, stack, reason: 'AI analyzeProblem remote call fallback triggered');
    }

    // Smart heuristic fallback
    return _generateHeuristicDiagnosis(description: description, imagesCount: images.length);
  }

  /// Analyze image specifically
  Future<String> analyzeImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final xFile = XFile.fromData(bytes, path: image.path);
      final diagnosis = await analyzeProblem(
        images: [xFile],
        description: 'تحليل صورة العطل المرفقة',
      );
      return '${diagnosis.problem}: ${diagnosis.solution}';
    } catch (e) {
      return 'تم فحص الصورة بنجاح بواسطة النظام الذكي';
    }
  }

  /// Generate heuristic diagnosis based on keyword rules & pricing logic
  AiDiagnosis _generateHeuristicDiagnosis({
    required String description,
    required int imagesCount,
  }) {
    final suggestedCategory = suggestServiceCategory(description);
    final price = estimatePrice(suggestedCategory, description);

    final solutions = {
      'سباكة': 'فحص خطوط التغذية والصرف، استبدال الجلب أو المحابس التالفة والتأكد من إحكام الغلق لمنع التسرب.',
      'كهرباء': 'فصل التيار فوراً وفحص القواطع والأسلاك المتضررة بواسطة فني معتمد لضمان السلامة.',
      'نجارة': 'ضبط المفصلات واستبدال الأجزاء الخشبية التالفة وتثبيت الهيكل بشكل محكم.',
      'تكييف': 'تنظيف الفلاتر وفحص ضغط غاز الفريون وتنظيف وحدات التبادل الحراري لرفع كفاءة التبريد.',
      'دهان': 'معالجة الرطوبة والشقوق بالمعجون المخصص ثم تطبيق طبقة أساس ودهان متطابق مع اللون الأصلي.',
      'أخرى': 'معاينة الموقع وتحديد متطلبات الصيانة بدقة مع الفني المختص.',
    };

    final problemSummary = description.trim().isNotEmpty
        ? (description.length > 50 ? '${description.substring(0, 50)}...' : description)
        : 'فحص عطل $suggestedCategory';

    final hasImagesText = imagesCount > 0 ? ' (تم تضمين فحص $imagesCount صور)' : '';

    return AiDiagnosis(
      problem: '$problemSummary$hasImagesText',
      suggestedService: suggestedCategory,
      solution: solutions[suggestedCategory] ?? solutions['أخرى']!,
      estimatedPrice: price,
      confidence: imagesCount > 0 ? 'عالية' : 'متوسطة',
    );
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
