import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin/admin_models.dart';
import '../../services/admin/admin_api_service.dart';

class AdminUserConversationsScreen extends StatefulWidget {
  final UserListItem user;

  const AdminUserConversationsScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminUserConversationsScreen> createState() => _AdminUserConversationsScreenState();
}

class _AdminUserConversationsScreenState extends State<AdminUserConversationsScreen> {
  List<UserConversationItem> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversations = await AdminApiService.getUserConversations(widget.user.id);
      if (mounted) {
        setState(() {
          _conversations = conversations;
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konwersacje użytkownika',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              widget.user.fullName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
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
              'Błąd ładowania konwersacji',
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
              onPressed: _loadConversations,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Użytkownik nie ma żadnych konwersacji'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  conversation.teacherSubject.isNotEmpty 
                    ? conversation.teacherSubject.substring(0, 1).toUpperCase()
                    : 'N',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                conversation.displayTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nauczyciel: ${conversation.teacherName}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Przedmiot: ${conversation.teacherSubject}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.message, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            '${conversation.messagesCount} wiad.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            DateFormat('dd.MM HH:mm').format(conversation.createdAt),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'view') {
                    _viewConversationMessages(conversation);
                  } else if (value == 'delete') {
                    _deleteConversation(conversation);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('Zobacz wiadomości'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Usuń konwersację', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _viewConversationMessages(conversation),
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Zobacz', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _deleteConversation(conversation),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Usuń', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (conversation.lastMessageAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ostatnia wiadomość: ${DateFormat('dd.MM.yyyy HH:mm').format(conversation.lastMessageAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _viewConversationMessages(UserConversationItem conversation) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminConversationMessagesScreen(
          user: widget.user,
          conversation: conversation,
        ),
      ),
    ).then((_) {
      // Odśwież listę konwersacji po powrocie (w przypadku usunięcia wiadomości)
      _loadConversations();
    });
  }

  Future<void> _deleteConversation(UserConversationItem conversation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text('Usuń konwersację'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Czy na pewno chcesz usunąć konwersację:'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${conversation.displayTitle}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Ta operacja spowoduje:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('• Usunięcie ${conversation.messagesCount} wiadomości'),
              const Text('• Usunięcie wszystkich załączników'),
              const SizedBox(height: 12),
              const Text(
                'UWAGA: Ta operacja jest nieodwracalna!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
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
            child: const Text('Usuń konwersację'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminApiService.deleteUserConversation(widget.user.id, conversation.id);
        
        _loadConversations(); // Odśwież listę
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Konwersacja "${conversation.displayTitle}" została usunięta'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd usuwania konwersacji: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class AdminConversationMessagesScreen extends StatefulWidget {
  final UserListItem user;
  final UserConversationItem conversation;

  const AdminConversationMessagesScreen({
    super.key,
    required this.user,
    required this.conversation,
  });

  @override
  State<AdminConversationMessagesScreen> createState() => _AdminConversationMessagesScreenState();
}

class _AdminConversationMessagesScreenState extends State<AdminConversationMessagesScreen> {
  UserConversationDetail? _conversationDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversationDetail();
  }

  Future<void> _loadConversationDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await AdminApiService.getUserConversationDetail(
        widget.user.id,
        widget.conversation.id,
      );
      if (mounted) {
        setState(() {
          _conversationDetail = detail;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.displayTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              '${widget.user.fullName} → ${widget.conversation.teacherName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversationDetail,
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
              'Błąd ładowania wiadomości',
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
              onPressed: _loadConversationDetail,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (_conversationDetail == null || _conversationDetail!.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Brak wiadomości w tej konwersacji'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversationDetail,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversationDetail!.messages.length,
        itemBuilder: (context, index) {
          final message = _conversationDetail!.messages[index];
          final isUser = message.isUser;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              decoration: BoxDecoration(
                color: isUser 
                  ? Colors.deepPurple.shade100
                  : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUser 
                    ? Colors.deepPurple.shade200
                    : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUser 
                              ? Colors.deepPurple
                              : Colors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isUser ? 'Użytkownik' : 'AI Nauczyciel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(message.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteMessage(message);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red, size: 18),
                                title: Text('Usuń', style: TextStyle(color: Colors.red, fontSize: 12)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (message.hasMedia) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attachment, size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${message.attachmentsCount} załącznik(ów)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMessage(UserMessageItem message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text('Usuń wiadomość'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Czy na pewno chcesz usunąć wiadomość od ${message.isUser ? 'użytkownika' : 'AI nauczyciela'}?'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.content.length > 100 
                    ? '${message.content.substring(0, 100)}...'
                    : message.content,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'UWAGA: Ta operacja jest nieodwracalna!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
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
            child: const Text('Usuń wiadomość'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminApiService.deleteMessage(message.id);
        
        _loadConversationDetail(); // Odśwież wiadomości
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wiadomość została usunięta'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd usuwania wiadomości: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
