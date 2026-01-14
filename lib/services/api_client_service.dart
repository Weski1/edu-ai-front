import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:praca_inzynierska_front/config/api_config.dart';
import 'package:praca_inzynierska_front/services/auth_service.dart';

class ApiClient {
  // Base URL moved to ApiConfig, exposed here for compatibility
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<http.Response> _handleResponse(
    Future<http.Response> request,
  ) async {
    final response = await request;
    if (response.statusCode == 401) {
      AuthService.logoutAndRedirect();
    }
    return response;
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    String? token,
  }) {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
    return _handleResponse(http.get(uri, headers: _headers(token)));
  }

  static Future<http.Response> post(
    String path, {
    Object? body,
    String? token,
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return _handleResponse(
      http.post(uri, headers: _headers(token), body: jsonEncode(body)),
    );
  }

  static Future<http.Response> put(String path, {Object? body, String? token}) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return _handleResponse(
      http.put(uri, headers: _headers(token), body: jsonEncode(body)),
    );
  }

  static Future<http.Response> delete(String path, {String? token}) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return _handleResponse(http.delete(uri, headers: _headers(token)));
  }

  static Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json; charset=utf-8',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}
