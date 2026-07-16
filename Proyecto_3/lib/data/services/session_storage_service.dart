import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:proyecto_3/data/models/user.dart';

class SessionStorageService {
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  final FlutterSecureStorage _storage;

  SessionStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<void> saveSession({
    required String token,
    required User user,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey, value: jsonEncode(user.toJson())),
    ]);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<User?> getUser() async {
    final rawUser = await _storage.read(key: _userKey);
    if (rawUser == null || rawUser.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
