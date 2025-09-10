import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_client_service.dart';
import '../../services/auth_service.dart';
import '../../models/admin/admin_models.dart';

class AdminApiService {
  static String get _baseUrl => ApiClient.baseUrl;

  // === Dashboard ===

  static Future<AdminDashboard> getDashboard() async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return AdminDashboard.fromJson(data);
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }

  // === Teacher Management ===

  static Future<TeacherResponse> createTeacher(TeacherCreate teacherData) async {
    final token = await AuthService.getSavedToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/teachers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(teacherData.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return TeacherResponse.fromJson(data);
    } else if (response.statusCode == 400) {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? 'Failed to create teacher');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to create teacher: ${response.body}');
    }
  }

  static Future<List<TeacherResponse>> getAllTeachers() async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/teachers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((teacher) => TeacherResponse.fromJson(teacher)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load teachers: ${response.body}');
    }
  }

  static Future<TeacherResponse> getTeacher(int teacherId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/teachers/$teacherId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return TeacherResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Teacher not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load teacher: ${response.body}');
    }
  }

  static Future<TeacherResponse> updateTeacher(int teacherId, TeacherUpdate updateData) async {
    final token = await AuthService.getSavedToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/admin/teachers/$teacherId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return TeacherResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Teacher not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to update teacher: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteTeacher(int teacherId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/teachers/$teacherId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 400) {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? 'Cannot delete teacher');
    } else if (response.statusCode == 404) {
      throw Exception('Teacher not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to delete teacher: ${response.body}');
    }
  }

  // === User Management ===

  static Future<List<UserListItem>> getAllUsers({int skip = 0, int limit = 100}) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/users?skip=$skip&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((user) => UserListItem.fromJson(user)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  static Future<UserListItem> updateUser(int userId, UserUpdate updateData) async {
    final token = await AuthService.getSavedToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/admin/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return UserListItem.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  /// Usuń użytkownika
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 400) {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? 'Cannot delete user');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // === Conversation Moderation ===

  static Future<List<ConversationModerationItem>> getAllConversations({
    int skip = 0, 
    int limit = 100
  }) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/conversations?skip=$skip&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((conv) => ConversationModerationItem.fromJson(conv)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load conversations: ${response.body}');
    }
  }

  static Future<ConversationModerationDetail> getConversationDetails(int conversationId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/conversations/$conversationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ConversationModerationDetail.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Conversation not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load conversation details: ${response.body}');
    }
  }

  // === User Conversations Management ===

  /// Pobierz wszystkie konwersacje konkretnego użytkownika
  static Future<List<UserConversationItem>> getUserConversations(int userId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/users/$userId/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      
      // Map ConversationModerationItem to UserConversationItem 
      return data.map((conv) {
        // Create a new map with correct field mapping for UserConversationItem
        final mappedConv = Map<String, dynamic>.from(conv);
        
        // Map backend fields to expected frontend fields
        if (mappedConv['subject'] != null && mappedConv['teacher_subject'] == null) {
          mappedConv['teacher_subject'] = mappedConv['subject'];
        }
        
        return UserConversationItem.fromJson(mappedConv);
      }).toList();
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load user conversations: ${response.body}');
    }
  }

  /// Pobierz szczegóły konwersacji użytkownika wraz z wiadomościami
  static Future<UserConversationDetail> getUserConversationDetail(int userId, int conversationId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/conversations/$conversationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      
      // Map ConversationModerationDetail to UserConversationDetail
      final conversation = data['conversation'];
      final messages = data['messages'] as List;
      
      // Create mapped conversation data
      final mappedConv = Map<String, dynamic>.from(conversation);
      if (mappedConv['subject'] != null && mappedConv['teacher_subject'] == null) {
        mappedConv['teacher_subject'] = mappedConv['subject'];
      }
      
      // Map messages to UserMessageItem format
      final mappedMessages = messages.map((msg) {
        final mappedMsg = Map<String, dynamic>.from(msg);
        // Map sender field if needed
        if (mappedMsg['type'] == null) {
          mappedMsg['type'] = 'text';
        }
        return mappedMsg;
      }).toList();
      
      return UserConversationDetail.fromJson({
        'conversation': mappedConv,
        'messages': mappedMessages,
      });
    } else if (response.statusCode == 404) {
      throw Exception('Conversation not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to load conversation details: ${response.body}');
    }
  }

  /// Usuń konkretną wiadomość z konwersacji
  static Future<void> deleteMessage(int messageId) async {
    final token = await AuthService.getSavedToken();
    // Note: This endpoint might not exist in your backend yet
    // You may need to implement it or use a different approach
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/messages/$messageId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Message not found or endpoint not implemented');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }

  /// Usuń całą konwersację użytkownika
  static Future<void> deleteUserConversation(int userId, int conversationId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/conversations/$conversationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Conversation not found');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      throw Exception('Failed to delete conversation: ${response.body}');
    }
  }

  // Debug method for creating first admin user
  static Future<void> promoteToAdmin(String userEmail) async {
    final token = await AuthService.getSavedToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/promote-to-admin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': userEmail}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to promote user to admin: ${response.body}');
    }
  }
}
