// lib/services/chat_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
    // ignore: avoid_print
    // print('HISTORIA[$conversationId]: $bodyTxt');

    final decoded = jsonDecode(bodyTxt);
    final List list = decoded is List
        ? decoded
        : (decoded is Map && decoded['messages'] is List
            ? decoded['messages'] as List
            : const []);

    return list.map((j) => ChatMessage.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Wysyłka obrazu + opcjonalnego tekstu (multipart/form-data).
  /// Backend zapisze wiadomość USER typu "media" + zwróci odpowiedź AI.
  static Future<ChatMessage> sendImageMessage({
    required int conversationId,
    required File imageFile,
    String? content,
    String? token,
  }) async {
    return sendMultipleImagesMessage(
      conversationId: conversationId,
      imageFiles: [imageFile],
      content: content,
      token: token,
    );
  }

  /// Wysyłka wielu obrazów + opcjonalnego tekstu (multipart/form-data).
  /// Backend zapisuje wszystkie obrazy jako jedną wiadomość MEDIA z wieloma załącznikami.
  static Future<ChatMessage> sendMultipleImagesMessage({
    required int conversationId,
    required List<File> imageFiles,
    String? content,
    String? token,
  }) async {
    if (imageFiles.isEmpty) {
      throw Exception('Brak plików do wysłania');
    }

    // Najpierw spróbujmy z fallbackiem do starej metody dla pojedynczego pliku
    if (imageFiles.length == 1) {
      return await sendImageMessage(
        conversationId: conversationId,
        imageFile: imageFiles[0],
        content: content,
        token: token,
      );
    }

    final uri = Uri.parse('${ApiClient.baseUrl}/chat/send-image');
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['conversation_id'] = conversationId.toString();
    if (content != null && content.trim().isNotEmpty) {
      request.fields['content'] = content.trim();
    }

    // Dodaj wszystkie pliki jako 'files' (zgodnie z nowym backendem)
    // Sprawdźmy różne warianty nazewnictwa pól
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      
      // Określ MIME type na podstawie rozszerzenia
      String mimeType = 'image/jpeg'; // domyślny
      final extension = file.path.toLowerCase();
      if (extension.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (extension.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (extension.endsWith('.gif')) {
        mimeType = 'image/gif';
      }
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          await file.readAsBytes(),
          filename: 'image_$i${_getFileExtension(file.path)}',
          contentType: MediaType.parse(mimeType),
        )
      );
      
      // print('DEBUG: Added file $i: ${file.path}, MIME: $mimeType');
    }

    // print('DEBUG: Sending ${imageFiles.length} files');
    // print('DEBUG: Fields: ${request.fields}');
    // print('DEBUG: Files count: ${request.files.length}');

    final streamed = await request.send();
    final bodyBytes = await streamed.stream.toBytes();
    final bodyTxt = utf8.decode(bodyBytes);

    // print('DEBUG: Status code: ${streamed.statusCode}');
    // print('DEBUG: Response body: $bodyTxt');

    if (streamed.statusCode != 200) {
      throw Exception('Błąd wysyłania obrazów: ${streamed.statusCode} - $bodyTxt');
    }

    return ChatMessage.fromJson(jsonDecode(bodyTxt) as Map<String, dynamic>);
  }

  /// Pomocnicza funkcja do wydobycia rozszerzenia pliku
  static String _getFileExtension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return '.${parts.last.toLowerCase()}';
    }
    return '.jpg'; // domyślne
  }
}
