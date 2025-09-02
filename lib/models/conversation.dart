class Conversation {
  final int id;
  final int userId;
  final int teacherId;
  final DateTime createdAt;
  final String? title;
  final String? subject;  // Nowe pole
  final String? topic;    // Nowe pole

  Conversation({
    required this.id,
    required this.userId,
    required this.teacherId,
    required this.createdAt,
    this.title,
    this.subject,
    this.topic,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      title: json['title'] as String?,
      subject: json['subject'] as String?,
      topic: json['topic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'subject': subject,
      'topic': topic,
    };
  }

  // Helper method to get display title
  String get displayTitle {
    if (topic != null && topic!.isNotEmpty) {
      return topic!;
    }
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return 'Rozmowa #$id';
  }
}
