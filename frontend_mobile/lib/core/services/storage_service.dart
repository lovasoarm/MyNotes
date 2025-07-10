import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _preferences!.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _preferences!.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _preferences!.remove(_tokenKey);
  }

  // User data management
  Future<void> saveUserData({required String userId, required String email}) async {
    await _preferences!.setString(_userIdKey, userId);
    await _preferences!.setString(_userEmailKey, email);
  }

  Future<String?> getUserId() async {
    return _preferences!.getString(_userIdKey);
  }

  Future<String?> getUserEmail() async {
    return _preferences!.getString(_userEmailKey);
  }

  Future<void> clearUserData() async {
    await _preferences!.remove(_userIdKey);
    await _preferences!.remove(_userEmailKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await removeToken();
    await clearUserData();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }
}
