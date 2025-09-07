import 'dart:convert';
import '../models/password_reset_request.dart';
import '../services/api_client_service.dart';

class PasswordResetApiService {
  /// Wyślij żądanie resetowania hasła
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final request = PasswordResetRequest(email: email);
    
    print('=== PASSWORD RESET REQUEST DEBUG ===');
    print('Email: $email');
    print('Request URL: ${ApiClient.baseUrl}/auth/password-reset/request');
    print('Request body: ${request.toJson()}');
    
    final res = await ApiClient.post(
      '/auth/password-reset/request',
      body: request.toJson(),
    );

    print('Response status: ${res.statusCode}');
    final bodyTxt = utf8.decode(res.bodyBytes);
    print('Response body: $bodyTxt');

    if (res.statusCode != 200) {
      throw Exception('Błąd żądania resetowania hasła: ${res.statusCode} $bodyTxt');
    }

    return jsonDecode(bodyTxt) as Map<String, dynamic>;
  }
}
