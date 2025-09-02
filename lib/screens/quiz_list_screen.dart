import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';
import 'quiz_attempt_screen.dart';
import 'quiz_generation_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<QuizListItem> _quizzes = [];
  bool _isLoading = true;
  String? _error;
  String _selectedSubject = 'Wszystkie';
  final List<String> _subjects = ['Wszystkie', 'Matematyka', 'Historia', 'Angielski', 'Biologia'];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<QuizListItem> quizzes;
      if (_selectedSubject == 'Wszystkie') {
        quizzes = await QuizApiService.getMyQuizzes();
      } else {
        // Mapowanie na nazwy używane przez backend
        String backendSubject = _mapSubjectToBackend(_selectedSubject);
        quizzes = await QuizApiService.getSubjectQuizzes(backendSubject);
      }
      
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _mapSubjectToBackend(String subject) {
    switch (subject) {
      case 'Matematyka':
        return 'Mathematics';
      case 'Historia':
        return 'Historia';
      case 'Angielski':
        return 'English';
      case 'Biologia':
        return 'Biologia';
      default:
        return subject;
    }
  }

  Future<void> _deleteQuiz(int quizId) async {
    try {
      await QuizApiService.deleteQuiz(quizId);
      _loadQuizzes(); // Reload list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz usunięty pomyślnie')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Błąd podczas usuwania: $e';
        if (e.toString().contains('Cannot delete quiz with existing attempts')) {
          errorMessage = 'Nie można usunąć quizu, który ma już rozwiązane próby. Quiz z wynikami nie może być usunięty.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Quizy'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizGenerationScreen(),
                ),
              );
              if (result == true) {
                _loadQuizzes();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtr przedmiotów
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Filtruj po przedmiocie',
                border: OutlineInputBorder(),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
                _loadQuizzes();
              },
            ),
          ),
          // Lista quizów
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuizGenerationScreen(),
            ),
          );
          if (result == true) {
            _loadQuizzes();
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.quiz, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Błąd podczas ładowania quizów',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuizzes,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Brak quizów',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Zacznij konwersację z nauczycielem\ni wygeneruj swój pierwszy quiz!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGenerationScreen(),
                  ),
                );
                if (result == true) {
                  _loadQuizzes();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Stwórz quiz'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildQuizCard(QuizListItem quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showQuizOptions(quiz),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        _showDeleteConfirmation(quiz);
                      }
                    },
                    itemBuilder: (context) => [
                      if (quiz.attemptsCount == 0) // Tylko jeśli brak prób
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Usuń quiz'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(quiz.subject),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quiz.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quiz.difficultyLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quiz.difficultyLevel.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nauczyciel: ${quiz.teacherName}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Pytania: ${quiz.totalQuestions}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prób: ${quiz.attemptsCount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (quiz.bestScore != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: _getScoreColor(quiz.bestScore!),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.bestScore!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(quiz.bestScore!),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizOptions(QuizListItem quiz) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Rozpocznij quiz'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final fullQuiz = await QuizApiService.getQuiz(quiz.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizAttemptScreen(quiz: fullQuiz),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd podczas ładowania quizu: $e')),
                  );
                }
              }
            },
          ),
          if (quiz.bestScore != null)
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Zobacz najlepszy wynik'),
              onTap: () {
                Navigator.pop(context);
                _showBestScoreDetails(quiz);
              },
            ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Szczegóły quiz'),
            onTap: () {
              Navigator.pop(context);
              _showQuizDetails(quiz);
            },
          ),
        ],
      ),
    );
  }

  void _showBestScoreDetails(QuizListItem quiz) {
    if (quiz.bestScore == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Najlepszy wynik - ${quiz.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: _getScoreColor(quiz.bestScore!),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${quiz.bestScore!.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(quiz.bestScore!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Liczba prób: ${quiz.attemptsCount}'),
            Text('Pytania: ${quiz.totalQuestions}'),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(quiz.bestScore!),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final fullQuiz = await QuizApiService.getQuiz(quiz.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizAttemptScreen(quiz: fullQuiz),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd podczas ładowania quizu: $e')),
                  );
                }
              }
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return 'Doskonały wynik! 🎉';
    if (score >= 80) return 'Bardzo dobry wynik! 👏';
    if (score >= 70) return 'Dobry wynik! 👍';
    if (score >= 60) return 'Wynik do poprawy 📚';
    return 'Warto poćwiczyć więcej 💪';
  }

  void _showQuizDetails(QuizListItem quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(quiz.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Przedmiot: ${quiz.subject}'),
            Text('Poziom: ${quiz.difficultyLevel.displayName}'),
            Text('Nauczyciel: ${quiz.teacherName}'),
            Text('Liczba pytań: ${quiz.totalQuestions}'),
            Text('Liczba prób: ${quiz.attemptsCount}'),
            if (quiz.bestScore != null)
              Text('Najlepszy wynik: ${quiz.bestScore!.toStringAsFixed(1)}%'),
            Text('Utworzono: ${_formatDate(quiz.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(QuizListItem quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń quiz'),
        content: Text(
          'Czy na pewno chcesz usunąć quiz "${quiz.title}"?\n'
          'Ta operacja jest nieodwracalna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteQuiz(quiz.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Matematyka':
      case 'Mathematics':
        return Colors.blue;
      case 'Historia':
        return Colors.brown;
      case 'Angielski':
      case 'English':
        return Colors.green;
      case 'Biologia':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
