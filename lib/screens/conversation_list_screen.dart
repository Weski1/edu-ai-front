import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praca_inzynierska_front/models/teacher.dart';
import 'package:praca_inzynierska_front/models/conversation.dart';
import 'package:praca_inzynierska_front/services/chat_api_service.dart';
import 'package:praca_inzynierska_front/screens/chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  final Teacher teacher;
  final String? token;

  const ConversationListScreen({super.key, required this.teacher, this.token});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final List<Conversation> _conversations = [];
  bool _loading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      print('Loading conversations for teacher: ${widget.teacher.id}');
      final conversationsData = await ChatApiService.getConversationsByTeacher(
        teacherId: widget.teacher.id,
        token: widget.token,
      );

      print('Received ${conversationsData.length} conversations');

      final conversations =
          conversationsData.map((data) => Conversation.fromJson(data)).toList();

      // Sortuj konwersacje - najnowsze pierwsza
      conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _conversations.clear();
        _conversations.addAll(conversations);
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _hasError = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania konwersacji: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startNewConversation() async {
    try {
      final conversationId = await ChatApiService.startConversation(
        teacherId: widget.teacher.id,
        token: widget.token,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                conversationId: conversationId,
                teacherName: widget.teacher.name,
                token: widget.token,
              ),
        ),
      ).then((_) => _loadConversations()); // Odśwież listę po powrocie
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się rozpocząć nowej rozmowy: $e')),
      );
    }
  }

  void _openConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              conversationId: conversation.id,
              teacherName: widget.teacher.name,
              token: widget.token,
            ),
      ),
    ).then((_) => _loadConversations()); // Odśwież listę po powrocie
  }

  Future<void> _showRenameDialog(Conversation conversation) async {
    final TextEditingController controller = TextEditingController(
      text: conversation.title ?? conversation.topic ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zmień nazwę konwersacji'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nowa nazwa',
              hintText: 'Wprowadź nazwę konwersacji',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            maxLength: 100,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  Navigator.of(context).pop(newTitle);
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _renameConversation(conversation.id, result);
    }
  }

  Future<void> _renameConversation(int conversationId, String newTitle) async {
    try {
      await ChatApiService.renameConversation(
        conversationId: conversationId,
        newTitle: newTitle,
        token: widget.token,
      );

      // Odśwież listę konwersacji
      await _loadConversations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nazwa konwersacji została zmieniona'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd zmiany nazwy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConversationOptions(Conversation conversation) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                conversation.displayTitle,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Zmień nazwę'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRenameDialog(conversation);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Otwórz konwersację'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openConversation(conversation);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime); // Dziś - tylko godzina
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'pl').format(dateTime); // Dzień tygodnia
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime); // Pełna data
    }
  }

  Widget _buildConversationTile(Conversation conversation) {
    final displayTitle = conversation.displayTitle;
    final subtitle = conversation.subject ?? 'Rozmowa z ${widget.teacher.name}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            conversation.topic != null && conversation.topic!.isNotEmpty
                ? Icons.topic
                : Icons.chat_bubble_outline,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(conversation.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenameDialog(conversation);
                } else if (value == 'open') {
                  _openConversation(conversation);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem<String>(
                      value: 'open',
                      child: ListTile(
                        leading: Icon(Icons.chat),
                        title: Text('Otwórz'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'rename',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Zmień nazwę'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
            ),
          ],
        ),
        onTap: () => _openConversation(conversation),
        onLongPress: () => _showConversationOptions(conversation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.teacher.name),
            if (widget.teacher.subject != null)
              Text(
                widget.teacher.subject!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadConversations,
            tooltip: 'Odśwież',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child:
            _loading && _conversations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _hasError && _conversations.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Błąd wczytywania konwersacji',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadConversations,
                        child: const Text('Spróbuj ponownie'),
                      ),
                    ],
                  ),
                )
                : _conversations.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Brak konwersacji z ${widget.teacher.name}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rozpocznij nową rozmowę!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: _conversations.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return _buildConversationTile(_conversations[index]);
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _startNewConversation,
        tooltip: 'Nowa rozmowa',
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
