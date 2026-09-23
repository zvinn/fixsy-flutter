import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';
import '../models/address_model.dart';

class AddressService {
  FirebaseFirestore? get _instance {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<AddressModel> _inMemoryAddresses = [
    AddressModel(
      id: 'addr_home',
      label: 'المنزل',
      city: 'القاهرة',
      street: 'شارع النصر، المعادي الجديدة',
      building: '14',
      floor: '3',
      apartment: '6',
      notes: 'بجوار صيدلية العزبي',
      isDefault: true,
      latitude: 29.9702,
      longitude: 31.2825,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AddressModel(
      id: 'addr_work',
      label: 'العمل',
      city: 'الجيزة',
      street: 'طريق مصر إسكندرية الصحراوي، القرية الذكية',
      building: 'B4',
      floor: '2',
      apartment: 'مكتب Fixsy الرئيسي',
      notes: 'الدخول من البوابة رقم 2',
      isDefault: false,
      latitude: 30.0768,
      longitude: 31.0208,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Get addresses for current user
  Stream<List<AddressModel>> getAddressesStream(String userId) {
    final firestore = _instance;
    if (firestore == null) {
      return Stream.value(List<AddressModel>.unmodifiable(_inMemoryAddresses));
    }

    try {
      return firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<List<AddressModel>>((snapshot) {
            if (snapshot.docs.isEmpty) {
              return List<AddressModel>.unmodifiable(_inMemoryAddresses);
            }
            return snapshot.docs.map<AddressModel>((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AddressModel.fromJson(data);
            }).toList();
          })
          .handleError((e) {
            AppLogger.warn('Error reading addresses from firestore, using mock: $e');
            return List<AddressModel>.unmodifiable(_inMemoryAddresses);
          });
    } catch (e) {
      AppLogger.warn('Firestore stream failed: $e');
      return Stream.value(List<AddressModel>.unmodifiable(_inMemoryAddresses));
    }
  }

  /// Add a new address
  Future<AddressModel> addAddress(String userId, AddressModel address) async {
    final newAddress = address.copyWith(
      id: address.id.isEmpty ? 'addr_${DateTime.now().millisecondsSinceEpoch}' : address.id,
      createdAt: DateTime.now(),
    );

    if (newAddress.isDefault) {
      for (var i = 0; i < _inMemoryAddresses.length; i++) {
        _inMemoryAddresses[i] = _inMemoryAddresses[i].copyWith(isDefault: false);
      }
    }

    _inMemoryAddresses.insert(0, newAddress);

    final firestore = _instance;
    if (firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(newAddress.id)
            .set(newAddress.toJson());
      } catch (e) {
        AppLogger.warn('Failed to save address in firestore: $e');
      }
    }

    return newAddress;
  }

  /// Update an existing address
  Future<AddressModel> updateAddress(String userId, AddressModel address) async {
    final idx = _inMemoryAddresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      if (address.isDefault) {
        for (var i = 0; i < _inMemoryAddresses.length; i++) {
          _inMemoryAddresses[i] = _inMemoryAddresses[i].copyWith(isDefault: false);
        }
      }
      _inMemoryAddresses[idx] = address;
    }

    final firestore = _instance;
    if (firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(address.id)
            .update(address.toJson());
      } catch (e) {
        AppLogger.warn('Failed to update address in firestore: $e');
      }
    }

    return address;
  }

  /// Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    _inMemoryAddresses.removeWhere((a) => a.id == addressId);

    final firestore = _instance;
    if (firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(addressId)
            .delete();
      } catch (e) {
        AppLogger.warn('Failed to delete address from firestore: $e');
      }
    }
  }

  /// Set an address as default
  Future<void> setDefaultAddress(String userId, String addressId) async {
    for (var i = 0; i < _inMemoryAddresses.length; i++) {
      _inMemoryAddresses[i] = _inMemoryAddresses[i].copyWith(
        isDefault: _inMemoryAddresses[i].id == addressId,
      );
    }

    final firestore = _instance;
    if (firestore != null) {
      try {
        final collectionRef = firestore.collection('users').doc(userId).collection('addresses');
        final snapshot = await collectionRef.get();
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isDefault': doc.id == addressId});
        }
        await batch.commit();
      } catch (e) {
        AppLogger.warn('Failed to set default address in firestore: $e');
      }
    }
  }
}
