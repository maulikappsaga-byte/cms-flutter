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

  Future<dynamic> getTodayAppointments() async {
    try {
      final response = await ApiService.get('/today-appointments');
      log(response.toString());
      return response;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<dynamic> getAppointmentHistory({
    int page = 1,
    String? dateRange,
    String? status,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (dateRange != null && dateRange.isNotEmpty) {
        queryParams['date_range'] = dateRange;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await ApiService.get('/appointment-history', queryParams: queryParams);
      log(response.toString());
      return response;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
