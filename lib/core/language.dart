import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  AppLanguage(this.code);

  String code;

  bool get english => code == 'en';

  static Future<AppLanguage> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLanguage(prefs.getString('hll_lang') ?? 'my');
  }

  Future<void> use(String value) async {
    if (value == code) {
      return;
    }
    code = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hll_lang', value);
    notifyListeners();
  }
}

String tr(AppLanguage language, String myanmar, String english) {
  return language.english ? english : myanmar;
}
