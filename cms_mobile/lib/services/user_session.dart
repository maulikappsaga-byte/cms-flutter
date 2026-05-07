import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? lastBookedName;
  static String? lastBookedPhone;
  static String? lastToken;

  static const String _keyName = 'last_booked_name';
  static const String _keyPhone = 'last_booked_phone';
  static const String _keyToken = 'last_token';

  // Initialize session from local storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    lastBookedName = prefs.getString(_keyName);
    lastBookedPhone = prefs.getString(_keyPhone);
    lastToken = prefs.getString(_keyToken);
  }

  static Future<void> updateSession({
    required String name,
    required String phone,
    String? token,
  }) async {
    lastBookedName = name;
    lastBookedPhone = phone;
    if (token != null) {
      lastToken = token;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    if (token != null) {
      await prefs.setString(_keyToken, token);
    }
  }

  static Future<void> clear() async {
    lastBookedName = null;
    lastBookedPhone = null;
    lastToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyToken);
  }
}
