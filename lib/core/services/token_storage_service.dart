import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Create storage instance
  final _storage = const FlutterSecureStorage();

  // Keys to avoid typos
  static const _keyToken = '';

  // Save the token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Read the token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Delete token (useful for logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }
}