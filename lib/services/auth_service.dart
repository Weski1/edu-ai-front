import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';

class AuthService {
  /// Logowanie: wysyłamy JSON {email, password}, backend zwraca {"message", "token"}.
  static Future<String?> login(String email, String password) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/auth/login');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) return token;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Rejestracja
  static Future<String?> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    if (res.statusCode == 200) {
      return null;
    } else {
      try {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['detail']?.toString() ?? 'Rejestracja nieudana';
      } catch (_) {
        return 'Rejestracja nieudana';
      }
    }
  }

  /// Zaloguj i zapisz token
  static Future<bool> loginAndSave(String email, String password) async {
    final token = await login(email, password);
    if (token == null || token.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return true;
  }

  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// Sprawdź czy token jest ważny
  static Future<bool> isTokenValid() async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) return false;
    
    try {
      // Dodaj debug info o tokenie
      print('=== TOKEN DEBUG ===');
      print('Token length: ${token.length}');
      print('Token start: ${token.substring(0, 50)}...');
      
      final uri = Uri.parse('${ApiClient.baseUrl}/auth/me');
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Token validation response: ${res.statusCode}');
      if (res.statusCode != 200) {
        print('Token validation error: ${res.body}');
      }
      
      return res.statusCode == 200;
    } catch (e) {
      print('Token validation exception: $e');
      return false;
    }
  }

  /// Sprawdź token i wyloguj jeśli nieważny
  static Future<bool> validateTokenOrLogout() async {
    final isValid = await isTokenValid();
    if (!isValid) {
      await logout();
    }
    return isValid;
  }

  /// Sprawdź czy błąd to wygasły token i wyloguj
  static bool handleTokenError(String error) {
    if (error.toLowerCase().contains('token') || 
        error.toLowerCase().contains('unauthorized') ||
        error.toLowerCase().contains('wygasł')) {
      logout();
      return true;
    }
    return false;
  }

  /// Reset hasła (opcjonalny)
  static Future<String?> requestPasswordReset(String email) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/auth/password-reset/request');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode == 200) return null;
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return data['detail']?.toString() ?? 'Nie udało się wysłać wiadomości.';
    } catch (_) {
      return 'Nie udało się wysłać wiadomości.';
    }
  }
}
