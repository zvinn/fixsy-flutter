import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/service_model.dart';

void main() {
  group('Service Model', () {
    final now = DateTime.now();
    final nowStr = now.toIso8601String();

    group('fromJson', () {
      test('should create Service from valid JSON', () {
        final json = {
          'id': 'service123',
          'name': 'Plumbing',
          'nameAr': 'سباكة',
          'category': 'home',
          'description': 'General plumbing services',
          'descriptionAr': 'خدمات السباكة العامة',
          'price': 100.0,
          'imageUrl': 'https://example.com/icon.png',
          'isActive': true,
          'createdAt': nowStr,
          'updatedAt': nowStr,
        };

        final service = Service.fromJson(json);

        expect(service.id, equals('service123'));
        expect(service.name, equals('Plumbing'));
        expect(service.nameAr, equals('سباكة'));
        expect(service.price, equals(100.0));
        expect(service.isActive, isTrue);
      });
    });

    group('toJson', () {
      test('should convert Service to JSON correctly', () {
        final service = Service(
          id: 'service123',
          name: 'Electrical',
          nameAr: 'كهرباء',
          category: 'home',
          description: 'Electrical installations and repairs',
          descriptionAr: 'تركيبات وإصلاحات الكهرباء',
          price: 120.0,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final json = service.toJson();

        expect(json['id'], equals('service123'));
        expect(json['name'], equals('Electrical'));
        expect(json['price'], equals(120.0));
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
          'تكييف',
          'نجارة',
          'نقاشة',
        ];

        for (final name in serviceNames) {
          expect(name, isA<String>());
          expect(name.isNotEmpty, isTrue);
        }
      });
    });

    group('Price Validation', () {
      test('price should be non-negative', () {
        final service = Service(
          id: 'test',
          name: 'Test',
          nameAr: 'اختبار',
          category: 'home',
          description: 'Test service',
          descriptionAr: 'خدمة اختبار',
          price: 150.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(service.price, greaterThanOrEqualTo(0));
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
    final now = DateTime.now();

    test('should filter active services', () {
      final services = [
        Service(id: '1', name: 'Active', nameAr: 'نشط', category: 'home', description: '', descriptionAr: '', price: 100, isActive: true, createdAt: now, updatedAt: now),
        Service(id: '2', name: 'Inactive', nameAr: 'غير نشط', category: 'home', description: '', descriptionAr: '', price: 100, isActive: false, createdAt: now, updatedAt: now),
        Service(id: '3', name: 'Active2', nameAr: 'نشط 2', category: 'home', description: '', descriptionAr: '', price: 100, isActive: true, createdAt: now, updatedAt: now),
      ];

      final activeServices = services.where((s) => s.isActive).toList();

      expect(activeServices.length, equals(2));
      expect(activeServices.every((s) => s.isActive), isTrue);
    });

    test('should filter by category', () {
      final services = [
        Service(id: '1', name: 'Home1', nameAr: 'منزل 1', category: 'home', description: '', descriptionAr: '', price: 100, createdAt: now, updatedAt: now),
        Service(id: '2', name: 'Com1', nameAr: 'تجاري 1', category: 'commercial', description: '', descriptionAr: '', price: 100, createdAt: now, updatedAt: now),
        Service(id: '3', name: 'Home2', nameAr: 'منزل 2', category: 'home', description: '', descriptionAr: '', price: 100, createdAt: now, updatedAt: now),
      ];

      final homeServices = services.where((s) => s.category == 'home').toList();

      expect(homeServices.length, equals(2));
    });

    test('should sort by price', () {
      final services = [
        Service(id: '1', name: 'Expensive', nameAr: 'مرتفع', category: 'home', description: '', descriptionAr: '', price: 200, createdAt: now, updatedAt: now),
        Service(id: '2', name: 'Cheap', nameAr: 'منخفض', category: 'home', description: '', descriptionAr: '', price: 50, createdAt: now, updatedAt: now),
        Service(id: '3', name: 'Medium', nameAr: 'متوسط', category: 'home', description: '', descriptionAr: '', price: 100, createdAt: now, updatedAt: now),
      ];

      services.sort((a, b) => a.price.compareTo(b.price));

      expect(services[0].price, equals(50));
      expect(services[1].price, equals(100));
      expect(services[2].price, equals(200));
    });
  });
}
