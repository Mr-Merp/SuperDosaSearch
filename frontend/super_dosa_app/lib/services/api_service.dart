import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/route_models.dart';
import 'api_config.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 120);
  static const Duration healthCheckTimeout = Duration(seconds: 5);

  static Future<bool> checkBackendReachable() async {
    final baseUrl = apiBaseUrl;
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(healthCheckTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<TripOption>> searchRoutes({
    required String from,
    required String to,
    double? budget,
    String? preference,
    bool includeRidehailAirportLeg = false,
  }) async {
    final baseUrl = apiBaseUrl;
    try {
      final body = <String, dynamic>{
        'from_address': from,
        'to_address': to,
      };
      if (budget != null) {
        body['budget'] = budget;
      }
      if (preference != null && preference.isNotEmpty) {
        body['preference'] = preference;
      }
      if (includeRidehailAirportLeg) {
        body['include_ridehail_airport_leg'] = true;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/routes/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout, onTimeout: () {
            throw Exception(
                'Request timed out after ${timeout.inSeconds}s. Backend may be slow. Try Retry or check backend terminal.');
          });

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => TripOption.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        String body = response.body;
        if (body.length > 200) body = '${body.substring(0, 200)}...';
        throw Exception(
            'Server error ${response.statusCode}. $body');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('timed out') ||
          msg.contains('Connection refused') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Operation not permitted') ||
          msg.contains('SocketException') ||
          msg.contains('Connection closed')) {
        throw Exception(
            'Cannot reach backend at $baseUrl. ($msg) Start backend: cd backend/server && uvicorn main:app --reload --host 0.0.0.0 --port 5001');
      }
      throw Exception('Error: $msg');
    }
  }
}
