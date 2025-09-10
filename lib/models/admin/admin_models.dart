class TeacherCreate {
  final String name;
  final String subject;
  final String stylePrompt;
  final String? avatarUrl;
  final String? welcomeMessage;

  TeacherCreate({
    required this.name,
    required this.subject,
    required this.stylePrompt,
    this.avatarUrl,
    this.welcomeMessage,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'subject': subject,
        'style_prompt': stylePrompt,
        'avatar_url': avatarUrl,
        'welcome_message': welcomeMessage,
      };
}

class TeacherUpdate {
  final String? name;
  final String? subject;
  final String? stylePrompt;
  final String? avatarUrl;
  final String? welcomeMessage;

  TeacherUpdate({
    this.name,
    this.subject,
    this.stylePrompt,
    this.avatarUrl,
    this.welcomeMessage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (subject != null) data['subject'] = subject;
    if (stylePrompt != null) data['style_prompt'] = stylePrompt;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (welcomeMessage != null) data['welcome_message'] = welcomeMessage;
    return data;
  }
}

class TeacherResponse {
  final int id;
  final String name;
  final String subject;
  final String stylePrompt;
  final String? avatarUrl;
  final String? welcomeMessage;
  final int conversationsCount;
  final int quizzesCount;

  TeacherResponse({
    required this.id,
    required this.name,
    required this.subject,
    required this.stylePrompt,
    this.avatarUrl,
    this.welcomeMessage,
    required this.conversationsCount,
    required this.quizzesCount,
  });

  factory TeacherResponse.fromJson(Map<String, dynamic> json) => TeacherResponse(
        id: json['id'],
        name: json['name'],
        subject: json['subject'],
        stylePrompt: json['style_prompt'],
        avatarUrl: json['avatar_url'],
        welcomeMessage: json['welcome_message'],
        conversationsCount: json['conversations_count'],
        quizzesCount: json['quizzes_count'],
      );
}

class UserListItem {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isVerified;
  final String? profileImageUrl;
  final int conversationsCount;
  final int quizzesCount;
  final int quizAttemptsCount;
  final DateTime? createdAt;

  UserListItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isVerified,
    this.profileImageUrl,
    required this.conversationsCount,
    required this.quizzesCount,
    required this.quizAttemptsCount,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserListItem.fromJson(Map<String, dynamic> json) => UserListItem(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        role: json['role'],
        isVerified: json['is_verified'],
        profileImageUrl: json['profile_image_url'],
        conversationsCount: json['conversations_count'],
        quizzesCount: json['quizzes_count'],
        quizAttemptsCount: json['quiz_attempts_count'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      );
}

class UserUpdate {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final bool? isVerified;

  UserUpdate({
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.isVerified,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;
    if (role != null) data['role'] = role;
    if (isVerified != null) data['is_verified'] = isVerified;
    return data;
  }
}

class ConversationModerationItem {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final int teacherId;
  final String teacherName;
  final String? title;
  final String? subject;
  final String? topic;
  final DateTime createdAt;
  final int messagesCount;
  final DateTime? lastMessageAt;

  ConversationModerationItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.teacherId,
    required this.teacherName,
    this.title,
    this.subject,
    this.topic,
    required this.createdAt,
    required this.messagesCount,
    this.lastMessageAt,
  });

  factory ConversationModerationItem.fromJson(Map<String, dynamic> json) =>
      ConversationModerationItem(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'],
        userEmail: json['user_email'],
        teacherId: json['teacher_id'],
        teacherName: json['teacher_name'],
        title: json['title'],
        subject: json['subject'],
        topic: json['topic'],
        createdAt: DateTime.parse(json['created_at']),
        messagesCount: json['messages_count'],
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'])
            : null,
      );
}

class MessageModerationItem {
  final int id;
  final String sender;
  final String content;
  final DateTime createdAt;
  final int attachmentsCount;
  final bool hasMedia;

  MessageModerationItem({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
    required this.attachmentsCount,
    required this.hasMedia,
  });

  factory MessageModerationItem.fromJson(Map<String, dynamic> json) =>
      MessageModerationItem(
        id: json['id'],
        sender: json['sender'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
        attachmentsCount: json['attachments_count'],
        hasMedia: json['has_media'],
      );
}

class ConversationModerationDetail {
  final ConversationModerationItem conversation;
  final List<MessageModerationItem> messages;

  ConversationModerationDetail({
    required this.conversation,
    required this.messages,
  });

  factory ConversationModerationDetail.fromJson(Map<String, dynamic> json) =>
      ConversationModerationDetail(
        conversation: ConversationModerationItem.fromJson(json['conversation']),
        messages: (json['messages'] as List)
            .map((msg) => MessageModerationItem.fromJson(msg))
            .toList(),
      );
}

class SystemStats {
  final int totalUsers;
  final int verifiedUsers;
  final int totalTeachers;
  final int totalConversations;
  final int totalMessages;
  final int totalQuizzes;
  final int totalQuizAttempts;
  final int usersRegisteredToday;
  final int conversationsCreatedToday;
  final int quizzesGeneratedToday;

  SystemStats({
    required this.totalUsers,
    required this.verifiedUsers,
    required this.totalTeachers,
    required this.totalConversations,
    required this.totalMessages,
    required this.totalQuizzes,
    required this.totalQuizAttempts,
    required this.usersRegisteredToday,
    required this.conversationsCreatedToday,
    required this.quizzesGeneratedToday,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) => SystemStats(
        totalUsers: json['total_users'],
        verifiedUsers: json['verified_users'],
        totalTeachers: json['total_teachers'],
        totalConversations: json['total_conversations'],
        totalMessages: json['total_messages'],
        totalQuizzes: json['total_quizzes'],
        totalQuizAttempts: json['total_quiz_attempts'],
        usersRegisteredToday: json['users_registered_today'],
        conversationsCreatedToday: json['conversations_created_today'],
        quizzesGeneratedToday: json['quizzes_generated_today'],
      );
}

class UserActivityStats {
  final String date;
  final int newUsers;
  final int activeUsers;
  final int conversationsCreated;
  final int messagesSent;
  final int quizzesGenerated;

  UserActivityStats({
    required this.date,
    required this.newUsers,
    required this.activeUsers,
    required this.conversationsCreated,
    required this.messagesSent,
    required this.quizzesGenerated,
  });

  factory UserActivityStats.fromJson(Map<String, dynamic> json) =>
      UserActivityStats(
        date: json['date'],
        newUsers: json['new_users'],
        activeUsers: json['active_users'],
        conversationsCreated: json['conversations_created'],
        messagesSent: json['messages_sent'],
        quizzesGenerated: json['quizzes_generated'],
      );
}

class PopularTeacher {
  final int id;
  final String name;
  final String subject;
  final int conversationsCount;
  final double avgMessagesPerConversation;

  PopularTeacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.conversationsCount,
    required this.avgMessagesPerConversation,
  });

  factory PopularTeacher.fromJson(Map<String, dynamic> json) => PopularTeacher(
        id: json['id'],
        name: json['name'],
        subject: json['subject'],
        conversationsCount: json['conversations_count'],
        avgMessagesPerConversation: json['avg_messages_per_conversation'].toDouble(),
      );
}

class AdminDashboard {
  final SystemStats systemStats;
  final List<UserActivityStats> recentActivity;
  final List<PopularTeacher> popularTeachers;
  final List<UserListItem> recentUsers;

  AdminDashboard({
    required this.systemStats,
    required this.recentActivity,
    required this.popularTeachers,
    required this.recentUsers,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
        systemStats: SystemStats.fromJson(json['system_stats']),
        recentActivity: (json['recent_activity'] as List)
            .map((activity) => UserActivityStats.fromJson(activity))
            .toList(),
        popularTeachers: (json['popular_teachers'] as List)
            .map((teacher) => PopularTeacher.fromJson(teacher))
            .toList(),
        recentUsers: (json['recent_users'] as List)
            .map((user) => UserListItem.fromJson(user))
            .toList(),
      );
}

// === User Conversations Management ===

class UserConversationItem {
  final int id;
  final int teacherId;
  final String teacherName;
  final String teacherSubject;
  final String? title;
  final String? subject;
  final String? topic;
  final DateTime createdAt;
  final int messagesCount;
  final DateTime? lastMessageAt;

  UserConversationItem({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.teacherSubject,
    this.title,
    this.subject,
    this.topic,
    required this.createdAt,
    required this.messagesCount,
    this.lastMessageAt,
  });

  String get displayTitle {
    if (topic != null && topic!.isNotEmpty) {
      return topic!;
    }
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return 'Rozmowa #$id';
  }

  factory UserConversationItem.fromJson(Map<String, dynamic> json) => UserConversationItem(
        id: json['id'],
        teacherId: json['teacher_id'],
        teacherName: json['teacher_name'],
        teacherSubject: json['subject'] ?? json['teacher_subject'] ?? 'Nieznany przedmiot',
        title: json['title'],
        subject: json['subject'],
        topic: json['topic'],
        createdAt: DateTime.parse(json['created_at']),
        messagesCount: json['messages_count'],
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'])
            : null,
      );
}

class UserMessageItem {
  final int id;
  final String sender;
  final String type;
  final String content;
  final DateTime createdAt;
  final int attachmentsCount;
  final bool hasMedia;

  UserMessageItem({
    required this.id,
    required this.sender,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.attachmentsCount,
    required this.hasMedia,
  });

  bool get isUser => sender == 'user';
  bool get isMedia => type == 'media';

  factory UserMessageItem.fromJson(Map<String, dynamic> json) => UserMessageItem(
        id: json['id'],
        sender: json['sender'],
        type: json['type'] ?? 'text',
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
        attachmentsCount: json['attachments_count'] ?? 0,
        hasMedia: json['has_media'] ?? false,
      );
}

class UserConversationDetail {
  final UserConversationItem conversation;
  final List<UserMessageItem> messages;

  UserConversationDetail({
    required this.conversation,
    required this.messages,
  });

  factory UserConversationDetail.fromJson(Map<String, dynamic> json) => UserConversationDetail(
        conversation: UserConversationItem.fromJson(json['conversation']),
        messages: (json['messages'] as List)
            .map((msg) => UserMessageItem.fromJson(msg))
            .toList(),
      );
}
