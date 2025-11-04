import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widget/KonekteBottomBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const String apiBaseUrl = Constants.apiBaseUrl;

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> conversations = [];
  bool isLoading = true;
  WebSocket? _socket;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchConversations();
    initWebSocket();
  }

  void initWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('current_user_id');
    if (currentUserId == null) return;

    try {
      _socket = await WebSocket.connect(
        'ws://${Constants.liteAppiBaseUrl}/ws/chat/$currentUserId',
      );
      _socket!.listen(
        (data) {
          final message = jsonDecode(data);
          updateConversation(message);
        },
        onError: (e) => print('Erreur WebSocket : $e'),
        onDone: () => print('WebSocket fermé'),
      );
    } catch (e) {
      print('Erreur de connexion WebSocket : $e');
    }
  }

  Future<void> fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("$apiBaseUrl/api/conversations"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        conversations = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print("Erreur API : ${response.body}");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/me"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        prefs.setString('current_user_id', userData["id"].toString());
      }
    } catch (e) {
      print("Erreur réseau : $e");
    }
  }

  void updateConversation(Map<String, dynamic> message) {
    setState(() {
      final index = conversations.indexWhere((conv) => conv['match_id'].toString() == message['match_id'].toString());
      if (index != -1) {
        final updatedConversation = conversations.removeAt(index);
        updatedConversation['last_message'] = message['text'] ?? '';
        conversations.insert(0, updatedConversation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversations"),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final user = conv["user"];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user["image"] ?? ""),
                    backgroundColor: Colors.grey[300],
                  ),
                  title: Text(user["nom"] ?? "Utilisateur"),
                  subtitle: Text(conv["last_message"] ?? "Aucun message"),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final currentUserId = prefs.getString('current_user_id');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserId: currentUserId.toString(),
                          otherUserId: user["id"].toString(),
                          otherUserName: user["nom"] ?? "Chat",
                          matchId: conv["match_id"].toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }
}
