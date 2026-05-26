import 'api_service.dart';

class QueueApi {
  Future<dynamic> getQueueDetails({int? doctorId, String? appointmentId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (appointmentId != null) {
        queryParams['appointment_id'] = appointmentId;
      }
      if (doctorId != null) {
        queryParams['doctor_id'] = doctorId;
      }

      return await ApiService.get(
        '/queue/live',
        queryParams: queryParams,
      );
    } catch (e) {
      throw Exception('Error fetching queue details: $e');
    }
  }

  Future<dynamic> callNextPatient({required int doctorId}) async {
    try {
      return await ApiService.post(
        '/queue/call-next',
        {"doctor_id": doctorId},
      );
    } catch (e) {
      throw Exception('Error calling next patient: $e');
    }
  }
}
