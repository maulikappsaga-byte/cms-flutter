import 'api_service.dart';

class AuthApi {
  static Future<dynamic> forgotPassword(String email) async {
    return await ApiService.post('/auth/forgot-password', {
      'email': email,
    });
  }

  static Future<dynamic> resetPassword(String email, String otp, String password, String passwordConfirmation) async {
    return await ApiService.post('/auth/reset-password', {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
