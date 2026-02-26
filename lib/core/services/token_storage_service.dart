import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const baseUrl = 'http://10.0.2.2:8080';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  static final StreamController<void> _logoutController = StreamController.broadcast(); 

  static Stream<void> get onLogout => _logoutController.stream;

  static void triggerLogout() {
    _logoutController.add(null);
  }
}