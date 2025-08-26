import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:praca_inzynierska_front/models/message.dart';
import 'package:praca_inzynierska_front/services/chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String teacherName;
  final String? token;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.teacherName,
    this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  final _picker = ImagePicker();

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _busy = true);
    try {
      final msgs = await ChatApiService.getMessages(
        conversationId: widget.conversationId,
        token: widget.token,
      );
      setState(() {
        _messages
          ..clear()
          ..addAll(msgs);
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd wczytywania historii: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    final tempUser = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      conversationId: widget.conversationId,
      sender: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(tempUser);
      _controller.clear();
      _busy = true;
    });
    _scrollToBottom();

    final typing = ChatMessage(
      id: -999,
      conversationId: widget.conversationId,
      sender: 'teacher_ai',
      content: '✍️ AI pisze odpowiedź...',
      createdAt: DateTime.now(),
    );
    setState(() => _messages.add(typing));
    _scrollToBottom();

    try {
      final ai = await ChatApiService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
        token: widget.token,
      );
      setState(() {
        _messages.removeWhere((m) => m.id == typing.id);
        _messages.add(ai);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == typing.id);
        _messages.add(ChatMessage(
          id: -998,
          conversationId: widget.conversationId,
          sender: 'teacher_ai',
          content: '⚠️ Błąd podczas komunikacji z serwerem.',
          createdAt: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_busy) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
      );
      if (picked == null) return;

      final file = File(picked.path);

      // Placeholder w UI – informacja, że wysyłamy obraz
      final placeholderId = -997;
      setState(() {
        _busy = true;
        _messages.add(ChatMessage(
          id: placeholderId,
          conversationId: widget.conversationId,
          sender: 'user',
          content: '📎 Wysyłanie obrazu${_controller.text.trim().isNotEmpty ? ' + tekst' : ''}…',
          createdAt: DateTime.now(),
        ));
      });
      _scrollToBottom();

      final ai = await ChatApiService.sendImageMessage(
        conversationId: widget.conversationId,
        imageFile: file,
        content: _controller.text.trim().isNotEmpty ? _controller.text.trim() : null,
        token: widget.token,
      );

      setState(() {
        _controller.clear();
        _messages.removeWhere((m) => m.id == placeholderId);
        _messages.add(ai);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: -996,
          conversationId: widget.conversationId,
          sender: 'teacher_ai',
          content: '⚠️ Błąd przy wysyłaniu obrazu: $e',
          createdAt: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacherName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m.sender == 'user';
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment:
                        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'Ty' : 'AI',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.content),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _busy ? null : _pickAndSendImage,
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Wyślij obraz',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_busy,
                    decoration: const InputDecoration(
                      hintText: 'Zadaj pytanie...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
