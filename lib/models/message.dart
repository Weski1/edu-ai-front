class ChatMessage {
  final int id;
  final int conversationId;
  final String sender; // "user" | "teacher_ai"
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? -1;
      return -1;
    }

    DateTime _toDate(dynamic v) {
      if (v is String) {
        // DateTime.parse radzi sobie z ISO z "T" i ze spacją;
        // jak przyjdzie coś nietypowego, niech nie wywala – weź teraz().
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ChatMessage(
      id: _toInt(j['id']),
      conversationId: _toInt(j['conversation_id']),
      sender: (j['sender'] ?? '').toString(),
      content: (j['content'] ?? '').toString(),
      createdAt: _toDate(j['created_at']),
    );
  }
}
