import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    // Check initial status
    Connectivity().checkConnectivity().then((result) {
      _updateStatus(result);
    });

    // Listen to changes
    Connectivity().onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  void _updateStatus(ConnectivityResult result) {
    bool newStatus = result != ConnectivityResult.none;
    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      notifyListeners();
    }
  }
}
