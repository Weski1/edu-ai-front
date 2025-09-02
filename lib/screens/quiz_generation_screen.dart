import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/teacher.dart';
import '../models/conversation.dart';
import '../services/quiz_api_service.dart';
import '../services/teachers_api_service.dart';
import '../services/auth_service.dart';
import '../services/chat_api_service.dart';

class QuizGenerationScreen extends StatefulWidget {
  const QuizGenerationScreen({super.key});

  @override
  State<QuizGenerationScreen> createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  List<Teacher> _teachers = [];
  List<Map<String, dynamic>> _conversations = [];
  
  Teacher? _selectedTeacher;
  int? _selectedConversationId;
  int _questionCount = 10;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  List<String> _specificTopics = [];
  final TextEditingController _topicController = TextEditingController();
  
  bool _isLoadingTeachers = true;
  bool _isLoadingConversations = false;
  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoadingTeachers = true;
        _error = null;
      });
      
      final result = await TeachersApiService.fetch();
      
      setState(() {
        _teachers = result.items;
        _isLoadingTeachers = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Błąd podczas ładowania nauczycieli: $e';
        _isLoadingTeachers = false;
      });
    }
  }

  Future<void> _loadConversationsForTeacher(Teacher teacher) async {
    try {
      setState(() {
        _isLoadingConversations = true;
        _selectedConversationId = null;
        _conversations = [];
      });
      
      print('=== DEBUG LOADING CONVERSATIONS ===');
      print('Loading conversations for teacher: ${teacher.name} (ID: ${teacher.id})');
      print('Selected Teacher ID: ${teacher.id}');
      print('Expected teacher_id in results: ${teacher.id}');
      
      final token = await AuthService.getSavedToken();
      print('Token: ${token != null ? token.substring(0, 20) + '...' : 'null'}');
      
      // Najpierw spróbujmy z dedykowanym endpointem
      try {
        final conversations = await ChatApiService.getConversationsByTeacher(
          teacherId: teacher.id,
          token: token,
        );
        
        print('Loaded ${conversations.length} conversations from /chat/conversations');
        print('Conversations raw data: $conversations');
        
        // Debug: sprawdźmy szczegółowo każdą konwersację
        for (int i = 0; i < conversations.length; i++) {
          final conv = conversations[i];
          print('Conversation $i:');
          print('  - ID: ${conv['id']}');
          print('  - teacher_id: ${conv['teacher_id']}');
          print('  - user_id: ${conv['user_id']}');
          print('  - title: ${conv['title']}');
          print('  - created_at: ${conv['created_at']}');
        }
        
        // TYMCZASOWE ROZWIĄZANIE: Filtruj po stronie frontendu
        final filteredConversations = conversations.where((conv) => 
          conv['teacher_id'] == teacher.id
        ).toList();
        
        print('=== AFTER FRONTEND FILTERING ===');
        print('Original conversations count: ${conversations.length}');
        print('Filtered conversations count: ${filteredConversations.length}');
        print('Showing only conversations with teacher_id: ${teacher.id}');
        
        setState(() {
          _conversations = filteredConversations;
          _isLoadingConversations = false;
        });
        return;
      } catch (e) {
        print('Error with /chat/conversations endpoint: $e');
        print('Trying fallback method...');
      }
      
      // Fallback: użyj mock data z istniejącymi ID konwersacji
      print('Using fallback mock conversations');
      
      setState(() {
        _conversations = [
          {
            'id': 1,
            'teacher_id': teacher.id,
            'title': 'Konwersacja z ${teacher.name}',
            'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ];
        _isLoadingConversations = false;
      });
      
    } catch (e) {
      print('=== ERROR LOADING CONVERSATIONS ===');
      print('Error: $e');
      
      // Sprawdź czy to błąd tokenu
      if (AuthService.handleTokenError(e.toString())) {
        setState(() {
          _error = 'Sesja wygasła. Zaloguj się ponownie.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sesja wygasła. Musisz się zalogować ponownie.'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Zamknij',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Błąd podczas ładowania konwersacji: $e';
          _isLoadingConversations = false;
        });
      }
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedTeacher == null || _selectedConversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz nauczyciela i konwersację')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final request = GenerateQuizRequest(
        conversationId: _selectedConversationId!,
        teacherId: _selectedTeacher!.id,
        questionCount: _questionCount,
        difficultyLevel: _selectedDifficulty,
        specificTopics: _specificTopics,
      );

      print('=== DEBUG QUIZ GENERATION ===');
      print('Request: ${request.toJson()}');
      print('ConversationId: ${request.conversationId}');
      print('TeacherId: ${request.teacherId}');
      print('QuestionCount: ${request.questionCount}');
      print('DifficultyLevel: ${request.difficultyLevel}');
      print('SpecificTopics: ${request.specificTopics}');

      final quiz = await QuizApiService.generateQuiz(request);
      print('Quiz generated successfully: ${quiz.title}');
      
      if (mounted) {
        // Pokaż dialog sukcesu
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quiz wygenerowany!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tytuł: ${quiz.title}'),
                Text('Przedmiot: ${quiz.subject}'),
                Text('Poziom: ${quiz.difficultyLevel.displayName}'),
                Text('Pytania: ${quiz.totalQuestions}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Zamknij dialog
                  Navigator.pop(context, true); // Wróć do listy quizów z wynikiem true
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('=== QUIZ GENERATION ERROR ===');
      print('Error: $e');
      
      // Sprawdź czy to błąd tokenu
      if (AuthService.handleTokenError(e.toString())) {
        setState(() {
          _error = 'Sesja wygasła. Zaloguj się ponownie.';
        });
        // Zamiast przekierowywania, pokaż komunikat z przyciskiem
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sesja wygasła. Musisz się zalogować ponownie.'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Zamknij',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Błąd podczas generowania quizu: $e';
        });
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _addSpecificTopic() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty && !_specificTopics.contains(topic)) {
      setState(() {
        _specificTopics.add(topic);
        _topicController.clear();
      });
    }
  }

  void _removeSpecificTopic(String topic) {
    setState(() {
      _specificTopics.remove(topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generuj Quiz'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingTeachers
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Wystąpił błąd',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeachers,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wybór nauczyciela
          _buildTeacherSelection(),
          const SizedBox(height: 24),
          
          // Wybór konwersacji
          if (_selectedTeacher != null) ...[
            _buildConversationSelection(),
            const SizedBox(height: 24),
          ],
          
          // Ustawienia quizu
          if (_selectedConversationId != null) ...[
            _buildQuizSettings(),
            const SizedBox(height: 24),
            
            // Konkretne tematy
            _buildSpecificTopics(),
            const SizedBox(height: 32),
            
            // Przycisk generowania
            _buildGenerateButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildTeacherSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wybierz nauczyciela',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_teachers.isEmpty)
              const Text('Brak dostępnych nauczycieli')
            else
              ...(_teachers.map((teacher) => RadioListTile<Teacher>(
                title: Text(teacher.name),
                subtitle: Text(teacher.subject ?? 'Brak przedmiotu'),
                value: teacher,
                groupValue: _selectedTeacher,
                onChanged: (value) {
                  setState(() {
                    _selectedTeacher = value;
                    _selectedConversationId = null;
                    _conversations = [];
                  });
                  if (value != null) {
                    _loadConversationsForTeacher(value);
                  }
                },
              ))),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wybierz konwersację',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingConversations)
              const Center(child: CircularProgressIndicator())
            else if (_conversations.isEmpty)
              const Text('Brak konwersacji z tym nauczycielem')
            else
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Konwersacja',
                  border: OutlineInputBorder(),
                ),
                value: _selectedConversationId,
                items: _conversations.map((conversation) {
                  final conversationObj = Conversation.fromJson(conversation);
                  return DropdownMenuItem<int>(
                    value: conversation['id'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversationObj.displayTitle,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (conversationObj.subject != null && conversationObj.subject!.isNotEmpty)
                          Text(
                            'Przedmiot: ${conversationObj.subject}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        Text(
                          'Utworzona: ${_formatDate(conversationObj.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedConversationId = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ustawienia quizu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Liczba pytań
            Row(
              children: [
                const Expanded(
                  child: Text('Liczba pytań:'),
                ),
                SizedBox(
                  width: 80,
                  child: DropdownButton<int>(
                    value: _questionCount,
                    isExpanded: true,
                    items: [5, 10, 15, 20, 25].map((count) {
                      return DropdownMenuItem(
                        value: count,
                        child: Text(count.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _questionCount = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Poziom trudności
            const Text('Poziom trudności:'),
            const SizedBox(height: 8),
            ...DifficultyLevel.values.map((difficulty) {
              return RadioListTile<DifficultyLevel>(
                title: Text(difficulty.displayName),
                value: difficulty,
                groupValue: _selectedDifficulty,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificTopics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konkretne tematy (opcjonalne)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dodaj konkretne tematy, na które chcesz się skupić:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            // Pole dodawania tematu
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      hintText: 'Np. równania kwadratowe, rewolucja francuska',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSpecificTopic(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSpecificTopic,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Lista dodanych tematów
            if (_specificTopics.isNotEmpty) ...[
              const Text('Dodane tematy:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specificTopics.map((topic) {
                  return Chip(
                    label: Text(topic),
                    onDeleted: () => _removeSpecificTopic(topic),
                    deleteIcon: const Icon(Icons.close),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = _selectedTeacher != null && 
                       _selectedConversationId != null && 
                       !_isGenerating;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canGenerate ? _generateQuiz : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Generowanie quizu...'),
                ],
              )
            : const Text(
                'Wygeneruj Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
