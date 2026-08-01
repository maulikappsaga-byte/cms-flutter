import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class UserSession {
  static String? lastBookedName;
  static String? lastBookedPhone;
  static String? lastToken;
  static String? lastAppointmentId;
  static String? lastBookingDate;
  static String? clinicName;

  // Authentication session fields
  static bool isLoggedIn = false;
  static String? userRole;
  static String? authToken;

  static const String _keyName = 'last_booked_name';
  static const String _keyPhone = 'last_booked_phone';
  static const String _keyToken = 'last_token';
  static const String _keyAppointmentId = 'last_appointment_id';
  static const String _keyBookingDate = 'last_booking_date';
  static const String _keyApiKey = 'api_key';
  static const String _keyClinicName = 'clinic_name';
  
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyAuthToken = 'auth_token';

  // Initialize session from local storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    lastBookedName = prefs.getString(_keyName);
    lastBookedPhone = prefs.getString(_keyPhone);
    lastToken = prefs.getString(_keyToken);
    lastAppointmentId = prefs.getString(_keyAppointmentId);
    lastBookingDate = prefs.getString(_keyBookingDate);
    clinicName = prefs.getString(_keyClinicName);

    isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    userRole = prefs.getString(_keyUserRole);
    authToken = prefs.getString(_keyAuthToken);

    final storedApiKey = prefs.getString(_keyApiKey);
    if (storedApiKey != null && storedApiKey.isNotEmpty) {
      ApiConstants.apiKey = storedApiKey;
    }
  }

  static Future<void> saveClinicName(String name) async {
    clinicName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClinicName, name);
  }

  static Future<void> saveLoginSession(String token, String role) async {
    isLoggedIn = true;
    authToken = token;
    userRole = role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyAuthToken, token);
    await prefs.setString(_keyUserRole, role);
  }

  static Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, apiKey);
    ApiConstants.apiKey = apiKey;
  }

  static Future<void> updateSession({
    required String name,
    required String phone,
    String? token,
    String? appointmentId,
    String? bookingDate,
  }) async {
    lastBookedName = name;
    lastBookedPhone = phone;
    if (token != null) {
      lastToken = token;
    }
    if (appointmentId != null) {
      lastAppointmentId = appointmentId;
    }
    if (bookingDate != null) {
      lastBookingDate = bookingDate;
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
    if (bookingDate != null) {
      await prefs.setString(_keyBookingDate, bookingDate);
    }
  }

  static Future<void> clearLoginSession() async {
    isLoggedIn = false;
    userRole = null;
    authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyAuthToken);
  }

  static Future<void> clear() async {
    lastBookedName = null;
    lastBookedPhone = null;
    lastToken = null;
    lastAppointmentId = null;
    lastBookingDate = null;
    isLoggedIn = false;
    userRole = null;
    authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyAppointmentId);
    await prefs.remove(_keyBookingDate);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyAuthToken);
  }
}
