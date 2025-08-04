import 'package:flutter/material.dart';

class MatchDialog extends StatelessWidget {
  final String userName;
  final String userImage;
  final String otherUserName;
  final String otherUserImage;
  final VoidCallback onChat;

  const MatchDialog({
    super.key,
    required this.userName,
    required this.userImage,
    required this.otherUserName,
    required this.otherUserImage,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "💖 C’est un match !",
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userImage),
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(otherUserImage),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "$userName et $otherUserName se sont likés !",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onChat,
              child: const Text("Discuter maintenant"),
            ),
          ],
        ),
      ),
    );
  }
}
