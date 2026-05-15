import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String name;
  final String email;

  UserModel({required this.name, required this.email});

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(name: json['name'] ?? '', email: json['email'] ?? '');
}

class AuthService {
  static const _prefKeyUsers = 'registered_users';
  static const _prefKeyLoggedIn = 'logged_in_user';

  // Returns null on success, error string on failure
  static Future<String?> register(
      String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_prefKeyUsers) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersRaw);

    if (users.containsKey(email)) {
      return 'Email sudah terdaftar, silakan login.';
    }

    users[email] = {'name': name, 'password': password};
    await prefs.setString(_prefKeyUsers, json.encode(users));
    return null; // success
  }

  // Returns null on success, error string on failure
  static Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_prefKeyUsers) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersRaw);

    if (!users.containsKey(email)) {
      return 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';
    }

    final userData = users[email] as Map<String, dynamic>;
    if (userData['password'] != password) {
      return 'Password salah. Silakan coba lagi.';
    }

    final user = UserModel(name: userData['name'] ?? '', email: email);
    await prefs.setString(_prefKeyLoggedIn, json.encode(user.toJson()));
    return null; // success
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyLoggedIn);
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyLoggedIn);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}