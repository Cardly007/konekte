import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final types.User _user = const types.User(id: 'user-id-1');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    const otherUser = types.User(id: 'user-id-2');

    setState(() {
      _messages = [
        types.TextMessage(
          author: otherUser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Hey 👋 Comment tu vas ?',
        ),
        types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Plutôt bien merci 😄 Et toi ?',
        ),
      ];
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }

  Future<void> _handleAttachmentPressed() async {
    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final mime = file.extension;

      if (mime == 'jpg' || mime == 'png') {
        final imageMessage = types.ImageMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          name: file.name,
          size: file.size,
          uri: file.path!,
        );
        setState(() => _messages.insert(0, imageMessage));
      } else if (mime == 'mp4') {
        final videoMessage = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          name: file.name,
          size: file.size,
          uri: file.path!,
          mimeType: 'video/mp4',
        );
        setState(() => _messages.insert(0, videoMessage));
      } else if (mime == 'mp3' || mime == 'wav') {
        final audioMessage = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          name: file.name,
          size: file.size,
          uri: file.path!,
          mimeType: 'audio/mpeg',
        );
        setState(() => _messages.insert(0, audioMessage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFff9a9e), Color(0xFFfad0c4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _user,
            onAttachmentPressed: _handleAttachmentPressed,
            theme: const DefaultChatTheme(
              backgroundColor: Colors.transparent,
              primaryColor: Colors.pinkAccent,
              secondaryColor: Colors.orangeAccent,
              inputBackgroundColor: Colors.white,
              inputTextColor: Colors.black,
              inputTextStyle: TextStyle(fontSize: 15),
              inputBorderRadius: BorderRadius.all(Radius.circular(30)),
              inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sendButtonIcon: Icon(Icons.send, color: Colors.pinkAccent),
              messageBorderRadius: 20,
              messageInsetsHorizontal: 12,
              messageInsetsVertical: 8,
              userAvatarNameColors: [Colors.pink, Colors.orange],
              userAvatarTextStyle: TextStyle(fontWeight: FontWeight.bold),
              attachmentButtonIcon: Icon(Icons.attach_file, color: Colors.pink),
              attachmentButtonMargin: EdgeInsets.all(8),
              dateDividerMargin: EdgeInsets.symmetric(vertical: 10),
              dateDividerTextStyle: TextStyle(color: Colors.white70),
              deliveredIcon: Icon(Icons.done, size: 16, color: Colors.white70),
              documentIcon: Icon(Icons.insert_drive_file, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
