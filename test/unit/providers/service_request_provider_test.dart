import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fixsy_flutter/presentation/providers/service_request_provider.dart';

void main() {
  late ServiceRequestProvider provider;

  setUpAll(() {
    dotenv.loadFromString(envString: 'GROQ_API_KEY=mock_key\nGEMINI_API_KEY=mock_key\n');
  });

  setUp(() {
    provider = ServiceRequestProvider();
  });

  group('ServiceRequestProvider', () {
    test('initial state is clean and empty', () {
      expect(provider.selectedServiceType, isEmpty);
      expect(provider.description, isEmpty);
      expect(provider.address, isEmpty);
      expect(provider.scheduledDate, isNull);
      expect(provider.images, isEmpty);
      expect(provider.aiDiagnosis, isNull);
      expect(provider.isAnalyzing, isFalse);
      expect(provider.isSubmitting, isFalse);
    });

    test('setters update state and notify listeners', () {
      provider.setServiceType('سباكة');
      expect(provider.selectedServiceType, equals('سباكة'));

      provider.setDescription('تسريب حنفية المطبخ');
      expect(provider.description, equals('تسريب حنفية المطبخ'));

      provider.setAddress('الرياض - حي الياسمين');
      expect(provider.address, equals('الرياض - حي الياسمين'));

      final testDate = DateTime(2026, 10, 15);
      provider.setScheduledDate(testDate);
      expect(provider.scheduledDate, equals(testDate));
    });

    test('image manipulation operations work accurately', () {
      final image1 = XFile('path/to/leak1.jpg');
      final image2 = XFile('path/to/leak2.jpg');

      provider.setImages([image1, image2]);
      expect(provider.images.length, equals(2));

      final image3 = XFile('path/to/leak3.jpg');
      provider.addImage(image3);
      expect(provider.images.length, equals(3));

      provider.removeImage(1);
      expect(provider.images.length, equals(2));
      expect(provider.images.first.path, equals('path/to/leak1.jpg'));
      expect(provider.images.last.path, equals('path/to/leak3.jpg'));

      provider.clearImages();
      expect(provider.images, isEmpty);
    });

    test('analyzeWithAI throws exception if both description and images are empty', () async {
      expect(
        () => provider.analyzeWithAI(),
        throwsA(isA<Exception>()),
      );
    });

    test('analyzeWithAI succeeds with description and auto-suggests service type', () async {
      provider.setDescription('عندي تسريب مياه كبير في مواسير الحمام ومحتاج سباك فورا');
      await provider.analyzeWithAI();

      expect(provider.aiDiagnosis, isNotNull);
      expect(provider.aiDiagnosis!.suggestedService, equals('سباكة'));
      expect(provider.selectedServiceType, equals('سباكة'));
      expect(provider.aiDiagnosis!.estimatedPrice, greaterThan(0));
      expect(provider.isAnalyzing, isFalse);
    });

    test('analyzeWithAI succeeds with image-only input', () async {
      final testImage = XFile('test_resources/broken_pipe.jpg');
      provider.addImage(testImage);

      await provider.analyzeWithAI();

      expect(provider.aiDiagnosis, isNotNull);
      expect(provider.aiDiagnosis!.confidence, equals('عالية'));
      expect(provider.isAnalyzing, isFalse);
    });
  });
}
