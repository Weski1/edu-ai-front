import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Android emulator → backend na lokalnej maszynie:
  static const String baseUrl = 'http://10.0.2.2:8000';
  // iOS Simulator: 'http://localhost:8000'

  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    String? token,
  }) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    return http.get(uri, headers: _headers(token));
  }

  static Future<http.Response> post(
    String path, {
    Object? body,
    String? token,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _headers(token), body: jsonEncode(body));
  }

  static Future<http.Response> delete(
    String path, {
    String? token,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: _headers(token));
  }

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
}
