// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
// import 'dart:convert';

// class ChatPage2 extends StatefulWidget {
//   final String currentUserId;
//   final String otherUserId;
//   final String otherUserName;
//   final String matchId; // Ajoutez `matchId`

//   const ChatPage2({
//     super.key,
//     required this.currentUserId,
//     required this.otherUserId,
//     required this.otherUserName,
//     required this.matchId, // Ajoutez `matchId`
//   });

//   @override
//   State<ChatPage2> createState() => _ChatPageState();
// }

// WebSocket? _socket;

// class _ChatPageState extends State<ChatPage2> {
//   TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> _messages = []; // Retirez le mot-clé `final`

//   // final String apiBaseUrl = "http://192.168.1.78:8000";
//   final String apiBaseUrl = "http://192.168.0.24:8000";

//   @override
//   void initState() {
//     super.initState();
//     fetchMessages(
//       widget.matchId,
//     ); // Utilisez `matchId` pour récupérer les messages
//     initWebSocket();
//   }

//   void initWebSocket() async {
//     try {
//       final socket = await WebSocket.connect(
//         'ws://192.168.0.24:8000/ws/chat/${widget.currentUserId}',
//       );

//       setState(() {
//         _socket = socket;
//       });

//       print('WebSocket connecté');

//       _socket!.listen(
//         (data) {
//           print('Message reçu via WebSocket : $data');

//           final message = jsonDecode(data);
//           setState(() {
//             _messages.add({
//               'sender_id': message['sender_id'],
//               'content': message['text'],
//             });
//           });
//         },
//         onDone: () => print('WebSocket fermé'),
//         onError: (e) => print('Erreur WebSocket : $e'),
//       );
//     } catch (e) {
//       print('Erreur de connexion WebSocket : $e');
//     }
//   }

//   Future<void> fetchMessages(String matchId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     try {
//       final response = await http.get(
//         Uri.parse("$apiBaseUrl/api/messages/$matchId"),
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         // final messages = json.decode(response.body);
//         final List<dynamic> messages = json.decode(response.body);
//         setState(() {
//           _messages = messages.cast<Map<String, dynamic>>();
//         });
//         // setState(() {
//         //   _messages = messages; // Assurez-vous que `_messages` est une liste
//         // });
//         print("Messages récupérés : $messages");
//       } else {
//         print("Erreur lors de la récupération des messages : ${response.body}");
//       }
//     } catch (e) {
//       print("Erreur réseau : $e");
//     }
//   }

//   Future<void> _loadMessages() async {
//     try {
//       print("currentUserId: ${widget.currentUserId}");
//       print("otherUserId: ${widget.otherUserId}");
//       print(
//         "URL: $apiBaseUrl/api/messages?user1=${widget.currentUserId}&user2=${widget.otherUserId}",
//       );

//       final response = await http.get(
//         Uri.parse(
//           "$apiBaseUrl/api/messages?user1=${widget.currentUserId}&user2=${widget.otherUserId}",
//         ),
//       );

//       if (response.statusCode == 200) {
//         final List data = json.decode(response.body);
//         setState(() {
//           _messages.clear();
//           _messages.addAll(data.cast<Map<String, dynamic>>());
//         });
//       } else {
//         print("Erreur de chargement des messages : ${response.body}");
//       }
//     } catch (e) {
//       print("Erreur réseau : $e");
//     }
//   }

//   // Future<void> sendMessage(String matchId, String text) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('token');

//   //   if (text.trim().isEmpty) {
//   //     print("Le message est vide, envoi annulé.");
//   //     return;
//   //   }

//   //   if (token == null) {
//   //     print("Erreur : Aucun token trouvé dans SharedPreferences.");
//   //     return;
//   //   }

//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse("$apiBaseUrl/api/messages/send"),
//   //       headers: {
//   //         "Authorization": "Bearer $token",
//   //         "Content-Type": "application/json",
//   //       },
//   //       body: json.encode({
//   //         "match_id": int.parse(
//   //           matchId,
//   //         ), // Assurez-vous que matchId est un entier
//   //         "text": text,
//   //         "current_user_id": widget.currentUserId, // Ajout du currentUserId
//   //       }),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       print("Message envoyé avec succès !");
//   //       _messageController.clear(); // Efface le champ de texte
//   //       fetchMessages(matchId); // Recharge les messages après l'envoi
//   //     } else if (response.statusCode == 403) {
//   //       print("Erreur : Vous ne faites pas partie de ce match.");
//   //     } else {
//   //       print("Erreur lors de l'envoi du message : ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     print("Erreur réseau : $e");
//   //   }
//   // }

//   Future<void> sendMessage(String matchId, String text) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (text.trim().isEmpty) {
//       print("Le message est vide, envoi annulé.");
//       return;
//     }

//     if (token == null) {
//       print("Erreur : Aucun token trouvé dans SharedPreferences.");
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse("$apiBaseUrl/api/messages/send"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: json.encode({
//           "match_id": int.parse(matchId),
//           "text": text,
//           "current_user_id": widget.currentUserId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print("Message envoyé avec succès !");
//         _messageController.clear(); // Pas besoin de fetchMessages ici
//       } else if (response.statusCode == 403) {
//         print("Erreur : Vous ne faites pas partie de ce match.");
//       } else {
//         print("Erreur lors de l'envoi du message : ${response.body}");
//       }
//     } catch (e) {
//       print("Erreur réseau : $e");
//     }
//   }

//   // Future<void> _sendSocketMessage() async {
//   //   final messageText = _messageController.text.trim();
//   //   if (messageText.isEmpty) return;

//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('token');

//   //     final response = await http.post(
//   //       Uri.parse("http://192.168.0.24:8000/api/messages/send"),
//   //       headers: {
//   //         "Authorization": "Bearer $token",
//   //         "Content-Type": "application/json",
//   //       },
//   //       body: json.encode({
//   //         "match_id": int.parse(widget.matchId),
//   //         "text": messageText,
//   //         "current_user_id": widget.currentUserId,
//   //       }),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       print("Message envoyé avec succès !");
//   //       _messageController.clear();
//   //       // Le message sera ajouté automatiquement via WebSocket
//   //     } else {
//   //       print("Erreur lors de l'envoi du message : ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     print("Erreur réseau : $e");
//   //   }
//   // }

//   Future<void> _sendMessage() async {
//     final messageText = _messageController.text.trim();
//     if (messageText.isEmpty) return;

//     final newMessage = {
//       "sender_id": widget.currentUserId,
//       "receiver_id": widget.otherUserId,
//       "content": messageText,
//     };

//     try {
//       print("currentUserId: ${widget.currentUserId}");
//       print("otherUserId: ${widget.otherUserId}");
//       print(
//         "URL: $apiBaseUrl/api/messages?user1=${widget.currentUserId}&user2=${widget.otherUserId}",
//       );

//       final response = await http.post(
//         Uri.parse("$apiBaseUrl/api/messages"),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(newMessage),
//       );

//       if (response.statusCode == 201) {
//         _messageController.clear();
//         _loadMessages();
//       } else {
//         print("Erreur lors de l'envoi : ${response.body}");
//       }
//     } catch (e) {
//       print("Erreur d'envoi : $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat avec ${widget.otherUserName}"),
//         backgroundColor: Colors.pink,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? const Center(child: Text("Aucun message"))
//                 : ListView.builder(
//                     reverse: true,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       final message = _messages[_messages.length - 1 - index];
//                       final isMe =
//                           message['sender_id'].toString() ==
//                           widget.currentUserId;

//                       return Align(
//                         alignment: isMe
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.pinkAccent
//                                 : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             message['text'] ?? message['content'] ?? '',
//                             style: TextStyle(
//                               color: isMe ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           const Divider(height: 1),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Écrire un message...",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.pink),
//                   // onPressed: _sendMessage,
//                   onPressed: () =>
//                       sendMessage(widget.matchId, _messageController.text),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _socket?.close();
//     super.dispose();
//   }
// }

//----------------------------  ---------------------------- ---------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_application_1/pages/conversations_page.dart';

class ChatPage2 extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String matchId;

  const ChatPage2({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.matchId,
  });

  @override
  State<ChatPage2> createState() => _ChatPageState();
}

WebSocket? _socket;

class _ChatPageState extends State<ChatPage2> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  // final String apiBaseUrl = "http://192.168.0.24:8000";
  final String apiBaseUrl = Constants.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    fetchMessages(widget.matchId);
    initWebSocket();
  }

  void handleIncomingMessage(Map<String, dynamic> message) {
    setState(() {
      _messages.add({
        'sender_id': message['sender_id'],
        'text': message['text'] ?? message['content'] ?? '',
      });
    });
  }

  void initWebSocket() async {
    try {
      final socket = await WebSocket.connect(
        'ws://${Constants.liteAppiBaseUrl}/ws/chat/${widget.currentUserId}',
      );

      setState(() {
        _socket = socket;
      });

      print('WebSocket connecté');

      _socket!.listen(
        (data) {
          print('Message reçu via WebSocket : $data');
          final message = jsonDecode(data);

          // handleIncomingMessage(message); // Mise à jour UI ici
          // ✅ Vérification du match_id avant mise à jour UI
          if (message["match_id"].toString() == widget.matchId.toString()) {
            handleIncomingMessage(message); // mise à jour de l'UI
          } else {
            print("⛔ Message ignoré : ne correspond pas au match actif.");
          }

          // Transmettez le message à la page ConversationsPage
          // Navigator.pop(context, message);
        },
        onDone: () => print('WebSocket fermé'),
        onError: (e) => print('Erreur WebSocket : $e'),
      );
    } catch (e) {
      print('Erreur de connexion WebSocket : $e');
    }
  }

  Future<void> fetchMessages(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/messages/$matchId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = json.decode(response.body);
        setState(() {
          _messages = messages.cast<Map<String, dynamic>>();
        });
        print("Messages récupérés : $messages");
      } else {
        print("Erreur lors de la récupération des messages : ${response.body}");
      }
    } catch (e) {
      print("Erreur réseau : $e");
    }
  }

  Future<void> sendMessage(String matchId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (text.trim().isEmpty) {
      print("Le message est vide, envoi annulé.");
      return;
    }

    if (token == null) {
      print("Erreur : Aucun token trouvé dans SharedPreferences.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/api/messages/send"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "match_id": int.parse(matchId),
          "text": text,
          "current_user_id": widget.currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        print("Message envoyé avec succès !");
        fetchMessages(widget.matchId);
        _messageController.clear();
        // Pas besoin d'appeler fetchMessages ici : l'ajout sera fait via WebSocket
      } else if (response.statusCode == 403) {
        print("Erreur : Vous ne faites pas partie de ce match.");
      } else {
        print("Erreur lors de l'envoi du message : ${response.body}");
      }
    } catch (e) {
      print("Erreur réseau : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat avec ${widget.otherUserName}"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("Aucun message"))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      final isMe =
                          message['sender_id'].toString() ==
                          widget.currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.pinkAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Écrire un message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pink),
                  onPressed: () =>
                      sendMessage(widget.matchId, _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
