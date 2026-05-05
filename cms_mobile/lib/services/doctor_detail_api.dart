import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorDetailApi {
  Future<dynamic> getDoctorDetails({
    required int doctorId,
    required String name,
    required String phone,
    required String date,
  }) async {
    final url = Uri.parse('http://13.126.47.19:8000/api/doctors');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-KEY': 'hFI1iwfp0CKOXAXfAL4laAw62pcziAG2AkMNH0RcJqjoj7ncFH7P1aDeN14klXrT',
    };
    final body = jsonEncode({
      "doctor_id": doctorId,
      "name": name,
      "phone": phone,
      "date": date,
    });

    try {
      // Using Request to support GET with body as per curl
      final request = http.Request('GET', url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load doctor details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }
}