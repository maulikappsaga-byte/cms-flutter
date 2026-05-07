import 'api_service.dart';

class QueueApi {
  Future<dynamic> getQueueDetails({required int doctorId}) async {
    try {
      return await ApiService.get(
        '/queue/live',
        queryParams: {"doctor_id": doctorId},
      );
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }
}
