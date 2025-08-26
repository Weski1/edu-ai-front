import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:praca_inzynierska_front/models/message.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';

class ChatApiService {
  static Future<int> startConversation({
    required int teacherId,
    String? title,
    String? token,
  }) async {
    final res = await ApiClient.post(
      '/chat/start',
      body: {'teacher_id': teacherId, 'title': title},
      token: token,
    );

    if (res.statusCode != 200) {
      final bodyTxt = utf8.decode(res.bodyBytes);
      throw Exception('Nie udało się rozpocząć rozmowy: ${res.statusCode} $bodyTxt');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (data['conversation_id'] as num).toInt();
  }

  static Future<ChatMessage> sendMessage({
    required int conversationId,
    required String content,
    String? token,
  }) async {
    final res = await ApiClient.post(
      '/chat/send',
      body: {'conversation_id': conversationId, 'content': content},
      token: token,
    );

    if (res.statusCode != 200) {
      final bodyTxt = utf8.decode(res.bodyBytes);
      throw Exception('Błąd wysyłania: ${res.statusCode} $bodyTxt');
    }

    final map = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return ChatMessage.fromJson(map);
  }

  static Future<List<ChatMessage>> getMessages({
    required int conversationId,
    String? token,
  }) async {
    final res = await ApiClient.get(
      '/chat/conversations/$conversationId/messages',
      token: token,
    );

    if (res.statusCode != 200) {
      final bodyTxt = utf8.decode(res.bodyBytes);
      throw Exception('Błąd pobierania wiadomości: ${res.statusCode} $bodyTxt');
    }

    final bodyTxt = utf8.decode(res.bodyBytes);
    // debug (zostaw, jeśli chcesz podglądać):
    // ignore: avoid_print
    print('HISTORIA[$conversationId]: $bodyTxt');

    final decoded = jsonDecode(bodyTxt);

    // Obsłuż zarówno czystą listę, jak i {"messages":[...]} (na przyszłość)
    final List list = decoded is List
        ? decoded
        : (decoded is Map && decoded['messages'] is List
            ? decoded['messages'] as List
            : const []);

    return list
        .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Wysyłka obrazu w konwersacji (multipart/form-data).
  /// `content` jest opcjonalny – możesz dołączyć tekst usera razem ze zdjęciem.
  static Future<ChatMessage> sendImageMessage({
    required int conversationId,
    required File imageFile,
    String? content,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/chat/send-image');

    final request = http.MultipartRequest('POST', uri);

    // Authorization nagłówek (Bearer)
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Pola formularza
    request.fields['conversation_id'] = conversationId.toString();
    if (content != null && content.trim().isNotEmpty) {
      request.fields['content'] = content.trim();
    }

    // Plik
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final bodyBytes = await streamed.stream.toBytes();
    final bodyTxt = utf8.decode(bodyBytes);

    if (streamed.statusCode != 200) {
      throw Exception('Błąd wysyłania obrazu: ${streamed.statusCode} $bodyTxt');
    }

    return ChatMessage.fromJson(jsonDecode(bodyTxt) as Map<String, dynamic>);
  }
}
