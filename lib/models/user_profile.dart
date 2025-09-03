class UserProfileStats {
  final String? favoriteTeacher;
  final int favoriteTeacherConversations;
  final int totalQuizAttempts;
  final int totalCompletedQuizzes;
  final String? favoriteSubject;
  final double? favoriteSubjectAvgScore;
  final double? overallAvgScore;

  UserProfileStats({
    this.favoriteTeacher,
    this.favoriteTeacherConversations = 0,
    this.totalQuizAttempts = 0,
    this.totalCompletedQuizzes = 0,
    this.favoriteSubject,
    this.favoriteSubjectAvgScore,
    this.overallAvgScore,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic> json) {
    return UserProfileStats(
      favoriteTeacher: json['favorite_teacher'] as String?,
      favoriteTeacherConversations: json['favorite_teacher_conversations'] as int? ?? 0,
      totalQuizAttempts: json['total_quiz_attempts'] as int? ?? 0,
      totalCompletedQuizzes: json['total_completed_quizzes'] as int? ?? 0,
      favoriteSubject: json['favorite_subject'] as String?,
      favoriteSubjectAvgScore: (json['favorite_subject_avg_score'] as num?)?.toDouble(),
      overallAvgScore: (json['overall_avg_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorite_teacher': favoriteTeacher,
      'favorite_teacher_conversations': favoriteTeacherConversations,
      'total_quiz_attempts': totalQuizAttempts,
      'total_completed_quizzes': totalCompletedQuizzes,
      'favorite_subject': favoriteSubject,
      'favorite_subject_avg_score': favoriteSubjectAvgScore,
      'overall_avg_score': overallAvgScore,
    };
  }
}

class UserProfile {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profileImageUrl;
  final UserProfileStats stats;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profileImageUrl,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      stats: UserProfileStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'profile_image_url': profileImageUrl,
      'stats': stats.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;

  ProfileUpdateRequest({
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    return data;
  }
}
