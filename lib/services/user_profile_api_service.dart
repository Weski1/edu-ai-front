import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';
import 'package:praca_inzynierska_front/services/auth_service.dart';
import 'package:praca_inzynierska_front/models/user_profile.dart';

class UserProfileApiService {
  
  /// Pobierz profil aktualnie zalogowanego użytkownika
  static Future<UserProfile> getUserProfile() async {
    final token = await AuthService.getSavedToken();
    if (token == null) throw Exception('Nie jesteś zalogowany');

    final uri = Uri.parse('${ApiClient.baseUrl}/user/profile');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('=== USER PROFILE GET DEBUG ===');
      print('Request URL: $uri');
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(errorData['detail'] ?? 'Błąd podczas pobierania profilu');
        } catch (e) {
          // Jeśli nie można zdekodować odpowiedzi błędu
          throw Exception('Błąd serwera (${response.statusCode}): ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      if (e.toString().contains('Sesja wygasła')) rethrow;
      throw Exception('Błąd połączenia z serwerem: $e');
    }
  }

  /// Aktualizuj profil użytkownika
  static Future<UserProfile> updateUserProfile(ProfileUpdateRequest updateRequest) async {
    final token = await AuthService.getSavedToken();
    if (token == null) throw Exception('Nie jesteś zalogowany');

    final uri = Uri.parse('${ApiClient.baseUrl}/user/profile');
    
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateRequest.toJson()),
      );

      print('=== USER PROFILE UPDATE DEBUG ===');
      print('Request URL: $uri');
      print('Request body: ${jsonEncode(updateRequest.toJson())}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? 'Błąd podczas aktualizacji profilu');
      }
    } catch (e) {
      print('Error in updateUserProfile: $e');
      if (e.toString().contains('Sesja wygasła')) rethrow;
      throw Exception('Błąd połączenia z serwerem: $e');
    }
  }

  /// Upload zdjęcia profilowego
  static Future<String> uploadProfileImage(File imageFile) async {
    final token = await AuthService.getSavedToken();
    if (token == null) throw Exception('Nie jesteś zalogowany');

    final uri = Uri.parse('${ApiClient.baseUrl}/user/profile/image');
    
    try {
      // Sprawdź czy plik istnieje
      if (!await imageFile.exists()) {
        throw Exception('Plik nie istnieje');
      }

      // Sprawdź rozmiar pliku
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Plik jest za duży (max 5MB)');
      }

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Określ MIME type na podstawie rozszerzenia
      String? mimeType;
      final extension = imageFile.path.toLowerCase();
      if (extension.endsWith('.jpg') || extension.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (extension.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (extension.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else {
        throw Exception('Nieobsługiwany format pliku');
      }
      
      // Dodaj plik do żądania z poprawnym MIME type
      final multipartFile = await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      print('=== PROFILE IMAGE UPLOAD DEBUG ===');
      print('Request URL: $uri');
      print('File path: ${imageFile.path}');
      print('File size: ${fileSize} bytes');
      print('MIME type: $mimeType');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data['image_url'] as String;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? 'Błąd podczas uploadu zdjęcia');
      }
    } catch (e) {
      print('Error in uploadProfileImage: $e');
      if (e.toString().contains('Sesja wygasła')) rethrow;
      throw Exception('Błąd podczas uploadu zdjęcia: $e');
    }
  }

  /// Usuń zdjęcie profilowe
  static Future<void> deleteProfileImage() async {
    final token = await AuthService.getSavedToken();
    if (token == null) throw Exception('Nie jesteś zalogowany');

    final uri = Uri.parse('${ApiClient.baseUrl}/user/profile/image');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('=== PROFILE IMAGE DELETE DEBUG ===');
      print('Request URL: $uri');
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return; // Sukces
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? 'Błąd podczas usuwania zdjęcia');
      }
    } catch (e) {
      print('Error in deleteProfileImage: $e');
      if (e.toString().contains('Sesja wygasła')) rethrow;
      throw Exception('Błąd podczas usuwania zdjęcia: $e');
    }
  }

  /// Wyloguj użytkownika (usuwa token z localStorage)
  static Future<void> logoutUser() async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;

    final uri = Uri.parse('${ApiClient.baseUrl}/user/logout');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('=== USER LOGOUT DEBUG ===');
      print('Request URL: $uri');
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      // Niezależnie od odpowiedzi serwera, usuń token lokalnie
      await AuthService.logout();
    } catch (e) {
      print('Error in logoutUser: $e');
      // Niezależnie od błędu, usuń token lokalnie
      await AuthService.logout();
    }
  }
}
