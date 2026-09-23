import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/address_provider.dart';
import 'package:fixsy_flutter/data/models/address_model.dart';

void main() {
  group('AddressProvider Unit Tests', () {
    late AddressProvider provider;

    setUp(() {
      provider = AddressProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initializes with mock addresses and finds default address', () {
      expect(provider.addresses.isNotEmpty, isTrue);
      expect(provider.defaultAddress, isNotNull);
      expect(provider.defaultAddress!.isDefault, isTrue);
    });

    test('adds a new address to the user profile', () async {
      final initialCount = provider.addresses.length;
      final newAddr = AddressModel(
        id: 'addr_new_test',
        label: 'الشاليه',
        city: 'الساحل الشمالي',
        street: 'قرية مارينا بوابة 5',
        building: 'فيللا 12',
        createdAt: DateTime.now(),
      );

      await provider.addAddress(newAddr);
      expect(provider.addresses.length, initialCount + 1);
      expect(provider.addresses.any((a) => a.label == 'الشاليه'), isTrue);
    });

    test('switches default address flag across items', () async {
      final target = provider.addresses.firstWhere((a) => !a.isDefault);
      await provider.setDefault(target.id);

      expect(provider.defaultAddress?.id, target.id);
      expect(provider.defaultAddress?.isDefault, isTrue);
      // All other addresses should not be default
      for (final a in provider.addresses.where((a) => a.id != target.id)) {
        expect(a.isDefault, isFalse);
      }
    });

    test('updates an existing address in saved list', () async {
      final target = provider.addresses.first;
      final updated = target.copyWith(label: 'المنزل المحدث', street: 'شارع جديد');
      await provider.updateAddress(updated);

      final found = provider.addresses.firstWhere((a) => a.id == target.id);
      expect(found.label, 'المنزل المحدث');
      expect(found.street, 'شارع جديد');
    });

    test('deletes an address from saved list', () async {
      final toDelete = provider.addresses.last;
      final initialCount = provider.addresses.length;

      await provider.deleteAddress(toDelete.id);
      expect(provider.addresses.length, initialCount - 1);
      expect(provider.addresses.any((a) => a.id == toDelete.id), isFalse);
    });
  });
}
