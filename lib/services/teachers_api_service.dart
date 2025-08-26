import 'dart:convert';
import 'package:praca_inzynierska_front/models/teacher.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';

class TeachersApiService {
  static Future<({List<Teacher> items, int total, int? nextOffset})> fetch({
    int limit = 20,
    int offset = 0,
    String? q,
    String? token,
  }) async {
    final res = await ApiClient.get(
      '/teachers',
      query: {
        'limit': '$limit',
        'offset': '$offset',
        if (q != null && q.isNotEmpty) 'q': q,
      },
      token: token,
    );

    if (res.statusCode != 200) {
      final bodyTxt = utf8.decode(res.bodyBytes);
      throw Exception('Błąd pobierania nauczycieli: ${res.statusCode} $bodyTxt');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
        .toList();

    return (
      items: items,
      total: (data['total'] as num).toInt(),
      nextOffset: (data['next_offset'] as num?)?.toInt()
    );
  }
}
