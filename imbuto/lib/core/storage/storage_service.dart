import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage();
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Regular storage
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  static String? getString(String key) {
    return _prefs.getString(key);
  }
  
  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  static Future<void> clear() async {
    await _prefs.clear();
  }
  
  // Secure storage
  static Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  static Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }
}
