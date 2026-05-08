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
      // For testing/demonstration purposes, adding a mock fallback for ID: 3
      if (doctorId == 3) {
        return {
          "status": "success",
          "data": {
            "doctors": [
              {
                "id": 3,
                "name": "Dr. Sarah Johnson",
                "qualification": "MD - Cardiology",
                "experience_years": 15,
                "gender": "Female",
                "profile_photo": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=200&h=200&fit=crop",
                "working_hours": {
                  "monday": "10:00 AM - 04:00 PM",
                  "tuesday": "10:00 AM - 04:00 PM",
                  "wednesday": "10:00 AM - 04:00 PM",
                  "thursday": "10:00 AM - 04:00 PM",
                  "friday": "10:00 AM - 04:00 PM",
                  "saturday": "Closed",
                  "sunday": "Closed"
                }
              }
            ]
          }
        };
      }
      return await ApiService.get('/doctors', queryParams: doctorId != null ? {"doctor_id": doctorId} : null);
    } catch (e) {
      throw Exception('Error fetching doctor details: $e');
    }
  }
}