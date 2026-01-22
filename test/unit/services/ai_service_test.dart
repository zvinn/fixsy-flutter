import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/services/ai_service.dart';

void main() {
  late AiService aiService;

  setUp(() {
    aiService = AiService();
  });

  group('AiService', () {
    group('suggestServiceCategory', () {
      test('should suggest سباكة for water-related keywords', () {
        final waterKeywords = [
          'تسريب مياه',
          'الحنفية لا تعمل',
          'مشكلة في المغسلة',
          'خزان المياه',
        ];

        for (final description in waterKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('سباكة'), reason: '$description should suggest سباكة');
        }
      });

      test('should suggest كهرباء for electrical keywords', () {
        final electricalKeywords = [
          'مشكلة في الكهرباء',
          'المفتاح لا يعمل',
          'اللمبة لا تضيء',
          'السلك مقطوع',
        ];

        for (final description in electricalKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('كهرباء'), reason: '$description should suggest كهرباء');
        }
      });

      test('should suggest نجارة for wood-related keywords', () {
        final woodKeywords = [
          'الباب لا يغلق',
          'مشكلة في الشباك',
          'الخزانة مكسورة',
        ];

        for (final description in woodKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('نجارة'), reason: '$description should suggest نجارة');
        }
      });

      test('should suggest تكييف for AC keywords', () {
        final acKeywords = [
          'المكيف لا يعمل',
          'مشكلة في التكييف',
          'تبريد ضعيف',
        ];

        for (final description in acKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('تكييف'), reason: '$description should suggest تكييف');
        }
      });

      test('should suggest دهان for painting keywords', () {
        final paintKeywords = [
          'دهان الجدار',
          'طلاء الحائط',
        ];

        for (final description in paintKeywords) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('دهان'), reason: '$description should suggest دهان');
        }
      });

      test('should return أخرى for unrecognized descriptions', () {
        final unknownDescriptions = [
          'مشكلة غريبة',
          'لا أعرف ما المشكلة',
          '',
        ];

        for (final description in unknownDescriptions) {
          final result = aiService.suggestServiceCategory(description);
          expect(result, equals('أخرى'), reason: '$description should suggest أخرى');
        }
      });
    });

    group('estimatePrice', () {
      test('should return base price for short descriptions', () {
        final price = aiService.estimatePrice('سباكة', 'مشكلة بسيطة');
        expect(price, equals(150.0));
      });

      test('should increase price for medium complexity', () {
        final longDescription = 'مشكلة في السباكة تحتاج إلى فحص شامل وإصلاح الأنابيب التالفة والتأكد من عدم وجود تسريبات أخرى في المنزل وتغيير بعض القطع';
        final price = aiService.estimatePrice('سباكة', longDescription);
        expect(price, greaterThan(150.0));
      });

      test('should have different base prices for different services', () {
        final plumbingPrice = aiService.estimatePrice('سباكة', 'test');
        final electricalPrice = aiService.estimatePrice('كهرباء', 'test');
        final carpentryPrice = aiService.estimatePrice('نجارة', 'test');

        expect(plumbingPrice, equals(150.0));
        expect(electricalPrice, equals(120.0));
        expect(carpentryPrice, equals(200.0));
      });

      test('should return default price for unknown service', () {
        final price = aiService.estimatePrice('خدمة غير معروفة', 'test');
        expect(price, equals(100.0));
      });
    });

    group('AiDiagnosis', () {
      test('should create AiDiagnosis from JSON', () {
        final json = {
          'problem': 'تسريب في الأنابيب',
          'suggestedService': 'سباكة',
          'solution': 'تغيير الأنابيب التالفة',
          'estimatedPrice': 200.0,
          'confidence': 'عالي',
        };

        final diagnosis = AiDiagnosis.fromJson(json);

        expect(diagnosis.problem, equals('تسريب في الأنابيب'));
        expect(diagnosis.suggestedService, equals('سباكة'));
        expect(diagnosis.estimatedPrice, equals(200.0));
        expect(diagnosis.confidence, equals('عالي'));
      });

      test('should convert AiDiagnosis to JSON', () {
        final diagnosis = AiDiagnosis(
          problem: 'مشكلة كهربائية',
          suggestedService: 'كهرباء',
          solution: 'فحص الدائرة الكهربائية',
          estimatedPrice: 150.0,
          confidence: 'متوسط',
        );

        final json = diagnosis.toJson();

        expect(json['problem'], equals('مشكلة كهربائية'));
        expect(json['suggestedService'], equals('كهرباء'));
        expect(json['estimatedPrice'], equals(150.0));
      });

      test('should handle missing JSON fields with defaults', () {
        final json = <String, dynamic>{};

        final diagnosis = AiDiagnosis.fromJson(json);

        expect(diagnosis.problem, equals(''));
        expect(diagnosis.suggestedService, equals(''));
        expect(diagnosis.estimatedPrice, equals(0.0));
        expect(diagnosis.confidence, equals('متوسط'));
      });
    });
  });
}
