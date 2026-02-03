import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> searchRoutes({
    required String from,
    required String to,
    required double budget,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': from,
          'to': to,
          'budget': budget,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
