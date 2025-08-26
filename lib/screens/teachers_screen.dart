import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/models/teacher.dart';
import 'package:praca_inzynierska_front/services/teachers_api_service.dart';
import 'package:praca_inzynierska_front/services/chat_api_service.dart';
import 'package:praca_inzynierska_front/screens/chat_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key, this.token});
  final String? token;

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final _scroll = ScrollController();
  final _items = <Teacher>[];
  bool _loading = false;
  int? _nextOffset = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _nextOffset == null) return;
    setState(() => _loading = true);
    try {
      final page = await TeachersApiService.fetch(
        offset: _nextOffset!,
        limit: 20,
        q: _query.isEmpty ? null : _query,
        token: widget.token,
      );
      setState(() {
        _items.addAll(page.items);
        _nextOffset = page.nextOffset;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd pobierania: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _nextOffset = 0;
    });
    await _loadMore();
  }

  Future<void> _openChat(Teacher t) async {
    // szybka obrona przed brakiem tokenu:
    if (widget.token == null || widget.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak tokenu – zaloguj się ponownie.')),
      );
      return;
    }

    try {
      final conversationId = await ChatApiService.startConversation(
        teacherId: t.id,
        token: widget.token,
      );
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversationId,
          teacherName: t.name,
          token: widget.token,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się rozpocząć rozmowy: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz nauczyciela'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Szukaj po imieniu/przedmiocie...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) async {
                _query = val.trim();
                await _refresh();
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scroll,
          itemCount: _items.length + 1,
          itemBuilder: (_, i) {
            if (i >= _items.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _nextOffset == null
                      ? const Text('To już wszystko ✨')
                      : const CircularProgressIndicator(),
                ),
              );
            }
            final t = _items[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    t.avatarUrl != null ? NetworkImage(t.avatarUrl!) : null,
                child: t.avatarUrl == null ? Text(t.name[0]) : null,
              ),
              title: Text(t.name),
              subtitle: Text(t.subject ?? 'Nauczyciel'),
              onTap: () => _openChat(t),
            );
          },
        ),
      ),
    );
  }
}
