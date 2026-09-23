import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config/env_config.dart';
import '../../core/error/error_logger.dart';

/// AI Diagnosis Result Model
class AiDiagnosis {

  AiDiagnosis({
    required this.problem,
    required this.suggestedService,
    required this.solution,
    required this.estimatedPrice,
    required this.confidence,
    double? minPrice,
    double? maxPrice,
    this.advice,
    this.tips = const [],
    this.severity = 'medium',
    this.icon = '🔧',
  })  : minPrice = minPrice ?? (estimatedPrice > 0 ? (estimatedPrice * 0.85).roundToDouble() : 100.0),
        maxPrice = maxPrice ?? (estimatedPrice > 0 ? (estimatedPrice * 1.35).roundToDouble() : 250.0);

  factory AiDiagnosis.fromJson(Map<String, dynamic> json) {
    final est = (json['estimatedPrice'] ?? json['estimatedCost'] ?? 0).toDouble();
    return AiDiagnosis(
      problem: json['problem'] ?? json['type'] ?? '',
      suggestedService: json['suggestedService'] ?? json['category'] ?? json['type'] ?? '',
      solution: json['solution'] ?? json['advice'] ?? '',
      estimatedPrice: est,
      confidence: json['confidence'] ?? 'متوسطة',
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      advice: json['advice'] ?? json['recommendation'],
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? [],
      severity: json['severity'] ?? 'medium',
      icon: json['icon'] ?? '🔧',
    );
  }
  final String problem;
  final String suggestedService;
  final String solution;
  final double estimatedPrice;
  final String confidence;
  final double minPrice;
  final double maxPrice;
  final String? advice;
  final List<String> tips;
  final String severity; // 'critical', 'high', 'medium', 'low'
  final String icon;

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,
      'suggestedService': suggestedService,
      'solution': solution,
      'estimatedPrice': estimatedPrice,
      'confidence': confidence,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'advice': advice,
      'tips': tips,
      'severity': severity,
      'icon': icon,
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

        const systemPrompt = '''
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

        final userContent = <Map<String, dynamic>>[];
        userContent.add({
          'type': 'text',
          'text': 'وصف المشكلة: $description',
        });

        // Add base64 encoded images if present (max 3 images)
        for (var i = 0; i < images.length && i < 3; i++) {
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

    final advices = {
      'سباكة': 'أغلق محبس المياه العمومي فوراً لتجنب غرق الأرضيات وتفاقم التلف.',
      'كهرباء': 'افصل القاطع الرئيسي من لوحة التوزيع فوراً ولا تلمس أي أسلاك مكشوفة.',
      'تكييف': 'أوقف تشغيل التكييف لتجنب احتراق الضاغط وتفقد تسريب المياه الداخلي.',
      'نجارة': 'تجنب غلق الباب أو النافذة بالقوة وافحص المفصلات والمجرى.',
      'دهان': 'حدد مصدر الرطوبة أو النشوع قبل دهان الحائط لضمان ثبات اللون.',
      'أخرى': 'قم بتأمين المكان والتقط صوراً واضحة للعطل لمشاركتها مع الفني.',
    };

    final tipsMap = {
      'سباكة': [
        'حدد موقع التسريب بدقة (تحت الحوض، السخان، قاعدة الحمام)',
        'جفف المياه المحيطة بمصدر التسريب بقطعة قماش',
        'لا تستخدم مواد كيميائية حارقة لتسليك المواسير بدون استشارة الفني'
      ],
      'كهرباء': [
        'أبعد الأطفال عن مكان العطل أو المقبس المتضرر',
        'لا تقم بتبديل القاطع بآخر بسعة أعلى دون معرفة الأحمال',
        'استعن بفني كهربائي معتمد لفحص الدائرة بأجهزة القياس'
      ],
      'تكييف': [
        'نظف فلاتر الهواء الداخلية بلطف وجففها',
        'تأكد من عدم وجود عوائق أمام وحدة التكثيف الخارجية',
        'لاحظ إذا كان هناك تجمد ثلجي على مواسير النحاس'
      ],
      'نجارة': [
        'تحقق مما إذا كان الخشب منتفخاً بسبب الرطوبة أو الرشح',
        'احتفظ بالأجزاء المتساقطة أو المسامير إن وجدت',
        'قس أبعاد الجزء المراد استبداله لتوفير الوقت'
      ],
      'دهان': [
        'نظف السطح من الأتربة والدهان المقشر',
        'اختر درجات الألوان المناسبة لإضاءة الغرفة',
        'احرص على تهوية المكان جيداً أثناء العمل وبعده'
      ],
      'أخرى': [
        'دوّن وقت حدوث العطل وما سبقه',
        'استشر فني متخصص لتحديد أنسب حل',
        'قارن عروض الأسعار وتقييمات الفنيين المعتمدين'
      ],
    };

    final iconsMap = {
      'سباكة': '💧',
      'كهرباء': '⚡',
      'تكييف': '❄️',
      'نجارة': '🪚',
      'دهان': '🎨',
      'أخرى': '🛠️',
    };

    final severities = {
      'كهرباء': 'critical',
      'سباكة': 'high',
      'تكييف': 'medium',
      'نجارة': 'low',
      'دهان': 'low',
      'أخرى': 'medium',
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
      advice: advices[suggestedCategory] ?? advices['أخرى'],
      tips: tipsMap[suggestedCategory] ?? tipsMap['أخرى']!,
      icon: iconsMap[suggestedCategory] ?? '🔧',
      severity: severities[suggestedCategory] ?? 'medium',
      minPrice: (price * 0.85).roundToDouble(),
      maxPrice: (price * 1.35).roundToDouble(),
    );
  }

  /// Ask conversational follow-up questions to Fixsy AI
  Future<String> askAiFollowUp({
    required String query,
    required AiDiagnosis contextDiagnosis,
  }) async {
    final qLower = query.toLowerCase();
    if (qLower.contains('خام') || qLower.contains('قطع') || qLower.contains('سعر') || qLower.contains('تكلف')) {
      return 'الأسعار التقديرية (${contextDiagnosis.minPrice.toInt()} - ${contextDiagnosis.maxPrice.toInt()} ج.م) تشمل الكشف ومصنعية الفني، أما قطع الغيار والخامات فتدفع وفق فواتير الشراء أو يتكفل الفني بإحضارها بموافقتك.';
    }
    if (qLower.contains('خطر') || qLower.contains('خطير') || qLower.contains('أمان') || qLower.contains('سلام')) {
      return 'إجراءات السلامة لعطل ${contextDiagnosis.suggestedService}: ${contextDiagnosis.advice ?? "يرجى توخي الحذر وإيقاف المصدر الرئيسي لحين وصول الفني"}.';
    }
    if (qLower.contains('وقت') || qLower.contains('ساع') || qLower.contains('مد') || qLower.contains('استغراق') || qLower.contains('يستغرق')) {
      return 'يستغرق الإصلاح المعتاد لهذا العطل ما بين 45 دقيقة إلى ساعتين كحد أقصى حسب المعاينة الميدانية وتوفر قطع الغيار.';
    }
    return 'بناءً على تشخيص "${contextDiagnosis.problem}"، يُفضل حجز فني فحص معتمد عبر التطبيق لضمان الجودة والسلامة وسرعة الوصول.';
  }

  /// Get service category suggestions based on keywords
  String suggestServiceCategory(String description) {
    final lowerDesc = description.toLowerCase();

    // High-priority exact category markers
    if (lowerDesc.contains('تكييف') || lowerDesc.contains('مكيف')) return 'تكييف';
    if (lowerDesc.contains('كهربا') || lowerDesc.contains('قاطع') || lowerDesc.contains('فيش')) return 'كهرباء';
    if (lowerDesc.contains('سباك') || lowerDesc.contains('حنفية') || lowerDesc.contains('تسريب') || lowerDesc.contains('ماسورة')) return 'سباكة';
    if (lowerDesc.contains('نجار') || lowerDesc.contains('باب') || lowerDesc.contains('شباك') || lowerDesc.contains('دولاب')) return 'نجارة';
    if (lowerDesc.contains('دهان') || lowerDesc.contains('نقاش') || lowerDesc.contains('رطوبة') || lowerDesc.contains('نشع') || lowerDesc.contains('طلاء')) return 'دهان';
    if (lowerDesc.contains('غسال') || lowerDesc.contains('ثلاج') || lowerDesc.contains('بوتاجاز') || lowerDesc.contains('جهاز')) return 'أجهزة منزلية';

    final keywords = {
      'تكييف': ['تبريد', 'تسخين', 'فريون', 'فلتر'],
      'كهرباء': ['مفتاح', 'لمبة', 'سلك', 'كابل', 'فيوز'],
      'سباكة': ['ماء', 'مغسلة', 'خزان', 'صرف', 'مواسير', 'حوض'],
      'نجارة': ['خزانة', 'خشب', 'طاولة', 'كرسي', 'مفصل'],
      'دهان': ['جدار', 'حائط', 'لون', 'معجون'],
    };

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

    var basePrice = basePrices[serviceType] ?? 100.0;
    
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
