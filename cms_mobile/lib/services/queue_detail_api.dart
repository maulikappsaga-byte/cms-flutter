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

      final liveResponse = await ApiService.get('/queue/live', queryParams: queryParams);
      final waitingResponse = await ApiService.get('/queue/waiting-list', queryParams: queryParams);

      return {
        'status': true,
        'data': {
          'queue': {
            'current_patient': liveResponse['data']?['queue']?['current_patient'],
            'waiting_list': waitingResponse['data']?['queue']?['waiting_list'] ?? [],
            'total_tokens': liveResponse['data']?['queue']?['total_tokens'],
            'completed_tokens': liveResponse['data']?['queue']?['completed_tokens'],
          }
        }
      };
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
