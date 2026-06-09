import 'api_service.dart';

class DoctorDetailApi {
  Future<dynamic> getDoctors() async {
    try {
      return await ApiService.get('/doctors');
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  Future<dynamic> createDoctor(Map<String, dynamic> doctorData) async {
    try {
      return await ApiService.post('/doctors', doctorData);
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  Future<dynamic> getDoctorDetails({int? doctorId}) async {
    try {
      return await ApiService.get('/doctors', queryParams: doctorId != null ? {"doctor_id": doctorId} : null);
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }

  Future<dynamic> getTodaySchedule({required int doctorId}) async {
    try {
      return await ApiService.get('/today-schedule', queryParams: {"doctor_id": doctorId});
    } catch (e) {
      throw Exception('Error fetching today schedule: $e');
    }
  }
}