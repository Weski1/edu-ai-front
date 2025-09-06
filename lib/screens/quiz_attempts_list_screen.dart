import 'package:flutter/material.dart';
import '../models/quiz_attempts.dart';
import '../services/quiz_api_service.dart';
import 'quiz_attempts_detail_screen.dart';

class QuizAttemptsListScreen extends StatefulWidget {
  final bool showAppBar;
  
  const QuizAttemptsListScreen({super.key, this.showAppBar = true});

  @override
  State<QuizAttemptsListScreen> createState() => _QuizAttemptsListScreenState();
}

class _QuizAttemptsListScreenState extends State<QuizAttemptsListScreen> {
  List<QuizAttemptListItem> _attempts = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final attempts = await QuizApiService.getMyAttempts();
      
      setState(() {
        _attempts = attempts;
        _totalCount = attempts.length;
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
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Moje podejścia do quizów'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildAttemptsList(),
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
            'Błąd podczas ładowania podejść',
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
            onPressed: _loadAttempts,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsList() {
    if (_attempts.isEmpty) {
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
              'Brak rozwiązanych quizów',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gdy rozwiążesz pierwszy quiz, pojawi się tutaj',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttempts,
      child: Column(
        children: [
          // Nagłówek z liczbą quizów
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Znaleziono $_totalCount quizów z twoimi podejściami',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          
          // Lista quizów
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _attempts.length,
              itemBuilder: (context, index) {
                final attempt = _attempts[index];
                return _buildAttemptCard(attempt);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptCard(QuizAttemptListItem attempt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToAttemptDetails(attempt),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek z tytułem i najlepszym wynikiem
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attempt.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attempt.subject,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: attempt.bestScore >= 50 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: attempt.bestScore >= 50 ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                    ),
                    child: Text(
                      '${attempt.bestScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: attempt.bestScore >= 50 ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Szczegóły quizu
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    attempt.teacherName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.quiz, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${attempt.totalQuestions} pytań',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _getDifficultyIcon(attempt.difficultyLevel),
                    size: 16,
                    color: _getDifficultyColor(attempt.difficultyLevel),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attempt.difficultyDisplayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getDifficultyColor(attempt.difficultyLevel),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Liczba podejść i data
              Row(
                children: [
                  const Icon(Icons.repeat, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${attempt.attemptsCount} podejś${attempt.attemptsCount == 1 ? 'cie' : attempt.attemptsCount < 5 ? 'cia' : 'ć'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(attempt.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Przycisk "Zobacz szczegóły"
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToAttemptDetails(attempt),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Zobacz wszystkie podejścia'),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _navigateToAttemptDetails(QuizAttemptListItem attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizAttemptsDetailScreen(
          quizId: attempt.id,
          quizTitle: attempt.title,
        ),
      ),
    );
  }
}
