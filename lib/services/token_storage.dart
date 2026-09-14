import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  TokenStorage(this._prefs);

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<bool> saveToken(String token) async {
    return _prefs.setString(_tokenKey, token);
  }

  Future<bool> clearToken() async {
    return _prefs.remove(_tokenKey);
  }

  UserModel? getUser() {
    final rawUser = _prefs.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) return null;

    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUser(UserModel user) async {
    try {
      final data = {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'governce': user.governce,
        'age': user.age,
      };
      await _prefs.setString(_userKey, jsonEncode(data));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearUser() async {
    return _prefs.remove(_userKey);
  }

  bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
