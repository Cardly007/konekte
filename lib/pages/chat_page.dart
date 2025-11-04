import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../main.dart'; // Pour MainLayout

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String matchId;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.matchId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  late types.User _currentUser;
  late types.User _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = types.User(id: widget.currentUserId);
    _otherUser = types.User(id: widget.otherUserId, firstName: widget.otherUserName);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/messages/${widget.matchId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final messagesData = json.decode(response.body) as List;
      final messages = messagesData.map((data) {
        return types.TextMessage(
          author: data['sender_id'].toString() == widget.currentUserId ? _currentUser : _otherUser,
          id: data['id'].toString(),
          text: data['text'],
          createdAt: DateTime.parse(data['timestamp']).millisecondsSinceEpoch,
        );
      }).toList();

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/messages/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'match_id': int.parse(widget.matchId),
        'text': message.text,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Colors.pink,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _currentUser,
            theme: const DefaultChatTheme(
              backgroundColor: Colors.transparent,
              primaryColor: Colors.pinkAccent,
              secondaryColor: Color(0xFFF5F5F5),
            ),
          ),
    );
  }
}
