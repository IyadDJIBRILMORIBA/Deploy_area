import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  static Future<void> saveUser(String name, String email) async {
    await _storage.write(key: "user_name", value: name);
    await _storage.write(key: "user_email", value: email);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: "user_name");
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: "user_email");
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}