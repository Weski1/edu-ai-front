import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/services/chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {'sender': 'AI', 'text': 'Cześć! Jak mogę Ci dziś pomóc w nauce?'},
  ];

  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'Ty', 'text': text});
      _controller.clear();
      _isLoading = true;
      _messages.add({'sender': 'AI', 'text': '✍️ AI pisze odpowiedź...'});
    });

    try {
      final aiResponse = await ChatApiService.sendMessage(text);
      setState(() {
        _messages.removeLast(); // usuń tymczasowy loading
        _messages.add({'sender': 'AI', 'text': aiResponse});
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({'sender': 'AI', 'text': '⚠️ Błąd podczas komunikacji z serwerem.'});
      });
    } finally {
      _isLoading = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['sender'] == 'Ty';
              return Container(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['sender'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text'] ?? ''),
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
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Zadaj pytanie...',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        )
      ],
    );
  }
}
