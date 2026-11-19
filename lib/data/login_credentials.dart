import 'package:shared_preferences/shared_preferences.dart';

class LoginCredentials {
  const LoginCredentials({
    required this.email,
    required this.password,
    required this.remember,
  });

  final String email;
  final String password;
  final bool remember;

  static const _emailKey = 'saved_login_email';
  static const _passwordKey = 'saved_login_password';
  static const _rememberKey = 'saved_login_remember';

  static Future<LoginCredentials> load() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? true;
    return LoginCredentials(
      email: prefs.getString(_emailKey) ?? '',
      password: remember ? (prefs.getString(_passwordKey) ?? '') : '',
      remember: remember,
    );
  }

  static Future<void> save({
    required String email,
    required String password,
    required bool remember,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, remember);
    if (!remember) {
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      return;
    }
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passwordKey, password);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.setBool(_rememberKey, false);
  }
}
