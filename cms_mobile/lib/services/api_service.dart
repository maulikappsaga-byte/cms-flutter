import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': ApiConstants.apiKey,
      };

  static Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    try {
      final request = http.Request('GET', url)
        ..headers.addAll(_headers);
      
      if (queryParams != null) {
        request.body = jsonEncode(queryParams);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
