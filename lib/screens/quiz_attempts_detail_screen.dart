import 'package:flutter/material.dart';
import '../models/quiz_attempts.dart';
import '../services/quiz_api_service.dart';
import 'quiz_attempt_review_screen.dart';

class QuizAttemptsDetailScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizAttemptsDetailScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizAttemptsDetailScreen> createState() => _QuizAttemptsDetailScreenState();
}

class _QuizAttemptsDetailScreenState extends State<QuizAttemptsDetailScreen> {
  QuizDetailsResponse? _quizDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final details = await QuizApiService.getQuizDetailsWithAttempts(widget.quizId);
      
      setState(() {
        _quizDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _quizDetails != null
                  ? _buildQuizDetails()
                  : const Center(child: Text('Brak danych')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Błąd podczas ładowania szczegółów quizu',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadQuizDetails,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizDetails() {
    if (_quizDetails!.attempts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Brak podejść do tego quizu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizHeader(),
          const SizedBox(height: 24),
          _buildAttemptsSection(),
        ],
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _quizDetails!.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.book, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  _quizDetails!.subject,
                  style: TextStyle(color: Colors.blue[600]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_quizDetails!.teacherName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.quiz, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${_quizDetails!.totalQuestions} pytań'),
                const SizedBox(width: 16),
                Icon(
                  _getDifficultyIcon(_quizDetails!.difficultyLevel),
                  size: 16,
                  color: _getDifficultyColor(_quizDetails!.difficultyLevel),
                ),
                const SizedBox(width: 4),
                Text(
                  _quizDetails!.difficultyDisplayName,
                  style: TextStyle(
                    color: _getDifficultyColor(_quizDetails!.difficultyLevel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Twoje podejścia (${_quizDetails!.attempts.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._quizDetails!.attempts.asMap().entries.map((entry) {
          final index = entry.key;
          final attempt = entry.value;
          return _buildAttemptCard(attempt, index + 1);
        }),
      ],
    );
  }

  Widget _buildAttemptCard(QuizDetailAttempt attempt, int position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToAttemptReview(attempt),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek podejścia
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      'Podejście $position',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: attempt.percentage >= 50 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: attempt.percentage >= 50 ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                    ),
                    child: Text(
                      '${attempt.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: attempt.percentage >= 50 ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Wynik punktowy
              Text(
                '${attempt.score.toStringAsFixed(1)} punktów',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Status ukończenia
              Row(
                children: [
                  Icon(
                    attempt.isCompleted ? Icons.check_circle : Icons.pending,
                    size: 16,
                    color: attempt.isCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attempt.isCompleted ? 'Ukończone' : 'W trakcie',
                    style: TextStyle(
                      color: attempt.isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Przycisk szczegółów
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToAttemptReview(attempt),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Zobacz odpowiedzi'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.speed;
      case 'medium':
        return Icons.trending_up;
      case 'hard':
        return Icons.trending_up;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAttemptReview(QuizDetailAttempt attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizAttemptReviewScreen(
          quizTitle: _quizDetails!.title,
          attempt: attempt,
        ),
      ),
    );
  }
}
