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
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception('Failed to generate quiz: ${response.body}');
    }
  }

  static Future<List<QuizListItem>> getMyQuizzes() async {
    final token = await AuthService.getSavedToken();
    print('=== QUIZ API DEBUG ===');
    print('Token for getMyQuizzes: ${token != null ? token.substring(0, 20) + '...' : 'null'}');
    
    final response = await ApiClient.get('/quiz/my-quizzes', token: token);
    
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
    }
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => QuizListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes: ${response.body}');
    }
  }

  static Future<Quiz> getQuiz(int quizId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/$quizId', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception('Failed to load quiz: ${response.body}');
    }
  }

  static Future<QuizAttempt> startQuiz(QuizAttemptStart request) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.post('/quiz/start', body: request.toJson(), token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return QuizAttempt.fromJson(jsonData);
    } else {
      throw Exception('Failed to start quiz: ${response.body}');
    }
  }

  static Future<QuizAttemptResult> submitQuiz(QuizAttemptSubmit request) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.post('/quiz/submit', body: request.toJson(), token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return QuizAttemptResult.fromJson(jsonData);
    } else {
      throw Exception('Failed to submit quiz: ${response.body}');
    }
  }

  static Future<QuizAttemptResult> getAttemptResult(int attemptId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/attempt/$attemptId', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return QuizAttemptResult.fromJson(jsonData);
    } else {
      throw Exception('Failed to load attempt result: ${response.body}');
    }
  }

  static Future<DashboardStats> getDashboardStats() async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/dashboard/stats', token: token);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return DashboardStats.fromJson(jsonData);
    } else {
      throw Exception('Failed to load dashboard stats: ${response.body}');
    }
  }

  static Future<List<QuizListItem>> getSubjectQuizzes(String subject) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.get('/quiz/subjects/$subject/quizzes', token: token);
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => QuizListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subject quizzes: ${response.body}');
    }
  }

  static Future<void> deleteQuiz(int quizId) async {
    final token = await AuthService.getSavedToken();
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/quiz/$quizId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete quiz: ${response.body}');
    }
  }

  // Pomocnicze metody dla UI
  static String getQuestionTypeDisplayName(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Wielokrotny wybór';
      case QuestionType.trueFalse:
        return 'Prawda/Fałsz';
      case QuestionType.fillInTheBlank:
        return 'Uzupełnij luki';
      case QuestionType.shortAnswer:
        return 'Krótka odpowiedź';
      case QuestionType.calculation:
        return 'Obliczenia';
      case QuestionType.matching:
        return 'Dopasuj pary';
      case QuestionType.ordering:
        return 'Uporządkuj';
    }
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
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
}
