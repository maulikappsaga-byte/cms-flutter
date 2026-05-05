import 'api_service.dart';

class DoctorDetailApi {
  Future<dynamic> getDoctorDetails({
    required int doctorId,
    required String name,
    required String phone,
    required String date,
  }) async {
    try {
      return await ApiService.get('/doctors', queryParams: {
        "doctor_id": doctorId,
        "name": name,
        "phone": phone,
        "date": date,
      });
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }
}