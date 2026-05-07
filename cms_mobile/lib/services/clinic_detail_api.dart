import 'api_service.dart';

class ClinicDetailApi {
  Future<Map<String, dynamic>> getClinicDetails({
    int? doctorId,
    String? name,
    String? phone,
    String? date,
  }) async {
    try {
      // The curl command used --data '' which indicates a POST request
      final response = await ApiService.post('/clinic/details', {});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching clinic details: $e');
    }
  }
}
