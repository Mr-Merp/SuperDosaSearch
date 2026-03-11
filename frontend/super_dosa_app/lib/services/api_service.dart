import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const List<String> baseUrls = [
    'http://localhost:5000',
    'http://127.0.0.1:5000',
  ];


  static Future<List<dynamic>> searchRoutes({
    required String from,
    required String to,
  }) async {
    try {
      Exception? lastError;
      for (final baseUrl in baseUrls) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/routes/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'from_address': from,
              'to_address': to,
            }),
          );

          if (response.statusCode == 200) {
            return jsonDecode(response.body) as List<dynamic>;
          } else {
            lastError = Exception('Failed to load routes');
          }
        } catch (e) {
          lastError = Exception('Error: $e');
        }
      }
      throw lastError ?? Exception('Failed to load routes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
