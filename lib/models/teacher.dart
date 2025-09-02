class Teacher {
  final int id;
  final String name;
  final String? subject;
  final String? avatarUrl;

  Teacher({
    required this.id,
    required this.name,
    this.subject,
    this.avatarUrl,
  });

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        id: j['id'] as int? ?? 0,
        name: j['name'] as String? ?? 'Unknown Teacher',
        subject: j['subject'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );
}
