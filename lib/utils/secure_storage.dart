import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> writeSecureData(
      {required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  static Future<String?> readSecureData({required String key}) async {
    return await storage.read(key: key);
  }

  static Future<void> deleteSecureData({required String key}) async {
    await storage.delete(key: key);
  }
}
