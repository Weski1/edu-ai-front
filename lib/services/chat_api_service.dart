import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // jeśli testujesz na Android emulatorze → "http://10.0.2.2:8000" //http://localhost:8000

  static Future<String> sendMessage(String message) async {
    final url = Uri.parse('$baseUrl/chat/message');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      print('[BACKEND] ❌ ${response.statusCode}');
      print('[BACKEND] 🔍 ${response.body}');
      return '⚠️ Wystąpił błąd po stronie serwera.';
    }
  }
}
