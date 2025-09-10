import 'package:flutter/material.dart';
import '../../models/admin/admin_models.dart';
import '../../services/admin/admin_api_service.dart';

class AdminTeacherManagementScreen extends StatefulWidget {
  const AdminTeacherManagementScreen({super.key});

  @override
  State<AdminTeacherManagementScreen> createState() => _AdminTeacherManagementScreenState();
}

class _AdminTeacherManagementScreenState extends State<AdminTeacherManagementScreen> {
  List<TeacherResponse> _teachers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzanie nauczycielami'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeachers,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTeacherDialog(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTeacherDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              'Błąd ładowania nauczycieli',
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
            Text('Brak nauczycieli w systemie'),
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
                backgroundColor: Colors.deepPurple,
                backgroundImage: teacher.avatarUrl != null
                    ? NetworkImage(teacher.avatarUrl!)
                    : null,
                child: teacher.avatarUrl == null
                    ? Text(
                        teacher.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.quizzesCount} quizów',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (teacher.welcomeMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Powitanie: ${teacher.welcomeMessage!.length > 50 ? '${teacher.welcomeMessage!.substring(0, 50)}...' : teacher.welcomeMessage!}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTeacherDialog(teacher);
                  } else if (value == 'view') {
                    _showTeacherDetailsDialog(teacher);
                  } else if (value == 'delete') {
                    _deleteTeacher(teacher);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('Zobacz szczegóły'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
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
                      title: Text('Usuń', style: TextStyle(color: Colors.red)),
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

  void _showCreateTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => TeacherCreateEditDialog(
        onSaved: (success) {
          if (success) {
            _loadTeachers();
          }
        },
      ),
    );
  }

  void _showEditTeacherDialog(TeacherResponse teacher) {
    showDialog(
      context: context,
      builder: (context) => TeacherCreateEditDialog(
        teacher: teacher,
        onSaved: (success) {
          if (success) {
            _loadTeachers();
          }
        },
      ),
    );
  }

  void _showTeacherDetailsDialog(TeacherResponse teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Szczegóły: ${teacher.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Imię', teacher.name),
              _buildDetailRow('Przedmiot', teacher.subject),
              _buildDetailRow('Konwersacje', '${teacher.conversationsCount}'),
              _buildDetailRow('Quizy', '${teacher.quizzesCount}'),
              if (teacher.avatarUrl != null)
                _buildDetailRow('Avatar URL', teacher.avatarUrl!),
              if (teacher.welcomeMessage != null)
                _buildDetailRow('Wiadomość powitalna', teacher.welcomeMessage!),
              const SizedBox(height: 12),
              const Text(
                'Prompt stylu:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  teacher.stylePrompt,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTeacherDialog(teacher);
            },
            child: const Text('Edytuj'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeacher(TeacherResponse teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Usuń nauczyciela'),
          ],
        ),
        content: Text(
          'Czy na pewno chcesz usunąć nauczyciela "${teacher.name}"?\n\n'
          'Ta operacja spowoduje:\n'
          '• Usunięcie nauczyciela z systemu\n'
          '• Usunięcie ${teacher.conversationsCount} konwersacji\n'
          '• Usunięcie ${teacher.quizzesCount} quizów\n\n'
          'UWAGA: Ta operacja jest nieodwracalna!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Usuń nauczyciela'),
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
            SnackBar(
              content: Text('Nauczyciel "${teacher.name}" został usunięty'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd usuwania nauczyciela: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class TeacherCreateEditDialog extends StatefulWidget {
  final TeacherResponse? teacher;
  final Function(bool success) onSaved;

  const TeacherCreateEditDialog({
    super.key,
    this.teacher,
    required this.onSaved,
  });

  @override
  State<TeacherCreateEditDialog> createState() => _TeacherCreateEditDialogState();
}

class _TeacherCreateEditDialogState extends State<TeacherCreateEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _stylePromptController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _welcomeMessageController = TextEditingController();

  bool _isSaving = false;
  bool get _isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final teacher = widget.teacher!;
      _nameController.text = teacher.name;
      _subjectController.text = teacher.subject;
      _stylePromptController.text = teacher.stylePrompt;
      _avatarUrlController.text = teacher.avatarUrl ?? '';
      _welcomeMessageController.text = teacher.welcomeMessage ?? '';
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
      if (_isEditing) {
        // Edycja istniejącego nauczyciela
        final updateData = TeacherUpdate(
          name: _nameController.text.trim(),
          subject: _subjectController.text.trim(),
          stylePrompt: _stylePromptController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
          welcomeMessage: _welcomeMessageController.text.trim().isEmpty ? null : _welcomeMessageController.text.trim(),
        );
        await AdminApiService.updateTeacher(widget.teacher!.id, updateData);
      } else {
        // Tworzenie nowego nauczyciela
        final createData = TeacherCreate(
          name: _nameController.text.trim(),
          subject: _subjectController.text.trim(),
          stylePrompt: _stylePromptController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
          welcomeMessage: _welcomeMessageController.text.trim().isEmpty ? null : _welcomeMessageController.text.trim(),
        );
        await AdminApiService.createTeacher(createData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                ? 'Nauczyciel został zaktualizowany'
                : 'Nauczyciel został utworzony',
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
      title: Text(_isEditing ? 'Edytuj nauczyciela' : 'Utwórz nauczyciela'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Imię nauczyciela *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wprowadź imię nauczyciela';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Przedmiot *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wprowadź przedmiot';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stylePromptController,
                decoration: const InputDecoration(
                  labelText: 'Prompt stylu *',
                  hintText: 'Opisz jak ma się zachowywać ten nauczyciel AI',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wprowadź prompt stylu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL avatara (opcjonalne)',
                  hintText: 'https://example.com/avatar.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _welcomeMessageController,
                decoration: const InputDecoration(
                  labelText: 'Wiadomość powitalna (opcjonalne)',
                  hintText: 'Cześć! Jestem Twoim nauczycielem...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
              : Text(_isEditing ? 'Zaktualizuj' : 'Utwórz'),
        ),
      ],
    );
  }
}
