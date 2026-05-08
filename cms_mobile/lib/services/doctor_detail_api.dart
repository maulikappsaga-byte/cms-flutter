import 'api_service.dart';

class DoctorDetailApi {
  Future<dynamic> getDoctors() async {
    try {
      return await ApiService.get('/doctors');
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  Future<dynamic> getDoctorDetails({int? doctorId}) async {
    try {
      return await ApiService.get('/doctors', queryParams: doctorId != null ? {"doctor_id": doctorId} : null);
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }
}