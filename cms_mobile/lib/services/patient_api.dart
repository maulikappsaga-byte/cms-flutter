import 'dart:developer';
import 'api_service.dart';

class PatientApi {
  Future<dynamic> checkToken({required String phone}) async {
    try {
      final response = await ApiService.post('/v1/patient/check-token', {
        'phone': phone,
      });
      log("Check Token Response: $response");
      return response;
    } catch (e) {
      log("Check Token Error: $e");
      rethrow;
    }
  }
}
