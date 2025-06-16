import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SharedPref {
  static const String _keyToken    = 'key_token';
  static const String _keyUser     = 'key_user';
  static const String _keyRemember = 'key_remember'; // opsional, untuk fitur "remember me"

  SharedPref._privateConstructor();
  static final SharedPref instance = SharedPref._privateConstructor();

  /// 1. Simpan token setelah login/register
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// 2. Ambil token (jika ada), atau return null
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 3. Hapus token (misalnya saat logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// 4. Simpan data UserModel (serialize ke JSON string)
  Future<void> setUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_keyUser, userJson);
  }

  /// 5. Ambil data UserModel (jika ada), atau return null
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUser);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(jsonString);
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  /// 6. Hapus data user (misalnya saat logout)
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  /// 7. (Opsional) Fitur "Remember Me" untuk login
  ///    Simpan flag boolean agar user tetap dianggap login
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemember, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemember) ?? false;
  }

  Future<void> removeRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemember);
  }
}
