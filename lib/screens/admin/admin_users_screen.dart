import 'package:flutter/material.dart';
import '../../models/admin/admin_models.dart';
import '../../services/admin/admin_api_service.dart';
import 'admin_user_conversations_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserListItem> _users = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  final int _pageSize = 50;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _error = null;
          _currentPage = 0;
          _hasMoreData = true;
        });
      }

      final users = await AdminApiService.getAllUsers(
        skip: loadMore ? _currentPage * _pageSize : 0,
        limit: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _users.addAll(users);
          } else {
            _users = users;
          }
          _hasMoreData = users.length == _pageSize;
          if (loadMore) _currentPage++;
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
        title: const Text('Zarządzanie użytkownikami'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUsers(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _users.isEmpty) {
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
              onPressed: () => _loadUsers(),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('Brak użytkowników'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            // Ładowanie kolejnych stron
            if (_hasMoreData && !_isLoading) {
              _loadUsers(loadMore: true);
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.isVerified ? Colors.teal : Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.isVerified ? 'Zweryfikowany' : 'Niezweryfikowany',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.chat, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${user.conversationsCount} konw.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${user.quizzesCount} quizów',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.assignment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${user.quizAttemptsCount} prób',
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
                    _showUserDialog(user);
                  } else if (value == 'verify') {
                    _toggleVerification(user);
                  } else if (value == 'promote') {
                    _toggleRole(user);
                  } else if (value == 'conversations') {
                    _showUserConversations(user);
                  } else if (value == 'delete') {
                    _deleteUser(user);
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
                    value: 'conversations',
                    child: ListTile(
                      leading: Icon(Icons.chat_bubble_outline),
                      title: Text('Zobacz konwersacje'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'verify',
                    child: ListTile(
                      leading: Icon(
                        user.isVerified ? Icons.cancel : Icons.verified_user,
                      ),
                      title: Text(
                        user.isVerified 
                          ? 'Usuń weryfikację' 
                          : 'Zweryfikuj',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'promote',
                    child: ListTile(
                      leading: Icon(
                        user.role == 'admin' ? Icons.person : Icons.admin_panel_settings,
                      ),
                      title: Text(
                        user.role == 'admin' 
                          ? 'Usuń uprawnienia admin' 
                          : 'Promuj na admin',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      title: Text('Usuń użytkownika', style: TextStyle(color: Colors.red)),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.deepPurple;
      case 'premium':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'premium':
        return 'Premium';
      default:
        return 'User';
    }
  }

  Future<void> _toggleVerification(UserListItem user) async {
    try {
      final updateData = UserUpdate(isVerified: !user.isVerified);
      await AdminApiService.updateUser(user.id, updateData);
      
      _loadUsers(); // Odśwież listę
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isVerified 
                ? 'Weryfikacja została usunięta'
                : 'Użytkownik został zweryfikowany',
            ),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRole(UserListItem user) async {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zmiana uprawnień'),
        content: Text(
          user.role == 'admin'
            ? 'Czy na pewno chcesz usunąć uprawnienia administratora użytkownikowi "${user.fullName}"?'
            : 'Czy na pewno chcesz nadać uprawnienia administratora użytkownikowi "${user.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: user.role == 'admin' ? Colors.amber : Colors.deepPurple,
            ),
            child: Text(
              user.role == 'admin' ? 'Usuń uprawnienia' : 'Promuj',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updateData = UserUpdate(role: newRole);
        await AdminApiService.updateUser(user.id, updateData);
        
        _loadUsers(); // Odśwież listę
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newRole == 'admin'
                  ? 'Użytkownik został promowany na administratora'
                  : 'Uprawnienia administratora zostały usunięte',
              ),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showUserDialog(UserListItem user) {
    showDialog(
      context: context,
      builder: (context) => UserEditDialog(
        user: user,
        onSaved: (success) {
          if (success) {
            _loadUsers();
          }
        },
      ),
    );
  }

  Future<void> _showUserConversations(UserListItem user) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminUserConversationsScreen(user: user),
      ),
    );
  }

  Future<void> _deleteUser(UserListItem user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Usuń użytkownika'),
          ],
        ),
        content: Text(
          'Czy na pewno chcesz trwale usunąć użytkownika "${user.fullName}"?\n\n'
          'Ta operacja spowoduje:\n'
          '• Usunięcie konta użytkownika\n'
          '• Usunięcie wszystkich jego konwersacji\n'
          '• Usunięcie wszystkich jego quizów\n'
          '• Usunięcie wszystkich jego danych\n\n'
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
            child: const Text('Usuń trwale'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminApiService.deleteUser(user.id);
        
        _loadUsers(); // Odśwież listę
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Użytkownik "${user.fullName}" został usunięty'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd usuwania użytkownika: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class UserEditDialog extends StatefulWidget {
  final UserListItem user;
  final Function(bool success) onSaved;

  const UserEditDialog({
    super.key,
    required this.user,
    required this.onSaved,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _emailController.text = widget.user.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updateData = UserUpdate(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );
      await AdminApiService.updateUser(widget.user.id, updateData);

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Użytkownik został zaktualizowany'),
            backgroundColor: Colors.teal,
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
      title: Text('Edytuj użytkownika: ${widget.user.fullName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Imię',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wprowadź imię';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nazwisko',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wprowadź nazwisko';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wprowadź e-mail';
                }
                if (!value.contains('@')) {
                  return 'Wprowadź prawidłowy e-mail';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveUser,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Zapisz'),
        ),
      ],
    );
  }
}
