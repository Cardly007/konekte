import 'dart:convert';
import 'dart:io'; // Ajoute ceci en haut
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widget/KonekteBottomBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/chat_page_test.dart';

import 'package:http/http.dart' as http;
// import '../../test/tes_chat.dart';

// const String apiBaseUrl = "192.168.1.78:8000";
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
    initWebSocket(); // Initialise le WebSocket
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
          updateConversation(
            message,
          ); // Met à jour la conversation en temps réel
        },
        onError: (e) {
          print('Erreur WebSocket : $e');
        },
        onDone: () {
          print('WebSocket fermé');
        },
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
      final data = json.decode(response.body);
      setState(() {
        conversations = data; // Assurez-vous que `data` contient `match_id`
        isLoading = false;
      });
    } else {
      print("Erreur API : ${response.body}");
      setState(() {
        isLoading = false;
      });
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
        final currentUserId =
            userData["id"]; // Assurez-vous que l'ID est dans la réponse
        prefs.setString(
          'current_user_id',
          currentUserId.toString(),
        ); // Stocker l'ID localement
        print("Current User ID: $currentUserId");
      } else {
        print(
          "Erreur lors de la récupération de l'utilisateur : ${response.body}",
        );
      }
    } catch (e) {
      print("Erreur réseau : $e");
    }
  }

  void updateConversation(Map<String, dynamic> message) {
    setState(() {
      final index = conversations.indexWhere(
        (conv) => conv['match_id'].toString() == message['match_id'].toString(),
      );
      if (index != -1) {
        conversations[index]['last_message'] =
            message['text'] ?? message['content'] ?? '';
        conversations[index]['last_sender_id'] = message['sender_id'];
        // Incrémente le compteur si ce n'est pas l'utilisateur courant
        final prefs = SharedPreferences.getInstance();
        prefs.then((p) {
          final currentUserId = p.getString('current_user_id');
          if (message['sender_id'].toString() != currentUserId) {
            conversations[index]['unread_count'] =
                (conversations[index]['unread_count'] ?? 0) + 1;
          }
        });
        final updatedConversation = conversations.removeAt(index);
        conversations.insert(0, updatedConversation);
      }
    });
  }

  Future<void> markConversationAsRead(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await http.post(
      Uri.parse("$apiBaseUrl/api/conversations/$matchId/read"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversations"),
        backgroundColor: Colors.pink,
      ),
      body: ListView.separated(
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
            title: Text(
              user["nom"] ?? "Utilisateur",
              style: TextStyle(
                fontWeight: (conv["unread_count"] ?? 0) > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              conv["last_message"] ?? "Aucun message",
              style: TextStyle(
                fontWeight: (conv["unread_count"] ?? 0) > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            trailing: (conv["unread_count"] ?? 0) > 0
                ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.pink,
                    child: Text(
                      conv["unread_count"].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : null,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final currentUserId = prefs.getString('current_user_id');

              await markConversationAsRead(conv["match_id"].toString());

              final message = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage2(
                    currentUserId: currentUserId.toString(),
                    otherUserId: user["id"].toString(),
                    otherUserName: user["nom"] ?? "Chat",
                    matchId: conv["match_id"].toString(),
                  ),
                ),
              );

              // Si un message est retourné, on met à jour la conversation
              if (message != null) {
                updateConversation(message);
              }
            },
          );
        },
      ),
      // bottomNavigationBar: KonekteBottomBar(currentIndex: 4, context: context),
    );
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }
}
