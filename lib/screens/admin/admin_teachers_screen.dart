import 'package:flutter/material.dart';
import '../../models/admin/admin_models.dart';
import '../../services/admin/admin_api_service.dart';

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});

  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  List<TeacherResponse> _teachers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final teachers = await AdminApiService.getAllTeachers();

      if (mounted) {
        setState(() {
          _teachers = teachers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTeacher(TeacherResponse teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń nauczyciela'),
        content: Text(
          'Czy na pewno chcesz usunąć nauczyciela "${teacher.name}"?\n\n'
          'Uwaga: Nauczyciel z istniejącymi konwersacjami nie może być usunięty.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminApiService.deleteTeacher(teacher.id);
        _loadTeachers(); // Odśwież listę
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nauczyciel został usunięty'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd usuwania: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzanie nauczycielami'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTeacherDialog(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Błąd ładowania',
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

    if (_teachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Brak nauczycieli'),
            SizedBox(height: 8),
            Text('Dodaj pierwszego nauczyciela używając przycisku +'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTeachers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teachers.length,
        itemBuilder: (context, index) {
          final teacher = _teachers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                backgroundImage: teacher.avatarUrl != null
                    ? NetworkImage(teacher.avatarUrl!)
                    : null,
                child: teacher.avatarUrl == null
                    ? const Icon(Icons.school, color: Colors.blue)
                    : null,
              ),
              title: Text(
                teacher.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teacher.subject),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.chat, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.conversationsCount} konwersacji',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.quizzesCount} quizów',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showTeacherDialog(teacher: teacher);
                  } else if (value == 'delete') {
                    _deleteTeacher(teacher);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edytuj'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Usuń'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTeacherDialog({TeacherResponse? teacher}) {
    showDialog(
      context: context,
      builder: (context) => TeacherDialog(
        teacher: teacher,
        onSaved: (success) {
          if (success) {
            _loadTeachers();
          }
        },
      ),
    );
  }
}

class TeacherDialog extends StatefulWidget {
  final TeacherResponse? teacher;
  final Function(bool success) onSaved;

  const TeacherDialog({
    super.key,
    this.teacher,
    required this.onSaved,
  });

  @override
  State<TeacherDialog> createState() => _TeacherDialogState();
}

class _TeacherDialogState extends State<TeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _stylePromptController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _welcomeMessageController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _nameController.text = widget.teacher!.name;
      _subjectController.text = widget.teacher!.subject;
      _stylePromptController.text = widget.teacher!.stylePrompt;
      _avatarUrlController.text = widget.teacher!.avatarUrl ?? '';
      _welcomeMessageController.text = widget.teacher!.welcomeMessage ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _stylePromptController.dispose();
    _avatarUrlController.dispose();
    _welcomeMessageController.dispose();
    super.dispose();
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.teacher == null) {
        // Tworzenie nowego nauczyciela
        final teacherData = TeacherCreate(
          name: _nameController.text.trim(),
          subject: _subjectController.text.trim(),
          stylePrompt: _stylePromptController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
          welcomeMessage: _welcomeMessageController.text.trim().isEmpty
              ? null
              : _welcomeMessageController.text.trim(),
        );
        await AdminApiService.createTeacher(teacherData);
      } else {
        // Aktualizacja istniejącego nauczyciela
        final updateData = TeacherUpdate(
          name: _nameController.text.trim(),
          subject: _subjectController.text.trim(),
          stylePrompt: _stylePromptController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
          welcomeMessage: _welcomeMessageController.text.trim().isEmpty
              ? null
              : _welcomeMessageController.text.trim(),
        );
        await AdminApiService.updateTeacher(widget.teacher!.id, updateData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.teacher == null
                  ? 'Nauczyciel został utworzony'
                  : 'Nauczyciel został zaktualizowany',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd zapisywania: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.teacher == null ? 'Nowy nauczyciel' : 'Edytuj nauczyciela'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Imię i nazwisko',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Wprowadź prawidłowe imię i nazwisko';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Przedmiot',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Wprowadź przedmiot';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stylePromptController,
                decoration: const InputDecoration(
                  labelText: 'Styl promptu',
                  hintText: 'Opisz jak nauczyciel ma się zachowywać',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Wprowadź opis stylu (min. 10 znaków)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL avatara (opcjonalne)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _welcomeMessageController,
                decoration: const InputDecoration(
                  labelText: 'Wiadomość powitalna (opcjonalne)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveTeacher,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.teacher == null ? 'Utwórz' : 'Zapisz'),
        ),
      ],
    );
  }
}
