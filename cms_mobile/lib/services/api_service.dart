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
    String queryString = '';
    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
      );
      queryString = uri.query;
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}');
    
    try {
      final response = await http.get(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed request: ${response.statusCode} - ${response.body}');
    }
  }
}
