import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';

/// Manages user authentication (PIN-based)
class AuthProvider extends ChangeNotifier {
  final StorageService _storage;
  UserSettings? _settings;
  bool _isAuthenticated = false;

  AuthProvider(this._storage);

  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstRun => _settings?.isFirstRun ?? true;

  /// Initialize and check if PIN is set
  Future<void> initialize() async {
    _settings = await _storage.getUserSettings();
    notifyListeners();
  }

  /// Hash PIN using SHA256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Set PIN on first run
  Future<bool> setPin(String pin) async {
    if (pin.length < 4) return false;

    final hash = _hashPin(pin);
    _settings = UserSettings(pinHash: hash, isFirstRun: false);

    await _storage.saveUserSettings(_settings!);
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    if (_settings == null) {
      await initialize();
    }

    if (_settings == null) return false;

    final hash = _hashPin(pin);
    if (hash == _settings!.pinHash) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!await verifyPin(oldPin)) return false;
    if (newPin.length < 4) return false;

    final hash = _hashPin(newPin);
    _settings!.pinHash = hash;
    await _storage.saveUserSettings(_settings!);
    notifyListeners();
    return true;
  }

  /// Logout
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
