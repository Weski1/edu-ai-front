import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_stats.dart';
import 'api_client_service.dart';
import 'auth_service.dart';

class QuizApiService {
  static Future<Quiz> generateQuiz(GenerateQuizRequest request) async {
    final token = await AuthService.getSavedToken();
    print('=== QUIZ API DEBUG ===');
    print('Token for generateQuiz: ${token != null ? token.substring(0, 20) + '...' : 'null'}');
    print('Request body: ${request.toJson()}');
    
    final response = await ApiClient.post('/quiz/generate', body: request.toJson(), token: token);
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${utf8.decode(response.bodyBytes)}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception('Failed to generate quiz: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<List<QuizListItem>> getMyQuizzes() async {
    final token = await AuthService.getSavedToken();
    print('=== QUIZ API DEBUG ===');
    print('Token for getMyQuizzes: ${token != null ? token.substring(0, 20) + '...' : 'null'}');
    
    final response = await ApiClient.get('/quiz/my-quizzes', token: token);
    
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response body: ${utf8.decode(response.bodyBytes)}');
    }
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => QuizListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<Quiz> getQuiz(int quizId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/$quizId', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception('Failed to load quiz: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<QuizAttempt> startQuiz(QuizAttemptStart request) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.post('/quiz/start', body: request.toJson(), token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return QuizAttempt.fromJson(jsonData);
    } else {
      throw Exception('Failed to start quiz: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<QuizAttemptResult> submitQuiz(QuizAttemptSubmit request) async {
    final token = await AuthService.getSavedToken();
    print('DEBUG Submit API - Sending timeSpentSeconds: ${request.timeSpentSeconds}');
    print('DEBUG Submit API - Request JSON: ${jsonEncode(request.toJson())}');
    
    final response = await ApiClient.post('/quiz/submit', body: request.toJson(), token: token);
    
    print('DEBUG Submit API - Response status: ${response.statusCode}');
    final responseBody = utf8.decode(response.bodyBytes);
    print('DEBUG Submit API - Response body: $responseBody');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(responseBody);
      final result = QuizAttemptResult.fromJson(jsonData);
      print('DEBUG Submit API - Received timeSpentSeconds: ${result.timeSpentSeconds}');
      return result;
    } else {
      throw Exception('Failed to submit quiz: $responseBody');
    }
  }

  static Future<QuizAttemptResult> getAttemptResult(int attemptId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/attempt/$attemptId', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return QuizAttemptResult.fromJson(jsonData);
    } else {
      throw Exception('Failed to load attempt result: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<DashboardStats> getDashboardStats() async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/dashboard/stats', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return DashboardStats.fromJson(jsonData);
    } else {
      throw Exception('Failed to load dashboard stats: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<List<QuizListItem>> getSubjectQuizzes(String subject) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/subjects/$subject/quizzes', token: token);
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => QuizListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subject quizzes: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<void> deleteQuiz(int quizId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.delete('/quiz/$quizId', token: token);
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete quiz: ${utf8.decode(response.bodyBytes)}');
    }
  }

  // Pomocnicze metody dla UI
  static String getQuestionTypeDisplayName(QuestionType type) {
    return type.displayName;
  }

  static String formatDuration(int seconds) {
    // Naprawka dla nieprawidłowych wartości czasu (np. ujemnych)
    if (seconds < 0) {
      print('Warning: Received negative time value: $seconds seconds. Using absolute value.');
      seconds = seconds.abs();
    }
    
    // Debug info
    print('DEBUG formatDuration: input seconds = $seconds');
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    String formattedTime;
    if (minutes > 0) {
      formattedTime = '${minutes}m ${remainingSeconds}s';
    } else {
      formattedTime = '${remainingSeconds}s';
    }
    
    print('DEBUG formatDuration: output = $formattedTime');
    return formattedTime;
  }

  static String getPerformanceLevel(double percentage) {
    if (percentage >= 90) return 'Doskonały';
    if (percentage >= 80) return 'Bardzo dobry';
    if (percentage >= 70) return 'Dobry';
    if (percentage >= 60) return 'Zadowalający';
    if (percentage >= 50) return 'Przeciętny';
    return 'Słaby';
  }

  static String getPerformanceEmoji(double percentage) {
    if (percentage >= 90) return '🏆';
    if (percentage >= 80) return '🥇';
    if (percentage >= 70) return '🥈';
    if (percentage >= 60) return '🥉';
    if (percentage >= 50) return '👍';
    return '📚';
  }

  // Obsługa upload obrazów dla pytań z grafiką
  static Future<String> uploadQuizImage(String imagePath) async {
    final token = await AuthService.getSavedToken();
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/quiz/upload-image'),
    );
    
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['image_url'] as String;
    } else {
      throw Exception('Failed to upload image: $responseBody');
    }
  }

  static Future<List<String>> uploadMultipleQuizImages(List<String> imagePaths) async {
    final token = await AuthService.getSavedToken();
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/quiz/upload-multiple-images'),
    );
    
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    for (final imagePath in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('files', imagePath));
    }
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return (data['image_urls'] as List).cast<String>();
    } else {
      throw Exception('Failed to upload images: $responseBody');
    }
  }
}
