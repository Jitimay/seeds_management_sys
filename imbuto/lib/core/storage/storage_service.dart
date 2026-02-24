import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _box;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  static Future<void> init() async {
    _box = await Hive.openBox('imbuto_storage');
  }
  
  // Secure storage for tokens
  static Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }
  
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }
  
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }
  
  // Regular storage for user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _box.put(AppConstants.userDataKey, userData);
  }
  
  static Map<String, dynamic>? getUserData() {
    return _box.get(AppConstants.userDataKey);
  }
  
  static Future<void> clearUserData() async {
    await _box.delete(AppConstants.userDataKey);
  }
  
  static Future<void> setFirstLaunch(bool isFirst) async {
    await _box.put(AppConstants.isFirstLaunchKey, isFirst);
  }
  
  static bool isFirstLaunch() {
    return _box.get(AppConstants.isFirstLaunchKey, defaultValue: true);
  }
  
  static Future<void> clearAll() async {
    await clearTokens();
    await _box.clear();
  }
}
