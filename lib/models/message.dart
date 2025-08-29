class ChatAttachment {
  final int id;
  final String url;        // np. /uploads/abc.png (ścieżka względna)
  final String? mimeType;
  final int? sizeBytes;
  final int? width;
  final int? height;

  ChatAttachment({
    required this.id,
    required this.url,
    this.mimeType,
    this.sizeBytes,
    this.width,
    this.height,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> j) => ChatAttachment(
        id: (j['id'] as num).toInt(),
        url: (j['url'] ?? '').toString(),
        mimeType: j['mime_type'] as String?,
        sizeBytes: (j['size_bytes'] as num?)?.toInt(),
        width: (j['width'] as num?)?.toInt(),
        height: (j['height'] as num?)?.toInt(),
      );
}

class ChatMessage {
  final int id;
  final int conversationId;
  final String sender;   // "user" | "teacher_ai"
  final String type;     // "text" | "media"
  final String content;
  final DateTime createdAt;
  final List<ChatAttachment> attachments; // <<— WAŻNE: ChatAttachment

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.attachments,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    DateTime toLocal(dynamic v) {
      final s = v?.toString();
      final dt = s != null ? DateTime.tryParse(s) : null;
      return (dt ?? DateTime.now()).toLocal();
    }

    final raw = j['attachments'];
    final List list = raw is List ? raw : const [];

    return ChatMessage(
      id: (j['id'] as num).toInt(),
      conversationId: (j['conversation_id'] as num).toInt(),
      sender: (j['sender'] ?? '').toString(),
      type: (j['type'] ?? 'text').toString(),
      content: (j['content'] ?? '').toString(),
      createdAt: toLocal(j['created_at']),
      attachments: list
          .map((e) => ChatAttachment.fromJson(e as Map<String, dynamic>))
          .toList(), // <<— daje List<ChatAttachment>
    );
  }

  bool get isUser => sender == 'user';
  bool get isMedia => type == 'media';
}
