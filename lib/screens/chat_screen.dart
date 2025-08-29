import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:praca_inzynierska_front/models/message.dart';
import 'package:praca_inzynierska_front/services/chat_api_service.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';

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
  bool _busy = false;

  // obrazy wybrane z galerii – czekają na wysłanie razem z tekstem
  final List<File> _pendingImages = [];

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

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        final imageFiles = <File>[];
        
        // Walidacja każdego pliku
        for (final xFile in picked) {
          final file = File(xFile.path);
          
          // Sprawdź rozszerzenie pliku
          final extension = xFile.path.toLowerCase();
          if (extension.endsWith('.jpg') || 
              extension.endsWith('.jpeg') || 
              extension.endsWith('.png') || 
              extension.endsWith('.webp')) {
            
            // Sprawdź czy plik istnieje i ma zawartość
            if (await file.exists()) {
              final size = await file.length();
              if (size > 0 && size < 10 * 1024 * 1024) { // max 10MB
                imageFiles.add(file);
                // print('DEBUG: Added valid image: ${xFile.path}, size: $size bytes');
              } else {
                // print('WARNING: File too large or empty: ${xFile.path}, size: $size');
              }
            } else {
              // print('WARNING: File does not exist: ${xFile.path}');
            }
          } else {
            // print('WARNING: Invalid file extension: ${xFile.path}');
          }
        }
        
        if (imageFiles.isNotEmpty) {
          setState(() => _pendingImages.addAll(imageFiles));
          // print('DEBUG: Added ${imageFiles.length} valid images');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Nie znaleziono poprawnych plików obrazów. Wybierz pliki JPG, PNG lub WebP.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Błąd przy wyborze obrazów: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() => _pendingImages.removeAt(index));
  }

  void _clearPendingImages() {
    setState(() => _pendingImages.clear());
  }

  // Formatowanie czasu/data
  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
  String _formatDate(DateTime dt) => DateFormat('d MMMM yyyy', 'pl').format(dt);

  bool _isNewDay(int index) {
    if (index == 0) return true;
    final prev = _messages[index - 1].createdAt;
    final curr = _messages[index].createdAt;
    return prev.year != curr.year || prev.month != curr.month || prev.day != curr.day;
  }

  // zamiana ścieżki względnej na pełny URL
  String? _fullUrl(String? rel) {
    if (rel == null || rel.isEmpty) return null;
    if (rel.startsWith('http://') || rel.startsWith('https://')) return rel;
    return '${ApiClient.baseUrl}$rel';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final hasPendingImages = _pendingImages.isNotEmpty;

    if ((!hasPendingImages && text.isEmpty) || _busy) return;

    setState(() => _busy = true);

    // Skopiuj listę obrazów przed czyszczeniem
    final imagesToSend = List<File>.from(_pendingImages);

    try {
      ChatMessage ai;

      if (hasPendingImages) {
        // lokalny bąbel użytkownika z podglądem obrazów
        final localMedia = ChatMessage(
          id: -DateTime.now().millisecondsSinceEpoch,
          conversationId: widget.conversationId,
          sender: 'user',
          type: 'media',
          content: text,
          createdAt: DateTime.now(),
          attachments: const [], // URL nieznany dopóki nie wyślemy
        );
        
        setState(() {
          _messages.add(localMedia);
          _controller.clear();
          _pendingImages.clear(); // Wyczyść listę obrazów NATYCHMIAST po dodaniu wiadomości
        });
        _scrollToBottom();

        // TERAZ dodaj "AI pisze..." PO wiadomości użytkownika
        final typing = ChatMessage(
          id: -999,
          conversationId: widget.conversationId,
          sender: 'teacher_ai',
          type: 'text',
          content: '✍️ AI pisze odpowiedź...',
          createdAt: DateTime.now(),
          attachments: const [],
        );
        setState(() => _messages.add(typing));
        _scrollToBottom();

        ai = await ChatApiService.sendMultipleImagesMessage(
          conversationId: widget.conversationId,
          imageFiles: imagesToSend, // Używaj kopii
          content: text.isEmpty ? null : text,
          token: widget.token,
        );

        // Przeładuj całą historię, żeby mieć aktualną wiadomość użytkownika z załącznikami
        await _loadHistory();
      } else {
        // zwykła wiadomość tekstowa
        final localUser = ChatMessage(
          id: -DateTime.now().millisecondsSinceEpoch,
          conversationId: widget.conversationId,
          sender: 'user',
          type: 'text',
          content: text,
          createdAt: DateTime.now(),
          attachments: const [],
        );
        setState(() {
          _messages.add(localUser);
          _controller.clear();
        });
        _scrollToBottom();

        // Dodaj "AI pisze..." PO wiadomości użytkownika
        final typing = ChatMessage(
          id: -999,
          conversationId: widget.conversationId,
          sender: 'teacher_ai',
          type: 'text',
          content: '✍️ AI pisze odpowiedź...',
          createdAt: DateTime.now(),
          attachments: const [],
        );
        setState(() => _messages.add(typing));
        _scrollToBottom();

        ai = await ChatApiService.sendMessage(
          conversationId: widget.conversationId,
          content: text,
          token: widget.token,
        );
      }

      setState(() {
        _messages.removeWhere((m) => m.id == -999); // Usuń "AI pisze..."
        // Dla wiadomości tekstowych dodaj odpowiedź AI
        if (!hasPendingImages) {
          _messages.add(ai);
        }
        // Dla wiadomości z obrazami historia została już przeładowana
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == -999); // Usuń "AI pisze..." w przypadku błędu
        _messages.add(ChatMessage(
          id: -998,
          conversationId: widget.conversationId,
          sender: 'teacher_ai',
          type: 'text',
          content: '⚠️ Błąd podczas komunikacji z serwerem.',
          createdAt: DateTime.now(),
          attachments: const [],
        ));
        // W przypadku błędu, przywróć obrazy
        if (hasPendingImages) {
          _pendingImages.addAll(imagesToSend);
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showImageFull(String url, {ImageProvider? localProvider}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            child: localProvider != null
                ? Image(image: localProvider)
                : Image.network(url),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaAttachments(ChatMessage m, {List<File>? localPendingFiles}) {
    // Jeśli to lokalny bąbel (id<0) i mamy pendingFiles – pokażemy ich miniatury.
    if (m.id < 0 && localPendingFiles != null && localPendingFiles.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wyświetlanie lokalnych obrazów w siatce
          if (localPendingFiles.length == 1)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () => _showImageFull(
                  '', // nieużywany przy localProvider
                  localProvider: FileImage(localPendingFiles[0]),
                ),
                child: Image.file(localPendingFiles[0], width: 220, fit: BoxFit.cover),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: localPendingFiles.length > 4 ? 3 : 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: localPendingFiles.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () => _showImageFull(
                      '',
                      localProvider: FileImage(localPendingFiles[index]),
                    ),
                    child: Image.file(
                      localPendingFiles[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          if (m.content.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(m.content),
            ),
        ],
      );
    }

    // W przeciwnym razie – renderuj załączniki z URL
    if (m.attachments.isEmpty) {
      // awaryjnie – nie ma załączników, ale type=media
      return const SizedBox(width: 220, height: 160);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wyświetlanie załączników z serwera
        if (m.attachments.length == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                final url = _fullUrl(m.attachments[0].url);
                if (url != null) _showImageFull(url);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _fullUrl(m.attachments[0].url)!,
                  width: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: m.attachments.length > 4 ? 3 : 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: m.attachments.length,
            itemBuilder: (context, index) {
              final att = m.attachments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: () {
                    final url = _fullUrl(att.url);
                    if (url != null) _showImageFull(url);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _fullUrl(att.url)!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        if (m.content.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(m.content),
          ),
      ],
    );
  }

  Widget _buildBubble(ChatMessage m) {
    final isUser = m.isUser;
    final bubbleColor = isUser ? Colors.blue[100] : Colors.grey[200];

    final inner = m.isMedia
        ? _buildMediaAttachments(
            m,
            localPendingFiles:
                (m.id < 0 && _pendingImages.isNotEmpty) ? _pendingImages : null,
          )
        : Text(m.content);

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(isUser ? 'Ty' : 'AI',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: inner,
          ),
          const SizedBox(height: 4),
          Text(_formatTime(m.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacherName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  final widgets = <Widget>[];

                  if (_isNewDay(i)) {
                    widgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            _formatDate(m.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  widgets.add(_buildBubble(m));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widgets,
                  );
                },
              ),
            ),

            // Pasek z podglądem wybranych obrazów (przed wysyłką)
            if (_pendingImages.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Wybrano ${_pendingImages.length} obraz${_pendingImages.length == 1 ? '' : (_pendingImages.length < 5 ? 'y' : 'ów')}. Wyślij, aby przesłać.',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        IconButton(
                          onPressed: _busy ? null : _clearPendingImages,
                          icon: const Icon(Icons.close),
                          tooltip: 'Usuń wszystkie obrazy',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pendingImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _pendingImages[index],
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: _busy ? null : () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),
            // Dodaj padding na dole, żeby nie nachodzić na przyciski systemowe
            Container(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 12,
                bottom: 12 + MediaQuery.of(context).padding.bottom, // Dodatkowy padding dla systemu
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _busy ? null : _pickImages,
                    icon: const Icon(Icons.photo_library_outlined),
                    tooltip: 'Dodaj zdjęcia',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        hintText:
                            'Napisz wiadomość… (np. "To moja kartkówka, pomóż z zad. 6")',
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
      ),
    );
  }
}
