import 'api_service.dart';

class ClinicDetailApi {
  Future<Map<String, dynamic>> getClinicDetails({
    int? doctorId,
    String? name,
    String? phone,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (doctorId != null) queryParams['doctor_id'] = doctorId;
      if (name != null) queryParams['name'] = name;
      if (phone != null) queryParams['phone'] = phone;
      if (date != null) queryParams['date'] = date;

      // Passing query parameters to the GET request
      final response = await ApiService.get('/clinic/details', queryParams: queryParams);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching clinic details: $e');
    }
  }
}
