import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/services/ai_service.dart';

void main() {
  late AiService aiService;

  setUpAll(() {
    dotenv.loadFromString(envString: 'GROQ_API_KEY=mock_key\nGEMINI_API_KEY=mock_key\n');
  });

  setUp(() {
    aiService = AiService();
  });

  group('AiService', () {
    group('suggestServiceCategory', () {
      test('should suggest سباكة for water-related keywords', () {
        final waterKeywords = [
          'تسريب ماء',
          'مواسير بتنقط',
          'مشكلة في الحنفية',
          'سدد في الصرف',
        ];

        for (final description in waterKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('سباكة'), reason: '$description should suggest سباكة');
        }
      });

      test('should suggest كهرباء for electrical keywords', () {
        final electricalKeywords = [
          'مشكلة في الكهرباء',
          'فيوز ضرب',
          'لمبة مش شغالة',
          'سلك مكشوف',
        ];

        for (final description in electricalKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('كهرباء'), reason: '$description should suggest كهرباء');
        }
      });

      test('should suggest نجارة for wood-related keywords', () {
        final woodKeywords = [
          'باب مكسور',
          'شباك مش بيقفل',
          'خشب مكسور',
          'كرسي مكسور',
        ];

        for (final description in woodKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('نجارة'), reason: '$description should suggest نجارة');
        }
      });

      test('should suggest تكييف for AC keywords', () {
        final acKeywords = [
          'التكييف مش شغال',
          'تبريد المكيف ضعيف',
          'صوت عالي من المكيف',
        ];

        for (final description in acKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('تكييف'), reason: '$description should suggest تكييف');
        }
      });

      test('should suggest دهان for painting keywords', () {
        final paintKeywords = [
          'دهان شقة',
          'طلاء الغرفة',
          'تقشير دهان الحائط',
        ];

        for (final description in paintKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('دهان'), reason: '$description should suggest دهان');
        }
      });

      test('should return أخرى for unrecognized descriptions', () {
        final result = aiService.suggestServiceCategory('كلمات عشوائية ليس لها علاقة');
        expect(result, equals('أخرى'));
      });
    });

    group('estimatePrice', () {
      test('should return base price for short descriptions', () {
        final price = aiService.estimatePrice('سباكة', 'تسريب بسيط');
        expect(price, greaterThan(0));
      });

      test('should increase price for medium and long complexity descriptions', () {
        final simplePrice = aiService.estimatePrice('سباكة', 'تسريب بسيط');
        final complexDesc = 'تسريب مياه كبير جدا في الحمام والمطبخ ومحتاج تكسير وتغيير كل المواسير الداخلية والخارجية والجبس بورد محتاج شغل كتير ومعدات خاصة وتغيير المحابس الرئيسية بالكامل وعمل عوازل جديدة للأرضيات والجدران لحماية المبنى من الرطوبة والتلف المستمر';
        final complexPrice = aiService.estimatePrice('سباكة', complexDesc);

        expect(complexPrice, greaterThan(simplePrice));
      });

      test('should have different base prices for different services', () {
        final plumbingPrice = aiService.estimatePrice('سباكة', 'مشكلة');
        final acPrice = aiService.estimatePrice('تكييف', 'مشكلة');

        expect(acPrice, greaterThanOrEqualTo(plumbingPrice));
      });

      test('should return default price for unknown service', () {
        final price = aiService.estimatePrice('خدمة_غير_معروفة', 'مشكلة');
        expect(price, equals(100.0));
      });
    });

    group('AiDiagnosis', () {
      test('should create AiDiagnosis from JSON', () {
        final json = {
          'problem': 'تسريب مياه في الصرف',
          'suggestedService': 'سباكة',
          'solution': 'إصلاح السيفون وتغيير الجلبة',
          'estimatedPrice': 150.0,
          'confidence': 'عالية',
        };

        final diagnosis = AiDiagnosis.fromJson(json);

        expect(diagnosis.problem, equals('تسريب مياه في الصرف'));
        expect(diagnosis.suggestedService, equals('سباكة'));
        expect(diagnosis.solution, equals('إصلاح السيفون وتغيير الجلبة'));
        expect(diagnosis.estimatedPrice, equals(150.0));
        expect(diagnosis.confidence, equals('عالية'));
      });

      test('should convert AiDiagnosis to JSON', () {
        final diagnosis = AiDiagnosis(
          problem: 'عطل كهربائي',
          suggestedService: 'كهرباء',
          solution: 'تغيير المفتاح الأوتوماتيك',
          estimatedPrice: 120.0,
          confidence: 'متوسطة',
        );

        final json = diagnosis.toJson();

        expect(json['problem'], equals('عطل كهربائي'));
        expect(json['suggestedService'], equals('كهرباء'));
        expect(json['estimatedPrice'], equals(120.0));
      });

      test('should handle missing JSON fields with defaults', () {
        final json = <String, dynamic>{};

        final diagnosis = AiDiagnosis.fromJson(json);

        expect(diagnosis.problem, equals(''));
        expect(diagnosis.suggestedService, equals(''));
        expect(diagnosis.estimatedPrice, equals(0.0));
      });
    });
  });
}
