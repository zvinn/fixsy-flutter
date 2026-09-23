import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/address_model.dart';
import '../../data/services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider() {
    loadAddresses('current_user');
  }

  final AddressService _service = AddressService();
  StreamSubscription<List<AddressModel>>? _subscription;

  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  String _currentUserId = 'current_user';

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => _addresses.isNotEmpty ? _addresses.first : throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }

  void loadAddresses(String userId) {
    _currentUserId = userId;
    _isLoading = true;
    _subscription?.cancel();

    _subscription = _service.getAddressesStream(userId).listen((list) {
      _addresses = List.from(list);
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addAddress(AddressModel address) async {
    final created = await _service.addAddress(_currentUserId, address);
    if (created.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.insert(0, created);
    notifyListeners();
  }

  Future<void> updateAddress(AddressModel address) async {
    await _service.updateAddress(_currentUserId, address);
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      if (address.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses[idx] = address;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    await _service.deleteAddress(_currentUserId, addressId);
    _addresses.removeWhere((a) => a.id == addressId);
    notifyListeners();
  }

  Future<void> setDefault(String addressId) async {
    await _service.setDefaultAddress(_currentUserId, addressId);
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == addressId,
      );
    }
    notifyListeners();
  }
}
