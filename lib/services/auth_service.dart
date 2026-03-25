import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'mm_users';
  static const String _currentUserKey = 'mm_current_user';
  static const _uuid = Uuid();

  /// Register a new user. Throws if email already in use.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    final List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List)
        : [];

    final exists = users.any(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    // Store user with password hash (plain for mock)
    final userRecord = {...user.toJson(), 'password': password};
    users.add(userRecord);
    await prefs.setString(_usersKey, jsonEncode(users));

    // Persist current session
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return user;
  }

  /// Login with email and password. Throws on invalid credentials.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    final List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List)
        : [];

    final userRecord = users.firstWhere(
      (u) =>
          (u['email'] as String).toLowerCase() == email.toLowerCase() &&
          u['password'] == password,
      orElse: () => {},
    );

    if (userRecord.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    final user = UserModel.fromJson(userRecord);
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return user;
  }

  /// Logout current user.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Returns the currently logged-in user, or null.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_currentUserKey);
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a user session exists.
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Simulates sending a password-reset email.
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    final List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List)
        : [];

    final exists = users.any(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
    );
    // In a real app we'd send an email. Here we silently succeed or fail.
    if (!exists) {
      throw Exception('No account found with this email address.');
    }
    // Mock: do nothing else.
  }
}
