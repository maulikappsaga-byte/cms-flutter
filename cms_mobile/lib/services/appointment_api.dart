import 'dart:developer';

import 'api_service.dart';

class AppointmentApi {
  Future<dynamic> bookAppointment({
    required int doctorId,
    required String name,
    required String phone,
    required String date,
  }) async {
    try {
      final response = await ApiService.post('/appointments/book', {
        'doctor_id': doctorId,
        'name': name,
        'phone': phone,
        'date': date,
      });
      log(response.toString());
      return response;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
