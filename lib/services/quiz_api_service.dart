import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_stats.dart';
import '../models/quiz_attempts.dart';
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

  static Future<QuizAttemptResult?> getLastAttemptResult(int quizId) async {
    // DEPRECATED: This endpoint no longer exists in backend
    // Use getQuizDetailsWithAttempts instead
    try {
      final details = await getQuizDetailsWithAttempts(quizId);
      if (details.attempts.isNotEmpty) {
        // Return the most recent completed attempt
        final recentAttempt = details.attempts.last;
        if (recentAttempt.isCompleted) {
          // Calculate total possible points
          final maxScore = recentAttempt.questions.length * 1.0; // Assuming 1 point per question
          
          // Convert to QuizAttemptResult format
          return QuizAttemptResult(
            id: recentAttempt.id,
            quizId: quizId,
            score: recentAttempt.score,
            maxScore: maxScore,
            percentage: recentAttempt.percentage,
            timeSpentSeconds: 0, // Not available in this model
            correctAnswers: recentAttempt.questions.where((q) => q.userAnswer?.isCorrect == true).length,
            totalQuestions: recentAttempt.questions.length,
            answers: recentAttempt.questions
                .where((q) => q.userAnswer != null)
                .map((q) => QuizAnswer(
                  id: 0, // Not available in this context
                  questionId: 0, // Not available in this model
                  userAnswer: q.userAnswer!.userAnswer,
                  isCorrect: q.userAnswer!.isCorrect,
                  pointsEarned: q.userAnswer!.pointsEarned,
                  answeredAt: DateTime.now(),
                  aiFeedback: null, // Not available in this model
                  aiStrengths: null, // Not available in this model
                  aiImprovements: null, // Not available in this model
                ))
                .toList(),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error in getLastAttemptResult: $e');
      return null;
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

  static Future<Map<String, dynamic>> deleteQuiz(int quizId) async {
    final token = await AuthService.getSavedToken();
    final response = await ApiClient.delete('/quiz/$quizId', token: token);
    
    if (response.statusCode == 200) {
      // Backend zwraca JSON z informacjami o usunięciu
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData;
    } else if (response.statusCode == 204) {
      // No content - zwróć podstawową wiadomość
      return {'message': 'Quiz usunięty pomyślnie'};
    } else {
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

  /// Pobranie szczegółów quizu z ostatnim podejściem
  static Future<QuizReviewData> getQuizDetails(int quizId) async {
    final token = await AuthService.getSavedToken();
    
    print('=== QUIZ DETAILS API DEBUG ===');
    print('Getting quiz and last attempt for quiz ID: $quizId');
    print('Token: ${token != null ? 'Present' : 'null'}');
    
    try {
      // Pobieramy podstawowe informacje o quizie
      final quizResponse = await ApiClient.get('/quiz/$quizId', token: token);
      if (quizResponse.statusCode != 200) {
        throw Exception('Nie udało się pobrać informacji o quizie');
      }
      
      final quiz = Quiz.fromJson(jsonDecode(utf8.decode(quizResponse.bodyBytes)));
      
      // Pobieramy ostatnie podejście
      final attemptResult = await getLastAttemptResult(quizId);
      
      if (attemptResult == null) {
        throw Exception('Brak podejść do tego quizu');
      }
      
      return QuizReviewData(
        quiz: quiz,
        attemptResult: attemptResult,
      );
      
    } catch (e) {
      print('Error getting quiz details: $e');
      throw Exception('Błąd podczas pobierania szczegółów quizu: $e');
    }
  }

  /// Pobranie listy quizów z podejściami użytkownika - używamy istniejącego endpointu
  static Future<List<QuizAttemptListItem>> getMyAttempts({int limit = 20, int offset = 0}) async {
    final token = await AuthService.getSavedToken();
    
    print('=== MY ATTEMPTS API DEBUG ===');
    print('Getting my quiz attempts via /quiz/my-quizzes endpoint');
    print('Token: ${token != null ? 'Present' : 'null'}');
    
    try {
      // Używamy istniejącego endpointu dla moich quizów
      final response = await ApiClient.get('/quiz/my-quizzes', token: token);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final List<QuizListItem> quizzes = jsonList.map((json) => QuizListItem.fromJson(json)).toList();
        
        // Dla każdego quizu sprawdzamy czy ma podejście
        final List<QuizAttemptListItem> attemptsWithResults = [];
        
        for (final quiz in quizzes) {
          try {
            final lastAttempt = await getLastAttemptResult(quiz.id);
            if (lastAttempt != null) {
              attemptsWithResults.add(QuizAttemptListItem(
                id: quiz.id,
                title: quiz.title,
                subject: quiz.subject,
                difficultyLevel: quiz.difficultyLevel.value,
                totalQuestions: quiz.totalQuestions,
                createdAt: quiz.createdAt,
                teacherName: quiz.teacherName,
                bestScore: lastAttempt.score,
                attemptsCount: 1, // Na razie tylko ostatnie podejście
              ));
            }
          } catch (e) {
            // Quiz bez podejść - pomijamy
            print('Quiz ${quiz.id} nie ma podejść: $e');
          }
        }
        
        return attemptsWithResults;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        throw Exception('Błąd podczas pobierania listy podejść');
      }
    } catch (e) {
      print('Error in getMyAttempts: $e');
      throw Exception('Błąd podczas pobierania listy podejść: $e');
    }
  }

  /// Pobranie szczegółów quizu z podejściami - używamy endpointu /quiz/details/{quiz_id}
  static Future<QuizDetailsResponse> getQuizDetailsWithAttempts(int quizId) async {
    final token = await AuthService.getSavedToken();
    
    print('=== QUIZ DETAILS WITH ATTEMPTS API DEBUG ===');
    print('Getting quiz details for quiz ID: $quizId via /quiz/details/$quizId');
    print('Token: ${token != null ? 'Present' : 'null'}');
    
    try {
      // POPRAWIONY URL - używamy /quiz/details zamiast /quizzes/details
      final response = await ApiClient.get('/quiz/details/$quizId', token: token);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return QuizDetailsResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else if (response.statusCode == 404) {
        throw Exception('Quiz nie został znaleziony lub nie ma podejść');
      } else {
        throw Exception('Błąd podczas pobierania szczegółów quizu');
      }
      
    } catch (e) {
      print('Error getting quiz details with attempts: $e');
      if (e.toString().contains('401')) {
        await AuthService.logout();
        throw Exception('Sesja wygasła. Zaloguj się ponownie.');
      } else {
        throw Exception('Błąd podczas pobierania szczegółów quizu: $e');
      }
    }
  }
}
