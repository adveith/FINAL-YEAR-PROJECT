import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class StorageService {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Tokens ──────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) =>
      _secure.write(key: AppConstants.accessTokenKey, value: token);

  static Future<String?> getToken() =>
      _secure.read(key: AppConstants.accessTokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _secure.write(key: AppConstants.refreshTokenKey, value: token);

  static Future<String?> getRefreshToken() =>
      _secure.read(key: AppConstants.refreshTokenKey);

  static Future<void> clearTokens() async {
    await _secure.delete(key: AppConstants.accessTokenKey);
    await _secure.delete(key: AppConstants.refreshTokenKey);
  }

  // ── User Cache ──────────────────────────────────────────────────────────
  static Future<void> cacheUser(String jsonStr) =>
      _prefs.setString(AppConstants.userKey, jsonStr);

  static String? getCachedUser() => _prefs.getString(AppConstants.userKey);

  static Future<void> clearUser() =>
      _prefs.remove(AppConstants.userKey);

  // ── FCM Token ───────────────────────────────────────────────────────────
  static Future<void> saveFcmToken(String token) =>
      _prefs.setString(AppConstants.fcmTokenKey, token);

  static String? getFcmToken() => _prefs.getString(AppConstants.fcmTokenKey);

  // ── General ─────────────────────────────────────────────────────────────
  static Future<void> clear() async {
    await clearTokens();
    await clearUser();
    await _prefs.clear();
  }

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);
  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  static String? getString(String key) => _prefs.getString(key);
}
