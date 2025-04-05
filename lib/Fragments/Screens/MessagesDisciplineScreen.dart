import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BRS/ForumMessage/ForumMessage.dart';
import '../../ResourceServer/Users/UserCrop.dart';
import '../../Token/MRSUAPI.dart';
import '../../Token/SharedPrefManager.dart';
import '../../Users/User.dart';

class MessagesDisciplineScreen extends StatefulWidget {
  final int idDiscipline;
  final String title;

  const MessagesDisciplineScreen({
    super.key,
    required this.idDiscipline,
    required this.title,
  });

  @override
  _MessagesDisciplineScreenState createState() => _MessagesDisciplineScreenState();
}

class _MessagesDisciplineScreenState extends State<MessagesDisciplineScreen> {
  late Future<List<ForumMessage>> _futureMessages;
  late MrsuApi dataApi;
  late String _authHeader;
  final SharedPrefManager _manager = SharedPrefManager();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  User? _currentUser; // Текущий пользователь

  @override
  void initState() {
    super.initState();
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final accessToken = _manager.getAccessToken() ?? '';
    _authHeader = 'Bearer $accessToken';
    _loadCurrentUser();
    _loadMessages();
  }

  void _loadCurrentUser() async {
    try {
      final user = await dataApi.getUser(_authHeader);
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      debugPrint('Ошибка получения текущего пользователя: $e');
    }
  }

  void _loadMessages() {
    setState(() {
      _futureMessages = dataApi.getForumMessage(_authHeader, widget.idDiscipline);
    });
  }

  Future<void> _refreshMessages() async {
    _loadMessages();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    final userCrop = UserCrop(
      id: _currentUser!.id,
      name: _currentUser!.userName,
      fio: _currentUser!.fio,
      photo: _currentUser!.photo,
    );

    final message = ForumMessage(
      id: 0,
      user: userCrop,
      isTeacher: false,
      createDate: DateTime.now().toIso8601String(),
      text: text,
    );

    try {
      await dataApi.postForumMessage(_authHeader, widget.idDiscipline, message);
      _messageController.clear();
      _refreshMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка отправки сообщения')),
      );
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    try {
      await dataApi.deleteMessage(_authHeader, messageId);
      _refreshMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка удаления сообщения')),
      );
    }
  }

  Widget _buildMessageCard(ForumMessage message) {
    DateTime date;
    try {
      date = DateTime.parse(message.createDate);
    } catch (e) {
      date = DateTime.now();
    }
    // Форматируем только время
    final formattedTime = DateFormat('HH:mm').format(date);
    bool isMyMessage = _currentUser != null && message.user.id == _currentUser!.id;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMyMessage ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMyMessage ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.user.fio,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurple),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 11, color: Colors.deepPurple.shade700),
                ),
                if (isMyMessage)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.deepPurple),
                    onPressed: () => _deleteMessage(message.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedMessages(List<ForumMessage> messages) {
    // Сортировка сообщений по возрастанию (старые сверху, новые снизу)
    messages.sort((a, b) => DateTime.parse(a.createDate).compareTo(DateTime.parse(b.createDate)));

    List<Widget> widgets = [];
    DateTime? lastDate;

    for (var message in messages) {
      final messageDate = DateTime.parse(message.createDate);
      // Извлекаем только дату (год, месяц, день)
      final messageDateOnly = DateTime(messageDate.year, messageDate.month, messageDate.day);

      if (lastDate == null || messageDateOnly.difference(lastDate).inDays != 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                DateFormat('dd.MM.yyyy').format(messageDate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ),
          ),
        );
        lastDate = messageDateOnly;
      }
      widgets.add(_buildMessageCard(message));
    }
    return widgets;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Добавляем небольшой отступ, чтобы гарантированно показать последнее сообщение
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 500,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ForumMessage>>(
              future: _futureMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Ошибка загрузки сообщений'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Сообщений нет'));
                }

                final groupedWidgets = _buildGroupedMessages(snapshot.data!);
                // После завершения построения виджетов, прокручиваем вниз
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: groupedWidgets,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Напишите сообщение...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.deepPurple.shade400,
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
