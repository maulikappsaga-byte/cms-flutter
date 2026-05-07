import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? lastBookedName;
  static String? lastBookedPhone;
  static String? lastToken;
  static String? lastAppointmentId;

  static const String _keyName = 'last_booked_name';
  static const String _keyPhone = 'last_booked_phone';
  static const String _keyToken = 'last_token';
  static const String _keyAppointmentId = 'last_appointment_id';

  // Initialize session from local storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    lastBookedName = prefs.getString(_keyName);
    lastBookedPhone = prefs.getString(_keyPhone);
    lastToken = prefs.getString(_keyToken);
    lastAppointmentId = prefs.getString(_keyAppointmentId);
  }

  static Future<void> updateSession({
    required String name,
    required String phone,
    String? token,
    String? appointmentId,
  }) async {
    lastBookedName = name;
    lastBookedPhone = phone;
    if (token != null) {
      lastToken = token;
    }
    if (appointmentId != null) {
      lastAppointmentId = appointmentId;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    if (token != null) {
      await prefs.setString(_keyToken, token);
    }
    if (appointmentId != null) {
      await prefs.setString(_keyAppointmentId, appointmentId);
    }
  }

  static Future<void> clear() async {
    lastBookedName = null;
    lastBookedPhone = null;
    lastToken = null;
    lastAppointmentId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyAppointmentId);
  }
}
