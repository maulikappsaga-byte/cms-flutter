import 'api_service.dart';

class ClinicDetailApi {
  Future<Map<String, dynamic>> getClinicDetails({
    required int doctorId,
    required String name,
    required String phone,
    required String date,
  }) async {
    try {
      final response = await ApiService.get('/clinic/details');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching clinic details: $e');
    }
  }
}
