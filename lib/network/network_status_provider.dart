import 'package:flutter/foundation.dart';

class NetworkStatusProvider extends ChangeNotifier {
  NetworkStatusProvider._();

  static final NetworkStatusProvider instance = NetworkStatusProvider._();
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  void reportNetworkFailure() {
    _updateOffline(true);
  }

  void reportSuccess() {
    _updateOffline(false);
  }

  void _updateOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }
}
