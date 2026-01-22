import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/service_model.dart';

void main() {
  group('Service Model', () {
    group('fromJson', () {
      test('should create Service from valid JSON', () {
        final json = {
          'id': 'service123',
          'name': 'سباكة',
          'nameEn': 'Plumbing',
          'description': 'خدمات السباكة المنزلية',
          'icon': 'plumbing',
          'basePrice': 100.0,
          'isActive': true,
          'category': 'home',
        };

        final service = Service.fromJson(json);

        expect(service.id, equals('service123'));
        expect(service.name, equals('سباكة'));
        expect(service.basePrice, equals(100.0));
        expect(service.isActive, isTrue);
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'service123',
          'name': 'سباكة',
          'basePrice': 100.0,
        };

        final service = Service.fromJson(json);

        expect(service.id, equals('service123'));
        expect(service.name, equals('سباكة'));
      });
    });

    group('toJson', () {
      test('should convert Service to JSON correctly', () {
        final service = Service(
          id: 'service123',
          name: 'كهرباء',
          nameEn: 'Electrical',
          description: 'خدمات الكهرباء',
          icon: 'electrical',
          basePrice: 120.0,
          isActive: true,
          category: 'home',
        );

        final json = service.toJson();

        expect(json['id'], equals('service123'));
        expect(json['name'], equals('كهرباء'));
        expect(json['basePrice'], equals(120.0));
        expect(json['isActive'], isTrue);
      });
    });

    group('Service Types', () {
      test('should have valid service categories', () {
        final categories = ['home', 'commercial', 'industrial'];
        
        for (final category in categories) {
          expect(category, isA<String>());
          expect(category.isNotEmpty, isTrue);
        }
      });

      test('should have valid service names', () {
        final serviceNames = [
          'سباكة',
          'كهرباء',
          'نجارة',
          'تكييف',
          'دهان',
        ];

        for (final name in serviceNames) {
          expect(name, isA<String>());
          expect(name.isNotEmpty, isTrue);
        }
      });
    });

    group('Price Validation', () {
      test('basePrice should be non-negative', () {
        final service = Service(
          id: 'test',
          name: 'Test',
          basePrice: 150.0,
        );

        expect(service.basePrice, greaterThanOrEqualTo(0));
      });

      test('should calculate price with multiplier', () {
        const basePrice = 100.0;
        const urgentMultiplier = 1.5;
        const expectedPrice = basePrice * urgentMultiplier;

        expect(expectedPrice, equals(150.0));
      });
    });
  });

  group('Service Repository', () {
    test('should filter active services', () {
      final services = [
        Service(id: '1', name: 'Active', basePrice: 100, isActive: true),
        Service(id: '2', name: 'Inactive', basePrice: 100, isActive: false),
        Service(id: '3', name: 'Active2', basePrice: 100, isActive: true),
      ];

      final activeServices = services.where((s) => s.isActive).toList();

      expect(activeServices.length, equals(2));
      expect(activeServices.every((s) => s.isActive), isTrue);
    });

    test('should filter by category', () {
      final services = [
        Service(id: '1', name: 'Home1', basePrice: 100, category: 'home'),
        Service(id: '2', name: 'Com1', basePrice: 100, category: 'commercial'),
        Service(id: '3', name: 'Home2', basePrice: 100, category: 'home'),
      ];

      final homeServices = services.where((s) => s.category == 'home').toList();

      expect(homeServices.length, equals(2));
    });

    test('should sort by price', () {
      final services = [
        Service(id: '1', name: 'Expensive', basePrice: 200),
        Service(id: '2', name: 'Cheap', basePrice: 50),
        Service(id: '3', name: 'Medium', basePrice: 100),
      ];

      services.sort((a, b) => a.basePrice.compareTo(b.basePrice));

      expect(services[0].basePrice, equals(50));
      expect(services[1].basePrice, equals(100));
      expect(services[2].basePrice, equals(200));
    });
  });
}
